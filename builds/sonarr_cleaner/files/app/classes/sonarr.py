#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from logzero import logger
from .empty import Code200
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import requests


class SonarrAPI(object):

    """
    Class for interacting with Sonarr API
    """

    def __init__(self, config: dict):
        self.config = config
        self.base_url = f"{config.sonarr_config.base_url}/api"
        self.headers = {
            "X-Api-Key": config.sonarr_config.api_key,
            "Accept-Encoding": "gzip, deflate",
            "cache-control": "no-cache",
            "Accept": "application/json; charset=utf-8",
            "Connection": "keepalive",
            "User-Agent": "python3-requests/app.py",
        }
        self.session = self.setup_session(self.base_url)

    def setup_session(self, retries=5, backoff_factor=0.3, status_forcelist=(500, 502, 504), session=None):

        """
        Creates a session object with retries built in
        """
        session = session or requests.Session()
        retry = Retry(
            total=retries,
            read=retries,
            connect=retries,
            backoff_factor=backoff_factor,
            status_forcelist=status_forcelist,
        )
        adapter = HTTPAdapter(max_retries=retry)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        return session

    def get_sonarr_shows(self) -> dict:
        """
        Gets all the sonar series data, not episodes or lower though
        """
        show_data = []
        shows = self.session.get(f"{self.base_url}/series", headers=self.headers).json()

        for index, show in enumerate(shows):
            show_data.append(
                dict(
                    series_id=int(show["id"]),
                    name=show["title"],
                    episodes=self.get_sonarr_series_episodes(show["id"]),
                    position=index,
                )
            )
        return show_data

    def get_sonarr_series_episodes(self, seriesid: int) -> dict:
        """
        Returns a list of episodes for a series in Sonarr
        """
        episode_data = []
        url = f"{self.base_url}/episode/"
        params = {"seriesId": seriesid}
        episodes = self.session.get(url, headers=self.headers, params=params).json()

        for episode in episodes:
            episode_data.append(
                dict(
                    episode_id=int(episode["id"]),
                    season=int(episode["seasonNumber"]),
                    episode=int(episode["episodeNumber"]),
                    monitored=episode["monitored"],
                    has_file=episode["hasFile"],
                    episode_file_id=episode["episodeFileId"] if "episodeFile" in episode else None,
                )
            )
        return episode_data

    def unmonitor_sonarr_episode(self, episodeid: int) -> int:
        """
        Reconfigured an episode to not be monitored
        Needed prior to deletion to prevent a new download
        """
        data = {"monitored": "false", "id": episodeid}
        url = f"{self.base_url}/episode/"

        if self.config.devel is not True:
            result = self.session.put(url, headers=self.headers, json=data)

        else:
            logger.debug("Developer mode on, skipping...")
            logger.debug(f"Would have unmonitored: {url}, episode: {episodeid}")
            result = Code200()  # testing only

        return result

    def delete_sonarr_episodefile(self, episodefileid: int) -> int:

        url = f"{self.base_url}/episodefile/{episodefileid}"

        if self.config.devel is not True:
            result = self.session.delete(url, headers=self.headers)

        else:
            logger.debug("Developer mode on, skipping...")
            logger.debug(f"Would have deleted: {url}")
            result = Code200()  # testing only

        return result
