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
    c refcursor;
    query text;
    query_int text;
    query_str text;
    query_ts text;
    query_bool text;
    query_float text;
    query_text text;
    select_query text;
    columns_query text;
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
    query = '';
    select_query = '';
    columns_query = '';
    query_int = '';

    loop
        fetch cint into field_name;
        exit when not found;
        
        select_query := select_query || ', data_int.value ';
        columns_query := columns_query || ', ' || field_name || ' int';

    end loop;
    close cint;

    if select_query != '' then
        select_query := 'select data_int.row_id, f.name' || select_query || ' from data_int inner join field f on data_int.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_int := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_int';
    end if;

    select_query = '';
    columns_query = '';
    query_str = '';
   
    loop 
        fetch cstr into field_name;
        exit when not found;

        select_query := select_query || ', data_string.value ';
        columns_query := columns_query || ', ' || field_name || ' varchar(255)';

    end loop;
    close cstr;

    if select_query != '' then
        select_query := 'select data_string.row_id, f.name' || select_query || ' from data_string inner join field f on data_string.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_str := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_str';
    end if;

    select_query = '';
    columns_query = '';
    query_ts = '';
   
    loop 
        fetch cts into field_name;
        exit when not found;
        
        select_query := select_query || ', data_timestamp.value ';
        columns_query := columns_query || ', ' || field_name || ' timestamp';

    end loop;
    close cts;
    
    if select_query != '' then
        select_query := 'select data_timestamp.row_id, f.name' || select_query || ' from data_timestamp inner join field f on data_timestamp.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_ts := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_ts';
    end if;

    select_query = '';
    columns_query = '';
    query_bool = '';
   
    loop 
        fetch cbool into field_name;
        exit when not found;
        
        select_query := select_query || ', data_bool.value ';
        columns_query := columns_query || ', ' || field_name || ' bool';

    end loop;
    close cbool;
    
    if select_query != '' then
        select_query := 'select data_bool.row_id, f.name' || select_query || ' from data_bool inner join field f on data_bool.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_bool := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_bool';
    end if;

    select_query = '';
    columns_query = '';
    query_float = '';
   
    loop 
        fetch cfloat into field_name;
        exit when not found;
        
        select_query := select_query || ', data_float.value ';
        columns_query := columns_query || ', ' || field_name || ' text';

    end loop;
    close cfloat;
    
    if select_query != '' then
        select_query := 'select data_float.row_id, f.name' || select_query || ' from data_float inner join field f on data_float.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_float := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_float';
    end if;

    select_query = '';
    columns_query = '';
    query_text = '';
   
    loop 
        fetch ctext into field_name;
        exit when not found;
        
        select_query := select_query || ', data_text.value ';
        columns_query := columns_query || ', ' || field_name || ' text';

    end loop;
    close ctext;
    
    if select_query != '' then
        select_query := 'select row_id, f.name' || select_query || ' from data_text dt inner join field f on dt.field_id = f.id where f.table_id = ' || new.table_id;
        columns_query := 'row_id int' || columns_query;
        query_text := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || columns_query || ')) as req_text';
    end if;


    from_clause_inserted = '';

    if query_int != '' then
        query := query || query_int;
        from_clause_inserted = 'req_int';
    end if;

    if query_str != '' then
        if from_clause_inserted != '' then
            query := query || ' inner join ' || query_str || ' on ' || from_clause_inserted || '.row_id = req_str.row_id';
        else
            query := query || query_str;
            from_clause_inserted = 'req_str';
        end if;
    end if;

    if query_ts != '' then
        if from_clause_inserted != '' then
            query := query || ' inner join ' || query_ts || ' on ' || from_clause_inserted || '.row_id = req_ts.row_id';
        else
            query := query || query_ts;
            from_clause_inserted = 'req_ts';
        end if;
    end if;

    if query_bool != '' then
        if from_clause_inserted != '' then
            query := query || ' inner join ' || query_bool || ' on ' || from_clause_inserted || '.row_id = req_bool.row_id';
        else
            query := query || query_bool;
            from_clause_inserted = 'req_bool';
        end if;
    end if;

    if query_float != '' then
        if from_clause_inserted != '' then
            query := query || ' inner join ' || query_float || ' on ' || from_clause_inserted || '.row_id = req_float.row_id';
        else
            query := query || query_float;
            from_clause_inserted = 'req_float';
        end if;
    end if;

    if query_text != '' then
        if from_clause_inserted != '' then
            query := query || ' inner join ' || query_text || ' on ' || from_clause_inserted || '.row_id = req_text.row_id';
        else
            query := query || query_text;
            from_clause_inserted = 'req_text';
        end if;
    end if;

    query := query || ' inner join "row" on ' || from_clause_inserted || '.row_id = "row".id';


    raise 'query : %', query;
    execute 'drop materialized view if exists ' || quote_ident(table_name) || '_mv';

    execute format('create materialized view %I_mv as select * from %s', table_name, query);

    close cname;
end;
$function$
;


create trigger on_insert_update_refresh_materialized_views
    after insert or update on field
    for each row
    execute function on_new_field_refresh_materialized_views();