#!/bin/bash

set -euo pipefail

readonly PREFIX="sample-secrets-manager"

readonly TEMPLATE="`pwd`/setup/template.yaml"
readonly BUCKETNAME="${PREFIX}-artifict"
readonly STACKNAME="${PREFIX}-lambda"

sam package \
  --template-file ./lambda/template.yaml \
  --output-template-file ./lambda/packaged.yaml \
  --s3-bucket ${BUCKETNAME}

sam deploy \
  --template-file ./lambda/packaged.yaml \
  --stack-name ${STACKNAME} \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    NamePrefix=${PREFIX}

rm ./lambda/packaged.yaml
