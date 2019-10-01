'use strict';

const AWS = require('aws-sdk');
AWS.config.update({region: 'ap-northeast-1'});

async function getSecretValue(secretName) {
  const param = { SecretId: secretName };
  const client = new AWS.SecretsManager();

  // [TODO] Error Case
  const data = await client.getSecretValue(param).promise();
  return 'SecretString' in data
         ? data.SecretString
         : new Buffer(data.SecretBinary, 'base64').toString('ascii')
}

exports.handler = async (event, context) => {
  const secretName=`/${process.env.SECRET_NAME}/id`;
  const secret = await getSecretValue(secretName);

  console.log('secret:', secret);

  return {};
};
