#!/usr/bin/env bash -ex

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-west-2}
IMAGE_REPO=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com


if [ ! -f ~/.aws/models/ecr-public/2020-10-30/service-2.json ]
then
    aws configure add-model \
      --service-model file://ecr-public-2020-10-30.api.json \
      --service-name ecr-public

    aws iam create-policy \
      --policy-name ECRPublicAccess \
      --policy-document file://ecr-public-policy.json
fi

#aws --region us-east-1 ecr-public get-authorization-token --output=text \
#      --query 'authorizationData.authorizationToken' \
#      | base64 --decode \
#      | cut -d: -f2 \
#      | tee /dev/tty \
#      | docker --debug -l debug login -u AWS --password-stdin ${IMAGE_REPO}

aws --region us-east-1 ecr-public create-repository --repository-name eks-distro/base

aws --region us-east-1 ecr-public describe-registries
