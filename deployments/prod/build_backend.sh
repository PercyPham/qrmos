#!/bin/bash

# This script is meant to run on prod server.

cd ~/qrmos

# get latest git version of branch "main"
git reset --hard HEAD
git checkout -b temp_branch
git branch -D main
git fetch
git checkout main
git branch -D temp_branch

# export go PATH
export PATH=$PATH:/usr/local/go/bin

echo "Building backend ..."

# build main
make build_clean
make build_backend

echo "Backend built!"
