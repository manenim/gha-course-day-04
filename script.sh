#!/bin/bash

# A script that simulates complex version logic
DATE=$(date +'%Y.%m.%d')
BUILD_ID=$((RANDOM % 1000))

echo "${DATE}-build.${BUILD_ID}"
