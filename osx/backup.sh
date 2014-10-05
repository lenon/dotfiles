#!/usr/bin/env bash
# Performs a backup of all .plist specified in "plists" file.
set -e

while read domain; do
  plutil -convert xml1 -o - "${HOME}/Library/Preferences/${domain}" | \
    xmllint --format - > "./Library/Preferences/${domain}"
done < config/plists
