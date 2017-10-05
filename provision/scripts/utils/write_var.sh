#!/usr/bin/env bash
# Write a shell variable to a file.
# The variable value will be wrapped in single quotes to avoid syntax errors
# if it contains special characters. As such, the value should NOT contain
# quotes itself.

key="$1"
value="$2"
file="$3"

output="$key='$value'"

# Add a newline to the end of the env.sh file, if it doesn't already end with a
# newline. Prevents the following statement from adding to an existing line.
sed -i -e '$a\' "$file"

if ! grep -q "$key" "$file" ; then
    echo "$output" >> "$file"
else
    sed -i -r "s|#?$key.*|$output|" "$file"
fi
