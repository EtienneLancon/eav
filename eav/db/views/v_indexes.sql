set search_path to eav;

drop view if exists v_indexes;

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