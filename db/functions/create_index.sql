drop function if exists create_index;

create function create_index(id_index int)
returns void
language plpgsql
as $function$
declare
    fields_mapping varchar(1000);
    fields_include varchar(1000);
    query text;
    index_table varchar(100);
    index_field varchar(100);
    name_index varchar(100);
    index_unique boolean;
    index_type varchar(100);
    cindexdef cursor for
        select field_name, field_type
        from v_indexes
        where index_id = id_index;
begin
    fields_include := '';
    fields_mapping := '';
    open cindexdef;

    loop
        fetch cindexdef into index_field, index_type;
        exit when not found;

        if index_type = 'MAPPING' then
            fields_mapping := fields_mapping || index_field || ', ';

        elsif index_type = 'INCLUDE' then
            fields_include := fields_include || index_field || ', ';
        else
            raise exception 'Unknown field type %', index_type;
        end if;

    end loop;

    close cindexdef;

    if fields_mapping  = '' then
        raise exception 'No fields for index %', id_index;
    end if;

    fields_mapping := substring(fields_mapping, 1, length(fields_mapping)-2);

    if fields_include <> '' then
        fields_include := substring(fields_include, 1, length(fields_include)-2);
    end if;

    select index_name, unique_index, table_name into name_index, index_unique, index_table
    from v_indexes
    where index_id = id_index
    limit 1;


    query := ' on ' || index_table || '_mv (' || fields_mapping || ') ';

    if fields_include <> '' then
        query := query || 'include (' || fields_include || ');';
    else
        query := query || ';';
    end if;

    if index_unique then
        query := 'create unique index if not exists ux_'|| name_index || query;
    else
        query := 'create index if not exists ix_' || query;
    end if;

    execute query;
end;
$function$
;
