#!/bin/bash

APK_FILE=$1
REMOVE_SO=${2:-true}

IFS='-' read -r -a parts <<< "$APK_FILE"
NAME="${parts[0]}"
for part in "${parts[@]:1}"; do
    echo $part
    if [[ $part =~ ^[0-9] ]]; then
        break
    else
        NAME="$NAME-$part"
    fi
done

VAR_NAME=${NAME//-/_}
VAR_NAME=${VAR_NAME//+/x}
VAR_NAME=${VAR_NAME^^}
BZL_FILE="$(pwd)/${NAME}.bzl"

mkdir -p staging
cp $APK_FILE staging

pushd staging

echo "${VAR_NAME}_OUTS = [" > $BZL_FILE
files=$(tar xvf $APK_FILE | grep -v '/$')

if [ "$REMOVE_SO" = true ]; then
    files=$(echo "$files" | grep -v '\.so$')
fi

for file in $files; do
  echo "  \"$file\"," >> $BZL_FILE
done
echo "]" >> $BZL_FILE

popd

rm -rf staging