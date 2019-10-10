const AWS = require('aws-sdk');
const ENV = 'sample-secrets-manager';
const region = 'ap-northeast-1';

AWS.config.update({region});

DocClient = new AWS.DynamoDB.DocumentClient({region});

class DynamoDocClientWrapper {

  constructor(region, table_name) {
    this.table_name = table_name;
  }

  getTableName() {
    return this.table_name;
  }

  async get(key, value) {
    return DocClient.get({
      TableName: this.getTableName(),
      Key: {
        [key]: value
      }
    }).promise();
  }

  put(item) {
    return DocClient.put({
      TableName: this.getTableName(),
      Item: item
    }).promise();
  }

  delete(key, value) {
    return DocClient.delete({
      TableName: this.getTableName(),
      Key: {
        [key]: value
      }
    }).promise();
  }

  static transactWrite(puts) {
    const params = {};
    params.TransactItems = puts.map(put => { 
      return { 
        Put: put
      }
    });
    return DocClient.transactWrite(params).promise();
  }

  static transactGet(gets) {
    const params = {};
    params.TransactItems = gets.map(get => { 
      return { 
        Get: get
      }
    });

    return DocClient.transactGet(params).promise();
  }

}

(async () => {

  const item = {
    CompanyId: 2,
    CompanyName: 'hogehoge',
    Tel: '1234567890'
  };

  const table = new DynamoDocClientWrapper(region, `${ENV}-Companies`);
  
  /*
  table.put(item).then((err, data) => {
    console.log(err, data);
    table.get('CompanyId', item.CompanyId).then((err, data) => {
      console.log(err, data);
      table.delete('CompanyId', item.CompanyId).then((err, data) => {
        console.log(err, data);
      });
    });
  });
  */

  const putA = {
    TableName: `${ENV}-Companies`,
    Item: {
      CompanyId: 3,
      CompanyName: 'TransactWrite',
      Tel: '1234567890'
    }
  };
  const putB = {
    TableName: `${ENV}-Employees`,
    Item: {
      CompanyId: 3,
      EmployeeId: 1,
      EmployeeName: 'takahashi',
      Age: 25
    }
  };

  DynamoDocClientWrapper.transactWrite([putA, putB]).then((err, data) => {
    console.log(err, data);
  });


  const getA = {
    TableName: `${ENV}-Companies`,
    Key: {
      CompanyId: 3
    }
  };

  const getB = {
    TableName: `${ENV}-Employees`,
    Key: {
      CompanyId: 3,
      EmployeeId: 1
    }
  };

  DynamoDocClientWrapper.transactGet([getA, getB]).then(data => {
    return console.log(data.Responses);
  })
  .catch(err => {
    console.log(err);
  });

})();

