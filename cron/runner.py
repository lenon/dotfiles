#!/usr/bin/env python3
# This is a script runner used to make sure that a script is executed at least
# once a day or as soon the computer is turned on. I wrote this because of a
# limitation of cron and launchd: they will never execute a task if the computer
# is always off in the task execution time.
from datetime import datetime
from datetime import timedelta
import glob
import os
import subprocess

class Task():
    def __init__(self, file, log):
        self.file = file
        self.log = log

    def run(self):
        if self._should_run():
            with open(self.log, 'a') as log:
                subprocess.call(self.file, stdout=log, stderr=log)

    def _should_run(self):
        modified_at = self._modified_at()
        if modified_at is None:
            return True
        next_run = modified_at + timedelta(days=1)
        return datetime.now() > next_run

    def _modified_at(self):
        if os.path.isfile(self.log):
            mtime = os.path.getmtime(self.log)
            return datetime.fromtimestamp(mtime)

class Runner():
    def __init__(self, root):
        self.root = root
        self.logdir = os.path.join(self.root, 'log')

    def run(self):
        for file in glob.iglob(os.path.join(self.root, '*')):
            if os.path.isfile(file):
                basename = os.path.basename(file)
                log = os.path.join(self.logdir, basename + '.log')
                Task(file=file, log=log).run()

if __name__ == '__main__':
    root = os.path.dirname(os.path.abspath(__file__))
    Runner(root=os.path.join(root, 'daily')).run()
