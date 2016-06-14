# dokku s3rver (beta) [![Build Status](https://img.shields.io/travis/cu12/dokku-s3rver.svg?maxAge=2592000 "Build Status")](https://travis-ci.org/cu12/dokku-s3rver)

Fake S3 plugin for dokku. Currently defaults to installing [seayou/s3rver latest](https://hub.docker.com/r/seayou/s3rver/).

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
dokku plugin:install https://github.com/cu12/dokku-s3rver.git s3rver
```

## commands

```
s3:create <name>            Create a fake S3 service with environment variables
s3:destroy <name>           Delete the service and stop its container if there are no links left
s3:expose <name> [port]     Expose a fake S3 service on custom port if provided (random port otherwise)
s3:info <name>              Print the connection information
s3:link <name> <app>        Link the fake S3 service to the app
s3:list                     List all fake S3 services
s3:logs <name> [-t]         Print the most recent log(s) for this service
s3:promote <name> <app>     Promote service <name> as S3_URL in <app>
s3:restart <name>           Graceful shutdown and restart of the s3 service container
s3:start <name>             Start a previously stopped s3 service
s3:stop <name>              Stop a running fake S3 service
s3:unexpose <name>          Unexpose a previously exposed s3 service
s3:unlink <name> <app>      Unlink the fake S3 service from the app
```

## usage

```shell
# create a fake S3 service named lolipop
dokku s3:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# seayou/s3rver image
export S3RVER_IMAGE="seayou/s3rver"
export S3RVER_IMAGE_VERSION="latest"

# create a fake S3 service
dokku s3:create lolipop

# get connection information as follows
dokku s3:info lolipop

# a fake S3 service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku s3:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_S3_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_S3_LOLIPOP_PORT=tcp://172.17.0.1:5000
#   DOKKU_S3_LOLIPOP_PORT_5000_TCP=tcp://172.17.0.1:5000
#   DOKKU_S3_LOLIPOP_PORT_5000_TCP_PROTO=tcp
#   DOKKU_S3_LOLIPOP_PORT_5000_TCP_PORT=5000
#   DOKKU_S3_LOLIPOP_PORT_5000_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   S3_URL=http://dokku-s3-lolipop:5000/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku s3:link other_service playground

# since S3_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_S3RVER_BLUE_URL=http://dokku-s3-other-service:5000/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku s3:promote other_service playground

# this will replace S3_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   S3_URL=http://dokku-s3-other_service:5000/other_service
#   DOKKU_S3RVER_BLUE_URL=http://dokku-s3-other-service:5000/other_service
#   DOKKU_S3RVER_SILVER_URL=http://dokku-s3-lolipop:5000/lolipop

# you can also unlink a fake S3 service
# NOTE: this will restart your app and unset related environment variables
dokku s3:unlink lolipop playground

# you can tail logs for a particular service
dokku s3:logs lolipop
dokku s3:logs lolipop -t # to tail

# finally, you can destroy the container
dokku s3:destroy lolipop
```
