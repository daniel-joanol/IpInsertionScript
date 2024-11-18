# ip_insertion_script
A console script to create PostgreSQL scripts to insert IPs from Ip2Location .CSV using Dart.

# Objectives
The goal of this project is to create a multi-platform console script to generate PostgreSQLl scripts for inserting IPs.

The intended flow is at follows:

## 1. Console command: ./name data.csv 2 1000
      data.csv is the path to the file with the data.
      2 is the line from the software should start (so if anything happens we don’t need to restart from beginning).
      1000 is the number of rows inserted per generated file.
      If the parameters are empty, the script should ask the user for the values.

## 2. We should provide a previous set of the table schema
      If the table schema is the same as the user wants he can proceed, otherwise we should ask for the field names used in his table.
      Add the new data to a file like (schema_info.txt), so next time we run the script the user doesn’t have to fill the fields again.

## 3. We should print on screen the first command generated
      If its ok than proceed.
      If it’s not then go back to item 2 and update the field names.
  
## 4. Generate sql files
      The scripts should have comments on the first and last line with the row number of csv file. This data is useful for when executing the code again.

