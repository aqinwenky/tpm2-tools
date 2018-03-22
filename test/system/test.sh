#!/bin/bash
#;**********************************************************************;
#
# Copyright (c) 2016, Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of Intel Corporation nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.
#;**********************************************************************;

# We Assume that the tests are run from the system/test location.
SRC_DIR=`readlink -f ../../tools/`
PATH=$SRC_DIR:$SRC_DIR/aux:$PATH

# Some test helpers are in the test directory
# and might be needed on PATH
TEST_DIR=`readlink -f .`
PATH=$TEST_DIR:$PATH

# Keep track of failures and successes for reporting
pass=0
fail=0

# Keep track of failed test scripts.
fail_summary=""

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# Set the default to print in a prety output
PRETTY=true

# Disable errata by default
ERRATA_ENABLED=false

# Do not run tcti specific tests by default
TCTI_TESTS=""

clear_colors() {
  red=''
  grn=''
  yel=''
  blu=''
  mag=''
  cyn=''
  end=''
}

test_wrapper() {

  PATH=$PATH ./$1 &
  # Process Id of the previous running command
  pid=$!
  spin='-\|/'
  i=0
  while kill -0 $pid 2>/dev/null; do
    if [ "$PRETTY" == true ]; then
      i=$(( (i+1) %4 ))
      printf "\r${yel}${spin:$i:1}${end}"
      sleep .1
    fi
  done

  wait $pid
  rc=$?

  failed_checks=0
  # check for leftover files and fail if present.
  leftovers=`git ls-files -o`
  if [ "$leftovers" != "" ]; then
    printf "Test left files around, found: %s\n" "$leftovers"
    failed_checks=1
  fi

  # check for persistent handles
  leftovers=`tpm2_listpersistent`
  if [ "$leftovers" != "" ]; then
    printf "Test left peristent objects loaded, found: %s\n" "$leftovers"
    failed_checks=1
  fi

  if [ $failed_checks -ne 0 ]; then
    # set the $? variable to not be 0!
    false
  fi

  if [ $rc -eq 0 ]; then
    printf "\r${grn}$1 ... PASSED${end}\n"
    let "pass++"
  else
    printf "\r${red}$1 ... FAILED${end}\n"
    let "fail++"
    fail_summary="$fail_summary"$'\n'"$1"
  fi
}

# Handle options
while getopts "pZt:" opt; do
  case $opt in
    p) PRETTY=false;;
    Z) ERRATA_ENABLED=true;;
    t) TCTI_TESTS="$OPTARG";;
   \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

# Get a list of test scripts, all tests should begin with test_tpm2_ and
# be a shell script.
tests=`find tests -maxdepth 1 -type f`

# Add tcti tests if specified and found..
if [ -n "$TCTI_TESTS" ]; then
  tcti_tests=`find tests/tcti/$TCTI_TESTS -maxdepth 1 -type f`
  if [ -z "$tcti_tests" ]; then
    echo "WARN: Found 0 tcti tests for tcti: $TCTI_TESTS"
  fi
  tests="$tests $tcti_tests"
fi

# If command line arguments are provided, assume it is
# the test suite to execute.
# IE: test_tpm2_getrandom.sh
if [ "$#" -gt 0 ]; then
  tests="$@"
fi

if [ "$PRETTY" != true ]; then
  clear_colors
fi

if [ "$ERRATA_ENABLED" = true ]; then
  export TPM2TOOLS_ENABLE_ERRATA=1
fi

for t in $tests; do
  test_wrapper $t;
done;

# Report the status of the tests
printf "${grn}Tests passed: $pass${end}\n"
printf "${red}Tests Failed: $fail${end}\n"

if [ $fail -gt 0 ]; then
  echo "Fail summary:"
  echo "$fail_summary"
fi

exit $fail
