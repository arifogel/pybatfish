#!/usr/bin/env bash
set -xe

export ALLINONE_JAR=workspace/allinone.jar
export QUESTIONS_DIR=questions

if [ -z "${BATFISH_TAG}" ]; then
  ### If not a triggered build, need to produce artifact and set variables
  git clone --depth 1 https://github.com/arifogel/batfish.git
  ## Build and save commit info
  pushd batfish
  mvn clean -f projects/pom.xml package
  BATFISH_TAG=$(git rev-parse --short HEAD)
  BATFISH_VERSION=$(grep -1 batfish-parent "projects/pom.xml" | grep version | sed 's/[<>]/|/g' | cut -f3 -d\|)
  popd
  mkdir -p "$(dirname ${ALLINONE_JAR})"
  cp "batfish/projects/allinone/target/allinone-bundle-${BATFISH_VERSION}.jar" "${ALLINONE_JAR}"
  cp -r "batfish/questions" .
else
  ### For triggered build, just prepare using downloaded artifacts
  # (allinone present as workspace/allinone.jar)
  tar -x --no-same-owner -f workspace/questions.tar
fi

echo "Using Batfish version ${BATFISH_VERSION}"

# Start this as early as possible so that batfish has time to start up.
java -cp "$ALLINONE_JAR" org.batfish.allinone.Main -runclient false -coordinatorargs "-templatedirs questions" &

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

