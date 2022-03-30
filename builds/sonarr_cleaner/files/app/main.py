#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from classes.config import LoadConfig
from classes.sonarr import SonarrAPI
from classes.exceptions import APIError
from plexapi.server import PlexServer
from classes.logger import Logger
import requests
import re


def dict_clean(plex_data, config):
    """
    Removes empty lists and parent key from a dict
    """
    logger = Logger(config)
    popping = []
    for series, series_data in plex_data.items():
        if len(series_data["episodes"]) == 0:
            if config.devel is True:
                logger.debug(f"dict_clean: Removing empty '{series}'")
            popping.append(series)

    for x in popping:
        plex_data.pop(x, None)

    return plex_data


def main():
    # Instantiate the common things
    config = LoadConfig().get()
    logger = Logger(config)

    if config.devel:
        logger.debug("==> Developer mode is on")

    try:
        logger.info("==> Querying Plex Media Server...")
        plex = PlexServer(config.plex_config.base_url, config.plex_config.token)
    except (requests.exceptions.ConnectTimeout, Exception) as e:
        logger.error(f"{e.__class__.__name__}: {e}")
    protected_shows = config.protected

    tv_shows = plex.library.section(config.plex_config.library_name)  # plex database
    plex_data = {}

    for show in tv_shows.all():

        plex_data[show.title] = dict(episodes=[])

        # All shows a left intact in Sonarr, only episodes are managed
        # Only continue is the show is unprotected
        if show.title not in protected_shows:

            # interate over all the episodes in the current show
            for episodes in show.episodes():
                for episode in episodes:

                    # If the episode has been watched, make it for deletion
                    episode_watched_state = "watched" if episode.isWatched is True else "not watched"
                    if episode.isWatched:

                        logger.warn(
                            f"Series: '{show.title}' {episode.seasonEpisode} is {episode_watched_state}, scheduling for deletion"
                        )

                        # selectors for extracting season and episode data
                        regex = r"^s(\d+)e(\d+)"
                        season_episode = episode.seasonEpisode

                        # season number
                        season_number = re.match(regex, season_episode).group(1)
                        season_number = re.sub(r"^0", "", season_number)

                        # episode number
                        episode_number = re.match(regex, season_episode).group(2)
                        episode_number = re.sub(r"^0", "", episode_number)

                        plex_data[show.title]["episodes"].append(
                            {"season": int(season_number), "episode": int(episode_number)}
                        )
        else:
            logger.info(f"Series: '{show.title}' is protected")

    plex_data = dict_clean(plex_data, config)
    # print(json.dumps(plex_data, indent=4))

    if plex_data:

        deletions = False
        resync = False

        print("\n" * 1)
        logger.info("==> Querying Sonarr...")
        sonarr_sdk = SonarrAPI(config)
        sonarr_shows = sonarr_sdk.get_sonarr_shows
        # print(json.dumps(sonarr_shows, indent=4))

        for series, series_data in plex_data.items():
            # Locate the position of the show from sonarr_data
            position = next((index for (index, data) in enumerate(sonarr_shows) if data["name"] == series), None)
            if config.devel is True:
                logger.debug(f"Series: '{series}' found at position {position} of sonarr_shows")

            for episode_data in series_data["episodes"]:
                try:
                    season_number, episode_number = (episode_data["season"], episode_data["episode"])
                    # Locate the episode to be deleted in the sonar_show[position]["episodes"] list
                    episode_position = next(
                        (
                            index
                            for (index, data) in enumerate(sonarr_shows[position]["episodes"])
                            if season_number == data["season"] and episode_number == data["episode"]
                        )
                    )
                    if config.devel is True:
                        logger.debug(
                            f"Episode: 's{season_number}e{episode_number}' found at position {episode_position} of sonarr_shows"
                        )

                    # Check for existing files and episode_id
                    sonarr_actionable = sonarr_shows[position]["episodes"][episode_position]
                    if sonarr_actionable["has_file"] is True and sonarr_actionable["episode_file_id"] is not None:
                        season, episode = (sonarr_actionable["season"], sonarr_actionable["episode"])

                        logger.debug(
                            f"Files found for '{series}' season: {episode_data['season']}, episode: {episode_data['episode']}"
                        )
                        logger.warn(f"Unmonitoring '{series}' season: {season}, episode: {episode}")

                        # Unmonitor the episode in Sonarr
                        if config.devel is False:
                            unmonitor = sonarr_sdk.unmonitor_sonarr_episode(sonarr_actionable["episode_id"])
                            if unmonitor.status_code == 202:
                                logger.warn(f"Episode unmonitored, starting deletion process...")
                                # Delete the episode file(s) using Sonarr API
                                delete = sonarr_sdk.delete_sonarr_episodefile(sonarr_actionable["episode_file_id"])
                            else:
                                raise APIError(
                                    f"==> Unmonitoring failed with status_code: {unmonitor.status_code}, exiting..."
                                )
                        else:
                            delete = type("delete", (object,), {"status_code": 204})
                            logger.debug("Not deleting or unmonitoring, debug mode active.")

                        if delete.status_code == 200 and config.devel is False:
                            logger.warn(f"Delete completed successfully")
                            deletions = True if deletions is False else deletions
                        if delete.status_code != 200:
                            raise APIError(f"==> Deletion failed with status_code: {delete.status_code}, exiting...")

                except Exception as e:
                    logger.error(
                        f"No episodefile match found in Sonarr, desync detected between Plex and Sonarr, resync tiggered"
                    )
                    resync = True if deletions is False else deletions

        if deletions:
            logger.info("==> Deletions have been carried out, Plex will be notified")
            tv_shows.update()
            plex.library.emptyTrash()

        if resync:
            logger.info("==> Plex resync triggered")
            tv_shows.update()

    logger.info(f"==> Script completed, exiting.")
    exit(0)


if __name__ == "__main__":
    main()
