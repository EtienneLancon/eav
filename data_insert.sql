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
('INCLUDE')