#!/bin/bash

# Values to modify
###########################################################
# Database type: mysql, tidb, or sdb (singlestoredb)
dbtype=tidb
###########################################################
# IP address of the database server
new_ip='127.0.0.1'
new_port=4000
new_dbname=web3bench
# Notice: add \ before & in the jdbc url
new_dburl="jdbc:mysql://$new_ip:$new_port/$new_dbname?useSSL=false\&amp;characterEncoding=utf-8"
new_username=root
new_password=
new_nodeid="main"
new_scalefactor=6000
# Test time in minutes
new_time=60
# terminals and rate for runthread1: R1, W1* and W4
new_terminals_thread1=30
# Total number of requests in one hour for R1 = 1000 * 6000 = 6000000
# then total rate per minute of thread1 = 1000 * 6000 / 80% / 60 = 1000 * 6000 / 48 = 125000
new_rate_thread1=125000
# terminals and rate for R2*
new_terminals_R21=2
new_terminals_R22=2
new_terminals_R23=2
new_terminals_R24=2
new_terminals_R25=2
# Total number of requests per minute
# R21, R22, R23 = 10 * 6000 / 60 = 1000
new_rate_R21=1000
new_rate_R22=1000
new_rate_R23=1000
# R24, R25 = 6000 / 6 / 60 = 16
new_rate_R24=16
new_rate_R25=16
###########################################################

# Create ~/mysql.cnf file
mysql_config_file=~/mysql.cnf
echo "[client]" > $mysql_config_file
echo "user=$new_username" >> $mysql_config_file
echo "password=$new_password" >> $mysql_config_file

set -e

# Create database
echo "Creating database $new_dbname if not exists"
mysql --defaults-extra-file=$mysql_config_file -h $new_ip -P $new_port -e "CREATE DATABASE IF NOT EXISTS $new_dbname;"

# When using TiDB
if [ $dbtype == "tidb" ] ; then
    # Set tidb_skip_isolation_level_check=1 to disable the isolation level check.
    echo -e "\nTest on TiDB."
    echo -e "\tSetting tidb_skip_isolation_level_check=1"
    mysql --defaults-extra-file=$mysql_config_file -h $new_ip -P $new_port -e "SET GLOBAL tidb_skip_isolation_level_check=1;"
fi

# Delete $mysql_config_file file
rm $mysql_config_file

# List of files to process
files=("loaddata.xml" 
        "runR21.xml" 
        "runR22.xml" 
        "runR23.xml" 
        "runR24.xml" 
        "runR25.xml" 
        "runthread1.xml" 
        "runthread2.xml"
)

# Modify config files
# Check the operating system
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    SED_INPLACE_OPTION="-i ''"
else
    # Linux or other Unix-like OS
    SED_INPLACE_OPTION="-i"
fi

echo -e "\nModifying config files with new values"
echo "###########################################################"
echo "DB type: $dbtype"
echo "New DBUrl: $new_dburl"
echo "New username: $new_username"
if [ "$new_password" == "" ]; then
    echo "New password: empty"
else
    echo "New password: $new_password"
fi
echo "New nodeid: $new_nodeid"
echo "New scalefactor: $new_scalefactor"
echo "New test time: $new_time"
echo "New terminals for runthread1: $new_terminals_thread1"
echo "New rate for runthread1 per minute: $new_rate_thread1"
echo "New terminals for runR21: $new_terminals_R21"
echo "New rate for runR21 per minute: $new_rate_R21"
echo "New terminals for runR22: $new_terminals_R22"
echo "New rate for runR22 per minute: $new_rate_R22"
echo "New terminals for runR23: $new_terminals_R23"
echo "New rate for runR23 per minute: $new_rate_R23"
echo "New terminals for runR24: $new_terminals_R24"
echo "New rate for runR24 per minute: $new_rate_R24"
echo "New terminals for runR25: $new_terminals_R25"
echo "New rate for runR25 per minute: $new_rate_R25"
echo "###########################################################"

for file in "${files[@]}"; do
    if [ -f "../config/$file" ]; then
        sed $SED_INPLACE_OPTION "s#<dbtype>.*</dbtype>#<dbtype>$dbtype</dbtype>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<DBUrl>.*</DBUrl>#<DBUrl>$new_dburl</DBUrl>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<username>.*</username>#<username>$new_username</username>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<password>.*</password>#<password>$new_password</password>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<nodeid>.*</nodeid>#<nodeid>$new_nodeid</nodeid>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<scalefactor>.*</scalefactor>#<scalefactor>$new_scalefactor</scalefactor>#g" "../config/$file"
        sed $SED_INPLACE_OPTION "s#<time>.*</time>#<time>$new_time</time>#g" "../config/$file"
        if [ $file == "runthread1.xml" ]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_thread1</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_thread1</rate>#g" "../config/$file"
        elif [[ $file == "runR21.xml" ]]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_R21</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_R21</rate>#g" "../config/$file"
        elif [[ $file == "runR22.xml" ]]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_R22</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_R22</rate>#g" "../config/$file"
        elif [[ $file == "runR23.xml" ]]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_R23</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_R23</rate>#g" "../config/$file"
        elif [[ $file == "runR24.xml" ]]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_R24</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_R24</rate>#g" "../config/$file"
        elif [[ $file == "runR25.xml" ]]; then
            sed $SED_INPLACE_OPTION "s#<terminals>.*</terminals>#<terminals>$new_terminals_R25</terminals>#g" "../config/$file"
            sed $SED_INPLACE_OPTION "s#<rate>.*</rate>#<rate>$new_rate_R25</rate>#g" "../config/$file"
        fi
        rm -f ../config/$file\'\'
        echo -e "\tFile $file modified"
    else
        echo -e "\tFile $file doesn't exist"
    fi
done

echo "All config files modified"

set +e
