#!/usr/bin/env bash
set -e
set -x
# Create virtual env + dependencies so we can download artifacts
virtualenv -p python3 .env
source ".env/bin/activate"
pip install awscli
S3_BUCKET="s3://batfish-build-artifacts-arifogel"
export BATFISH_TAR="artifacts/batfish/dev.tar"
BATFISH_DIR="$(dirname "${BATFISH_TAR}")"
mkdir -p "${BATFISH_DIR}"
pushd "${BATFISH_DIR}"
aws s3 cp "${S3_BUCKET}/${BATFISH_TAR}" .
tar -x --no-same-owner -f dev.tar
[ -n "$(cat tag)" ]
popd

