export TEST_IMAGE='jenkins-server-test-run-on-docker'
export WORKSPACE='/tmp/test-workspace'

prepare.environment() {
  rm -rf $WORKSPACE
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

T_allowsEnvVarsToBeProvidedToTheUnderlyingDockerRunCommand() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  set -e
  output=$(run.on.docker $TEST_IMAGE --env OTHER_VAR="foo" -e A_VAR="env-var" -- 'echo Vars: $A_VAR $OTHER_VAR')
  set +e

  if ! [[ "$output" =~ 'Vars: env-var foo' ]]; then
    $T_fail "Env var not passed on to docker run"
  fi
}

T_allowsEnvVarsFileToBeProvidedToTheUnderlyingDockerRunCommand() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE
  echo 'FROM_FILE=value' > $WORKSPACE/envfile

  output=$(run.on.docker $TEST_IMAGE --env-file $WORKSPACE/envfile -- 'echo From file: $FROM_FILE')

  if ! [[ "$output" =~ 'From file: value' ]]; then
    $T_fail "Env var file not passed on to docker run"
  fi
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
RUN exit 1
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

T_failsIfNoImageNameGetsProvided() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  output=$(run.on.docker -e foo=bar -- echo Hello world 2>&1)
  exitcode=$?

  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
  fi
}

T_failsIfNoCommandGetsProvided() {
  prepare.environment <<-DOCKERFILE
FROM gliderlabs/alpine:3.2
RUN apk-install bash
DOCKERFILE

  output=$(run.on.docker $TEST_IMAGE 2>&1)
  exitcode=$?
  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
  fi

  output=$(run.on.docker $TEST_IMAGE -e foo=bar 2>&1)
  exitcode=$?

  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
  fi

  output=$(run.on.docker $TEST_IMAGE -e foo=bar -- 2>&1)
  exitcode=$?

  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
  fi
}
