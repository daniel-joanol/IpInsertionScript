class SqlTemplate {

  late String idFieldName;
  String? jointKeys;
  String? jointValues;

  SqlTemplate(this.idFieldName);

  final comment = '-- CSV row number: {row_number}\n';
  final insertTemplate = 
      'INSERT INTO {table_name} ({field_names}) SELECT ({field_values}) WHERE NOT EXISTS (SELECT 1 FROM {table_name} WHERE {id_name} = {id_value})';


  String insert({required String tableName,
      required Map<String, String> mapTextValuesByFieldName,
      Map<String, double>? mapNumberValuesByFieldName,
      int? rowNumber
  }) {
    _generateJoints(
        mapTextValuesByFieldName: mapTextValuesByFieldName,
        mapNumberValuesByFieldName: mapNumberValuesByFieldName);

    String statement = '';
    if (rowNumber != null) {
      statement = _generate_comment(rowNumber);
    }
    
    String? idValue = mapTextValuesByFieldName[idFieldName];
    return statement += _generate_insert_statement(tableName, idValue);
  }


  void _generateJoints({required Map<String, String> mapTextValuesByFieldName, Map<String, double>? mapNumberValuesByFieldName}) {
    bool hasNumbers = mapNumberValuesByFieldName != null && mapNumberValuesByFieldName.isNotEmpty;
    if (hasNumbers) {
      jointKeys = _generateJointVariables(
          textValues: mapTextValuesByFieldName.keys.toList(),
          numberValues:  mapNumberValuesByFieldName.keys.toList()
      );
      jointValues = _generateJointVariables(
          textValues: mapTextValuesByFieldName.values.toList(),
          numberValues: mapNumberValuesByFieldName.values.toList()
      );
    } else {
      jointKeys = _generateJointVariables(
          textValues: mapTextValuesByFieldName.keys.toList()
      );
      jointValues = _generateJointVariables(
          textValues: mapTextValuesByFieldName.values.toList()
      );
    }
  }


  String _generateJointVariables({required List<String> textValues, List<dynamic>? numberValues}) {
    var jointTextValues = textValues.join(',');
    bool hasNumberValues = numberValues != null && !numberValues.isEmpty;
    if (hasNumberValues) {
      var jointNumberValues = numberValues.join(',');
      return '$jointTextValues, $jointNumberValues';
    } else {
      return jointTextValues;
    }    
  }


  String _generate_comment(int rowNumber) {
    Map<String, String> values = {
      'row_number': rowNumber.toString()
    };
    return _format(template: comment, values: values);
  }


  String _generate_insert_statement(String tableName, String? idValue) {

    Map<String, dynamic> values = {
      'table_name': tableName,
      'field_names': jointKeys,
      'field_values': jointValues,
      'id_name': idFieldName,
      'id_value': idValue
    };

    return _format(template: insertTemplate, values: values);
  }
  

  String _format({required String template, required Map<String, dynamic> values}) {
    return template.replaceAllMapped(RegExp(r'\{\w+\}'), (match) {
      String key = match.group(0)!.replaceAll(RegExp(r'[{}]'), '');
      return values[key] ?? match.group(0)!;
    });
  }

}