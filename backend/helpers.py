# helpers.py
# ----------
# This file holds little helper functions, so they don't clutter up the main 
# files. Import them if you need them!

from datetime import datetime

def get_date_from_json(date_string):
    try:
        return datetime.strptime(date_string, "%Y-%m-%dT%H:%M:%S.%fZ")
    except ValueError:
        return None
