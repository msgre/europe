#!/bin/bash

# copy requirements to current directory
if [ ! -f requirements.txt ]; then
    cp ../requirements/common.txt ./requirements.txt
fi

# make shasum of current requirements.txt and original in source code
CONTEXT_REQUIREMENTS=`cat requirements.txt | shasum -a 256 `
SOURCECODE_REQUIREMENTS=`cat ../requirements/common.txt | shasum -a 256`

# if the content of file differs, copy original to current directory
# NOTE: if differs just metadata (like time information on file) it is evaluated as no change
if [ "$CONTEXT_REQUIREMENTS" != "$SOURCECODE_REQUIREMENTS" ]; then
    cp ../requirements/common.txt ./requirements.txt
fi

# build!
tar cz Dockerfile requirements.txt | docker build -t msgre/europe -
