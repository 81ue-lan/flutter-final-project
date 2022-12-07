import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "expense-manager-370905",
  "private_key_id": "8beba571d27b9885e4ec8328dd9830ce4f47a4d4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8VPIHn8CLy040\n7JlUSyurAZkQjVev729KGj7FhHf4f+1Uq/vWM7djYn5qdIj26gS2KI8RS8qDIbsS\nxXq6/l2m4OzzdL48Z/9vy8d6tmFE02t3k1G8iJQrRqiYo12DW1rseT56pk0oA5SN\ng21WSdA1sAiK5MHag2yN8Bu18aEqlU4fMfwKJysut7fxFxrx37ba/ODa0er0n/QJ\nCzDysmBsahH7dybU7pFoz4pwftiJzfFLu29Px+0+2aGeet3AYyLDrznyNWU64K8m\nmJbaMMzg7+vuwtYmv934xggPO/oqWBsMppyiGmTB6BDnZ3SvPmebFTABEcHhcdRR\nwQR4q70tAgMBAAECggEAIJYEEKykCKwjOoYLm6msAxkyLkp+dxsTIvu6i7t5dJ5R\n5rohR3VIUGJs5CeIwUxJh2kqJAB8qEbQUxWnQC6d7q9xYEh9V/9Yk7PrLoDbAKki\nKZzsYhYxqPE/X7W4iu9mIo9x74/RvtArxnaMlwcLhxaPy9R79D6ULFT0vnzx+Wdy\na58y8bZXjHBy/fxAxup3sEsk/qxFCpdBI+7Cz89QcT3AegJVZ5o03pl7+pCv7O3j\nw+kd9Jq0VMRUm30oX2OgZm2MmsVp3I7R9iRdVaKboOfyzSBgiTKpWRyEghoM1egM\nBLRrKtTbSlp+YJ6fUNbZzJsdmaE/quJGYTsDfjNhoQKBgQD6RTcTJAxib+5ZDtck\nK+PPFvDMchCUde1j+R8uENWtwJoaKrf1jYsw9kXPl29sCuUnx3qgd6eZCjK4Er22\nUywzb/0mdAKh9pTpAdzBD61f+kEka9sIOq2dqVW+TJqNfeqP+uRRrywkInPmbhJD\n2uglPcrJJe636WDyXD+QYFpJnQKBgQDApLiDLHHgVK3/tH6BNI402HLFbm1W1jH5\n58LzjTXyPmephwSgdKC9IyoNHREJx56NlPwOUqRx4eVtjTBlZYQmPeCJZmFYYa+P\nLAHSM5VJznT909BMlTSzebFK+gfXeznszmev5ERdmwuITu9lsSBBIo+r40GfZW+6\nxFw4gDz00QKBgQCAAztijQPQrhQqdY7SL6j82m0dBhM4/QEKK/ko5O+HSocIb2Vd\nMqNJzg5zWrBhgUkpib1NqyaM/0xmHx/uzKhFPzkrnBdkpO4SKSOzlMNH3ofHi2uj\nz+/SPzVee2xqh0edkeWLaqCXcw/5g7/P+X7Y3byGGuL6K2OtVEYnIUHNeQKBgBVu\nfeSB/k1BvnXTI7vGGAgDCIm0Zk+h1r+BrCuiSx0fGjM/BSHAt90y20vILwwSfC4u\nI/iH8ymEQxzz9y1gpNoISkGe9Td67qgT8kPrXzFt2ZAfj23lr45D/JhlxpePavtQ\nXzKvR3fOdvL8LR/4G6mDac5qovNTuqFhlQzoH1/xAoGAQmflkRh+PnNMSs/ufN2n\njG4pC+Gu9z19zEmkBzcWbLNchgfgP9tfpZQEhl/IIj7mQq/JpJwHOAak2Xzwg9cB\n4N5eNaU+HhCbuxC8An/YeVlgkPQoQsuLaaqLHqlAMsOrTj3Jh0R69Baliz1RfNMa\n+6rXwCwEJJ0kt86RwfBdwBM=\n-----END PRIVATE KEY-----\n",
  "client_email": "expense-manager@expense-manager-370905.iam.gserviceaccount.com",
  "client_id": "103513558477478110462",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expense-manager%40expense-manager-370905.iam.gserviceaccount.com"
}
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '15je6QIjVYcj7uEagK3EEQx0flpUnvlMUC86zOmBy9Tc';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;


  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }


  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    loadTransactions();
  }

  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // 計算總收益
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // 計算總支出
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
