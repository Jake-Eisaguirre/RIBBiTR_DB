set search_path = "e_dna";

-- add UUID extension 
create extension if not exists "uuid-ossp";
alter extension "uuid-ossp" set schema e_dna;

-- add UUID to location table
alter table edna_location 
add column location_id uuid default (e_dna.uuid_generate_v4());

alter table edna_location 
add primary key(location_id);

-- Region: add unique Id and join to location table
alter table edna_region 
add column region_id uuid default (e_dna.uuid_generate_v4());

alter table edna_region 
add primary key(region_id);

alter table edna_region 
add column location_id uuid;

update edna_region r
set location_id =
	(select l.location_id
	from edna_location l
	where l.location = r.location);
	
alter table edna_region  
add constraint fk_region foreign key (location_id) references edna_location (location_id);

-- Site: add unique id and join to region table
alter table edna_site 
add column site_id uuid default (e_dna.uuid_generate_v4());

alter table edna_site 
add primary key(site_id);

alter table edna_site 
add column region_id uuid;

update edna_site s 
set region_id = 
	(select region_id 
	from edna_region r
	where s.region = r.region);
	
alter table edna_site 
add constraint fk_site foreign key (region_id) references edna_region (region_id);

-- Visit: add unique id and join site table
alter table edna_visit 
add column visit_id uuid default (e_dna.uuid_generate_v4());

alter table edna_visit 
add primary key(visit_id);

alter table edna_visit 
add column site_id uuid;

update edna_visit v 
set site_id=
	(select site_id
	from edna_site s
	where (v.site) = (s.site));

alter table edna_visit 
add constraint fk_visit foreign key (site_id) references edna_site (site_id);

-- edna_panama_survey: add unique id and join table on site and date
alter table edna_panama_survey 
add column panama_survey_id uuid default (e_dna.uuid_generate_v4());

alter table edna_panama_survey 
add primary key(panama_survey_id);

alter table edna_panama_survey 
add column visit_id uuid;

update edna_panama_survey p
set visit_id =
	(select visit_id
	from edna_visit v
	where (p.site, p.date_collected) = (v.site, v.date_collected));

alter table edna_panama_survey 
add constraint fk_panama_survey foreign key (visit_id) references edna_visit (visit_id);

-- edna_serdp_bd: add unique id and join table on site and date
alter table edna_serdp_bd 
add column serdp_bd_id uuid default (e_dna.uuid_generate_v4());

alter table edna_serdp_bd
add primary key(serdp_bd_id);

alter table edna_serdp_bd 
add column visit_id uuid;

update edna_serdp_bd s 
set visit_id =
	(select visit_id
	from edna_visit v
	where (s.site_code, s.date_collected) = (v.site_code, v.date_collected));
	
alter table edna_serdp_bd 
add constraint fk_serdp_bd foreign key (visit_id) references edna_visit (visit_id);
	
-- drop columns

---- region
alter table edna_region 
drop column location;

---- site
alter table edna_site 
drop column region;

alter table edna_site 
drop column date_collected;

----- visit
alter table edna_visit 
drop column site;

alter table edna_visit 
drop column site_code;

---- panama survye
alter table edna_panama_survey 
drop column region;

alter table edna_panama_survey 
drop column site;

alter table edna_panama_survey 
drop column date_collected;

----- serpd_bd
alter table edna_serdp_bd 
drop column site_code;

alter table edna_serdp_bd 
drop column date_collected;

alter table edna_serdp_bd 
drop column region
	
	
	
	
