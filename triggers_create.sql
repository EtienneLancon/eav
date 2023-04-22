CREATE OR REPLACE FUNCTION refresh_materialized_views()
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
    from_clause_inserted varchar(20);
begin

    open cint for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'int';

    open cstr for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'string';

    open cts for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'timestamp';

    open cbool for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'bool';

    open cfloat for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'float';
    
    open ctext for select row_id, field_name
                from v_schema
                where table_name = new.table_name
                and field_data_type = 'text';

    query = 'create materialized view ' || new.table_name || ' as select * from ';
    select_query = '';
    columns_query = '';
    query_int = '';

    loop
        fetch cint into row_id, field_name;
        exit when not found;
        
        select_query := select_query || ', data_int.field_value ';
        columns_query := columns_query || ', ' || field_name || ' int';

    end loop;
    close cint;

    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_int where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_int := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_int';
    end if;

    select_query = '';
    columns_query = '';
    query_str = '';
   
    loop 
        fetch cstr into row_id, field_name;
        exit when not found;

        select_query := select_query || ', data_string.field_value ';
        columns_query := columns_query || ', ' || field_name || ' varchar(100)';

    end loop;
    close cstr;

    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_string where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_str := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_str';
    end if;

    select_query = '';
    columns_query = '';
    query_ts = '';
   
    loop 
        fetch cts into row_id, field_name;
        exit when not found;
        
        select_query := select_query || ', data_timestamp.field_value ';
        columns_query := columns_query || ', ' || field_name || ' timestamp';

    end loop;
    close cts;
    
    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_timestamp where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_ts := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_ts';
    end if;

    select_query = '';
    columns_query = '';
    query_bool = '';
   
    loop 
        fetch cbool into row_id, field_name;
        exit when not found;
        
        select_query := select_query || ', data_bool.field_value ';
        columns_query := columns_query || ', ' || field_name || ' bool';

    end loop;
    close cbool;
    
    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_bool where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_bool := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_bool';
    end if;

    select_query = '';
    columns_query = '';
    query_float = '';
   
    loop 
        fetch cfloat into row_id, field_name;
        exit when not found;
        
        select_query := select_query || ', data_float.field_value ';
        columns_query := columns_query || ', ' || field_name || ' float';

    end loop;
    close cfloat;
    
    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_float where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_bool := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_float';
    end if;

    select_query = '';
    columns_query = '';
    query_text = '';
   
    loop 
        fetch ctext into row_id, field_name;
        exit when not found;
        
        select_query := select_query || ', data_text.field_value ';
        columns_query := columns_query || ', ' || field_name || ' text';

    end loop;
    close ctext;
    
    if select_query != '' then
        select_query := 'select row_id, ' || select_query || ' from data_text where row_id = ' || row_id;
        columns_query := 'row_id int' || columns_query;
        query_text := '(select * from crosstab(' || quote_literal(select_query) || ') as ct(' || quote_literal(columns_query) || ')) as req_text';
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

    query := query || ' inner join row on ' || from_clause_inserted || '.row_id = row.row_id';


    drop materialized view if exists new.table_name;
    execute query;
end;
$function$
;


create trigger v_schema_trigger
    after insert or update or delete on v_schema
    for each statement
    execute function refresh_materialized_views();