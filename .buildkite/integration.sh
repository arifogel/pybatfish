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
  cp "batfish/projects/allinone/target/allinone-bundle-${BATFISH_VERSION}.jar" "${ALLINONE_JAR}"
  cp -r "batfish/questions" .
else
  ### For triggered build, just prepare using downloaded artifacts
  # (allinone present as workspace/allinone.jar)
  tar -x --no-same-owner -f workspace/questions.tar
fi

echo "Using Batfish version ${BATFISH_VERSION}"

# Build and install pybatfish
pip install -e .[dev,test]

# Start this as early as possible so that batfish has time to start up.
java -cp "$ALLINONE_JAR" org.batfish.allinone.Main -runclient false -coordinatorargs "-templatedirs questions" &

#### Running integration tests (require batfish)
echo -e "\n  ..... Running python integration with batfish"
retcode=0
py.test tests/integration

