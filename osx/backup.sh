#!/usr/bin/env bash
# This script performs a backup of all .plist files listed in config/plists.
set -e

while read domain; do
  echo "Restoring ${domain}..."
  plutil -convert xml1 -o - "${HOME}/Library/Preferences/${domain}" | \
    xmllint --format - > "Library/Preferences/${domain}"
done < config/plists
