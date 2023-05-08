drop view if exists v_schema;

create view v_schema as
    select
        t.id as table_id,
        t.name as table_name,
        f.id as field_id,
        f.name as field_name,
        dt.name as data_type
    from "table" t
    inner join field f on f.table_id = t.id
    inner join data_type dt on dt.id = f.data_type_id;