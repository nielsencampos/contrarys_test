#!/bin/sh
cd /contrarys_test/apps/
pkill -f "python3 /contrarys_test/apps/api4data.py"
vLogFile=/contrarys_test/logs/api4data_$(TZ="America/Sao_Paulo" date "+%Y%m%d_%H%M%S").log
nohup python3 /contrarys_test/apps/api4data.py >> $vLogFile 2>>$vLogFile & >>$vLogFile