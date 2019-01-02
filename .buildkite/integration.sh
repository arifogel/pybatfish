#!/usr/bin/env bash
set -xe

export ALLINONE_JAR=workspace/allinone.jar
export QUESTIONS_DIR=questions

BATFISH_TAG="$(cat artifacts/batfish/tag)"
[ -n "${BATFISH_TAG}" ]
BATFISH_VERSION="$(cat artifacts/batfish/version)"
[ -n "${BATFISH_VERSION}" ]

mkdir -p workspace
ln "artifacts/batfish/allinone.jar" "${ALLINONE_JAR}"
tar -x --no-same-owner -f artifacts/batfish/questions.tgz

echo "Using Batfish version ${BATFISH_VERSION}"

# Start this as early as possible so that batfish has time to start up.
java -cp "${ALLINONE_JAR}" org.batfish.allinone.Main -runclient false -coordinatorargs "-templatedirs questions" &

# Build and install pybatfish
python3 -m virtualenv .venv
. .venv/bin/activate
pip install -e .[dev,test]

# Poll until we can connect to the container v1 endpoint
while ! curl http://localhost:9997/
do
  echo "$(date) - waiting for Batfish v1 API to start"
  sleep 1
done
echo "$(date) - connected to Batfish"

# Poll until we can connect to the container v2 endpoint
while ! curl http://localhost:9996/
do
  echo "$(date) - waiting for Batfish v2 API to start"
  sleep 1
done
echo "$(date) - connected to Batfish"

#### Running integration tests (require batfish)
echo -e "\n  ..... Running python integration with batfish"
retcode=0
py.test tests/integration || retcode=$?

echo -e "\n  ..... Running doctests"
py.test docs pybatfish --doctest-glob='docs/source/*.rst' --doctest-modules

exit ${retcode}

