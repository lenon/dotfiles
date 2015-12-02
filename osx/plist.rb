require 'fileutils'

# Property list files (.plist) are files used to store settings on Mac OS X
# apps. This class provides some methods to copy and restore these files.
class Plist
  PREF_DIR = '~/Library/Preferences'

  def initialize(file)
    @basename = File.basename(file)
    @source = File.expand_path(File.join(PREF_DIR, file))
    @dest = File.expand_path(File.join(__dir__, 'backup', @basename))
  end

  # Copy a .plist file from the Preferences folder to ./backup. It also
  # converts it to XML (the original file is a binary format).
  def copy
    FileUtils.cp(@source, @dest)
    system("plutil -convert xml1 #{@dest}")
    system("xmllint --output #{@dest} #{@dest}")
  end

  # Restore a .plist file from the backup folder to the preferences folder,
  # converting it to the original binary format.
  def restore
    FileUtils.cp(@dest, @source)
    system("plutil -convert binary1 #{@source}")
    system('killall cfprefsd')
  end
end
