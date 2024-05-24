#!/bin/bash

RECORDER_FILE=${RECORDER_FILE:-/tmp/recorder}

export RECORDER_FILE
export PROMPT_COMMAND='history 1 | awk "{\$1=\"\"; print}" >> $RECORDER_FILE 2>/dev/null'

echo "echo -e 'You are currently running a \033[1;31mRecorder\033[0m container.'" >>~/.bashrc
echo "echo -e 'All successful commands are being recorded to ${RECORDER_FILE}.'" >>~/.bashrc
