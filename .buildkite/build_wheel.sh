#!/usr/bin/env bash
set -e
set -x
python3 -m virtualenv .venv
. .venv/bin/activate
python setup.py bdist_wheel
deactivate
DIST_WHEEL="$(readlink -f "$(find dist -name '*.whl' | head -n1)")"
[ -n "${DIST_WHEEL}" ]
WHEEL="$(basename ${DIST_WHEEL})"
[ -n "${WHEEL}" ]
mkdir -p workspace
ln "${DIST_WHEEL}" "workspace/pybatfish.whl"

