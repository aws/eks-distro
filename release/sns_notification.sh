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
#
#
# HOW TO USE
# - Prerequisites
#   + The machine running the script must have the credentials needed to use your AWS account.
#   + An intended release branch, which you must provide for the required argument RELEASE_BRANCH. This value must be in
#     the expected format of "X-XX" (e.g. "1-19").
#   + An SNS topic you wish publish the notification to. The default topic name is the value assigned to SNS_TOPIC_NAME,
#     but you can override this if you choose. The topic must already exist, and you must have permission to list topics
#     and publish to the intended topic. Presumably, you should also have at least one subscriber. See official SNS docs:
#     https://docs.aws.amazon.com/sns/latest/dg/sns-configuring.html
#   + File paths must exist as expected, especially those that include directories named RELEASE_BRANCH.
#   + A file named 'RELEASE' found at the script-determined RELEASE_NUMBER_PATH. This file must contain only the release
#     number (e.g. "2" for 1.19.2).
#   + A file named release-announcement.txt found at the script-determined NOTIFICATION_BODY_PATH. This file must contain
#     the intended body of the SNS message.
# - Run ./sns_notification.sh <release branch> <OPTIONAL:SNS topic name> (e.g. $ ./sns_notification.sh 1-19 my-sns-topic)
# - When prompted to confirm that you wish to publish, review the provided notification preview, as this is your only
#   chance to check what is about to be sent to all subscribers. If all the information looks correct and you wish to
#   publish to the SNS topic, enter the requested response to confirm. All non-matching input results in exiting without
#   sending the notification.
# - If the response received from SNS did not indicate there was an error, you will be provided the MessageID.

ANNOUNCEMNT_FILE="${1?First required argument is release branch, e.g. 1-19}"
SNS_TOPIC_ARN="${2?Second required argument is SNS topic ARN}"

BASE_DIRECTORY="$(git rev-parse --show-toplevel)"

# Prints error message about failing to publish notification and then exits. Intended for when it is certain that the
# notification was not published. The 1st argument should be details about what went wrong.
fail_without_sending() {
  echo "Failed to publish release notification: ${1}"
  exit 1
}

# Get release number
RELEASE_NUMBER_PATH="${BASE_DIRECTORY}/release/${RELEASE_BRANCH}/RELEASE"
if ! [ -s "$RELEASE_NUMBER_PATH" ]; then
 fail_without_sending "Release number expected at ${RELEASE_NUMBER_PATH}"
fi
RELEASE_NUMBER=$(<"${RELEASE_NUMBER_PATH}")

# Get release notification subject
NOTIFICATION_SUBJECT="EKS-D v${RELEASE_BRANCH/-/.}.${RELEASE_NUMBER} Release" # e.g. "EKS-D v1.19.2 Release"

# Get release notification body
NOTIFICATION_BODY_PATH="${BASE_DIRECTORY}/docs/contents/releases/${RELEASE_BRANCH}/${RELEASE_NUMBER}/release-announcement.txt"
if ! [ -s "$NOTIFICATION_BODY_PATH" ]; then
  fail_without_sending "Non-empty text for notification body expected at ${NOTIFICATION_BODY_PATH}"
fi
NOTIFICATION_BODY=$(<"${NOTIFICATION_BODY_PATH}")

## Get SNS topic ARN
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?ends_with(TopicArn,':$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)
if [ -z "$SNS_TOPIC_ARN" ]; then
  fail_without_sending "Encountered error when trying to get the ARN for SNS topic '${SNS_TOPIC_NAME}'"
elif [ "$SNS_TOPIC_ARN" == "None" ]; then
  fail_without_sending "Unable to find SNS topic '${SNS_TOPIC_NAME}'"
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
  echo "Received unexpected response while publishing to SNS topic. An error may have occurred, and the notification \
may not have not have been published"
  exit 1
fi
