set search_path to eav;

delete from "simple_relation";
delete from "table";
delete from "field";
delete from "index";
delete from "index_field";

alter sequence "table_id_seq" restart with 1;
alter sequence "field_id_seq" restart with 1;
alter sequence "index_id_seq" restart with 1;
alter sequence "index_field_id_seq" restart with 1;
alter sequence "simple_relation_id_seq" restart with 1;


insert into "table" ("name") values ('ville');
insert into "table" ("name") values ('personne');

insert into "field" ("name", "table_id", "data_type_id") values
('nom', 1, 2),
('code_postal', 1, 1),
('nom', 2, 2),
('prenom', 2, 2);


insert into simple_relation ("name", cascade_delete, relation_type_id, table_id_pk, table_id_fk) values ('ville_personne', true, 2, 1, 2);

insert into "index" ("name", "unique") values ('personne_nom_prenom', true);
insert into index_field (index_id, field_id, index_field_type_id, order_index) values (1, 3, 1, 1);
insert into index_field (index_id, field_id, index_field_type_id, order_index) values (1, 4, 1, 2);
insert into "index" ("name", "unique") values ('ville_code_postal', true);
insert into index_field (index_id, field_id, index_field_type_id, order_index) values (2, 2, 1, 1);
insert into index_field (index_id, field_id, index_field_type_id, order_index) values (2, 1, 2, 1);


select refresh_tables();


select insert_ville(75000, 'Paris');
select insert_ville(69000, 'Lyon');
select insert_personne(1, 'Dupont', 'Jean');
select insert_personne(2, 'Moulin', 'Michel');



