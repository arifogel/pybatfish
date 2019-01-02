#!/usr/bin/env bash
set -e
set -x
S3_BUCKET="s3://batfish-build-artifacts-arifogel"
export BATFISH_TAR="artifacts/batfish/dev.tar"
BATFISH_DIR="$(dirname "${BATFISH_TAR}")"
mkdir -p "${BATFISH_DIR}"
pushd "${BATFISH_DIR}"
buildkite-agent artifact download --debug --debug-http "${S3_BUCKET}/${BATFISH_TAR}" .
tar -x --no-same-owner -f dev.tar
[ -n "$(cat tag)" ]
popd

