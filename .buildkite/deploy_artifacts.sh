#!/usr/bin/env bash
set -e
set -x
S3_BUCKET="s3://batfish-build-artifacts-arifogel"
PYBATFISH_TAG="$(git rev-parse HEAD)"
[ -n "${PYBATFISH_TAG}" ]
PYBATFISH_VERSION="$(python setup.py --version)"
[ -n "${PYBATFISH_VERSION}" ]
ARTIFACTS_DIR=artifacts/pybatfish
ARTIFACT_TAR="${PYBATFISH_TAG}.tar"
mkdir -p "${ARTIFACTS_DIR}"
cd "${ARTIFACTS_DIR}"
echo "${PYBATFISH_TAG}" > tag
echo "${PYBATFISH_VERSION}" > version
tar -cf "${ARTIFACT_TAR}" tag version
ln "${ARTIFACT_TAR}" dev.tar
buildkite-agent artifact upload "${ARTIFACT_TAR}" "${S3_BUCKET}/${ARTIFACTS_DIR}/"
buildkite-agent artifact upload dev.tar "${S3_BUCKET}/${ARTIFACTS_DIR}/"

