#!/bin/bash

echo "Make sure you've rebased over the current HEAD branch:"
echo "git rebase -i origin/main docs"

set -e
set -x

rm -rf .build
mkdir -p .build/symbol-graphs

swift build --target CameraControlARView \
-Xswiftc -emit-symbol-graph \
-Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

xcrun docc convert Sources/CameraControlARView/Documentation.docc \
--analyze \
--fallback-display-name CameraControlARView \
--fallback-bundle-identifier com.github.heckj.CameraControlARView \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
--experimental-documentation-coverage \
--level brief

export DOCC_JSON_PRETTYPRINT=YES

# Swift package plugin for hosted content:
#
swift package \
    --allow-writing-to-directory ./docs \
    --target CameraControlARView \
    generate-documentation \
    --output-path ./docs \
    --emit-digest \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'CameraControlARView'

echo "Page will be available at https://heckj.github.io/CameraControlARView/documentation/cameracontrolarview/"

# Generate a list of all the identifiers for DocC curation
#

cat docs/linkable-entities.json | jq '.[].referenceURL' -r > all_identifiers.txt

sort all_identifiers.txt \
 | sed -e 's/doc:\/\/CameraControlARView\/documentation\///g' \
 | sed -e 's/^/- ``/g' \
 | sed -e 's/$/``/g' > all_symbols.txt
