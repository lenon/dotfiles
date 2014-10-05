#!/usr/bin/env bash
# Restores a .plist file converting it to the binary form.
set -e

while read domain; do
  plutil -convert binary1 -o "${HOME}/Library/Preferences/${domain}" - \
    < "./Library/Preferences/${domain}"
done < config/plists
