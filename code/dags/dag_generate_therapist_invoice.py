# Used the following DAG as a template:
# https://airflow.apache.org/docs/apache-airflow-providers-microsoft-mssql/stable/operators.html

import os
import datetime
#import pytest

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

DAG_ID = "generate_therapist_invoice"


with DAG(
	DAG_ID,
	schedule="@daily",
	start_date=datetime.datetime(2024, 8, 18),
	tags=["flourish"],
	catchup=False,
) as dag:
    
	delete_session_data_task = SQLExecuteQueryOperator(
		task_id="delete_session_data",
		conn_id="conn_flourish",
		sql=r"""EXEC dbo.sp_delete_session_data""",
		database="flourish",
		dag=dag,
	)

	delete_payment_data_task = SQLExecuteQueryOperator(
		task_id="delete_payment_data",
		conn_id="conn_flourish",
		sql=r"""EXEC dbo.sp_delete_payment_data""",
		database="flourish",
		dag=dag,
	)
	
	(
		delete_session_data_task
		>> delete_payment_data_task
	)

#    from tests.system.utils.watcher import watcher

    # This test needs watcher in order to properly mark success/failure
    # when "tearDown" task with trigger rule is part of the DAG
#    list(dag.tasks) >> watcher()
#from tests.system.utils import get_test_run  # noqa: E402

# Needed to run the example DAG with pytest (see: tests/system/README.md#run_via_pytest)
#test_run = get_test_run(dag)