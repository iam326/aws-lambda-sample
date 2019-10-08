#!/bin/bash

set -euo pipefail

readonly PREFIX="sample-secrets-manager"

readonly LAMBDA_DIR="./lambda"
readonly LAYER_PATH="${LAMBDA_DIR}/dependencies/nodejs"
readonly SRC_TEMPLATE="${LAMBDA_DIR}/template.yaml"
readonly DST_TEMPLATE="${LAMBDA_DIR}/packaged.yaml"
readonly BUCKETNAME="${PREFIX}-artifict"
readonly STACKNAME="${PREFIX}-lambda"

mkdir -p ${LAYER_PATH}
cp ${LAMBDA_DIR}/package.json ${LAYER_PATH}
cp ${LAMBDA_DIR}/package-lock.json ${LAYER_PATH}
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
