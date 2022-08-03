#!/usr/bin/env bash
set -ex

go test -v -p 16 -tags noembed -bench XYZXYZXYZXYZ -run XYZXYZXYZXYZ ./...
go test -v -p 16 -tags noembed -bench XYZXYZXYZXYZ -run XYZXYZXYZXYZ -race ./...
go install -race -v storj.io/storj/cmd/satellite storj.io/storj/cmd/storagenode storj.io/storj/cmd/storj-sim storj.io/storj/cmd/versioncontrol storj.io/storj/cmd/uplink storj.io/storj/cmd/identity storj.io/storj/cmd/certificates  storj.io/storj/cmd/multinode
go install -race -v storj.io/gateway@latest