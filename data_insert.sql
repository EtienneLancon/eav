insert into relation_type
(name) 
values 
('ONE_TO_ONE'),
('ONE_TO_MANY'),
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

insert into "table" 
("name")
values
('operation'),
('prestation'),
('piquetage');

insert into field 
("name", "data_type_id", "table_id")
values
('no', 1, 1),
('designation', 2, 1),
('description', 2, 2),
('date_demarage', 3, 2),
('date_fin', 3, 2),
('montant_ht', 5, 3);