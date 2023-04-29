insert into "table" ("name") values ('ville');
insert into "table" ("name") values ('personne');

insert into "field" ("name", "table_id", "data_type_id") values
('nom', 1, 2),
('code_postal', 1, 1),
('nom', 2, 2),
('prenom', 2, 2);


insert into simple_relation ("name", cascade_delete, relation_type_id, table_id_pk, table_id_fk) values ('ville_personne', true, 2, 1, 2);

insert into "index" ("name", "unique", "table_id") values ('personne_nom_prenom', true, 2);
insert into index_field (index_id, field_id, index_field_type_id) values (1, 3, 1);
insert into index_field (index_id, field_id, index_field_type_id) values (1, 4, 1);
insert into "index" ("name", "unique", "table_id") values ('ville_code_postal', true, 1);
insert into index_field (index_id, field_id, index_field_type_id) values (2, 2, 1);
insert into index_field (index_id, field_id, index_field_type_id) values (2, 1, 2);


select insert_ville(75000, 'Paris');
select insert_ville(69000, 'Lyon');
select insert_personne(1, 'Dupont', 'Jean');
select insert_personne(2, 'Moulin', 'Michel');



