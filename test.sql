select id, date_inserted, date_updated 
from "row" 
left join (select * 
			from crosstab('select data_string.row_id, f.name data_string.value 
							from data_string 
							inner join field f on data_string.field_id = f.id 
							where f.table_id = 2') as ct(row_id int, description varchar(100))) as req_str on "row".id = req_str.row_id 