#! /bin/bash

# Import dump database in MY SQL and export it from there to Postgres.
# This is needed as the dump file was created for MYSQL and if it is 
# imported directly in Postgres, fails. 
# It is also prefered to worked in Postgres as it supports schemas,
# MYSQL doesnt.

#########################################
#### Get Credentials 
#########################################

# User and Pass for MYSQL and postgres
. users_pass.txt

sqluser=$USERSQL
sqlpass=$PASSWORDSQL
postgresuser=$USERPOSTGRES
postgrespass=$PASSWORDPOSTGRES

#########################################
#### Create database in MYSQL 
#########################################

echo 'Starting script...'

echo 'Connecting to MYSQL...'

# Initate SQL Shell
mysql -u$sqluser -p$sqlpass <<EOF

-- Create database
CREATE database if not exists donaronline_boosted;

-- Import Data into database
USE donaronline_boosted;
source /Users/mac/Documents/Wingu/donaronline/trabajo_final_boosteado/churn_donations/data/sql/donaronline_database.sql

-- Exit SQL shell
exit 
EOF

# Return to root
cd

# Confirm this step is finished
echo 'Import database in SQL - Finished'

##########################################
##### Create empty db in Postgres
##########################################

echo 'Connecting to Postgres...'

Initiate PSQL
PGPASSWORD=$postgrespass psql -U $postgresuser << EOF

-- Create database
CREATE DATABASE donaronline_boosted;
\connect donaronline_boosted;

-- Create schemas
CREATE SCHEMA if not exists cleaned;
CREATE SCHEMA if not exists semantic;

-- Exit PSQL
\q
EOF

# Confirm this step is finished
echo 'Create empty database in Postgres - Finished'

##########################################
##### Migrate DB from MYSQL to Postgres 
##########################################

cd

# From MYSQL to Postgres
pgloader mysql://root:12345678@Localhost/donaronline_boosted pgsql://postgres:123456@Localhost/donaronline_boosted

echo 'DB transfered from MYsql to Postgres - Finished'

##########################################
##### Rename schema in Postgres 
##########################################

# Initiate PSQL
PGPASSWORD=$postgrespass psql -U $postgresuser << EOF
\connect donaronline_boosted;

-- Rename schema
ALTER SCHEMA donaronline_boosted RENAME to raw;
EOF

echo 'Finished'



