#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ANNOUNCEMENT_FILE="${1?First required argument is file path (from base directory) for announcement message}"
SNS_TOPIC_ARN="${2?Second required argument is SNS topic ARN}"

# Get release notification subject
RELEASE_NUMBER=$(echo "${ANNOUNCEMENT_FILE}" | grep -o -E "[[:digit:]]{1}\-[[:digit:]]{2}") # e.g. 1-19
if [ -z "$RELEASE_NUMBER" ]; then
  echo "Failed to publish release notification: Unable to generate release number for notification subject"
  exit 1
fi
NOTIFICATION_SUBJECT="New Release of EKS-D v$RELEASE_NUMBER"

# Get release notification body
if ! [ -s "$ANNOUNCEMENT_FILE" ]; then
  echo "Failed to publish release notification: Non-empty text for notification body expected at ${ANNOUNCEMENT_FILE}"
  exit 1
fi
NOTIFICATION_BODY=$(<"${ANNOUNCEMENT_FILE}")

# Publish release notification
echo "
Sending SNS message with the following details:
    - Topic ARN: $SNS_TOPIC_ARN
    - Subject: $NOTIFICATION_SUBJECT
    - Body: $NOTIFICATION_BODY"

SNS_MESSAGE_ID=$(
  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --subject "$NOTIFICATION_SUBJECT" \
    --message "$NOTIFICATION_BODY" \
    --query "MessageId" --output text
)

if [ "$SNS_MESSAGE_ID" ]; then
  echo -e "\nRelease notification published with SNS MessageId $SNS_MESSAGE_ID"
else
  echo "Received unexpected response while publishing to release SNS topic. An error may have occurred, and the \
notification may not have been published"
  exit 1
fi
