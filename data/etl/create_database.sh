#! /bin/bash

#########################################
#### Get Credentials 
#########################################

# User and Pass for MYSQL
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
source /Users/mac/Documents/donaronline_database.sql

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

User and Pass for MYSQL
. users_pass.txt

echo 'Connecting to MYSQL...'

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



