drop view if exists v_schema;
drop view if exists v_simple_relations;
drop view if exists v_complex_relations;
drop view if exists v_indexes;
drop view if exists v_lazyness;

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

create view v_simple_relations as
    select
        r.id as relation_id,
        r.name as relation_name,
        r.cascade_delete as cascade_delete,
        t.name as relation_type,
        pk.id as pk_id,
        pk.name as pk_name,
        fk.id as fk_id,
        fk.name as fk_name
    from simple_relation r
    inner join relation_type t on t.id = r.relation_type_id
    inner join "table" pk on pk.id = r.table_id_pk
    inner join "table" fk on fk.id = r.table_id_fk;

create view v_complex_relations as
    select
        r.id as relation_id,
        r.name as relation_name,
        r.cascade_delete as cascade_delete,
        t.name as relation_type,
        pk.id as pk_id,
        pk.name as pk_name,
        fk.id as fk_id,
        fk.name as fk_name
    from complex_relation r
    inner join relation_type t on t.id = r.relation_type_id
    inner join complex_relation_keys k on k.complex_relation_id = r.id
    inner join field pk on pk.id = k.field_id_pk
    inner join field fk on fk.id = k.field_id_fk;

create view v_indexes as
    select
        i.id as index_id,
        i.name as index_name,
        i.unique as unique_index,
        fi.id as index_field_id,
        fi.order_index as order_index,
        t.id as table_id,
        t.name as table_name,
        f.id as field_id,
        f.name as field_name,
        ft.name as field_type
    from "index" i
    inner join index_field fi on fi.index_id = i.id
    inner join index_field_type ft on ft.id = fi.index_field_type_id
    inner join field f on f.id = fi.field_id
    inner join "table" t on t.id = f.table_id
    order by i.id, ft.id, fi.order_index;

create view v_lazyness as
    select
        s.name as struct_lazyness,
        d.name as data_lazyness
    from conf c
    inner join mv_data_lazyness d on d.id = c.mv_data_lazyness_id
    inner join mv_struct_lazyness s on s.id = c.mv_struct_lazyness_id;