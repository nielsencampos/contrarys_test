#!/bin/sh
cd /contrarys_test/apps/
vLogFile=/contrarys_test/logs/ingest_data_$(TZ="America/Sao_Paulo" date "+%Y%m%d_%H%M%S").log
python3 /contrarys_test/apps/ingest_data.py >> $vLogFile 2>>$vLogFile