set search_path = "hobo";

-- Hobo site table
alter table hobo_site
add column hobo_site_id UUID default (public.uuid_generate_v4());

alter table hobo_site 
add primary key(hobo_site_id);

-- Soil hobo: add unique ID, join f.key, on site_code
alter table soil_hobo 
add column soil_hobo_id UUID default (public.uuid_generate_v4());

alter table soil_hobo 
add column hobo_site_id UUID;

alter table soil_hobo 
add primary key(soil_hobo_id);

update soil_hobo sh
set hobo_site_id =
	(select hs.hobo_site_id
	from hobo_site hs
	where (hs.site_code) = (sh.site_code));

alter table soil_hobo 
add constraint fk_soil_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);

-- Water hobo: add unique ID, join f.key, on site_code
alter table water_hobo 
add column water_hobo_id UUId default (public.uuid_generate_v4());

alter table water_hobo 
add column hobo_site_id UUID;

alter table water_hobo 
add primary key(water_hobo_id);

update water_hobo wh
set hobo_site_id =
	(select hs.hobo_site_id
	from hobo_site hs
	where (hs.site_code) = (wh.site_code));

alter table water_hobo 
add constraint fk_water_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);

-- Sun hobo: add unique ID, join f.key, on site_code
alter table sun_hobo 
add column sun_hobo_id UUID default (public.uuid_generate_v4());

alter table sun_hobo 
add column hobo_site_id UUID;

alter table sun_hobo 
add primary key(sun_hobo_id);

update sun_hobo sh 
set hobo_site_id =
	(select hs.hobo_site_id
	from hobo_site hs
	where (hs.site_code)= (sh.site_code));

alter table sun_hobo 
add constraint fk_sun_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id); 

-- Shade hobo: add unique ID, join f.key, on site_code
alter table shade_hobo 
add column shade_hobo_id UUID default (public.uuid_generate_v4());

alter table shade_hobo 
add column hobo_site_id UUID;

alter table shade_hobo 
add primary key(shade_hobo_id);

update shade_hobo sh
set hobo_site_id =
	(select hs.hobo_site_id
	from hobo_site hs
	where (hs.site_code) = (sh.site_code));

alter table shade_hobo 
add constraint fk_shade_hobo foreign key (hobo_site_id) references hobo_site (hobo_site_id);
	
