CREATE OR REPLACE FUNCTION on_new_field_refresh_materialized_views()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    cint refcursor;
    cstr refcursor;
    cts refcursor;
    cbool refcursor;
    cfloat refcursor;
    ctext refcursor;
    cname refcursor;
    query text;
    query_int text;
    query_str text;
    query_ts text;
    query_bool text;
    query_float text;
    query_text text;
    select_query text;
    columns_query text;
    columns_final text;
   	row_id int;
  	field_name varchar(100);
    table_name varchar(100);
    from_clause_inserted varchar(20);
begin
    open cname for select t."name"
                    from "table" t
                    inner join field f on t.id = f.table_id
                    where f.id = new.id;

    fetch cname into table_name;

    close cname;

    open cint for execute format('select field_name
                            from v_schema
                            where table_id = $1
                            and data_type = ''int''') using new.table_id;

    open cstr for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''string''') using new.table_id;

    open cts for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''timestamp''') using new.table_id;

    open cbool for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''bool''') using new.table_id;

    open cfloat for execute format('select field_name
                                    from v_schema
                                    where table_id = $1
                                    and data_type = ''float''') using new.table_id;
    
    open ctext for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''text''') using new.table_id;

    --query = 'create materialized view ' || table_name || ' as select * from ';
    columns_query = '';

    query := ' from row ';

    columns_final = '';

    loop
        fetch cint into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' int';
    end loop;

    if columns_query != '' then
        select_query := 'select data_int.row_id, f.name, data_int.value from data_int inner join field f on data_int.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_int on "row".id = req_int.row_id';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cstr into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' varchar(100)';
    end loop;

    if columns_query != '' then
        select_query := 'select data_string.row_id, f.name, data_string.value from data_string inner join field f on data_string.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_str on "row".id = req_str.row_id';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cts into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' timestamp';
    end loop;
    
    if columns_query != '' then
        select_query := 'select data_timestamp.row_id, f.name, data_timestamp.value from data_timestamp inner join field f on data_timestamp.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_ts on "row".id = req_ts.row_id';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cbool into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' boolean';
    end loop;
    
    if columns_query != '' then
        select_query := 'select data_bool.row_id, f.name, data_bool.value from data_bool inner join field f on data_bool.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_bool on "row".id = req_bool.row_id';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cfloat into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' float';
    end loop;
    
    if columns_query != '' then
        select_query := 'select data_float.row_id, f.name, data_float.value from data_float inner join field f on data_float.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_float on "row".id = req_float.row_id';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch ctext into field_name;
        exit when not found;
        columns_final := columns_final || ', ' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' text';
    end loop;
    
    if columns_query != '' then
        select_query := 'select data_text.row_id, f.name, data_text.value from data_text dt inner join field f on dt.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_text on "row".id = req_text.row_id';
    end if;

    query = 'select id, date_inserted, date_updated' || columns_final || query;

    execute 'drop materialized view if exists ' || quote_ident(table_name) || '_mv';

    execute format('create materialized view %I_mv as %s', table_name, query);

    return null;
end;
$function$
;


create trigger on_insert_update_refresh_materialized_views
    after insert or update on field
    for each row
    execute function on_new_field_refresh_materialized_views();


create function delete_row(int id) returns void
as $function$
language plpgsql
begin
    delete from data_int where row_id = id;
    delete from data_string where row_id = id;
    delete from data_timestamp where row_id = id;
    delete from data_bool where row_id = id;
    delete from data_float where row_id = id;
    delete from data_text where row_id = id;
    delete from "row" where id = id;
end;
$function$
;


create or replace function on_delete_row_refresh_materialized_views() 
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
begin
    select name into table_name 
    from "table" t
    inner join "row" r on t.id = r.table_id
    where r.id = old.id;

    refresh materialized view concurrently table_name || '_mv';

    return null;
end;
$function$
;

create trigger on_delete_row_refresh_materialized_views
    after delete on "row"
    for each row
    execute function on_delete_row_refresh_materialized_views();