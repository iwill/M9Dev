#!/bin/bash

pod spec lint M9Dev.podspec \
    --use-libraries \
    --allow-warnings \
    --verbose \
&& \
pod trunk push M9Dev.podspec \
    --use-libraries \
    --allow-warnings \
    --verbose

