#!/bin/bash
#
# Installation profile builder
# Created by Dave Hall http://davehall.com.au
#

FILES="base.info base.install base.profile"
OK_NS_CHARS="a-z0-9_"
SCRIPT_NAME=$(basename $0)

namespace="my_profile"
name=""
description="My automatically generated installation profile."
target=""

usage() {
  echo "usage: $SCRIPT_NAME -t target_path -s profile_namespace [-d 'project_descrption'] [-n 'human_readable_profile_name']"
}

while getopts  "d:n:s:t:h" arg; do
  case $arg in
    d)
      description="$OPTARG"
      ;;
    n)
      name="$OPTARG"
      ;;
    s)
      namespace="$OPTARG"
      ;;
    t)
      target="$OPTARG"
      ;;
    h)
      usage
      exit
      ;;
  esac
done

if [ -z "$target" ]; then
  echo ERROR: You must specify a target path. >&2
  exit 1;
fi

if [ ! -d "$target" -o ! -w "$target" ]; then
  echo ERROR: The target path must be a writable directory that already exists. >&2
  exit 1;
fi

ns_test=${namespace/[^$OK_NS_CHARS]//}
if [ "$ns_test" != "$namespace" ]; then
  echo "ERROR: The namespace can only contain lowercase alphanumeric characters and underscores ($OK_NS_CHARS)" >&2
  exit 1
fi

if [ -z "$name" ]; then
  name="$namespace";
fi

for file in $FILES; do
  echo Processing $file
  sed -e "s/PROFILE_NAMESPACE/$namespace/g" -e "s/PROFILE_NAME/$name/g" -e "s/PROFILE_DESCRIPTION/$description/g" $file > $target/$file
done

echo Completed generating files for $name installation profile in $target.

