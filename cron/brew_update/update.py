#!/usr/bin/env python
from datetime import datetime, timedelta
import os
import pickle
import subprocess
import sys

HOME = os.path.expanduser('~')
TIMESTAMP_FILE = os.path.join(HOME, 'dotfiles/tmp/brew_update_timestamp')

def last_updated():
    if os.path.isfile(TIMESTAMP_FILE):
        return pickle.load(open(TIMESTAMP_FILE, 'rb'))

def update_timestamp():
    pickle.dump(datetime.utcnow(), open(TIMESTAMP_FILE, 'wb'))

def brew_update():
    devnull = open(os.devnull, 'w')
    subprocess.call(['/usr/local/bin/brew', 'update'], stdout=devnull, stderr=devnull)

def updated_1_day_ago():
    return datetime.utcnow() > last_updated() + timedelta(days=1)

if not last_updated() or updated_1_day_ago():
    brew_update()
    update_timestamp()
