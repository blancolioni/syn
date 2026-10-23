#!/bin/sh
# Compile every expected file with GNAT's syntax and style checks, as
# strict as Rose's build: style problems are errors.

cd "$(dirname "$0")" || exit 1
work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"' EXIT
status=0

for file in expected/*.ad[sb]; do
  [ -e "$file" ] || continue
  if (cd "$work" && gcc -c -gnats -gnat2022 -gnatyabcefhiklmnoprst -gnaty3 \
        -gnatwe "$OLDPWD/$file"); then
    echo "STYLE OK   $file"
  else
    echo "STYLE FAIL $file"
    status=1
  fi
done

exit $status
