#!/usr/bin/env bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"/..

cd web/satellite

npm install --prefer-offline --no-audit --loglevel verbose
./scripts/build-wasm.sh
npm run build
cd -

cd web/storagenode
npm install --prefer-offline --no-audit --loglevel verbose
npm run build
cd -

cd web/multinode
npm install --prefer-offline --no-audit --loglevel verbose
npm run build
cd - 

cd satellite/admin/ui
npm install --prefer-offline --no-audit --loglevel verbose
npm run build
