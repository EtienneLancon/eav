drop function if exists create_materialized_view;

CREATE FUNCTION create_materialized_view(modified_table_id int)
returns void
LANGUAGE plpgsql
AS $function$
declare
    cint cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'int';

    cstr cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'string';
    
    cts cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'timestamp';

    cbool cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'bool';

    cfloat cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'float';

    ctext cursor for
        select field_name
        from v_schema
        where table_id = modified_table_id
        and data_type = 'text';

    crelatedmany cursor for
        select pk_name
        from v_simple_relations
        where fk_id = modified_table_id
        and relation_type = 'MANY_TO_ONE';

    crelatedone cursor for
        select pk_name
        from v_simple_relations
        where fk_id = modified_table_id
        and relation_type = 'ONE_TO_ONE';

    cindex cursor for
        select i.id
        from "index" i
        inner join index_field on i.id = index_field.index_id
        inner join field on index_field.field_id = field.id
        where field.table_id = modified_table_id;

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
    unique_indexes text;
    non_unique_indexes text;
    field_name varchar(100);
    table_name varchar(100);
    related_table_name varchar(100);
    from_clause_inserted varchar(20);
    index_id int;
begin
    if not exists (select 1 from "table" where id = modified_table_id and struct_uptodate = false) then
        return;
    end if;

    columns_query := '';
    query := ' from "row" ';
    columns_final := '';

    open cint;

    loop
        fetch cint into field_name;
        exit when not found;
        columns_final := columns_final || ', req_int.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' int';
    end loop;

    close cint;

    if columns_query != '' then
        select_query := 'select data_int.row_ui, f.name, data_int.value from data_int inner join field f on data_int.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_int on "row".ui = req_int.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    open cstr;

    loop
        fetch cstr into field_name;
        exit when not found;
        columns_final := columns_final || ', req_str.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' varchar(100)';
    end loop;

    close cstr;

    if columns_query != '' then
        select_query := 'select data_string.row_ui, f.name, data_string.value from data_string inner join field f on data_string.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_str on "row".ui = req_str.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    open cts;

    loop
        fetch cts into field_name;
        exit when not found;
        columns_final := columns_final || ', req_ts.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' timestamp';
    end loop;

    close cts;
    
    if columns_query != '' then
        select_query := 'select data_timestamp.row_ui, f.name, data_timestamp.value from data_timestamp inner join field f on data_timestamp.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_ts on "row".ui = req_ts.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    open cbool;

    loop
        fetch cbool into field_name;
        exit when not found;
        columns_final := columns_final || ', req_bool.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' boolean';
    end loop;

    close cbool;
    
    if columns_query != '' then
        select_query := 'select data_bool.row_ui, f.name, data_bool.value from data_bool inner join field f on data_bool.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_bool on "row".ui = req_bool.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    open cfloat;

    loop
        fetch cfloat into field_name;
        exit when not found;
        columns_final := columns_final || ', req_float.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' float';
    end loop;

    close cfloat;
    
    if columns_query != '' then
        select_query := 'select data_float.row_ui, f.name, data_float.value from data_float inner join field f on data_float.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_float on "row".ui = req_float.row_ui';
    end if;

    select_query = '';
    columns_query = '';

    open ctext;

    loop
        fetch ctext into field_name;
        exit when not found;
        columns_final := columns_final || ', req_text.' || quote_ident(field_name);
        columns_query := columns_query || ', ' || quote_ident(field_name) || ' text';
    end loop;

    close ctext;
    
    if columns_query != '' then
        select_query := 'select data_text.row_ui, f.name, data_text.value from data_text dt inner join field f on dt.field_id = f.id where f.table_id = ' || modified_table_id;
        columns_query := 'row_ui int' || columns_query;
        query := query || ' left join (select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_text on "row".ui = req_text.row_ui';
    end if;

    query = 'select "row".ui, "row".date_inserted, "row".date_updated' || columns_final || query || ' where "row".table_id = ' || modified_table_id || ' order by "row".ui';

    select t."name" into table_name 
    from "table" t
    where t.id = modified_table_id;

    non_unique_indexes := '';
    open crelatedmany;

    loop
        fetch crelatedmany into related_table_name;
        exit when not found;
        non_unique_indexes := non_unique_indexes || 'create index fk_ix_' || related_table_name || '_mv_ui on ' || table_name || '_mv (' || related_table_name || '_ui); ';
    end loop;

    close crelatedmany;

    unique_indexes := '';
    open crelatedone;

    loop
        fetch crelatedone into related_table_name;
        exit when not found;
        unique_indexes := unique_indexes || 'create unique index fk_ux_' || related_table_name || '_mv_ui on ' || table_name || '_mv (' || related_table_name || '_ui); ';
    end loop;

    close crelatedone;

    execute format('drop materialized view if exists %I_mv', table_name);
    execute format('create materialized view %I_mv as %s; create unique index ux_%I_mv_ui on %I_mv (ui);', table_name, query, table_name, table_name);
    execute non_unique_indexes;
    execute unique_indexes;

    open cindex;

    loop
        fetch cindex into index_id;
        exit when not found;
        perform create_index(index_id);
    end loop;

    close cindex;

    update "table" set struct_uptodate = true where id = modified_table_id;
end;
$function$
;