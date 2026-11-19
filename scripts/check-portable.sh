#!/bin/sh
# Fail if machine-specific paths or names leak into packages.
if grep -rnE "/Users/|matt\.fisher|Matt's|Matt Fisher's" packages --include='*.md'; then
  echo "machine-specific content found" >&2; exit 1
fi
echo ok
