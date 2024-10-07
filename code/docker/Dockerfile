FROM apache/airflow:2.9.3
COPY requirements.txt /
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r /requirements.txt
USER root
COPY install_mssql_tools.sh /scripts/docker
RUN bash /scripts/docker/install_mssql_tools.sh
USER airflow
