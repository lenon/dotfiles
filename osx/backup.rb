#!/usr/bin/env ruby
require_relative 'plist'

plists = File.readlines(File.join(__dir__, 'plists')).map(&:strip)
plists.each do |plist|
  Plist.new(plist).copy
end
