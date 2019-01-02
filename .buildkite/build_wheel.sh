#!/usr/bin/env bash
set -e
set -x
python3 -m virtualenv .venv
. .venv/bin/activate
python setup.py bdist_wheel
deactivate

