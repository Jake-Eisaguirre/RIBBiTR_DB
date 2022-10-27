set search_path = "survey_data";

-- add UUID extension 
create extension if not exists "uuid-ossp";

-- Location: add unique ID and p.key
alter table "location" 
add column location_id UUID default (survey_data.uuid_generate_v4());

alter table "location" 
add primary key(location_id);

-- Region: add unique ID, p.key, join id on location, and create f.key
alter table region 
add column region_id UUID default (survey_data.uuid_generate_v4());

alter table region 
add primary key(region_id);

alter table region 
add column location_id uuid;

update region r
set location_id = 
	(select rs.location_id 
	from "location" rs
	where rs.location = r.location);

alter table region  
add constraint fk_region foreign key (location_id) references location (location_id);

-- Site: add unique ID, p.key, join id on region, and create f.key
alter table site 
add column site_id UUID default (survey_data.uuid_generate_v4());

alter table site 
add primary key(site_id);

alter table site 
add column region_id uuid;

update site s 
set region_id =
	(select r.region_id
	 from region r 
	 where r.region = s.region);
	 
alter table site 
add constraint fk_site foreign key (region_id) references region (region_id);

-- Visit: add unique ID. p.eky, join id on site, and create f.key
alter table visit 
add column visit_id UUID default (survey_data.uuid_generate_v4());

alter table visit
add primary key(visit_id);

alter table visit 
add column site_id uuid;

alter table visit 
alter column "date" type date using ("date"::text::date);

update visit v 
set site_id =
	(select s.site_id
	 from site s
	 where s.site = v.site);
	
alter table visit 
add constraint fk_visit foreign key (site_id) references site (site_id);


--Penn_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table penn_survey 
add column penn_survey_id UUID default (survey_data.uuid_generate_v4());

alter table penn_survey 
add primary key(penn_survey_id);

alter table penn_survey 
add column visit_id UUID;

alter table penn_survey 
alter column "date" type date using ("date"::text::date);

update penn_survey ps 
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site, v."date", v.survey_time) = (ps.site, ps."date", ps.survey_time));

alter table penn_survey 
add constraint fk_penn_survey foreign key (visit_id) references visit (visit_id);

-- Panama_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table panama_survey 
add column panama_survey_id UUID default (survey_data.uuid_generate_v4());

alter table panama_survey 
add primary key(panama_survey_id);

alter table panama_survey 
add column visit_id UUID;

alter table panama_survey 
alter column "date" type date using ("date"::text::date);

update panama_survey pas 
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site, v."date", v.survey_time) = (pas.site, pas."date", pas.survey_time));

alter table panama_survey 
add constraint fk_panama_survey foreign key (visit_id) references visit (visit_id);

-- Serdp_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table serdp_survey 
add column serdp_survey_id UUID default (survey_data.uuid_generate_v4());

alter table serdp_survey 
add primary key(serdp_survey_id);

alter table serdp_survey 
add column visit_id UUID;

alter table serdp_survey 
alter column "date" type date using ("date"::text::date);

update serdp_survey ss 
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site_code, v."date", v.survey_time) = (ss.site_code, ss."date", ss.survey_time));
	
alter table serdp_survey 
add constraint fk_serdp_survey foreign key (visit_id) references visit (visit_id);

-- Brazil_legacy_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table brazil_legacy_survey 
add column brazil_legacy_survey_id UUID default (survey_data.uuid_generate_v4());

alter table brazil_legacy_survey 
add primary key(brazil_legacy_survey_id);

alter table brazil_legacy_survey 
add column visit_id UUID;

alter table brazil_legacy_survey 
alter column "date" type date using ("date"::text::date);

update brazil_legacy_survey bl
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site, v."date", v.survey_time, v.campaign) = (bl.site, bl."date", bl.survey_time, bl.campaign));

alter table brazil_legacy_survey 
add constraint fk_brazil_legacy_survey foreign key (visit_id) references visit (visit_id);

-- sierra_nevada_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table sierra_nevada_survey 
add column sierra_nevada_survey_id UUID default (survey_data.uuid_generate_v4());

alter table sierra_nevada_survey 
add primary key(sierra_nevada_survey_id);

alter table sierra_nevada_survey
add column visit_id UUID;

alter table sierra_nevada_survey 
alter column "date" type date using ("date"::text::date);

alter table sierra_nevada_survey 
alter column site type text;

update sierra_nevada_survey sn 
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site, v."date", v.survey_time) = (sn.site, sn."date", sn.survey_time));

alter table sierra_nevada_survey 
add constraint fk_sierra_nevada_survey foreign key (visit_id) references visit (visit_id);

	
-- VES: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key 	
alter table ves 
add column ves_id UUID default (survey_data.uuid_generate_v4());

alter table ves 
add primary key(ves_id);

alter table ves 
add column penn_survey_id UUID;

alter table ves 
add column panama_survey_id UUID;

alter table ves 
add column sierra_nevada_survey_id UUID;

alter table ves 
alter column "date" type date using ("date"::text::date);

--------- VES to panama_survey w/ f.key
update ves v 
set panama_survey_id = 
    (select ps.panama_survey_id
    from panama_survey ps
    where (ps.site, ps."date", ps.survey_time, ps.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
   
alter table ves 
add constraint fk_ves_panama foreign key (panama_survey_id) references panama_survey (panama_survey_id);


--------- VES to sierra_nevada_survey w/ f.key
update ves v
set sierra_nevada_survey_id =
	(select sns.sierra_nevada_survey_id
	from sierra_nevada_survey sns
    where (sns.site, sns."date", sns.survey_time, sns.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
	
alter table ves 
add constraint fk_ves_sierra_nevada foreign key (sierra_nevada_survey_id) references sierra_nevada_survey (sierra_nevada_survey_id);
   
--------- VES to penn_survey
update ves v 
set  penn_survey_id =
	(select pes.penn_survey_id
	from penn_survey pes
	where (pes.site, pes."date", pes.survey_time, pes.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));

alter table ves
add constraint fk_ves_penn foreign key (penn_survey_id) references penn_survey (penn_survey_id);


-- Aural: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key
alter table aural 
add column aural_id UUID default (survey_data.uuid_generate_v4());

alter table aural 
add primary key(aural_id);

alter table aural 
add column penn_survey_id uuid;

alter table aural 
add column panama_survey_id uuid;

alter table aural 
alter column "date" type date using ("date"::text::date);

--------- Aural to panama_survey w/ f.key
update aural v 
set panama_survey_id = 
    (select pa.panama_survey_id
    from panama_survey pa
    where (pa.site, pa."date", pa.survey_time, pa.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
   
alter table aural 
add constraint fk_aural_panama foreign key (panama_survey_id) references panama_survey (panama_survey_id);
	
--------- Aural to penn_survey w/ f.key
update aural v 
set  penn_survey_id =
	(select pe.penn_survey_id
	from penn_survey pe
	where (pe.site, pe."date", pe.survey_time, pe.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));

alter table aural
add constraint fk_aural_penn foreign key (penn_survey_id) references penn_survey (penn_survey_id);

-- Capture: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key
alter table capture
add column capture_id UUID default (survey_data.uuid_generate_v4());

alter table capture 
add primary key(capture_id);

alter table capture 
add column penn_survey_id uuid;

alter table capture 
add column brazil_legacy_survey_id uuid;

alter table capture 
add column serdp_survey_id uuid;

alter table capture 
add column panama_survey_id uuid;

alter table capture 
add column sierra_nevada_survey_id uuid;

alter table capture  
alter column "date" type date using ("date"::text::date);

------- Capture to penn_survey
update capture c 
set penn_survey_id =
	(select psi.penn_survey_id
	from penn_survey psi
	where (psi.site, psi."date", psi.survey_time, psi.detection_type) = (c.site, c."date", c.survey_time, c.detection_type));

alter table capture
add constraint fk_capture_penn foreign key (penn_survey_id) references penn_survey (penn_survey_id);


------- Capture to panama_survey
update capture c 
set panama_survey_id =
	(select pan.panama_survey_id
	from panama_survey pan
	where (pan.site, pan."date", pan.survey_time, pan.detection_type) = (c.site, c."date", c.survey_time, c.detection_type));

alter table capture
add constraint fk_capture_panama foreign key (panama_survey_id) references panama_survey (panama_survey_id);

-------- Capture to sierra_nevada_survey
update capture c 
set sierra_nevada_survey_id = 
	(select sni.sierra_nevada_survey_id
	from sierra_nevada_survey sni
	where (sni.site, sni."date", sni.survey_time, sni.detection_type) = (c.site, c."date", c.survey_time, c.detection_type));

alter table capture
add constraint fk_capture_sierra_nevada foreign key (sierra_nevada_survey_id) references sierra_nevada_survey (sierra_nevada_survey_id);


------- Capture to serdp_survey
update capture c 
set serdp_survey_id =
	(select serd.serdp_survey_id
	from serdp_survey serd
	where (serd.site_code, serd."date", serd.survey_time, serd.detection_type) = (c.site_code, c."date", c.survey_time, c.detection_type));

alter table capture
add constraint fk_capture_serdp foreign key (serdp_survey_id) references serdp_survey (serdp_survey_id);


------ Capture to brazil_legacy_survey 
update capture c 
set brazil_legacy_survey_id = 
	(select z.brazil_legacy_survey_id
	from brazil_legacy_survey z
	where (z.site, z."date", z.survey_time, z.detection_type) = (c.site, c."date", c.survey_time, c.detection_type));

alter table capture 
add constraint fk_capture_brazil_legacy foreign key (brazil_legacy_survey_id) references brazil_legacy_survey (brazil_legacy_survey_id);

------ serdp_bd_genomic to capture (probs need to create seperate IDs until missing data is found)

alter table serdp_bd_genomic 
add column serdp_bd_genomic_id UUID default (survey_data.uuid_generate_v4());

alter table serdp_bd_genomic 
add primary key(serdp_bd_genomic_id);

alter table capture
add column serdp_bd_genomic_id UUID;

update capture c 
set serdp_bd_genomic_id =
	(select v.serdp_bd_genomic_id
	from serdp_bd_genomic v
	where (v.genetic_id) = (c.genetic_id));

alter table capture 
add constraint fk_serdp_bd_genomic foreign key (serdp_bd_genomic_id) references serdp_bd_genomic (serdp_bd_genomic_id);


-- genomic data check
--select l.location, r.location, r.region, s.site, s.region, s.location, 
--v.date, v.site, v.survey_time, ss.date, ss.survey_time, c.site, c.date,
--c.survey_time, c.genetic_id,  sbg.genetic_id
--from "location" l 
--join region r on l.location_id = r.location_id 
--join site s on r.region_id = s.region_id 
--join visit v on s.site_id = v.site_id 
--join serdp_survey ss on v.visit_id = ss.visit_id 
--join capture c on ss.serdp_survey_id = c.serdp_survey_id 
--join serdp_bd_genomic sbg on c.serdp_bd_genomic_id = sbg.serdp_bd_genomic_id 

--select l.location, r.region, r.location, s.site, s.region, s.location,
--v.date, v.site, v.survey_time, ps.site, ps.date, ps.survey_time,
--pes.site, pes.date, pes.survey_time
--from location l
--join region r on l.location_id = r.location_id 
--join site s on r.region_id = s.region_id 
--join visit v on s.site_id = v.site_id 
--join panama_survey ps on v.visit_id = ps.visit_id 
--join brazil_legacy_survey pes on v.visit_id = pes.visit_id 
--
---- Data Check
--
--select 'penn' as survey, v.date as visit_date, v.site as visit_site, 
--  ps.date as survey_date, ps.site as survey_site
--from visit v 
--join penn_survey ps on ps.visit_id = v.visit_id 
--union 
--select 'brazil', v.date, v.site, b.date, b.site
--from visit v 
--join brazil_legacy_survey b on b.visit_id = v.visit_id 
--union
--select 'sn', v.date, v.site, sn.date, sn.site
--from visit v
--join sierra_nevada_survey sn on sn.visit_id = v.visit_id 
--union 
--select 'serdp', v.date, v.site, s.date, s.site
--from visit v
--join serdp_survey s on s.visit_id = v.visit_id;


