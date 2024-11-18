class SqlTemplate {

  late String idFieldName;
  String? jointKeys;
  String? jointValues;

  SqlTemplate(this.idFieldName);

  final comment = '-- CSV row number: {row_number}\n';
  final insertTemplate = 
      'INSERT INTO {table_name} ({field_names}) SELECT ({field_values}) WHERE NOT EXISTS (SELECT 1 FROM {table_name} WHERE {id_name} = {id_value})';


  String insert({
      required String tableName,
      required Map<String, String> mapTextValuesByFieldName,
      Map<String, double>? mapNumberValuesByFieldName,
      int? rowNumber
  }) {
    _generateJoints(mapTextValuesByFieldName, mapNumberValuesByFieldName);

    String statement = '';
    if (rowNumber != null) {
      statement = _generateComment(rowNumber);
    }
    
    String? idValue = mapTextValuesByFieldName[idFieldName];
    return statement += _generateInsertStatement(tableName, idValue);
  }


  void _generateJoints(Map<String, String> mapTextValuesByFieldName, Map<String, double>? mapNumberValuesByFieldName) {
    bool hasNumbers = mapNumberValuesByFieldName != null && mapNumberValuesByFieldName.isNotEmpty;
    if (hasNumbers) {
      jointKeys = _generateJointVariables(
          mapTextValuesByFieldName.keys.toList(),
          mapNumberValuesByFieldName.keys.toList()
      );
      jointValues = _generateJointVariables(
          mapTextValuesByFieldName.values.toList(),
          mapNumberValuesByFieldName.values.toList()
      );
    } else {
      jointKeys = _generateJointVariables(mapTextValuesByFieldName.keys.toList(), null);
      jointValues = _generateJointVariables(mapTextValuesByFieldName.values.toList(), null);
    }
  }


  String _generateJointVariables(List<String> textValues, List<dynamic>? numberValues) {
    var jointTextValues = textValues.join(',');
    bool hasNumberValues = numberValues != null && numberValues.isNotEmpty;
    if (hasNumberValues) {
      var jointNumberValues = numberValues.join(',');
      return '$jointTextValues, $jointNumberValues';
    } else {
      return jointTextValues;
    }    
  }


  String _generateComment(int rowNumber) {
    Map<String, String> values = {
      'row_number': rowNumber.toString()
    };
    return _format(comment, values);
  }


  String _generateInsertStatement(String tableName, String? idValue) {

    Map<String, dynamic> values = {
      'table_name': tableName,
      'field_names': jointKeys,
      'field_values': jointValues,
      'id_name': idFieldName,
      'id_value': idValue
    };

    return _format(insertTemplate, values);
  }


  String _format(template, Map<String, dynamic> values) {
    return template.replaceAllMapped(RegExp(r'\{\w+\}'), (match) {
      String key = match.group(0)!.replaceAll(RegExp(r'[{}]'), '');
      return values[key] ?? match.group(0)!;
    });
  }

}