drop function if exists create_materialized_view;
drop function if exists create_insert;
drop function if exists create_update;

CREATE OR REPLACE FUNCTION create_materialized_view(table_id int)
returns void
LANGUAGE plpgsql
AS $function$
declare
    cint refcursor;
    cstr refcursor;
    cts refcursor;
    cbool refcursor;
    cfloat refcursor;
    ctext refcursor;
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
    field_name varchar(100);
    table_name varchar(100);
    from_clause_inserted varchar(20);
begin

    open cint for execute format('select field_name
                            from v_schema
                            where table_id = $1
                            and data_type = ''int''') using table_id;

    open cstr for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''string''') using table_id;

    open cts for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''timestamp''') using table_id;

    open cbool for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''bool''') using table_id;

    open cfloat for execute format('select field_name
                                    from v_schema
                                    where table_id = $1
                                    and data_type = ''float''') using table_id;
    
    open ctext for execute format('select field_name
                                from v_schema
                                where table_id = $1
                                and data_type = ''text''') using table_id;

    columns_query := '';
    query := ' from "row" ';
    columns_final := '';

    loop
        fetch cint into field_name;
        exit when not found;
        columns_final := columns_final || ', req_int.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' int';
    end loop;

    close cint;

    if columns_query != '' then
        select_query := 'select data_int.row_ui, f.name, data_int.value from data_int inner join field f on data_int.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_int on "row".ui = req_int.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cstr into field_name;
        exit when not found;
        columns_final := columns_final || ', req_str.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' varchar(100)';
    end loop;

    close cstr;

    if columns_query != '' then
        select_query := 'select data_string.row_ui, f.name, data_string.value from data_string inner join field f on data_string.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_str on "row".ui = req_str.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cts into field_name;
        exit when not found;
        columns_final := columns_final || ', req_ts.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' timestamp';
    end loop;

    close cts;
    
    if columns_query != '' then
        select_query := 'select data_timestamp.row_ui, f.name, data_timestamp.value from data_timestamp inner join field f on data_timestamp.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_ts on "row".ui = req_ts.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cbool into field_name;
        exit when not found;
        columns_final := columns_final || ', req_bool.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' boolean';
    end loop;

    close cbool;
    
    if columns_query != '' then
        select_query := 'select data_bool.row_ui, f.name, data_bool.value from data_bool inner join field f on data_bool.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_bool on "row".ui = req_bool.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch cfloat into field_name;
        exit when not found;
        columns_final := columns_final || ', req_float.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' float';
    end loop;

    close cfloat;
    
    if columns_query != '' then
        select_query := 'select data_float.row_ui, f.name, data_float.value from data_float inner join field f on data_float.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_float on "row".ui = req_float.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    loop
        fetch ctext into field_name;
        exit when not found;
        columns_final := columns_final || ', req_text.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' text';
    end loop;

    close ctext;
    
    if columns_query != '' then
        select_query := 'select data_text.row_ui, f.name, data_text.value from data_text dt inner join field f on dt.field_id = f.id where f.table_id = ' || table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_text on "row".ui = req_text.row_ui';
    end if;

    query = 'select "row".ui, "row".date_inserted, "row".date_updated' || columns_final || query || ' where "row".table_id = ' || table_id || ' order by "row".ui';


    select t."name" into table_name 
    from "table" t
    where t.id = table_id;

    execute format('drop materialized view if exists %I_mv', table_name);

    execute format('create materialized view %I_mv as %s; create unique index ux_%I_mv_ui on %I_mv (ui)', table_name, query, table_name, table_name);
end;
$function$
;

create or replace function create_insert(modified_table_id int)
returns void
language plpgsql
as $function$
declare
    cint cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'int';

    cstr cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'string';
    
    cts cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'timestamp';

    cbool cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'bool';

    cfloat cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'float';

    ctext cursor for
        select field_id, field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'text';

    field_id int;
    field_name varchar(100);
    data_type varchar(100);
    table_name varchar(100);
    query text;
    insertsint text;
    insertsstr text;
    insertsts text;
    insertsbool text;
    insertsfloat text;
    insertstext text;
begin
    select t."name" into table_name 
    from "table" t
    where t.id = modified_table_id;

    query := 'create function insert_' || table_name || '(';

    insertsint := '';
    open cint;
    loop
        fetch cint into field_id, field_name;
        exit when not found;
        query := query || field_name || ' int, ';
        insertsint := insertsint || 'insert into data_int (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
    end loop;

    close cint;

    insertsstr := '';
    open cstr;
    loop
        fetch cstr into field_id, field_name;
        exit when not found;
        query := query || field_name || ' varchar(100), ';
        insertsstr := insertsstr || 'insert into data_string (row_ui, field_id, value) values (row_ui, ' || field_id || ', quote_literal(' || field_name || ')); ';
    end loop;

    close cstr;

    insertsts := '';
    open cts;
    loop
        fetch cts into field_id, field_name;
        exit when not found;
        query := query || field_name || ' timestamp, ';
        insertsts := insertsts || 'insert into data_timestamp (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
    end loop;

    close cts;

    insertsbool := '';
    open cbool;
    loop
        fetch cbool into field_id, field_name;
        exit when not found;
        query := query || field_name || ' boolean, ';
        insertsbool := insertsbool || 'insert into data_bool (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
    end loop;

    close cbool;

    insertsfloat := '';
    open cfloat;
    loop
        fetch cfloat into field_id, field_name;
        exit when not found;
        query := query || field_name || ' float, ';
        insertsfloat := insertsfloat || 'insert into data_float (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
    end loop;

    close cfloat;

    insertstext := '';
    open ctext;
    loop
        fetch ctext into field_id, field_name;
        exit when not found;
        query := query || field_name || ' text, ';
        insertstext := insertstext || 'insert into data_text (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
    end loop;

    close ctext;

    query := substring(query, 1, length(query)-2) || ') returns void language plpgsql as $$ ';
    query := query || 'declare row_ui int; ';
    query := query || 'begin ';
    query := query || 'insert into "row" (table_id) values (' || modified_table_id || ') returning ui into row_ui; ';
    query := query || insertsint || insertsstr || insertsts || insertsbool || insertsfloat || insertstext;
    query := query || 'end; $$;';


    execute format('drop function if exists insert_%I', table_name);
    execute query;
end;
$function$
;

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

create or replace function on_delete_row_refresh_materialized_views() 
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
begin
    select "name" into table_name 
    from "table" t
    inner join "row" r on t.id = r.table_id
    where r.ui = old.ui;

    execute format('refresh materialized view concurrently %I_mv', table_name);

    return null;
end;
$function$
;

create or replace function on_update_row_refresh_materialized_views()
returns trigger
language plpgsql
as $function$
declare
    table_name varchar(100);
begin
    select "name" into table_name 
    from "table" t
    inner join "row" r on t.id = r.table_id
    where r.ui = new.ui;

    execute format('refresh materialized view concurrently %I_mv', table_name);

    return null;
end;
$function$
;

create or replace function on_update_data_update_row_date_updated()
returns trigger
language plpgsql
as $function$
begin
    update "row" set date_updated = now() where ui = new.row_ui;
    return null;
end;
$function$
;