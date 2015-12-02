#!/usr/bin/env ruby
require_relative 'lib/plist'

plists = File.readlines(File.join(__dir__, 'config/plists')).map(&:strip)
plists.each do |plist|
  Plist.new(plist).restore
end
