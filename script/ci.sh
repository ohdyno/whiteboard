#!/bin/bash

export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
gem install bundler -v 1.10.6
bundle exec rake db:setup
rake