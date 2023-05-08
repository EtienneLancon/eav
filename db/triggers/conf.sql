drop trigger if exists on_conf_insert on conf;

create or replace function on_conf_insert()
returns trigger
language plpgsql
as $function$
begin
    if exists (select 1 from conf) then
        raise exception 'There can be only one row in conf table';
    end if;
    return new;
end;
$function$
;

create trigger on_conf_insert
    before insert on conf
    for each row
    execute function on_conf_insert();