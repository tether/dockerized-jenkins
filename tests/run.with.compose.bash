export WORKSPACE='/tmp/test-workspace'

prepare.environment() {
  rm -rf $WORKSPACE
  mkdir -p $WORKSPACE
  cat > $WORKSPACE/docker-compose.yml
}

run.with.compose() {
  cd $WORKSPACE
  /workspace/jenkins/bin/run.with.compose $* 2>&1
  exitcode=$?
  cd - &>/dev/null
  return $exitcode
}

T_runsMainRunnner() {
  prepare.environment <<DOCKER_COMPOSE_YML
mainrunner:
  image: gliderlabs/alpine:3.2
  command: echo Hello world
DOCKER_COMPOSE_YML

  output=$(run.with.compose)
  exitcode=$?

  if [[ "$exitcode" = '1' ]]; then
    $T_fail "Build did not fail"
    return
  fi

  if ! [[ "$output" =~ 'Hello world' ]]; then
    $T_fail "Something went wrong!"
  fi
}

T_buildsImagesBeforeRunning() {
  prepare.environment <<DOCKER_COMPOSE_YML
mainrunner:
  build: .
DOCKER_COMPOSE_YML

  cat <<DOCKERFILE > $WORKSPACE/Dockerfile
FROM gliderlabs/alpine:3.2
RUN apk-install curl
CMD ["sh", "-c", "echo curl path: \$(which curl)"]
DOCKERFILE

  output=$(run.with.compose)
  exitcode=$?

  if [[ "$exitcode" = '1' ]]; then
    $T_fail "Build did not fail"
    return
  fi

  if ! [[ "$output" =~ 'curl path: /usr/bin/curl' ]]; then
    $T_fail "Something went wrong!"
  fi
}

T_returnsAnErrorIfTheMainRunnerCommandFails() {
  prepare.environment <<DOCKER_COMPOSE_YML
mainrunner:
  image: gliderlabs/alpine:3.2
  command: exit 31
DOCKER_COMPOSE_YML

  output=$(run.with.compose)
  exitcode=$?

  if [[ "$exitcode" = '0' ]]; then
    $T_fail "Build did not fail"
    return
  fi
}

T_allowsEnvVarsToBeProvidedToTheUnderlyingDockerComposeRunCommand() {
  prepare.environment <<-DOCKERFILE
mainrunner:
  image: gliderlabs/alpine:3.2
  command: sh -c 'env | grep "_VAR" || true'
DOCKERFILE

  output=$(run.with.compose -e OTHER_VAR="foo" -e A_VAR="env-var")
  exitcode=$?

  if [[ "$exitcode" != '0' ]]; then
    $T_fail "Build failed"
    return
  fi

  if ! [[ "$output" =~ 'A_VAR=env-var' ]]; then
    $T_fail "Env var not passed on to docker compose run"
  fi
  if ! [[ "$output" =~ 'OTHER_VAR=foo' ]]; then
    $T_fail "Env var not passed on to docker compose run"
  fi
}
