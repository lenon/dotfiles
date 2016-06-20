import os
import unittest
import plistlib
import tempfile
import subprocess
from utils import plist

class TestPlist(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.plist_bin = os.path.join(self.tmp.name, 'bin.plist')
        self.plist_xml = os.path.join(self.tmp.name, 'xml.plist')

    def tearDown(self):
        self.tmp.cleanup()

    def test_convert_to_xml(self):
        with open(self.plist_bin, 'wb') as fp:
            plistlib.dump(dict(
                value1='foobar',
                value2=123
            ), fp, fmt=plistlib.FMT_BINARY)

        plist.convert_to_xml(src=self.plist_bin, dest=self.plist_xml)

        expected = '''\
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>value1</key>
	<string>foobar</string>
	<key>value2</key>
	<integer>123</integer>
</dict>
</plist>
'''
        with open(self.plist_xml, 'r') as plist_xml:
            self.assertMultiLineEqual(plist_xml.read(), expected)

    def test_convert_to_bin(self):
        with open(self.plist_xml, 'wb') as fp:
            plistlib.dump(dict(
                value1='foobar',
                value2=123
            ), fp, fmt=plistlib.FMT_XML)

        plist.convert_to_bin(src=self.plist_xml, dest=self.plist_bin)

        output = subprocess.check_output(['file', self.plist_bin])
        self.assertTrue('Apple binary property list' in str(output))
