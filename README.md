
# Setting Enviroment

## Java

    JAVA_HOME environment variable (must be java 8 or greater)
    
## Spark framework
    SPARK_HOME (must be 3x)

## Start application by running:
    ./run.sh start

## Initialize Hive metastore
    ./run.sh hiveInit

    Use docker exec command to login into the mysql container
    docker exec -it mysqld /bin/bash

    login to mysql database use the MYSQL_ROOT_PASSWORD from docker compose
    mysql -u root -p 

## Create the hive `metastore` database
~~~
mysql> CREATE DATABASE `metastore`;
~~~

## Grant the `dataeng` user access to the `metastore` db

`It is worth noting that you can also create new users who have specific access to only a few tables, or all tables, or only read or write access. This allows you to govern the database access using privileges bound to a users grant permissions.`

~~~
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'dataeng'@'%';
GRANT ALL PRIVILEGES ON `default`.* TO 'dataeng'@'%';
GRANT ALL PRIVILEGES ON `metastore`.* TO 'dataeng'@'%';
FLUSH PRIVILEGES;
~~~

### Exit as the `root` user
~~~
mysql> exit
~~~

### Authenticate as the `dataeng` user
~~~
mysql -u dataeng -p
~~~

### Switch Databases to the `metastore`
~~~
mysql> use metastore;
~~~

### Import the Hive Metastore Tables
Use the MySQL `SOURCE` command to read in the hive 2.3.0 schema
This is the file that you copied using `docker cp`.
~~~
mysql> SOURCE /hive-schema-2.3.0.mysql.sql;
~~~

Now you will be able to use the Hive Metastore.

### Check the Tables
From the mysql commandline `mysql>`. Run the following.
~~~
use metastore;
show tables;
~~~    

# Setup Airflow

## Initial Setup Work
You must run this `once` before you can get started. This is the initial bootstrap process. This process will download all of the required Docker container images, and run the initialization sequence required to run Airflow.

~~~

~~~

./run.sh airflowInit
~~~

~~~

## Running Basic Airflow

**Build the Local Airflow Environment with Spark Providers and Java11**
~~~
~~~

./run.sh buildAirflow
~~~

~~~


Update your `.env` to include the

~~~
echo -e "AIRFLOW_IMAGE_NAME=newfrontdocker/apache-airflow-spark:2.1.0" >> .env
echo -e "SPARK_HOME=${SPARK_HOME}" >> .env
echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" > .env
~~~