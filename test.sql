insert into "table" ("name") values ('ville');
insert into "table" ("name") values ('personne');

insert into "field" ("name", "table_id", "data_type_id") values
('id', 1, 1),
('nom', 1, 2),
('code_postal', 1, 1),
('id', 2, 1),
('nom', 2, 2),
('prenom', 2, 2),
('ville_id', 2, 1);

insert into relation ("name", "relation_type_id") values
('personne_ville', 2);

insert into relation_keys ("relation_id", "field_id_pk", "field_id_fk") values
(1, 1, 6);

insert into "index" ("name", "table_id", "unique") values
('ix_ville_code_postal', 2, True);

insert into index_field ("index_id", "field_id", "index_field_type_id") values
(1, 3, 1),
(1, 2, 2);

insert into "row" (date_inserted, date_updated, table_id) values
(now(), now(), 1);

insert into data_int ("row_ui", "field_id", "value") values
(1, 1, 1),
(1, 3, 75000);

insert into data_string ("row_ui", "field_id", "value") values
(1, 2, 'Paris');

insert into "row" (date_inserted, date_updated, table_id) values
(now(), now(), 2);

insert into data_int ("row_ui", "field_id", "value") values
(2, 4, 1),
(2, 7, 1);

insert into data_string ("row_ui", "field_id", "value") values
(2, 5, 'Dupont'),
(2, 6, 'Jean');





