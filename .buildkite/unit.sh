#!/usr/bin/env bash
set -xe

python3 -m virtualenv .venv
. .venv/bin/activate
# Build and install pybatfish
pip install -e .[dev,test]

# We can only run mypy using python 3. That's ok.
# Our type annotations are py2-compliant and will be checked by mypy.
if [[ $TRAVIS_PYTHON_VERSION != 2.7 ]]; then
    echo -e "\n  ..... Running mypy typechecker on pybatfish"
    mypy pybatfish
    mypy --py2 pybatfish
fi

echo -e "\n  ..... Running flake8 on pybatfish to check style and docstrings"
# Additional configuration in setup.cfg
flake8 pybatfish tests

echo -e "\n  ..... Running flake8 on jupyter notebooks"
# Running flake test on generated python script from jupyter notebook(s)
for file in jupyter_notebooks/*.ipynb; do
    jupyter nbconvert "$file" --to python --stdout --TemplateExporter.exclude_markdown=True | flake8 - --select=E,W --ignore=E501,W391
done

### Run unit tests that don't require running instance of batfish
echo -e "\n  ..... Running unit tests with pytest"
python setup.py test

### Build docs. This will fail on warnings
echo -e "\n  ..... Building documentation"
python setup.py build_sphinx

