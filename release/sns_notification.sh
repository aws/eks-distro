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

RELEASE_BRANCH="${1?First required argument is release branch, e.g. 1-18}"
SNS_TOPIC_NAME="${2:-"eks-distro-updates"}"
NOTIFICATION_BODY_FILE_NAME="release-announcement.txt"

# Get release directory
RELEASE_BRANCH_DIRECTORY="$(git rev-parse --show-toplevel)/release/${RELEASE_BRANCH}"

# Get release notification body
NOTIFICATION_BODY_FILE_PATH="${RELEASE_BRANCH_DIRECTORY}/${NOTIFICATION_BODY_FILE_NAME}"
if ! [ -s "$NOTIFICATION_BODY_FILE_PATH" ]; then
  echo "Non-empty text for notification message body expected at ${NOTIFICATION_BODY_FILE_PATH}"
  exit 1
fi
NOTIFICATION_BODY=$(<"${NOTIFICATION_BODY_FILE_PATH}")

# Get release notification subject
RELEASE_NUMBER_PATH="${RELEASE_BRANCH_DIRECTORY}/RELEASE"
if ! [ -s "$RELEASE_NUMBER_PATH" ]; then
  echo "Release number expected at ${RELEASE_NUMBER_PATH}"
  exit 1
fi
NOTIFICATION_SUBJECT="EKS-D v${RELEASE_BRANCH/-/.}.$(<"${RELEASE_NUMBER_PATH}") Release" # e.g. EKS-D v1.18.0 Release

## Get SNS topic ARN
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?ends_with(TopicArn,':$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)
if [ "$SNS_TOPIC_ARN" == "None" ]; then
  echo "Failed to send SNS notification because unable to find SNS topic'${SNS_TOPIC_NAME}'"
  exit 1
elif [ -z "$SNS_TOPIC_ARN" ]; then
  echo "Failed to send SNS notification due to error when trying to get the SNS topic ARN for topic '${SNS_TOPIC_NAME}'"
  exit 1
fi

# Confirm release notification details
read -r -p "
A notification with the below details will be immediately published to ALL eligible subscribers. It cannot be unsent.

    - Topic ARN: $SNS_TOPIC_ARN
    - Subject: $NOTIFICATION_SUBJECT
    - Body: $NOTIFICATION_BODY

Are you sure you want to send this notification? Enter 'publish' to confirm: " confirmation_response

if [ "$confirmation_response" != "publish" ]; then
  echo -e "\nExited without publishing the notification"
  exit 0
fi

# Publish release notification
SNS_MESSAGE_ID=$(
  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --subject "$NOTIFICATION_SUBJECT" \
    --message "$NOTIFICATION_BODY" \
    --query "MessageId" --output text
)
echo

if [ "$SNS_MESSAGE_ID" ]; then
  echo "Release notification published with SNS MessageId $SNS_MESSAGE_ID"
else
  echo "Revived unexpected response while publishing to SNS topic. An error may have occurred, and the notification \
may not have not have been published"
  exit 1
fi
