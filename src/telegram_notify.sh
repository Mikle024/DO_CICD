#!/bin/bash

BOT_TOKEN="" # Вставить нужный токен
CHAT_ID="" # Вставить нужный id

TIME="10"

URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

BUILD_STATUS="✅ Success"
CODE_STYLE_STATUS="✅ Success"
TEST_STATUS="✅ Success"
DEPLOY_STATUS="✅ Success"

TEXT="Pipeline Status Notification:
Project: $CI_PROJECT_NAME
Pipeline URL: $CI_PIPELINE_URL

Build Stage: $BUILD_STATUS
- Details: Build completed successfully, artifacts copied.

Code Style Stage: $CODE_STYLE_STATUS
- Details: Code style check completed successfully.

Test Stage: $TEST_STATUS
- Details: All integration tests passed successfully.

Deploy Stage: $DEPLOY_STATUS
- Details: Artifacts successfully deployed to the second virtual machine.

--------------------"

curl -s -m $TIME -d "chat_id=$CHAT_ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null