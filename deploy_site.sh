#!/bin/bash

# Make sure to disable incremental build if deleting files.
bundle exec jekyll build --lsi #--incremental

sudo rm -r /usr/share/nginx/html/*
sudo cp -r _site/* /usr/share/nginx/html/
