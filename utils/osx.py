import os
from utils import cmd

def write(args):
    """
    Writes an OS X setting using the 'defaults' command.
    """
    args = 'defaults write ' + args
    cmd.execute(desc=args, args=args)

def get_user_shell():
    """
    Returns the current user shell.
    """
    login = os.getlogin()
    output = cmd.output(['dscacheutil', '-q', 'user', '-a', 'name', login])

    for line in output.splitlines():
        if line.startswith('shell:'):
            parts = line.strip().split()
            path_to_shell = parts[1]
            shell_name = path_to_shell.split('/')[-1]
            return shell_name

def tm_local_backup_disabled():
    """
    Returns True if local time machine backups are disabled.
    """
    tmplist = '/Library/Preferences/com.apple.TimeMachine.plist'
    output = cmd.output('defaults read %s MobileBackups' % tmplist)
    return output.strip() == '0'
