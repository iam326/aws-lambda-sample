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
cp ${LAMBDA_DIR}/yarn.lock ${LAYER_PATH}
yarn --cwd ${LAYER_PATH} install --production

cd ${LAMBDA_DIR}
npx tsc src/index.ts
cd ..

sam package \
  --template-file ${SRC_TEMPLATE} \
  --output-template-file ${DST_TEMPLATE} \
  --force-upload \
  --s3-bucket ${BUCKETNAME}

sam deploy \
  --template-file ${DST_TEMPLATE} \
  --stack-name ${STACKNAME} \
  --force-upload \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    NamePrefix=${PREFIX}

rm ./lambda/packaged.yaml
