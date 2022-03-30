#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from logzero import logger
import yaml


class Struct(object):
    def __init__(self, adict):
        """
        Convert a dictionary to a class
        params:
            adict: Dictionary
        """
        self.__dict__.update(adict)
        for k, v in adict.items():
            if isinstance(v, dict):
                self.__dict__[k] = Struct(v)


class LoadConfig(object):
    def __init__(self):
        """
        Opens the config and sets dict as self.config_dict
        """
        try:

            with open("config/main.yml", "r") as config:
                self.config_dict = yaml.load(config, Loader=yaml.FullLoader)

        except (FileNotFoundError, Exception) as e:

            logger.error(f"{e.__class__.__name__}: Could not load configuration.  {e}")
            raise FileNotFoundError

    def get(self):
        """
        Returns the class
        """
        return Struct(self.config_dict)
