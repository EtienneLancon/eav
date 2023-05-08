drop trigger if exists on_field_insert_update_create_materialized_views on field;
drop trigger if exists on_field_delete_create_materialized_views on field;

create or replace function on_field_insert_update_create_materialized_views()
returns trigger
language plpgsql
as $function$
declare
    lazyness varchar(20);
begin
    select struct_lazyness into lazyness
    from v_lazyness;

    if(lazyness = 'EAGER') then
        perform create_materialized_view(new.table_id);
        perform create_insert(new.table_id);
    else
        update "table" set struct_uptodate = false where id = new.table_id;
    end if;

    return null;
end;
$function$
;

create or replace function on_field_delete_create_materialized_views()
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
    query varchar(1000);
    lazyness varchar(20);
begin
    select struct_lazyness into lazyness
    from v_lazyness;

    if(lazyness = 'EAGER') then

        if exists (select 1 from field where table_id = old.table_id) then
            perform create_materialized_view(old.table_id);
            perform create_insert(old.table_id);
        else
            select "name" into table_name
            from "table"
            where id = old.table_id;

            query := 'drop materialized view if exists ' || table_name || '_mv';
            execute query;
        end if;
    else
        update "table" set struct_uptodate = false where id = old.table_id;
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