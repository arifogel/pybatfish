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
tar -czf "${ARTIFACTS_DIR}/integration_tests.tgz" tests/integration
tar -czf "${ARTIFACTS_DIR}/jupyter_notebooks.tgz" jupyter_notebooks
DIST_WHEEL="$(readlink -f "$(find dist -name '*.whl' | head -n1)")"
[ -n "${DIST_WHEEL}" ]
WHEEL="$(basename ${DIST_WHEEL})"
[ -n "${WHEEL}" ]
cd "${ARTIFACTS_DIR}"
ln "${DIST_WHEEL}" "${WHEEL}"
echo "${PYBATFISH_TAG}" > tag
echo "${PYBATFISH_VERSION}" > version
tar -cf "${ARTIFACT_TAR}" integration_tests.tgz jupyter_notebooks.tgz tag version "${WHEEL}"
ln "${ARTIFACT_TAR}" dev.tar
buildkite-agent artifact upload "${ARTIFACT_TAR}" "${S3_BUCKET}/${ARTIFACTS_DIR}/"
buildkite-agent artifact upload dev.tar "${S3_BUCKET}/${ARTIFACTS_DIR}/"

