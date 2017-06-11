#!/usr/bin/env bash

# Fail on errors
set -ev

# Test a subfolder
cd $TEST_DIR
pub get
pub run test
cd ..