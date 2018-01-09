#!/bin/bash

if [[ ! -f /data/bin/hugo ]]; then
  cd /tmp
  wget https://github.com/gohugoio/hugo/releases/download/v0.32.3/hugo_0.32.3_Linux-64bit.tar.gz
  tar -xzf hugo_0.32.3_Linux-64bit.tar.gz
  mv hugo /data/bin/hugo
  cd -
  rm -rf /tmp/*
fi