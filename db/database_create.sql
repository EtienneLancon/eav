drop table if exists trigger_actions;
drop table if exists trigger_function;
drop table if exists "trigger";
drop table if exists trigger_type;
drop table if exists workflow;
drop table if exists data_int;
drop table if exists data_string;
drop table if exists data_int;
drop table if exists data_string;
drop table if exists data_timestamp;
drop table if exists data_bool;
drop table if exists data_float;
drop table if exists data_text;
drop table if exists relation_keys;
drop table if exists relation;
drop table if exists relation_type;
drop table if exists index_field;
drop table if exists index_field_type;
drop table if exists "index";
drop table if exists "row";
drop table if exists field;
drop table if exists data_type;
drop table if exists "table";
drop table if exists conf;
drop table if exists mv_data_lazyness;
drop table if exists mv_struct_lazyness;

create table mv_struct_lazyness
(
    id serial primary key,
    name varchar(20) not null
);

create unique index ux_name_mv_struct_lazyness on mv_struct_lazyness ("name");

create table mv_data_lazyness
(
    id serial primary key,
    name varchar(20) not null
);

create unique index ux_name_mv_data_lazyness on mv_data_lazyness ("name");

create table conf
(
    mv_data_lazyness_id int not null,
    mv_struct_lazyness_id int not null,
    constraint fk_mv_data_lazyness_id foreign key (mv_data_lazyness_id) references mv_data_lazyness (id),
    constraint fk_mv_struct_lazyness_id foreign key (mv_struct_lazyness_id) references mv_struct_lazyness (id)
);

create table "table"
(
	id serial primary key,
	name varchar(100) not null,
    struct_uptodate bool not null default false,
    data_uptodate bool not null default true
);

create unique index ux_name on "table" ("name");

create table data_type
(
    id serial primary key,
    name varchar(20) not null
);

create unique index ux_name_data_type on data_type ("name");

create table field
(
    id serial primary key,
    name varchar(100) not null,
    table_id int not null,
    data_type_id int not null,
    constraint fk_table_id foreign key (table_id) references "table" (id) on delete cascade,
    constraint fk_data_type_id foreign key (data_type_id) references data_type (id)
);

create unique index ux_name_table_id on field ("name", "table_id");

create table "index"
(
    id serial primary key,
    name varchar(100) not null,
    "unique" bool not null
);

create table index_field_type
(
    id serial primary key,
    "name" varchar(20) not null
);

create unique index ux_name_index_field_type on index_field_type ("name");

create table index_field
(
    id serial primary key,
    index_id int not null,
    field_id int not null,
    order_index int not null,
    index_field_type_id int not null,
    constraint fk_index_id foreign key (index_id) references "index" (id) on delete cascade,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_index_field_type_id foreign key (index_field_type_id) references index_field_type (id)
);

create unique index ux_index_id_field_id on index_field ("index_id", "field_id");
create unique index ux_index_id_order_index on index_field ("index_id", "index_field_type_id", "order_index");

create table "row"
(
    ui serial primary key,
    date_inserted timestamp not null default now(),
    date_updated timestamp,
    table_id int not null,
    constraint fk_table_id foreign key (table_id) references "table" (id) on delete cascade
);

CREATE table data_int
(
    field_id int not null,
    row_ui int not null,
    value int,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

CREATE table data_string
(
    field_id int not null,
    row_ui int not null,
    value varchar(255),
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

CREATE table data_timestamp
(
    field_id int not null,
    row_ui int not null,
    value timestamp,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

CREATE table data_bool
(
    field_id int not null,
    row_ui int not null,
    value boolean,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

CREATE table data_float
(
    field_id int not null,
    row_ui int not null,
    value float,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

CREATE table data_text
(
    field_id int not null,
    row_ui int not null,
    value text,
    constraint fk_field_id foreign key (field_id) references field (id) on delete cascade,
    constraint fk_row_ui foreign key (row_ui) references "row" (ui) on delete cascade
);

create unique index ux_field_id_row_ui_int on data_int ("field_id", "row_ui");
create unique index ux_field_id_row_ui_string on data_string ("field_id", "row_ui");
create unique index ux_field_id_row_ui_timestamp on data_timestamp ("field_id", "row_ui");
create unique index ux_field_id_row_ui_bool on data_bool ("field_id", "row_ui");
create unique index ux_field_id_row_ui_float on data_float ("field_id", "row_ui");
create unique index ux_field_id_row_ui_text on data_text ("field_id", "row_ui");

create table relation_type
(
    id serial primary key,
    name varchar(100) not null
);

create table complex_relation
(
    id serial primary key,
    name varchar(100) not null,
    cascade_delete bool not null,
    relation_type_id int not null,
    constraint fk_relation_type_id foreign key (relation_type_id) references relation_type (id)
);

create unique index ux_name_complex_relation on complex_relation ("name");

create table complex_relation_keys
(
    complex_relation_id int not null,
    field_id_pk int not null,
    field_id_fk int not null,
    constraint fk_relation_id foreign key (complex_relation_id) references complex_relation (id) on delete cascade,
    constraint fk_field_id_pk foreign key (field_id_pk) references field (id),
    constraint fk_field_id_fk foreign key (field_id_fk) references field (id)
);

create unique index ux_complex_relation_id_field_id_pk_field_id_fk on complex_relation_keys ("complex_relation_id", "field_id_pk", "field_id_fk");

create table simple_relation
(
    id serial primary key,
    name varchar(100) not null,
    cascade_delete bool not null,
    relation_type_id int not null,
    table_id_pk int not null,
    table_id_fk int not null,
    constraint fk_relation_type_id foreign key (relation_type_id) references relation_type (id),
    constraint fk_table_id_pk foreign key (table_id_pk) references "table" (id),
    constraint fk_table_id_fk foreign key (table_id_fk) references "table" (id)
);

create unique index ux_name_simple_relation on simple_relation ("name");
create unique index ux_table_id_pk_table_id_fk on simple_relation ("table_id_pk", "table_id_fk");

create table workflow
(
    id serial primary key,
    name varchar(100) not null,
    description varchar(255)
);

create table trigger_type
(
    id serial primary key,
    name varchar(100) not null
);

create table trigger_function
(
    id serial primary key,
    name varchar(100) not null,
    description varchar(255),
    lambda varchar(1000) not null
);

create table trigger
(
    id serial primary key,
    "name" varchar(100) not null,
    description varchar(255),
    workflow_id int not null,
    table_id int not null,
    trigger_type_id int not null,
    constraint fk_workflow_id foreign key (workflow_id) references workflow (id),
    constraint fk_table_id foreign key (table_id) references "table" (id),
    constraint fk_trigger_type_id foreign key (trigger_type_id) references trigger_type (id)
);

create unique index ux_name_workflow_id_table_id_trigger_type_id on trigger ("name", "workflow_id", "table_id", "trigger_type_id");

create table trigger_actions(
    trigger_id int not null,
    trigger_function_id int not null,
    constraint fk_trigger_id foreign key (trigger_id) references trigger (id),
    constraint fk_trigger_function_id foreign key (trigger_function_id) references trigger_function (id)
);

create unique index ux_trigger_id_trigger_function_id on trigger_actions ("trigger_id", "trigger_function_id");

insert into mv_data_lazyness
(name)
values
('EAGER'),
('LAZY');

insert into mv_struct_lazyness
(name)
values
('EAGER'),
('LAZY');

insert into conf
(mv_data_lazyness_id, mv_struct_lazyness_id)
values
(1, 2);

insert into relation_type
(name) 
values 
('ONE_TO_ONE'),
('MANY_TO_ONE'),
('MANY_TO_MANY');

insert into trigger_type 
(name)
values
('AFTER_INSERT'),
('AFTER_UPDATE'),
('AFTER_DELETE');

insert into data_type
(name) 
values 
('int'),
('string'),
('timestamp'),
('bool'),
('float'),
('text');

insert into index_field_type
(name)
values
('MAPPING'),
('INCLUDE');