import unittest
from unittest.mock import Mock, patch, ANY, call
from utils import cmd

class TestCmd(unittest.TestCase):
    def test_run(self):
        # true always sets the exit status to 0
        self.assertTrue(cmd.run('true'))
        # false always sets the exit status to 1
        self.assertFalse(cmd.run('false'))

    @patch('subprocess.call')
    def test_run_with_string(self, scall):
        cmd.run('foo')
        scall.assert_called_with(args=['foo'], stdout=ANY, stderr=ANY)

        cmd.run('foo bar')
        scall.assert_called_with(args=['foo', 'bar'], stdout=ANY, stderr=ANY)

    @patch('subprocess.call')
    def test_run_with_list(self, scall):
        cmd.run(['foo', 'bar'])
        scall.assert_called_with(args=['foo', 'bar'], stdout=ANY, stderr=ANY)

    def test_output(self):
        output = cmd.output('echo foobar')
        self.assertEqual('foobar', output)

    def test_output_error(self):
        output = cmd.output('false')
        self.assertEqual('', output)

    @patch('utils.cmd.run')
    @patch('time.sleep')
    def test_wait(self, sleep, run):
        run.side_effect = [False, False, True]

        cmd.wait('foo')

        run.assert_has_calls([call('foo'), call('foo'), call('foo')])
        self.assertEqual(run.call_count, 3)

        sleep.assert_has_calls([call(1), call(1)])
        self.assertEqual(sleep.call_count, 2)

    @patch('utils.cmd.run')
    def test_execute(self, run):
        cmd.execute(desc='foo', args='bar')
        run.assert_called_with('bar')

    @patch('utils.cmd.run')
    def test_execute_with_skip_if(self, run):
        skipfn = Mock(return_value=True)
        cmd.execute(desc='foo', args='bar', skip_if=skipfn)

        skipfn.assert_called_with()
        run.assert_not_called()

    @patch('utils.cmd.run')
    def test_execute_with_wait_for(self, _):
        waitfn = Mock(return_value=True)
        cmd.execute(desc='foo', args='bar', wait_for=waitfn)

        waitfn.assert_called_with()

    @patch('utils.cmd.run')
    def test_execute_error_with_wait_for(self, run):
        run.return_value = False

        waitfn = Mock(return_value=True)
        cmd.execute(desc='foo', args='bar', wait_for=waitfn)

        waitfn.assert_not_called()
