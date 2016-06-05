#!/usr/bin/env python3
from datetime import datetime, timedelta
import os
from os.path import join
from pathlib import Path
import unittest
from unittest.mock import ANY, patch, call
import tempfile
import time
from runner import Runner

def mkdir(dirpath):
    os.makedirs(dirpath, exist_ok=True)

def touch(file):
    Path(file).touch()

def change_utime(file, utime):
    os.utime(file, times=(utime, utime))

def time_ago(**kwargs):
    fulltime = (datetime.now() - timedelta(**kwargs)).timetuple()
    return time.mktime(fulltime)

class TestRunner(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        # create a log dir inside the root dir
        # the script breaks if this directory does not exist
        mkdir(join(self.tmpdir.name, 'log'))

        self.script1 = join(self.tmpdir.name, 'script1')
        self.script1_log = join(self.tmpdir.name, 'log', 'script1.log')
        self.script2 = join(self.tmpdir.name, 'script2')
        self.script2_log = join(self.tmpdir.name, 'log', 'script2.log')

        touch(self.script1)
        touch(self.script2)

    def tearDown(self):
        self.tmpdir.cleanup()

    @patch('subprocess.call')
    def test_jobs_never_executed(self, subcall):
        Runner(root=self.tmpdir.name).run()

        subcall.assert_has_calls([
            call(self.script1, stdout=ANY, stderr=ANY),
            call(self.script2, stdout=ANY, stderr=ANY)
        ])

        self.assertTrue(os.path.isfile(self.script1_log))
        self.assertTrue(os.path.isfile(self.script2_log))

    @patch('subprocess.call')
    def test_jobs_executed_within_period(self, subcall):
        # last execution time is controlled by the log file
        # so touching the log file changes its utime to current time and
        # makes Runner not execute it
        touch(self.script1_log)
        change_utime(self.script1_log, time_ago(hours=1))

        Runner(root=self.tmpdir.name).run()

        subcall.assert_called_once_with(self.script2, stdout=ANY, stderr=ANY)

    @patch('subprocess.call')
    def test_jobs_not_executed_within_period(self, subcall):
        touch(self.script1_log)
        touch(self.script2_log)

        change_utime(self.script1_log, time_ago(days=2))
        change_utime(self.script2_log, time_ago(hours=1))

        Runner(root=self.tmpdir.name).run()

        subcall.assert_called_once_with(self.script1, stdout=ANY, stderr=ANY)

if __name__ == '__main__':
    unittest.main()
