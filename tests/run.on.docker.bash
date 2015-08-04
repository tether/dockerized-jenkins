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
  exitcode=$?
  cd - &>/dev/null
  return $exitcode
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

  if ! [[ "$output" =~ 'curl path: /usr/bin/curl' ]]; then
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

  if ! [[ "$output" =~ 'Current dir: /opt/workspace' ]]; then
    $T_fail "Working directory not set"
  fi
}

T_allowsDockerRunArgsToBeProvided() {
  $T_fail "TODO"
}

T_returnsWithSameExitCodeAsTheCommandRan() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  run.on.docker $TEST_IMAGE 'exit 123' &>/dev/null
  exitcode="$?"

  if [[ "$exitcode" != '123' ]]; then
    $T_fail "Exit code from inner command not returned"
  fi
}

T_removesTheContainerRegardlessOfTheExitCode() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  containers_before=$(docker ps -aq | wc -l)
  run.on.docker $TEST_IMAGE 'exit 123' &>/dev/null
  run.on.docker $TEST_IMAGE 'echo "Hello world"' &>/dev/null
  containers_after=$(docker ps -aq | wc -l)

  if [[ "$containers_before" -ne "$containers_after" ]]; then
    $T_fail "A container was left behind after a build"
  fi
}

T_failsIfImageCantBeBuilt() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install non-exist
DOCKERFILE

  output=$(run.on.docker $TEST_IMAGE 'echo Hello world' 2>&1)
  exitcode=$?

  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
  fi

  if [[ "$output" =~ 'Hello world' ]]; then
    $T_fail "Command was executed even though the image build failed o_O"
  fi
}
