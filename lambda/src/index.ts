'use strict';

import * as AWS from 'aws-sdk';
import {APIGatewayEvent, Context, Callback} from 'aws-lambda';
import * as Moment from 'moment';

AWS.config.update({region: 'ap-northeast-1'});

async function getSecretValue(secretName: string) {
  const param = { SecretId: secretName };
  const client = new AWS.SecretsManager();

  // [TODO] Error Case
  const data = await client.getSecretValue(param).promise();
  const binary = data.SecretBinary;
  return 'SecretString' in data
         ? data.SecretString
         : new Buffer(binary as string, 'base64').toString('ascii')
}

export async function handler(
  event: APIGatewayEvent,
  context: Context,
  callback: Callback
) {
  const format='YYYY-MM-DD HH:mm:ss.SSS';
  console.log(Moment().format(format));

  const secretName=`/${process.env.SECRET_NAME}/id`;
  const secret = await getSecretValue(secretName);

  console.log('secret:', secret);
  console.log(Moment().format(format));

  return {};
};
