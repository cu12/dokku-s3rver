# dokku fakes3 (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-s3.svg?branch=master "Build Status")](https://travis-ci.org/cu12/dokku-fakes3) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

FakeS3 plugin for dokku. Currently defaults to installing [convox/aws-s3 latest](https://hub.docker.com/r/convox/aws-s3/).

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
dokku plugin:install https://github.com/dokku/dokku-fakes3.git fakes3
```

## commands

```
s3:create <name>            Create a FakeS3 service with environment variables
s3:destroy <name>           Delete the service and stop its container if there are no links left
s3:expose <name> [port]     Expose a FakeS3 service on custom port if provided (random port otherwise)
s3:info <name>              Print the connection information
s3:link <name> <app>        Link the FakeS3 service to the app
s3:list                     List all FakeS3 services
s3:logs <name> [-t]         Print the most recent log(s) for this service
s3:promote <name> <app>     Promote service <name> as S3_URL in <app>
s3:restart <name>           Graceful shutdown and restart of the s3 service container
s3:start <name>             Start a previously stopped s3 service
s3:stop <name>              Stop a running FakeS3 service
s3:unexpose <name>          Unexpose a previously exposed s3 service
s3:unlink <name> <app>      Unlink the FakeS3 service from the app
```

## usage

```shell
# create a FakeS3 service named lolipop
dokku s3:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# convox/aws-s3 s3 image
export FAKES3_IMAGE="convox/aws-s3"
export FAKES3_IMAGE_VERSION="latest"

# create a FakeS3 service
dokku s3:create lolipop

# get connection information as follows
dokku s3:info lolipop

# a FakeS3 service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku s3:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_S3_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_S3_LOLIPOP_PORT=tcp://172.17.0.1:80
#   DOKKU_S3_LOLIPOP_PORT_80_TCP=tcp://172.17.0.1:80
#   DOKKU_S3_LOLIPOP_PORT_80_TCP_PROTO=tcp
#   DOKKU_S3_LOLIPOP_PORT_80_TCP_PORT=80
#   DOKKU_S3_LOLIPOP_PORT_80_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   S3_URL=http://dokku-s3-lolipop/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku s3:link other_service playground

# since S3_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_S3_BLUE_URL=http://dokku-s3-other-service/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku s3:promote other_service playground

# this will replace S3_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   S3_URL=http://dokku-s3-other_service/other_service
#   DOKKU_S3_BLUE_URL=http://dokku-s3-other-service/other_service
#   DOKKU_S3_SILVER_URL=http://dokku-s3-lolipop/lolipop

# you can also unlink a FakeS3 service
# NOTE: this will restart your app and unset related environment variables
dokku s3:unlink lolipop playground

# you can tail logs for a particular service
dokku s3:logs lolipop
dokku s3:logs lolipop -t # to tail

# finally, you can destroy the container
dokku s3:destroy lolipop
```