#!/usr/bin/env bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"/..

function report() {
  cat .build/tests.json | tparse -all -top -slow 100

  filter-cover-profile < .build/coverprofile > .build/clean.coverprofile
  gocov convert .build/clean.coverprofile > .build/cover.json
  gocov-xml  < .build/cover.json > .build/cobertura.xml
}

service postgresql start

cockroach start-single-node --insecure --store=type=mem,size=2GiB --listen-addr=localhost:26256 --http-addr=localhost:8086 --cache 512MiB --max-sql-memory 512MiB --background
cockroach start-single-node --insecure --store=type=mem,size=2GiB --listen-addr=localhost:26257 --http-addr=localhost:8087 --cache 512MiB --max-sql-memory 512MiB --background
cockroach start-single-node --insecure --store=type=mem,size=2GiB --listen-addr=localhost:26258 --http-addr=localhost:8088 --cache 512MiB --max-sql-memory 512MiB --background
cockroach start-single-node --insecure --store=type=mem,size=2GiB --listen-addr=localhost:26259 --http-addr=localhost:8089 --cache 512MiB --max-sql-memory 512MiB --background
cockroach start-single-node --insecure --store=type=mem,size=2GiB --listen-addr=localhost:26260 --http-addr=localhost:8090 --cache 256MiB --max-sql-memory 256MiB --background

export STORJ_TEST_HOST='127.0.0.20;127.0.0.21;127.0.0.22;127.0.0.23;127.0.0.24;127.0.0.25'
export STORJ_TEST_COCKROACH = 'cockroach://root@localhost:26256/testcockroach?sslmode=disable;cockroach://root@localhost:26257/testcockroach?sslmode=disable;cockroach://root@localhost:26258/testcockroach?sslmode=disable;cockroach://root@localhost:26259/testcockroach?sslmode=disable'
export STORJ_TEST_COCKROACH_NODROP='true'
export STORJ_TEST_COCKROACH_ALT='cockroach://root@localhost:26260/testcockroach?sslmode=disable'
export STORJ_TEST_POSTGRES='postgres://postgres@localhost/teststorj?sslmode=disable'
export STORJ_TEST_LOG_LEVEL='info'
export COVERFLAGS='-coverprofile=.build/coverprofile -coverpkg=storj.io/storj/private/...,storj.io/storj/satellite/...,storj.io/storj/storage/...,storj.io/storj/storagenode/...,storj.io/storj/versioncontrol/...'

sleep 10

cockroach sql --insecure --host=localhost:26256 -e 'create database testcockroach;'
cockroach sql --insecure --host=localhost:26257 -e 'create database testcockroach;'
cockroach sql --insecure --host=localhost:26258 -e 'create database testcockroach;'
cockroach sql --insecure --host=localhost:26259 -e 'create database testcockroach;'
cockroach sql --insecure --host=localhost:26260 -e 'create database testcockroach;'

psql -U postgres -c 'create database teststorj;'

use-ports -from 1024 -to 10000 &

: ${TEST_TARGET:=./...}
go test -tags noembed -parallel 4 -p 6 -vet=off $COVERFLAGS -timeout 32m -json -race ${TEST_TARGET} 2>&1 | tee .build/tests.json | xunit -out .build/tests.xml

pkill -f cockroach
service postgresl stop 
