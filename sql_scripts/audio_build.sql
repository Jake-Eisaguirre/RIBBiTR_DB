set search_path = 'audio';

-- location
alter table audio_location 
add primary key(location_id);

-- region
alter table audio_region 
add primary key(region_id);

update audio_region r 
set location_id = 
	(select l.location_id
	from audio_location l
	where l.location = r.location);
	
alter table audio_region 
add constraint fk_audio_region foreign key (location_id)
references audio_location (location_id);

-- site
alter table audio_site 
add primary key(site_id);

update audio_site s 
set region_id =
	(select r.region_id
	from audio_region r
	where r.region = s.region);
	
alter table audio_site 
add constraint fk_audio_site foreign key (region_id)
references audio_region (region_id);

-- visit
alter table audio_visit 
add primary key(visit_id);

update audio_visit v 
set site_id =
	(select s.site_id
	from audio_site s
	where s.site = v.site);

alter table audio_visit
add constraint fk_audio_visit foreign key (site_id)
references audio_site (site_id);

-- audio_info
alter table audio_info 
add primary key(audio_id);

update audio_info a 
set visit_id = 
	(select v.visit_id 
	from audio_visit v 
	where (v.date_of_deployment, v.site) = (a.date_of_deployment, a.site));

alter table audio_info 
add constraint fk_audio_info foreign key (visit_id)
references audio_visit (visit_id);

-- drop columns 

--region
alter table audio_region 
drop column region;

-- site
alter table audio_site 
drop column region;

-- audio visit
alter table audio_visit 
drop column site;

-- info
alter table audio_info 
drop column site;

alter table audio_info 
drop column date_of_deployment;


select al.location, ar.location, ar.region, as2.site, as2.region, av.site,
av.date_of_deployment, ai.site, ai.date_of_deployment
from audio_location al 
join audio_region ar on al.location_id = ar.location_id 
join audio_site as2 on ar.region_id = as2.region_id 
join audio_visit av on as2.site_id = av.site_id 
join audio_info ai on av.visit_id = ai.visit_id;