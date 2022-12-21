set search_path = "hobo";

-- add UUID extension 
create extension if not exists "uuid-ossp";
alter extension "uuid-ossp" set schema hobo;

-- Hobo location table
alter table hobo_location
add column hobo_location_id UUID default (hobo.uuid_generate_v4());

alter table hobo_location 
add primary key(hobo_location_id);

-- Hobo region table
alter table hobo_region 
add column hobo_region_id UUID default (hobo.uuid_generate_v4());

alter table hobo_region
add primary key(hobo_region_id);

alter table hobo_region 
add column hobo_location_id uuid;

update hobo_region hr
set hobo_location_id = 
	(select hs.hobo_location_id
	from hobo_location hs
	where hs.location = hr.location);

alter table hobo_region  
add constraint fk_region_hobo foreign key (hobo_location_id) references hobo_location (hobo_location_id);


-- Hobo site table
alter table hobo_site
add column hobo_site_id UUID default (hobo.uuid_generate_v4());

alter table hobo_site 
add primary key(hobo_site_id);

alter table hobo_site 
add column hobo_region_id uuid;

update hobo_site hs 
set hobo_region_id =
	(select hr.hobo_region_id
	from hobo_region hr
	where hr.region = hs.region);
	
alter table hobo_site 
add constraint fk_site_hobo foreign key (hobo_region_id) references hobo_region (hobo_region_id);


-- hobo table
alter table hobo 
add column hobo_id UUID default (hobo.uuid_generate_v4());

alter table hobo 
add primary key(hobo_id);

alter table hobo 
add column hobo_site_id uuid;

update hobo h 
set hobo_site_id =
	(select hs.hobo_site_id
	from hobo_site hs
	where hs.site_code = h.site_code);

alter table hobo 
add constraint fk_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);

-- drop columns

--- region
alter table hobo_region 
drop column location;

--- site
alter table hobo_site 
drop column region;

alter table hobo_site 
drop column location;

---- hobo
alter table hobo
drop column site_code;




-- Soil hobo: add unique ID, join f.key, on site_code
--alter table soil_hobo 
--add column soil_hobo_id UUID default (hobo.uuid_generate_v4());
--
--alter table soil_hobo 
--add column hobo_site_id UUID;
--
--alter table soil_hobo 
--add primary key(soil_hobo_id);
--
--update soil_hobo sh
--set hobo_site_id =
--	(select hs.hobo_site_id
--	from hobo_site hs
--	where (hs.site_code) = (sh.site_code));
--
--alter table soil_hobo 
--add constraint fk_soil_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);
--
-- Water hobo: add unique ID, join f.key, on site_code
--alter table water_hobo 
--add column water_hobo_id UUId default (hobo.uuid_generate_v4());
--
--alter table water_hobo 
--add column hobo_site_id UUID;
--
--alter table water_hobo 
--add primary key(water_hobo_id);
--
--update water_hobo wh
--set hobo_site_id =
--	(select hs.hobo_site_id
--	from hobo_site hs
--	where (hs.site_code) = (wh.site_code));
--
--alter table water_hobo 
--add constraint fk_water_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);
--
-- Sun hobo: add unique ID, join f.key, on site_code
--alter table sun_hobo 
--add column sun_hobo_id UUID default (hobo.uuid_generate_v4());
--
--alter table sun_hobo 
--add column hobo_site_id UUID;
--
--alter table sun_hobo 
--add primary key(sun_hobo_id);
--
--update sun_hobo sh 
--set hobo_site_id =
--	(select hs.hobo_site_id
--	from hobo_site hs
--	where (hs.site_code)= (sh.site_code));
--
--alter table sun_hobo 
--add constraint fk_sun_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id); 
--
-- Shade hobo: add unique ID, join f.key, on site_code
--alter table shade_hobo 
--add column shade_hobo_id UUID default (hobo.uuid_generate_v4());
--
--alter table shade_hobo 
--add column hobo_site_id UUID;
--
--alter table shade_hobo 
--add primary key(shade_hobo_id);
--
--update shade_hobo sh
--set hobo_site_id =
--	(select hs.hobo_site_id
--	from hobo_site hs
--	where (hs.site_code) = (sh.site_code));
--
--alter table shade_hobo 
--add constraint fk_shade_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);
--
--	
