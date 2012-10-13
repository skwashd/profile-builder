#!/bin/bash
#
# Installation profile builder
# Created by Dave Hall http://davehall.com.au
#

PROFILE_EXTS="info install profile"
MODULE_EXTS="info install module"
OK_NS_CHARS="a-z0-9_"
SCRIPT_NAME=$(basename $0)

namespace="my"
name=""
description="Automatically generated."
target=""

usage() {
  echo "Usage: $SCRIPT_NAME -t target_path -s namespace [-d 'project_description'] [-n 'human_readable_name']"
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
  usage
  exit 1;
fi

if [ ! -d "$target" -o ! -w "$target" ]; then
  echo ERROR: The target path must be a writable directory that already exists. >&2
  usage
  exit 1;
fi

ns_test=${namespace/[^$OK_NS_CHARS]//}
if [ "$ns_test" != "$namespace" ]; then
  echo "ERROR: The namespace can only contain lowercase alphanumeric characters and underscores ($OK_NS_CHARS)" >&2
  usage
  exit 1
fi

if [ -z "$name" ]; then
  name="$namespace";
fi

profile_name="${namespace}_profile"
for ext in $PROFILE_EXTS; do
  full_path="$target/$profile_name.$ext"
  echo "Processing $full_path"
  sed -e "s/PROFILE_NAMESPACE/$namespace/g" -e "s/PROFILE_NAME/$profile_name/g" -e "s/PROFILE_DESCRIPTION/$description/g" "profile.$ext" > "$full_path"
done

module_name="${namespace}_base"
module_path="$target/modules/$module_name"
mkdir -p "$module_path"
for ext in $MODULE_EXTS; do
  full_path="$module_path/$module_name.$ext"
  echo "Processing $full_path"
  sed -e "s/MODULE_NAMESPACE/$namespace/g" -e "s/MODULE_NAME/$module_name/g" -e "s/MODULE_DESCRIPTION/$description/g" "module.$ext" > "$full_path"
done

echo "Completed generating files for namespace '$namespace' profile in $target."

