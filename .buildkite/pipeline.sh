#!/usr/bin/env bash
### Build and quick lint
set -e

cat <<EOF
steps:
  - label: "lint and unit tests"
    command: 
      - ".buildkite/unit.sh"
    plugins:
      - docker#v2.1.0:
          image: "arifogel/batfish-docker-build-base:latest"
          always-pull: true
          volumes:
            - ".:/workdir"
          workdir: "/workdir"
EOF
cat <<EOF
  - label: "integration tests"
    command: 
      - ".buildkite/integration.sh"
    plugins:
      - docker#v2.1.0:
          image: "arifogel/batfish-docker-build-base:latest"
          always-pull: true
          volumes:
            - ".:/workdir"
          workdir: "/workdir"
EOF
### If triggered from another pipeline, we need to download artifacts
if [ -n "${BUILDKITE_TRIGGERED_FROM_BUILD_ID}" ]; then
  cat <<EOF
      - artifacts#v1.2.0:
          build: "\${BUILDKITE_TRIGGERED_FROM_BUILD_ID}"
          download:
EOF
  ### If triggered from batfish, download batfish artifacts
  if [ "${BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG}" = "batfish" ]; then
    cat <<EOF
            - "workspace/allinone.jar"
            - "workspace/questions.tar"
EOF
  fi
fi

### Trigger docker tests
cat <<EOF
  - wait
  - label: "Trigger batfish-docker build"
    trigger: "batfish-docker-pipeline"
    branches: "master"
#    build:
#      env:
#        PYBATFISH_TAG: "$(git rev-parse --short HEAD)"
#        PYBATFISH_VERSION: "$(grep -1 batfish-parent 'projects/pom.xml' | grep version | sed 's/[<>]/|/g' | cut -f3 -d\|)"
EOF

