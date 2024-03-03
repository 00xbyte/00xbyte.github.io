@echo off

del Gemfile.lock
bundle lock --add-platform x86_64-linux
bundle install
