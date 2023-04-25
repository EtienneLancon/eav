drop trigger if exists on_field_insert_update_create_materialized_views on field;
drop trigger if exists on_field_delete_create_materialized_views on field;
drop trigger if exists on_delete_row_refresh_materialized_views on "row";
drop trigger if exists on_insert_update_row_refresh_materialized_views on "row";


create trigger on_field_insert_update_create_materialized_views
    after insert or update on field
    for each row
    execute function on_field_insert_update_create_materialized_views();

create trigger on_field_delete_create_materialized_views
    after delete on field
    for each row
    execute function on_field_delete_create_materialized_views();

create trigger on_insert_update_row_refresh_materialized_views
    after insert or update on "row"
    for each row
    execute function on_insert_update_row_refresh_materialized_views();

create trigger on_delete_row_refresh_materialized_views
    after delete on "row"
    for each row
    execute function on_delete_row_refresh_materialized_views();