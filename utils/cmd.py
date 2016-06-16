from __future__ import print_function
import os
import subprocess
import sys
import time

def _prepare_args(command):
    if isinstance(command, str):
        return command.split()
    else:
        return command

def write(*args, **kwargs):
    """
    Prints to stdout and immediately flushs the buffer.
    """
    print(*args, **kwargs)
    sys.stdout.flush()

def run(args):
    """
    Executes a command. Returns True if it exits with 0.
    """
    with open(os.devnull, 'w') as devnull:
        status = subprocess.call(args=_prepare_args(args),
                                 stdout=devnull,
                                 stderr=devnull)
        return status == 0

def output(args):
    """
    Executes a command and returns its output.
    """
    try:
        out = subprocess.check_output(args=_prepare_args(args),
                                      stderr=subprocess.STDOUT,
                                      universal_newlines=True)
        return out.strip()
    except subprocess.CalledProcessError:
        return ''

def wait(args):
    """
    Wait for a command to return success.
    """
    while not run(args):
        time.sleep(1)

def execute(desc, args, skip_if=None, wait_for=None):
    """
    Executes a command and prints a nice line about its execution status.
    """
    write('%s... ' % desc, end='')

    if skip_if and skip_if():
        write('skipped')
    elif run(args):
        if wait_for:
            write('(waiting) ', end='')
            wait_for()
        write('success')
    else:
        write('error')
