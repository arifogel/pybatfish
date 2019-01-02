#!/usr/bin/env bash
set -e
set -x
PYBATFISH_TAG="$(git rev-parse HEAD)"
ARTIFACTS_DIR=artifacts/pybatfish
ARTIFACT_TAR="${PYBATFISH_TAG}.tar"
mkdir -p "${ARTIFACTS_DIR}"
cd "${ARTIFACTS_DIR}"
echo "${BATFISH_TAG}" > tag
tar -cf "${ARTIFACT_TAR}" tag
ln "${ARTIFACT_TAR}" dev.tar
buildkite-agent artifact upload "${ARTIFACT_TAR}" s3://batfish-build-artifacts-arifogel
buildkite-agent artifact upload dev.tar s3://batfish-build-artifacts-arifogel

