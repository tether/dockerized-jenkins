export TEST_IMAGE='jenkins-server-test-run-on-docker'
export WORKSPACE='/tmp/test-workspace'

prepare.environment() {
  mkdir -p $WORKSPACE
  cat > $WORKSPACE/Dockerfile
}

run.on.docker() {
  cd $WORKSPACE
  image=$1
  shift 1
  /workspace/jenkins/bin/run.on.docker $image $*
  cd - &>/dev/null
}

T_buildsAndRunsTheImage() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
RUN apk-install curl
DOCKERFILE

  set -e
  output=$(run.on.docker $TEST_IMAGE echo 'curl path: $(which curl)')
  set +e

  if ! [[ "${output}" =~ 'curl path: /usr/bin/curl' ]]; then
    $T_fail "Something went wrong!"
  fi
}

T_mountsCurrentDirectoryAsTheWorkspaceRootInsideTheContainer() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
RUN date > /tmp/created-on-build
DOCKERFILE

  set -e
  output=$(run.on.docker $TEST_IMAGE 'cp /tmp/created-on-build /opt/workspace')
  set +e

  if [[ ! -f "$WORKSPACE/created-on-build" ]]; then
    $T_fail "Workspace was not mounted inside the container"
  fi
}

T_setsTheWorkspaceCorrectly() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  set -e
  output=$(run.on.docker $TEST_IMAGE 'echo Current dir: $(pwd)')
  set +e

  if ! [[ "${output}" =~ 'Current dir: /opt/workspace' ]]; then
    $T_fail "Working directory not set"
  fi
}

T_allowsDockerRunArgsToBeProvided() {
  $T_fail "TODO"
}

T_returnsWithSameExitCodeAsTheCommandRan() {
  $T_fail "TODO"
}

T_removesTheContainerRegardlessOfTheExitCode() {
  $T_fail "TODO"
}

T_failsIfImageCantBeBuilt() {
  $T_fail "TODO"
}
