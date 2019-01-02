#!/usr/bin/env bash
set -e
set -x
S3_BUCKET="s3://batfish-build-artifacts-arifogel"
export BATFISH_TAR="artifacts/batfish/dev.tar"
BATFISH_DIR="$(dirname "${BATFISH_TAR}")"
mkdir -p "${BATFISH_DIR}"
buildkite-agent artifact download "${S3_BUCKET}/${BATFISH_TAR}" "${BATFISH_DIR}/"
pushd "${BATFISH_DIR}"
tar -x --no-same-owner -f dev.tar
[ -n "$(cat tag)" ]
popd

