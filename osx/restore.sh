#!/usr/bin/env bash
# This script restores all .plist files listed on config/plists by converting
# the file to its binary form.
set -e

while read domain; do
  echo "Restoring ${domain}..."
  plutil -convert binary1 -o "${HOME}/Library/Preferences/${domain}" - \
    < "Library/Preferences/${domain}"
done < config/plists
