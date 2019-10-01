#!/bin/bash

set -euo pipefail

readonly PREFIX="sample-secrets-manager"

readonly TEMPLATE="`pwd`/setup/template.yaml"
readonly STACKNAME="${PREFIX}-setup"

aws cloudformation validate-template \
  --template-body "file://${TEMPLATE}"

aws cloudformation deploy \
  --stack-name ${STACKNAME} \
  --template-file ${TEMPLATE} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    NamePrefix=${PREFIX}
