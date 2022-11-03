#!/bin/sh
docker pull fedora

docker pull postgres

docker network create contrarys_test-network

docker run -dit --privileged --name contrarys_test-postgres -p 5432:5432 -e POSTGRES_PASSWORD=contrarys_test postgres

docker network connect contrarys_test-network contrarys_test-postgres

docker run -dit --privileged -p 22:22 -p 4321:4321 --name contrarys_test-fedora fedora

docker network connect contrarys_test-network contrarys_test-fedora

docker exec -u root --workdir / -it contrarys_test-fedora bash

dnf -y upgrade
dnf -y install cronie cronie-anacron ncurses
dnf -y group install "Development Tools"

yum -y update
yum -y install passwd procps telnet-server telnet htop libaio libaio-devel wget vim gcc python3 pip python3-netifaces

dnf -y upgrade
yum -y update

pip3 install --upgrade pip

pip3 install --upgrade Cmake wheel
pip3 install --upgrade python-openstackclient
pip3 install --upgrade datetime pytz pandas
pip3 install --upgrade pyodbc psycopg2-binary sqlalchemy
pip3 install --upgrade requests fastapi pydantic uvicorn

mkdir /contrarys_test/
mkdir /contrarys_test/apps/
mkdir /contrarys_test/logs/
chmod 777 -R /contrarys_test/

exit

docker network inspect contrarys_test-network

docker cp ./ingest_data.py contrarys_test-fedora:/contrarys_test/apps/

docker cp ./ingest_data.sh contrarys_test-fedora:/contrarys_test/apps/

docker cp ./api4data.py contrarys_test-fedora:/contrarys_test/apps/

docker cp ./api4data.sh contrarys_test-fedora:/contrarys_test/apps/

###Run contrarys_test_constructor.sql inside the PostgreSQL created

docker exec -u root --workdir / -it contrarys_test-fedora bash

chmod 777 -R /contrarys_test/
chmod +x -R /contrarys_test/apps/*
rm -rf /contrarys_test/logs/*
/contrarys_test/apps/ingest_data.sh
/contrarys_test/apps/api4data.sh

exit

docker commit contrarys_test-postgres nielsencampos/contrarys_test-postgres

docker commit contrarys_test-fedora nielsencampos/contrarys_test-fedora

docker push nielsencampos/contrarys_test-postgres

docker push nielsencampos/contrarys_test-fedora