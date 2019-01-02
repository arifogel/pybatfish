#!/usr/bin/env bash
set -e
set -x
. /root/workdir/.venv-aws/bin/activate
S3_BUCKET="s3://batfish-build-artifacts-arifogel"
export BATFISH_TAR="artifacts/batfish/dev.tar"
BATFISH_DIR="$(dirname "${BATFISH_TAR}")"
mkdir -p "${BATFISH_DIR}"
pushd "${BATFISH_DIR}"
aws s3 cp "${S3_BUCKET}/${BATFISH_TAR}" .
deactivate
tar -x --no-same-owner -f dev.tar
[ -n "$(cat tag)" ]
popd

