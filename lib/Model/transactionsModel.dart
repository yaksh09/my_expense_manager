class TransactionModel {
  int? id;
  int? user_id;
  String? title;
  double? amount;
  String? transaction_type;
  String? date;

  TransactionModel(
      this.user_id, this.title, this.amount, this.transaction_type, this.date,
      {this.id});

  TransactionModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    user_id = map['user_id'];
    title = map['title'];
    amount = map['amount'];
    transaction_type = map['transaction_type'];
    date = map['date'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    // if (id != null) {
    map = <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'title': title,
      'amount': amount,
      'transaction_type': transaction_type,
      'date': date
    };

    // } else {
    //   map = <String, dynamic>{
    //     'user_id': user_id,
    //     'title': title,
    //     'amount': amount,
    //     'transaction_type': transaction_type,
    //     'date': date
    //   };
    // }
    //
    // if (user_id != null) {
    //   map['user_id'] = user_id;
    // }

    return map;
  }
}
