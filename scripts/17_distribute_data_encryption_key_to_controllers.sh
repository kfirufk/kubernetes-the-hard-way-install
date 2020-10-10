#!/bin/bash -x
set -e

echo distributing data encryption key to controllers..


for instance in $CONTROLLERS; do
  DIR="files/${instance}"
  cp encryption-config.yaml $DIR
done