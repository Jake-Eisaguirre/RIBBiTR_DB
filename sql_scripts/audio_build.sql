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

select l.location, r.region, r.location, s.site, s.region, v.site
from audio_location l
join audio_region r on l.location_id = r.location_id 
join audio_site s on r.region_id = s.region_id
join audio_visit v on s.site_id = v.site_id;
