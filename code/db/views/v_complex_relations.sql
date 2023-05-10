set search_path to eav;

drop view if exists v_complex_relations;

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