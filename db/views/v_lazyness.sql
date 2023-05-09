set search_path to eav;

drop view if exists v_lazyness;

create view v_lazyness as
    select
        s.name as struct_lazyness,
        d.name as data_lazyness
    from conf c
    inner join mv_data_lazyness d on d.id = c.mv_data_lazyness_id
    inner join mv_struct_lazyness s on s.id = c.mv_struct_lazyness_id;