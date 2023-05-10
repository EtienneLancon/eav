host=$(<./db/env/host)
user=$(<./db/env/user)
db=$(<./db/env/db)

psql -h $host -U $user -d $db -f ./db/database_create.sql

for f in ./db/views/*.sql;
do
    psql -h $host -U $user -d $db -f "$f"
done

for f in ./db/functions/*.sql;
do
    psql -h $host -U $user -d $db -f "$f"
done

for f in ./db/triggers/*.sql;
do
    psql -h $host -U $user -d $db -f "$f"
done