#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:create) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:create"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:destroy) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:destroy"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:create) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:create" not_existing_service
  assert_contains "${lines[*]}" "Please specify a name for the bucket"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:destroy) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:destroy" not_existing_service
  assert_contains "${lines[*]}" "Please specify a name for the bucket"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:list) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:list" not_existing_service
  assert_contains "${lines[*]}" "s3rver service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:create) error when bucket exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:create" l lll
  assert_contains "${lines[*]}" "s3rver service l bucket already exist: lll"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:create) error when bucket name is less than three characters" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:create" l l
  assert_contains "${lines[*]}" "s3rver failed to create bucket: l"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:destroy) error when bucket does not exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:destroy" l mmm
  assert_contains "${lines[*]}" "s3rver service l bucket does not exist: mmm"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:create) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:create" l mmm
  assert_contains "${lines[*]}" "s3rver bucket created: mmm"
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:destroy) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:destroy" l lll
  assert_contains "${lines[*]}" "s3rver bucket deleted: "
}

@test "($PLUGIN_COMMAND_PREFIX:bucket:list) success when buckets are listed" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:bucket:list" l
  assert_output "docker exec dokku.s3.l /usr/bin/env sh -c AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake AWS_DEFAULT_REGION=fake aws --endpoint-url http://localhost:5000 s3 ls --output text"
}
