drop view if exists v_schema;
drop table if exists trigger_actions;
drop table if exists trigger_function;
drop table if exists "trigger";
drop table if exists trigger_type;
drop table if exists workflow;
drop table if exists data_int;
drop table if exists data_string;drop view if exists v_schema;
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

create table "table"
(
	id serial primary key,
	name varchar(100) not null
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
    constraint fk_table_id foreign key (table_id) references "table" (id),
    constraint fk_data_type_id foreign key (data_type_id) references data_type (id)
);

create unique index ux_name_table_id on field ("name", "table_id");

create table "index"
(
    id serial primary key,
    name varchar(100) not null,
    table_id int not null,
    "unique" bool not null,
    constraint fk_table_id foreign key (table_id) references "table" (id)
);

create unique index ux_index_name_table_id on "index" ("name", "table_id");

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
    index_field_type_id int not null,
    constraint fk_index_id foreign key (index_id) references "index" (id),
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_index_field_type_id foreign key (index_field_type_id) references index_field_type (id)
);

create unique index ux_index_id_field_id on index_field ("index_id", "field_id");

create table "row"
(
    id serial primary key,
    date_inserted timestamp not null,
    date_updated timestamp,
    table_id int not null,
    constraint fk_table_id foreign key (table_id) references "table" (id)
);

CREATE table data_int
(
    field_id int not null,
    row_id int not null,
    value int,
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

CREATE table data_string
(
    field_id int not null,
    row_id int not null,
    value varchar(255),
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

CREATE table data_timestamp
(
    field_id int not null,
    row_id int not null,
    value timestamp,
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

CREATE table data_bool
(
    field_id int not null,
    row_id int not null,
    value boolean,
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

CREATE table data_float
(
    field_id int not null,
    row_id int not null,
    value float,
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

CREATE table data_text
(
    field_id int not null,
    row_id int not null,
    value text,
    constraint fk_field_id foreign key (field_id) references field (id),
    constraint fk_row_id foreign key (row_id) references "row" (id)
);

create unique index ux_field_id_row_id_int on data_int ("field_id", "row_id");
create unique index ux_field_id_row_id_string on data_string ("field_id", "row_id");
create unique index ux_field_id_row_id_timestamp on data_timestamp ("field_id", "row_id");
create unique index ux_field_id_row_id_bool on data_bool ("field_id", "row_id");
create unique index ux_field_id_row_id_float on data_float ("field_id", "row_id");
create unique index ux_field_id_row_id_text on data_text ("field_id", "row_id");

create table relation_type
(
    id serial primary key,
    name varchar(100) not null
);

create table relation
(
    id serial primary key,
    name varchar(100) not null,
    relation_type_id int not null,
    constraint fk_relation_type_id foreign key (relation_type_id) references relation_type (id)
);

create unique index ux_name_relation on relation ("name");

create table relation_keys
(
    relation_id int not null,
    field_id_pk int not null,
    field_id_fk int not null,
    constraint fk_relation_id foreign key (relation_id) references relation (id),
    constraint fk_field_id_pk foreign key (field_id_pk) references field (id),
    constraint fk_field_id_fk foreign key (field_id_fk) references field (id)
);

create unique index ux_relation_id_field_id_pk_field_id_fk on relation_keys ("relation_id", "field_id_pk", "field_id_fk");


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