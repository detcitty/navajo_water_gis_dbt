.PHONY: setup-python setup-env run-dbt clean-up

setup-python:
	python -m venv venv_dbt_navajowells && \
	source venv_dbt_navajowells/bin/activate && \
	pip install -r requirements.txt

setup-duckdb-data:
	source venv_dbt_navajowells/bin/activate && \
	python3 load_data_duckdb.py

run-dbt:
	export DBT_DUCKDB_PG_PWD=mysecretpassword && \
	source venv_dbt_navajowells/bin/activate && \
	cd navajo_water_wells && \
	dbt deps && \
	dbt build

clean-up:
	rm -rf venv_dbt_navajowells
	rm -rf navajo_wells.db
