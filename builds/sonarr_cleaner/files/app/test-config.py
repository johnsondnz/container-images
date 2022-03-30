#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from classes.config import LoadConfig
from logzero import logger

config = LoadConfig().get()


logger.debug("---------------------------------------------------------------")
logger.debug(config)
logger.debug("---------------------------------------------------------------")
logger.debug(config.devel)
logger.debug("---------------------------------------------------------------")
logger.debug(config.protected)
logger.debug("---------------------------------------------------------------")
logger.debug(config.plex_config)
logger.debug("---------------------------------------------------------------")
logger.debug(dir(config))
logger.debug("---------------------------------------------------------------")
logger.debug(dir(config.plex_config))
logger.debug("---------------------------------------------------------------")
logger.debug(config.plex_config.token)
logger.debug("---------------------------------------------------------------")
logger.debug(config.sonarr_config.api_key)
logger.debug("---------------------------------------------------------------")
