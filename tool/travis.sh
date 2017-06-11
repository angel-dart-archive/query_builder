#!/usr/bin/env bash

set -ev

# Test the SQL repo
cd sql
pub run test
cd ..