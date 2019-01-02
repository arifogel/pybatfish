#!/usr/bin/env bash
set -e
set -x
python3 -m virtualenv .venv
. .venv/bin/activate
PYBATFISH_VERSION="$(python setup.py --version)"
[ -n "${PYBATFISH_VERSION}" ]
python setup.py bdist_wheel
deactivate
BDIST_WHEEL="${PWD}/dist/pybatfish-${PYBATFISH_VERSION}-py2.py3-none-any.whl"
[ -n "${BDIST_WHEEL}" ]
mkdir -p workspace
pushd workspace
ln "${BDIST_WHEEL}"
popd

