#!/bin/bash

VAGRANT_CWD=tests vagrant up --destroy-on-error

(cd tests; ./test.sh)

VAGRANT_CWD=tests vagrant destroy -f

rm -rf tests/roles

rm tests/test_hosts
