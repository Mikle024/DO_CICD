#!/bin/bash

REMOTE_USER="mikle"
REMOTE_HOST="192.168.0.180"
REMOTE_DIR="/usr/local/bin"
ARTIFACTS_DIR="/home/gitlab-runner/builds/H88J4gtA/0/students/DO6_CICD.ID_356283/onionyas_student.21_school.ru/DO6_CICD-1/artifacts"

if [ -d "$ARTIFACTS_DIR" ]; then
        echo "Artifacts found, start copy.."

        scp "$ARTIFACTS_DIR/s21_cat" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" && \
        scp "$ARTIFACTS_DIR/s21_grep" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

        if [ $? -eq 0 ]; then
                echo "COPY SUCCESSFUL"
        else
                echo "COPY FAIL"
                exit 1
        fi
else
        echo "NO ARTIFACTS FOUND"
        exit 1
fi

ssh $REMOTE_USER@$REMOTE_HOST ls -la $REMOTE_DIR