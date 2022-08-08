#!/usr/bin/env bash
set -euxo pipefail

mkdir -p build
: ${OUTPUT_DIR:=./build}

function build(){
   go build -race -v -o $OUTPUT_DIR $1
}

build storj.io/storj/cmd/satellite 
build storj.io/storj/cmd/storagenode 
build storj.io/storj/cmd/storj-sim 
build storj.io/storj/cmd/versioncontrol 
build storj.io/storj/cmd/uplink 
build storj.io/storj/cmd/identity 
build storj.io/storj/cmd/certificates  
build storj.io/storj/cmd/multinode
