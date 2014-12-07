# helpers.py
# ----------
# This file holds little helper functions, so they don't clutter up the main 
# files. Import them if you need them!

from datetime import datetime
import os
import yaml
import logging

def get_date_from_json(date_string):
    try:
        return datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S.%fZ")
    except ValueError:
        return None

# All the settings for the app are stored in the settings file. This is a good idea
# because it gives us one place where we can make all necessary changes. 
# This helper function reads the settings file.
def get_settings():
    settings_filename = os.path.join(os.path.dirname(__file__), 'settings.yaml')
    with open(settings_filename) as settingsFile:
        settings = yaml.load(settingsFile.read())
    return settings

# The log is to keep track of what has been happening on the server.
# We have been having trouble with the server crashing mysteriously, 
# so we want to write down every time something happens on the server.
def set_up_log():
    settings = get_settings()
    if not os.path.isfile(settings['log_file']):
        open(settings['log_file'], 'a').close()
    logging.basicConfig(
        filename=settings['log_file'],
        level=getattr(logging, settings['log_level']),
        format='%(levelname)8s %(asctime)s %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p'
    )
