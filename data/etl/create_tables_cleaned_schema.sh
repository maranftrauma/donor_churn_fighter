#! /bin/bash

########################################
### Get Credentials 
########################################

# User and Pass for Postgres 
. users_pass.txt

postgresuser=$USERPOSTGRES
postgrespass=$PASSWORDPOSTGRES

echo Creating tables inside cleaned schema...

########################################
### PSQL
########################################

# Initiate PSQL
PGPASSWORD=$postgrespass psql -U $postgresuser << EOF
\connect donaronline_boosted;

\i /Users/mac/Documents/Wingu/donaronline/trabajo_final_boosteado/churn_donations/data/etl/sql/create_tables_cleaned_schema.sql

EOF

echo Tables in cleaned schema created - finished

########################################
### MYSQL
########################################




