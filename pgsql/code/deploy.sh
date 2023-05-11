host=$POSTGRES_HOST
user=$POSTGRES_USER
db=$POSTGRES_DB
port=$POSTGRES_PORT

export PGPASSWORD=$POSTGRES_PASSWORD

echo Variables:

echo User: $user
echo Database: $db
echo Host: $host
echo Port: $port

RETRIES=10

until psql -h $host -U $user -d $db -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo Waiting for postgres server, $RETRIES remaining attempts...
    RETRIES=$((RETRIES-=1))
    sleep 1
done


psql -h $host -p $port -U $user -d $db -f ./db/database_create.sql

for f in ./db/views/*.sql;
do
    psql -h $host -p $port -U $user -d $db -f "$f"
done

for f in ./db/functions/*.sql;
do
    psql -h $host -p $port -U $user -d $db -f "$f"
done

for f in ./db/triggers/*.sql;
do
    psql -h $host -p $port -U $user -d $db -f "$f"
done