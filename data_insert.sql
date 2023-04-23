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

insert into index_field_type
(name)
values
('MAPPING'),
('INCLUDE')