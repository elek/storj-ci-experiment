#!/usr/bin/env bash
set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"/..

if [ ! -f ".golangci.yml" ]; then
   wget https://raw.githubusercontent.com/storj/ci/main/.golangci.yml
fi

check-mod-tidy
check-copyright
check-imports -race ./...
check-peer-constraints -race
check-atomic-align ./...
check-monkit ./...
check-errs ./...
staticcheck ./...
golangci-lint -j=2 run
make check-monitoring
make test-wasm-size
protolock status

cd testsuite/ui
check-imports ./...
check-atomic-align ./...
check-monkit ./...
check-errs ./...
staticcheck ./...
if [ ! -f ".golangci.yml" ]; then
   wget https://raw.githubusercontent.com/storj/ci/main/.golangci.yml
fi
golangci-lint -j=2 run
cd -

cd satellite/admin/ui
npm run check
npm run lint
cd -

./scripts/check-package-lock.sh

