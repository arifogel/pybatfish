#!/usr/bin/env bash
set -e
set -x
S3_BUCKET_NAME="batfish-build-artifacts-arifogel"
S3_BUCKET="s3://${S3_BUCKET_NAME}"
PYBATFISH_TAG="$(git rev-parse HEAD)"
[ -n "${PYBATFISH_TAG}" ]
PYBATFISH_VERSION="$(python setup.py --version)"
[ -n "${PYBATFISH_VERSION}" ]
ARTIFACTS_DIR=artifacts/pybatfish
ARTIFACT_TAR="${PYBATFISH_TAG}.tar"
mkdir -p "${ARTIFACTS_DIR}"
tar -czf "${ARTIFACTS_DIR}/integration_tests.tgz" tests/integration
tar -czf "${ARTIFACTS_DIR}/jupyter_notebooks.tgz" jupyter_notebooks
export BDIST_WHEEL="${PWD}/workspace/pybatfish-${PYBATFISH_VERSION}-py2.py3-none-any.whl"
[ -f "${BDIST_WHEEL}" ]
cd "${ARTIFACTS_DIR}"
ln "${BDIST_WHEEL}"
echo "${PYBATFISH_TAG}" > tag
echo "${PYBATFISH_VERSION}" > version
tar -cf "${ARTIFACT_TAR}" integration_tests.tgz jupyter_notebooks.tgz "$(basename "${BDIST_WHEEL}")" tag version
ln "${ARTIFACT_TAR}" dev.tar
ARTIFACT_KEY="${ARTIFACTS_DIR}/${ARTIFACT_TAR}"
if aws s3api head-object --bucket "${S3_BUCKET_NAME}" --key "${ARTIFACT_KEY}"; then
  echo "Skipping upload since artifact already exists for this commit"
else
  buildkite-agent artifact upload "${ARTIFACT_TAR}" "${S3_BUCKET}/${ARTIFACTS_DIR}/"
  buildkite-agent artifact upload dev.tar "${S3_BUCKET}/${ARTIFACTS_DIR}/"
fi

