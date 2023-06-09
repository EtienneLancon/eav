set search_path to eav;

drop trigger if exists on_simple_relation_insert_create_field on simple_relation;
drop trigger if exists on_simple_relation_delete_delete_field on simple_relation;



create or replace function on_simple_relation_insert()
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
    data_type_id int;
    query varchar(1000);
begin
    select t."name" into table_name 
    from "table" t
    where t.id = new.table_id_pk;

    select id into data_type_id
    from data_type
    where "name" = 'int';

    query := 'insert into field (table_id, "name", data_type_id) values (' || new.table_id_fk || ', ''' || table_name || '_ui'', ' || data_type_id || ');';
    execute query;

    return null;
end;
$function$
;

create or replace function on_simple_relation_delete()
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
    query varchar(1000);
begin
    select t."name" into table_name 
    from "table" t
    where t.id = old.table_id_pk;

    query := 'delete from field where table_id = ' || old.table_id_fk || ' and "name" = ''' || table_name || '_ui'';';
    execute query;

    return null;
end;
$function$
;

create trigger on_simple_relation_insert_create_field
    after insert on simple_relation
    for each row
    execute function on_simple_relation_insert();

create trigger on_simple_relation_delete_delete_field
    after delete on simple_relation
    for each row
    execute function on_simple_relation_delete();