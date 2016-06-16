import unittest
from unittest.mock import patch
from utils import osx

class TestOsx(unittest.TestCase):
    @patch('utils.cmd.execute')
    def test_write(self, execute):
        osx.write('-g foo')
        execute.assert_called_with(desc='defaults write -g foo',
                                   args='defaults write -g foo')

    @patch('utils.cmd.output')
    def test_get_user_shell(self, output):
        output.return_value = '''\
name: foo
password: ********
uid: 123
gid: 456
dir: /Users/foo
shell: /usr/local/bin/fish
gecos: Foo Bar
'''
        self.assertEqual(osx.get_user_shell(), 'fish')

    @patch('utils.cmd.output')
    def test_tm_local_backup_disabled(self, output):
        output.return_value = '0\n'
        self.assertTrue(osx.tm_local_backup_disabled())

        output.return_value = '1\n'
        self.assertFalse(osx.tm_local_backup_disabled())

        output.return_value = ''
        self.assertFalse(osx.tm_local_backup_disabled())
