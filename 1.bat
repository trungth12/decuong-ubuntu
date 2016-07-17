@echo off
E:
cd E:\decuong
set RACK_ENV=production
bundle exec thin start -p 4000