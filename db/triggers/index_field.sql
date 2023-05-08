drop trigger if exists on_index_field_insert_update on index_field;
drop trigger if exists on_index_field_delete on index_field;
drop trigger if exists before_insert_index_field on index_field;

create or replace function before_insert_index_field()
returns trigger
language plpgsql
as $function$
declare
    existing_index_field_table_id int;
    new_index_field_table_id int;
    existing_index_field_table_name varchar(100);
    new_index_field_table_name varchar(100);
begin
    select table_id, table_name into existing_index_field_table_id
    from v_indexes
    where index_id = new.index_id;

    if existing_index_field_table_id is not null then
        select table_id into new_index_field_table_id
        from field f
        where f.id = new.field_id;

        if existing_index_field_table_id <> new_index_field_table_id then
            select "name" into existing_index_field_table_name
            from "table"
            where id = existing_index_field_table_id;

            select "name" into new_index_field_table_name
            from "table"
            where id = new_index_field_table_id;

            raise exception 'All index fields must be from the same table -- existing % (id %) -- new % (id %)', existing_index_field_table_name, existing_index_field_table_id, new_index_field_table_name, new_index_field_table_id;
        end if;
    end if;
    
    return new;
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
    lazyness varchar(20);
    table_id int;
begin
    select struct_lazyness into lazyness
    from v_lazyness;

    if lazyness = 'EAGER' then

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
    else
        select t.id into table_id
        from "table" t
        inner join field f on f.table_id = t.id
        inner join index_field i on i.field_id = f.id
        where i.id = new.index_id;

        update "table" set struct_uptodate = false where id = table_id;
        return null;
    end if;
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
    lazyness varchar(20);
    table_id int;
begin
    select struct_lazyness into lazyness
    from v_lazyness;

    if lazyness = 'EAGER' then

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
    else
        select t.id into table_id
        from "table" t
        inner join field f on f.table_id = t.id
        inner join index_field i on i.field_id = f.id
        where i.id = new.index_id;

        update "table" set struct_uptodate = false where id = table_id;
        return null;
    end if;
end;
$function$
;


create trigger before_insert_index_field
    before insert on index_field
    for each row
    execute function before_insert_index_field();

create trigger on_index_field_insert_update
    after insert or update on index_field
    for each row
    execute function on_index_field_insert_update();

create trigger on_index_field_delete
    after delete on index_field
    for each row
    execute function on_index_field_delete();