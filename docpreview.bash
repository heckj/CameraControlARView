#!/bin/bash

set -e
set -x

rm -rf .build
mkdir -p .build/symbol-graphs

swift build --target CameraControlARView \
-Xswiftc -emit-symbol-graph \
-Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

#xcrun docc convert Sources/CameraControlARView/Documentation.docc \
#--analyze \
#--fallback-display-name CameraControlARView \
#--fallback-bundle-identifier com.github.heckj.CameraControlARView \
#--fallback-bundle-version 0.1.0 \
#--additional-symbol-graph-dir .build/symbol-graphs \
#--experimental-documentation-coverage \
#--level brief

xcrun docc preview Sources/CameraControlARView/Documentation.docc \
--fallback-display-name CameraControlARView \
--fallback-bundle-identifier com.github.heckj.CameraControlARView \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs
