set search_path = "survey_data";

-- add UUID extension 
create extension if not exists "uuid-ossp";
alter extension "uuid-ossp" set schema survey_data;

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

--Survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
alter table survey 
add column survey_id UUID default (survey_data.uuid_generate_v4());

alter table survey 
add primary key(survey_id);

alter table survey 
add column visit_id UUID;

alter table survey 
alter column "date" type date using ("date"::text::date);

update survey ps 
set visit_id =
	(select v.visit_id
	from visit v
	where (v.site, v."date", v.survey_time) = (ps.site, ps."date", ps.survey_time));

alter table survey 
add constraint fk_survey foreign key (visit_id) references visit (visit_id);



	
-- VES: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key 	
alter table ves 
add column ves_id UUID default (survey_data.uuid_generate_v4());

alter table ves 
add primary key(ves_id);

alter table ves 
add column survey_id UUID;

alter table ves 
alter column "date" type date using ("date"::text::date);

update ves v 
set survey_id = 
    (select ps.survey_id
    from survey ps
    where (ps.site, ps."date", ps.survey_time, ps.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
   
alter table ves 
add constraint fk_ves foreign key (survey_id) references survey (survey_id);




-- Aural: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key
alter table aural 
add column aural_id UUID default (survey_data.uuid_generate_v4());

alter table aural 
add primary key(aural_id);

alter table aural 
add column survey_id uuid;

alter table aural 
alter column "date" type date using ("date"::text::date);

update aural v 
set survey_id = 
    (select pa.survey_id
    from survey pa
    where (pa.site, pa."date", pa.survey_time, pa.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
   
alter table aural 
add constraint fk_aural foreign key (survey_id) references survey (survey_id);
	 

-- Capture: add unique ID, p.key, join id on site/date/survey_time/detection_type, and create f.key
alter table capture
add column capture_id UUID default (survey_data.uuid_generate_v4());

alter table capture 
add primary key(capture_id);

alter table capture 
add column survey_id uuid;

alter table capture  
alter column "date" type date using ("date"::text::date);

update capture c 
set survey_id =
	(select psi.survey_id
	from survey psi
	where (psi.site, psi."date", psi.survey_time, psi.detection_type) = (c.site, c."date", c.survey_time, c.detection_type));

alter table capture
add constraint fk_capture foreign key (survey_id) references survey (survey_id);

-- serdp_bd_genomic create primary key
alter table serdp_bd_genomic 
add primary key(genetic_id);


-- serdp newt create mult primary key
alter table serdp_newt_microbiome_mucosome_antifungal 
add primary key(microbiome_swab_id, mucosome_id);


-- serdp amp create primary key
alter table serdp_amp 
add primary key(amp_id);


-- serdp bd create primary key - dub IDs
alter table serdp_bd 
add primary key(bd_swab_id);

-- temp panama bd creat primary key - dub IDs
alter table panama_bd_temp 
add primary key(bd_swab_id);



-- serdp_edna table
--alter table serdp_edna
--add column serdp_edna_id UUID default (survey_data.uuid_generate_v4());

--alter table serdp_edna 
--add primary key(serdp_edna_id);

--alter table serdp_survey 
--add column serdp_edna_id UUID;

--alter table serdp_edna  
--alter column date_collected type date using (date_collected::text::date);

--update serdp_survey v 
--set serdp_edna_id = 
	--(select s.serdp_edna_id
	--from serdp_edna s
	--where (s.site_code, s.date_collected) = (v.site_code, v."date"));

--alter table serdp_survey  
--add constraint fk_serdp_edna foreign key (serdp_edna_id) references serdp_edna (serdp_edna_id);




-- drop columns

---- drop columns region
alter table region 
drop column location;

---- drop columns site
alter table site 
drop column region;

alter table site 
drop column location;

---- drop columns visit
alter table visit 
drop column site;

alter table visit 
drop column site_code;

---- drop columns survey
alter table survey 
drop column site;

alter table survey 
drop column date;

alter table survey 
drop column survey_time;

alter table survey 
drop column detection_type;

---- drop columns aural
alter table aural 
drop column date;

alter table aural
drop column site;

alter table aural 
drop column detection_type;

alter table aural 
drop column survey_time;

---- drop columns ves
alter table ves 
drop column date;

alter table ves 
drop column site;

alter table ves 
drop column survey_time;

alter table ves 
drop column detection_type;

---- drop column capture
alter table capture 
drop column date;

alter table capture 
drop column site;

alter table capture 
drop column survey_time;

alter table capture 
drop column detection_type;

alter table capture
drop column site_code;

alter table capture 
drop column pcr;

alter table capture
drop column campaign;


---- drop column serd_newt_microbiomi....
alter table serdp_newt_microbiome_mucosome_antifungal 
drop column swab_id;





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
--join brazil_survey pes on v.visit_id = pes.visit_id 
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
--join brazil_survey b on b.visit_id = v.visit_id 
--union
--select 'sn', v.date, v.site, sn.date, sn.site
--from visit v
--join sierra_nevada_survey sn on sn.visit_id = v.visit_id 
--union 
--select 'serdp', v.date, v.site, s.date, s.site
--from visit v
--join serdp_survey s on s.visit_id = v.visit_id;


--Penn_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
--alter table penn_survey 
--add column penn_survey_id UUID default (survey_data.uuid_generate_v4());
--
--alter table penn_survey 
--add primary key(penn_survey_id);
--
--alter table penn_survey 
--add column visit_id UUID;
--
--alter table penn_survey 
--alter column "date" type date using ("date"::text::date);
--
--update penn_survey ps 
--set visit_id =
--	(select v.visit_id
--	from visit v
--	where (v.site, v."date", v.survey_time) = (ps.site, ps."date", ps.survey_time));
--
--alter table penn_survey 
--add constraint fk_penn_survey foreign key (visit_id) references visit (visit_id);
--
---- Panama_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
--alter table panama_survey 
--add column panama_survey_id UUID default (survey_data.uuid_generate_v4());
--
--alter table panama_survey 
--add primary key(panama_survey_id);
--
--alter table panama_survey 
--add column visit_id UUID;
--
--alter table panama_survey 
--alter column "date" type date using ("date"::text::date);
--
--update panama_survey pas 
--set visit_id =
--	(select v.visit_id
--	from visit v
--	where (v.site, v."date", v.survey_time) = (pas.site, pas."date", pas.survey_time));
--
--alter table panama_survey 
--add constraint fk_panama_survey foreign key (visit_id) references visit (visit_id);
--
---- Serdp_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
--alter table serdp_survey 
--add column serdp_survey_id UUID default (survey_data.uuid_generate_v4());
--
--alter table serdp_survey 
--add primary key(serdp_survey_id);
--
--alter table serdp_survey 
--add column visit_id UUID;
--
--alter table serdp_survey 
--alter column "date" type date using ("date"::text::date);
--
--update serdp_survey ss 
--set visit_id =
--	(select v.visit_id
--	from visit v
--	where (v.site_code, v."date", v.survey_time) = (ss.site_code, ss."date", ss.survey_time));
--	
--alter table serdp_survey 
--add constraint fk_serdp_survey foreign key (visit_id) references visit (visit_id);
--
---- brazil_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
--alter table brazil_survey 
--add column brazil_survey_id UUID default (survey_data.uuid_generate_v4());
--
--alter table brazil_survey 
--add primary key(brazil_survey_id);
--
--alter table brazil_survey 
--add column visit_id UUID;
--
--alter table brazil_survey 
--alter column "date" type date using ("date"::text::date);
--
--update brazil_survey bl
--set visit_id =
--	(select v.visit_id
--	from visit v
--	where (v.site, v."date", v.survey_time) = (bl.site, bl."date", bl.survey_time));
--
--alter table brazil_survey 
--add constraint fk_brazil_legacy_survey foreign key (visit_id) references visit (visit_id);
--
---- sierra_nevada_survey: add unique ID, p.key, join id on site/date/survey_time, and create f.key
--alter table sierra_nevada_survey 
--add column sierra_nevada_survey_id UUID default (survey_data.uuid_generate_v4());
--
--alter table sierra_nevada_survey 
--add primary key(sierra_nevada_survey_id);
--
--alter table sierra_nevada_survey
--add column visit_id UUID;
--
--alter table sierra_nevada_survey 
--alter column "date" type date using ("date"::text::date);
--
--alter table sierra_nevada_survey 
--alter column site type text;
--
--update sierra_nevada_survey sn 
--set visit_id =
--	(select v.visit_id
--	from visit v
--	where (v.site, v."date", v.survey_time) = (sn.site, sn."date", sn.survey_time));
--
--alter table sierra_nevada_survey 
--add constraint fk_sierra_nevada_survey foreign key (visit_id) references visit (visit_id);

--------- VES to sierra_nevada_survey w/ f.key
--update ves v
--set sierra_nevada_survey_id =
--	(select sns.sierra_nevada_survey_id
--	from sierra_nevada_survey sns
--    where (sns.site, sns."date", sns.survey_time, sns.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
--	
--alter table ves 
--add constraint fk_ves_sierra_nevada foreign key (sierra_nevada_survey_id) references sierra_nevada_survey (sierra_nevada_survey_id);
--   
----------- VES to penn_survey
--update ves v 
--set  penn_survey_id =
--	(select pes.penn_survey_id
--	from penn_survey pes
--	where (pes.site, pes."date", pes.survey_time, pes.detection_type) = (v.site, v."date", v.survey_time, v.detection_type));
--
--alter table ves
--add constraint fk_ves_penn foreign key (penn_survey_id) references penn_survey (penn_survey_id);
