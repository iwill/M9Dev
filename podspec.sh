#!/bin/bash

if [[ $1 = "-l" || $1 = "-lint" ]]; then
    shift
    pod spec lint M9Dev.podspec \
        --use-libraries \
        --allow-warnings \
        --verbose
else
    pod trunk push M9Dev.podspec \
        --use-libraries \
        --allow-warnings \
        --verbose
fi

