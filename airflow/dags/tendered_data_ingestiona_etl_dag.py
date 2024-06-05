from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

from airflow.models import DAG, Variable

from airflow.utils.dates import days_ago

args = {
    "owner": "shah"
}

spark_home = Variable.get("SPARK_HOME")

data_config = {
    "spark.data.extractor.sourceFile": f"{spark_home}/user_jars/IOT-temp.csv",
    "spark.data.extractor.destination.table": "tendered_data",
    "spark.data.extractor.save.mode": "Append",
    "spark.data.extractor.database.url": "jdbc:mysql://mysqld:3306/default",
    "spark.data.extractor.database.driver": "com.mysql.cj.jdbc.Driver",
    "spark.data.extractor.database.user": "dataeng",
    "spark.data.extractor.database.db_password": "dataengineering_user"
}

app_jars=f'{spark_home}/user_jars/mariadb-java-client-2.7.2.jar,{spark_home}/user_jars/mysql-connector-java-8.0.23.jar'
driver_class_path=f'{spark_home}/user_jars/mariadb-java-client-2.7.2.jar:{spark_home}/user_jars/mysql-connector-java-8.0.23.jar'

with DAG(
    dag_id="tendered_data_ingestion_etl_dag",
    default_args=args,
    schedule_interval='@daily',
    start_date=days_ago(1),
    tags=["tendered", "data"]
) as dag:
    etl_job = SparkSubmitOperator(
        application=f'{spark_home}/user_jars/tendered-data-extractor-assembly-0.1-SNAPSHOT.jar',
        jars=app_jars,
        driver_class_path=driver_class_path,
        conf=data_config,
        conn_id="local_spark_connection",
        name="tendered-data-ingestion",
        verbose=True,
        java_class="com.tendered.data.TenderedDataExtractorApp",
        status_poll_interval='20',
        task_id="tendered_data_ingestion_etl_job"
    )