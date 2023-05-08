drop view if exists v_simple_relations;

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