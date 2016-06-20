import plistlib

def convert_to_xml(src, dest):
    """
    Converts a binary .plist file to a XML file.
    """
    with open(src, 'rb') as plist_bin:
        with open(dest, 'wb') as plist_xml:
            plistlib.dump(plistlib.load(plist_bin), plist_xml)

def convert_to_bin(src, dest):
    """
    Converts a XML .plist file to a binary file.
    """
    with open(src, 'rb') as plist_xml:
        with open(dest, 'wb') as plist_bin:
            plistlib.dump(plistlib.load(plist_xml), plist_bin,
                          fmt=plistlib.FMT_BINARY)
