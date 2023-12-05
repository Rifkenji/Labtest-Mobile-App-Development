import '../Controller/sqlite_db.dart';


class bmicalculate {
  static const String SQLiteTable = "bmi";
  int? id;
  String username;
  double weight;
  double height;
  String gender;
  String bmi_status;
  bmicalculate (this.username, this.weight, this.height, this.gender, this.bmi_status);

  bmicalculate.fromJson(Map<String, dynamic> json)
      : username = json['username'] as String,
        weight = double.parse(json['weight'] as dynamic),
        height = double.parse(json['height'] as dynamic),
        gender = json['gender'] as String,
        bmi_status = json['bmi_status'] as String,
        id = json['id'] as int?;

  Map<String, dynamic> toJson() =>
      {'username': username, 'weight': weight, 'height': height, 'gender': gender, 'bmi_status': bmi_status};

  //add save
  Future<bool> save() async {
    // Save to local SQLite
    int result = await SQLiteDB().insert(SQLiteTable, toJson());
    if (result != 0) {
      return true;
    } else {
      return false;
    }
    }

}