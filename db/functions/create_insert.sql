drop function if exists create_insert(int);

create function create_insert(modified_table_id int)
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
    lazyness varchar(20);
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

    select data_lazyness into lazyness
    from v_lazyness;

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
        insertsstr := insertsstr || 'insert into data_string (row_ui, field_id, value) values (row_ui, ' || field_id || ', ' || field_name || '); ';
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

    query := substring(query, 1, length(query)-2) || ') returns int language plpgsql as $$ ';
    query := query || 'declare row_ui int; ';
    query := query || 'begin ';
    query := query || 'insert into "row" (table_id) values (' || modified_table_id || ') returning ui into row_ui; ';
    query := query || insertsint || insertsstr || insertsts || insertsbool || insertsfloat || insertstext;

    if lazyness = 'LAZY' then
        query := query || 'update table "table" set data_uptodate = false where id = ' || modified_table_id || '; ';
    else
        query := query || format('refresh materialized view concurrently %I_mv', table_name) || '; ';
    end if;

    query := query || 'return row_ui; end; $$;';


    execute format('drop function if exists insert_%I', table_name);
    execute query;
end;
$function$
;