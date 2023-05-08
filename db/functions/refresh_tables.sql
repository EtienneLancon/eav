drop function if exists refresh_tables;

create function refresh_tables()
returns void
language plpgsql
as $function$
declare
    c cursor for
        select id
        from "table"
        where struct_uptodate = false;

    table_id int;

begin
    open c;
    loop
        fetch c into table_id;
        exit when not found;
        perform create_materialized_view(table_id);
        perform create_insert(table_id);
    end loop;
    close c;
end;
$function$
;