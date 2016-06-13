#!/bin/bash
# Use as ./sql_scrub_dump.sh local_db_user local_db_pass dump_file.gz
# Creates a scrubbed version of a database dump using the local database defined below as the intermediary.
# note: the dump file will be gzip compressed, as will the resulting file.

local_db=6000_temp_scrub

function db_query() {
    sql=${1}
    mysql -u${local_user} -p${local_pass} -e "$sql" ${local_db}
}

local_user=${1}
local_pass=${2}
dump_file=${3}
new_dump_file=scrubbed-${3}

mysql -u${1} -p${2} -e "DROP DATABASE IF EXISTS $local_db"
mysql -u${1} -p${2} -e "CREATE DATABASE $local_db"
gunzip -c $dump_file | mysql -u${1} -p${2} $local_db

mysql -u${1} -p${2} $local_db < scrub.sql
mysql -u${1} -p${2} $local_db < live_to_dev_scrub.sql

# Here we make sure that all the tables are InnoDB.

mysql -u${1} -p${2} -e "SHOW TABLES" $local_db \
  | grep --invert-match '^Tables' \
  | sed -e 's/\(.*\)/ALTER TABLE `\1` ENGINE = innodb;/' \
  | mysql -u${1} -p${2} $local_db

# Dump the scrubbed version and drop the temporary DB.

mysqldump -u${1} -p${2} $local_db | gzip > $new_dump_file
mysql -u${1} -p${2} -e "DROP DATABASE IF EXISTS $local_db"
