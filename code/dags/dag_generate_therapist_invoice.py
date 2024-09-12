# Used the following DAG as a template:
# https://airflow.apache.org/docs/apache-airflow-providers-microsoft-mssql/stable/operators.html

import os
import datetime
import pytz
#import pytest

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
from airflow.sensors.filesystem import FileSensor

DAG_ID = "generate_therapist_invoice"

with DAG(
	DAG_ID,
	schedule=None,
	start_date=datetime.datetime(2024, 9, 1, tzinfo=pytz.timezone('US/Eastern')),
	params=	{
				"session_glob": "Therapist_Session_Export_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]_to_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9].csv",
				"payment_glob": "Therapist_Payment_Export_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]_to_[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9].csv",
				"app_folder": "/opt/airflow/apps/flourish"
			},
	tags=["flourish"],
	catchup=False
) as dag:
	
	# With respect to passing data between tasks, we will use XComs.
	#	The detect tasks will push the path to the file detected.
	#	The fix tasks will push the path to the pre-processed file.
	detect_session_data = FileSensor(
		task_id = "wait_for_session_data",
		fs_conn_id = "fs_flourish_stage",
		filepath = "",
		poke_interval = 30,
		timeout = 60 * 30,
		mode = "poke"
	)
	
	detect_payment_data = FileSensor(
		task_id = "wait_for_payment_data",
		fs_conn_id = "fs_flourish_stage",
		filepath = "",
		poke_interval = 30,
		timeout = 60 * 30,
		mode = "poke"
	)
	
	# Will need to pull the filepath XComs pushed by the detect tasks.
	# By default, the BashOperator pushes an XCom corresponding to the last line
	# printed on the standard output by the bash commands.
	
	fix_session_dates = BashOperator(
		task_id="fix_session_dates",
		bash_command="{{ params.app_folder }}/scripts/fix_owl_export.sh {{ params.app_folder }}/stage/{{ params.session_glob }} ",
		do_xcom_push=True
	)
	
	fix_payment_dates = BashOperator(
		task_id="fix_payment_dates",
		bash_command="{{ params.app_folder }}/scripts/fix_owl_export.sh {{ params.app_folder }}/stage/{{ params.payment_glob}} ",
		do_xcom_push=True
	)
    
	delete_session_data = SQLExecuteQueryOperator(
		task_id="delete_session_data",
		conn_id="db_flourish",
		sql=r"""EXEC dbo.sp_delete_session_data""",
		database="flourish",
		dag=dag,
	)
	
	delete_payment_data = SQLExecuteQueryOperator(
		task_id="delete_payment_data",
		conn_id="db_flourish",
		sql=r"""EXEC dbo.sp_delete_payment_data""",
		database="flourish",
		dag=dag,
	)
	
	
	(
		detect_session_data >> fix_session_dates >> delete_session_data,
		detect_payment_data >> fix_payment_dates >> delete_payment_data
	)
	
#    from tests.system.utils.watcher import watcher

    # This test needs watcher in order to properly mark success/failure
    # when "tearDown" task with trigger rule is part of the DAG
#    list(dag.tasks) >> watcher()
#from tests.system.utils import get_test_run  # noqa: E402

# Needed to run the example DAG with pytest (see: tests/system/README.md#run_via_pytest)
#test_run = get_test_run(dag)