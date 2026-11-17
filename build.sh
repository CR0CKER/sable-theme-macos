#!/bin/sh
# Builds the importable Sable theme files from the shared sources:
#   macos-{light,dark}.sable.css       shadow version
#   macos-flat-{light,dark}.sable.css  flat version (hairlines, src/flat.css)
set -eu
cd "$(dirname "$0")"
for v in light dark; do
  cat "src/tokens-$v.css" src/structure.css > "macos-$v.sable.css"
  # Flat: same tokens with its own id/name, then the flat overrides.
  sed -e "s/^id: macos-$v\$/id: macos-flat-$v/" \
      -e 's/^name: macOS \(.*\)$/name: macOS Flat \1/' \
      -e 's/^description: Native-feeling macOS theme/description: Flat (hairline) native-feeling macOS theme/' \
      -e 's/^tags: \(.*\)$/tags: \1, flat/' \
      "src/tokens-$v.css" | cat - src/structure.css src/flat.css > "macos-flat-$v.sable.css"
done
echo "Built macos-{light,dark}.sable.css and macos-flat-{light,dark}.sable.css"
