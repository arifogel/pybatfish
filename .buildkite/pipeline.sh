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
      - ".buildkite/download_artifacts.sh"
      - ".buildkite/integration.sh"
    plugins:
      - docker#v2.1.0:
          image: "arifogel/batfish-docker-build-base:latest"
          always-pull: true
          volumes:
            - ".:/workdir"
          workdir: "/workdir"
EOF

### Upload build artifacts on post-commit
if [ "${BUILDKITE_PULL_REQUEST}" = "false" ]; then
  cat <<EOF
  - wait
  - label: "Deploy artifacts"
    command: ".buildkite/deploy_artifacts.sh"
    branches: "master"
EOF
fi

### Branches
cat <<EOF
branches: "*"
EOF

