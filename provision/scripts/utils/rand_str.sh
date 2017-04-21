#!/usr/bin/env bash

NUMBER_RE='^[0-9]+$'
LENGTH="$1"

if ! [[ $LENGTH =~ $NUMBER_RE ]] ; then
   echo "Integer length required" >&2
   exit 1
fi

# Generate a random string using a Python script to choose random characters
# from a set of letters, numbers and punctuation.
# NOTE: An explicit list of punctuation is provided, rather than using
# string.punctuation, so as to exclude single quotes, double quotes and
# backticks. This is done to avoid SyntaxErrors, both in this script and if the
# result is output to a language file (e.g. Python) as a string.

# The default version of Python available on an unprovisioned system may vary,
# but there should always be one.

if command -v python >/dev/null; then
    python -c "import random; import string; print ''.join([random.SystemRandom().choice(string.letters + string.digits + '!#$%&\()*+,-./:;<=>?@[\\]^_{|}~') for i in range($LENGTH)])"
elif command -v python3 >/dev/null; then
    python -c "import random; import string; print(''.join([random.SystemRandom().choice(string.ascii_letters + string.digits + '!#$%&\()*+,-./:;<=>?@[\\]^_{|}~') for i in range($LENGTH)]))"
else
    echo "Python not available" >&2
    exit 1
fi
