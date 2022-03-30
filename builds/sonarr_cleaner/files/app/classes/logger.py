#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from logzero import logger

class Logger(object):

    def __init__(self, config):

        """
        Custom class for logging and when to log
        """

        self.config = config
    
    def debug(self, msg):

        """
        Log debug messages only if self.config.devel == True
        """

        if self.config.devel is True:
            logger.debug(msg)
    
    def error(self, msg):

        """
        Error logger
        """

        logger.error(msg)
    
    def warn(self, msg):
    
        """
        Warning logger
        """

        logger.warn(msg)
    
    def info(self, msg):
    
        """
        Info logger
        """

        logger.info(msg)
