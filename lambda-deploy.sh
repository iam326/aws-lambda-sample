#!/bin/bash

set -euo pipefail

readonly PREFIX="sample-secrets-manager"

readonly LAYER_PATH="./lambda/layer_modules"
readonly LAMBDA_SRC_PATH="./lambda/src"
readonly SRC_TEMPLATE="./lambda/template.yaml"
readonly DST_TEMPLATE="./lambda/packaged.yaml"
readonly BUCKETNAME="${PREFIX}-artifict"
readonly STACKNAME="${PREFIX}-lambda"

mkdir -p ${LAYER_PATH}
cp ${LAMBDA_SRC_PATH}/package.json ${LAYER_PATH}
cp ${LAMBDA_SRC_PATH}/package-lock.json ${LAYER_PATH}
npm install --production --prefix ${LAYER_PATH}

sam package \
  --template-file ${SRC_TEMPLATE} \
  --output-template-file ${DST_TEMPLATE} \
  --s3-bucket ${BUCKETNAME}

sam deploy \
  --template-file ${DST_TEMPLATE} \
  --stack-name ${STACKNAME} \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    NamePrefix=${PREFIX}

rm ./lambda/packaged.yaml
