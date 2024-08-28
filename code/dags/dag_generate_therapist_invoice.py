# Used the following DAG as a template:
# https://airflow.apache.org/docs/apache-airflow-providers-microsoft-mssql/stable/operators.html

import os
import datetime
#import pytest

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.sensors.filesystem import FileSensor

DAG_ID = "generate_therapist_invoice"


with DAG(
	DAG_ID,
	schedule="@daily",
	start_date=datetime.datetime(2024, 8, 18),
	tags=["flourish"],
	catchup=False,
) as dag:
	
	detect_session_data = FileSensor(
		task_id = "wait_for_session_data",
		fs_conn_id = "fs_flourish_staging",
		filepath = "Therapist_Session_Export_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]_to_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9].csv",
		poke_interval = 30,
		timeout = 60 * 30,
		mode = "poke"
	)
	
	detect_payment_data = FileSensor(
		task_id = "wait_for_payment_data",
		fs_conn_id = "fs_flourish_staging",
		filepath = "Therapist_Payment_Export_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]_to_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9].csv",
		poke_interval = 30,
		timeout = 60 * 30,
		mode = "poke"
	)
    
	delete_session_data = SQLExecuteQueryOperator(
		task_id="delete_session_data",
		conn_id="conn_flourish",
		sql=r"""EXEC dbo.sp_delete_session_data""",
		database="flourish",
		dag=dag,
	)

	delete_payment_data = SQLExecuteQueryOperator(
		task_id="delete_payment_data",
		conn_id="conn_flourish",
		sql=r"""EXEC dbo.sp_delete_payment_data""",
		database="flourish",
		dag=dag,
	)
	
	(
		detect_session_data >> delete_session_data,
		detect_payment_data >> delete_payment_data
	)

#    from tests.system.utils.watcher import watcher

    # This test needs watcher in order to properly mark success/failure
    # when "tearDown" task with trigger rule is part of the DAG
#    list(dag.tasks) >> watcher()
#from tests.system.utils import get_test_run  # noqa: E402

# Needed to run the example DAG with pytest (see: tests/system/README.md#run_via_pytest)
#test_run = get_test_run(dag)