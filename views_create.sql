create view v_schema as
    select
        t.id as table_id,
        t.name as table_name,
        f.id as field_id,
        f.name as field_name,
        dt.name as data_type
    from "table" t
    inner join field f on f.table_id = t.id
    inner join data_type dt on dt.id = f.data_type_id
    union
    select
        r.id as table_id, 
        r.name as table_name,
        f.id as field_id,
        f.name as field_name,
        dt.name as data_type
    from relation r
    inner join relation_keys rk on rk.relation_id = r.id
    inner join field f on f.id = rk.field_id_pk
    inner join data_type dt on dt.id = f.data_type_id
    inner join relation_type rt on rt.id = r.relation_type_id
    where rt.name = 'MANY_TO_MANY';