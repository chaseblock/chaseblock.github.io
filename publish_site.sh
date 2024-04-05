#!/bin/bash

SITE_PATH=/home/chase/sites/chaseblock.github.io

# Make sure to disable incremental build if deleting files.
bundle exec jekyll build --lsi #--incremental

rm -rf $SITE_PATH/*
cp -r _site/* $SITE_PATH

pushd $SITE_PATH
git add --all
git commit -m "Update site"
git push
popd