drop trigger if exists on_field_insert_update_create_materialized_views on field;
drop trigger if exists on_field_delete_create_materialized_views on field;
drop trigger if exists on_simple_relation_insert_create_field on simple_relation;
drop trigger if exists on_simple_relation_delete_delete_field on simple_relation;
drop trigger if exists on_index_field_insert_update on index_field;
drop trigger if exists on_index_field_delete on index_field;


create or replace function on_field_insert_update_create_materialized_views()
returns trigger
language plpgsql
as $function$
begin
    perform create_materialized_view(new.table_id);
    perform create_insert(new.table_id);
    return null;
end;
$function$
;

create or replace function on_field_delete_create_materialized_views()
returns trigger
language plpgsql
as $function$
begin
    perform create_materialized_view(old.table_id);
    perform create_insert(old.table_id);
    return null;
end;
$function$
;

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

create or replace function on_index_field_insert_update()
returns trigger
language plpgsql
as $function$
declare
    query varchar(1000);
    id_index int;
    index_name varchar(100);
begin
    select into id_index, index_name
        v.index_id, p.indexname
    from v_indexes v
    left join pg_indexes p on p.indexname = v.index_name
    where v.index_id = new.index_id
    limit 1;

    if index_name is not null then
        query := 'drop index ' || index_name || ';';
        execute query;
    end if;

    query := 'select create_index(' || new.index_id || ');';
    execute query;

    return null;
end;
$function$
;

create or replace function on_index_field_delete()
returns trigger
language plpgsql
as $function$
declare
    query varchar(1000);
    id_index int;
    index_name varchar(100);
begin
    select into id_index, index_name
        v.index_id, p.indexname
    from v_indexes v
    left join pg_indexes p on p.indexname = v.index_name
    where v.index_id = old.index_id
    limit 1;

    if index_name is not null then
        query := 'drop index ' || index_name || ';';
        execute query;
    end if;

    if id_index is not null then
        query := 'select create_index(' || old.index_id || ');';
        execute query;
    end if;

    return null;
end;
$function$
;


create trigger on_field_insert_update_create_materialized_views
    after insert or update on field
    for each row
    execute function on_field_insert_update_create_materialized_views();

create trigger on_field_delete_create_materialized_views
    after delete on field
    for each row
    execute function on_field_delete_create_materialized_views();

create trigger on_simple_relation_insert_create_field
    after insert on simple_relation
    for each row
    execute function on_simple_relation_insert();

create trigger on_simple_relation_delete_delete_field
    after delete on simple_relation
    for each row
    execute function on_simple_relation_delete();

create trigger on_index_field_insert_update
    after insert or update on index_field
    for each row
    execute function on_index_field_insert_update();

create trigger on_index_field_delete
    after delete on index_field
    for each row
    execute function on_index_field_delete();