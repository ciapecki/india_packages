-- Updated on 28 November 2008


/*****************************************************************************/
/* LIST MANAGEMENT GROUP - EMEA  (Production)        		            */  
/***************************************************************************/


/*****************************************************************************/
/* SECTION I: Droping Existing tables	                                    */
/***************************************************************************/

BEGIN execute immediate ('drop table LMOUNL_Prof_NL');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_plugged_in_2');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_emailall');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_email_inds');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_otn_inds');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_Base_INDS');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_unique_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/


BEGIN execute immediate ('drop table OU_Newsletter_EL');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_EL_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_unmatch_inds');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_tech_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_crm_all');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_crm_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_erp_all');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMOUNL_erp_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/

create table LMOUNL_Prof_NL nologging as
select distinct nsl_usr_fk
from prfl_rep.ucm_newsletter_mv@sun_prfl.us.oracle.com
where nsl_nlt_fk = 6 and nsl_subscribe = '1'
;

-- 
create index LMOUNL_in_indx1 on LMOUNL_Prof_NL(nsl_usr_fk) nologging;

-- deactivated,terminated not counted
create table LMOUNL_plugged_in_2 nologging 
as
select b.usr_email,b.usr_first_name,b.usr_id,b.usr_last_name,usr_modified_date,b.usr_universal_id
from LMOUNL_Prof_NL a, prfl_rep.ucm_user_mv@sun_prfl.us.oracle.com b
where a.nsl_usr_fk = b.usr_id
and instr(b.usr_username,'_deact') = 0
and instr(b.usr_email,'_term_') = 0;

-- create table of unique email addresses for LMOUNL_Prof_NL
-- 

create table LMOUNL_emailall nologging
as 
select upper(b.usr_email) usr_email, max(b.usr_id)usr_id, max(b.USR_FIRST_NAME)USR_FIRST_NAME
, max(b.USR_LAST_NAME)USR_LAST_NAME, max(b.usr_universal_id) usr_universal_id
from LMOUNL_plugged_in_2 b
group by usr_email 
;
-- 

-- Any emails which does not have an @ will be deleted 
delete from LMOUNL_emailall
where instr(usr_email,'@')=0;

commit;
--

create table LMOUNL_email_inds nologging
as
select distinct individual_id 
from   LMOUNL_emailall a, gcd_dw.Gcd_data_source_details b
where a.usr_universal_id=b.universal_id
;
--
create index LMOUNL_nl_indv on LMOUNL_email_inds (individual_id) tablespace disc_indx
;

/*****************************************************************************/
/* SECTION II : Creating initial tables	                   		    */
/***************************************************************************/


/*-------------------------------------------------------------------*/
/* Section IIC	- Creating Individual tables based on OTN Download  */
/*-----------------------------------------------------------------*/


CREATE TABLE LMOUNL_otn_inds NOLOGGING
AS
SELECT individual_id, DECODE(sum(case when UPPER (description) LIKE '%DATABASE%'  or UPPER (product) LIKE '%DATABASE%' then 1 else 0 end),0,'N','Y') TECH,
DECODE(sum(case when UPPER (description) LIKE '%CRM%' OR
		        UPPER (description) LIKE '%CUSTOMER%RELATION%' OR
			UPPER (description) LIKE '%SUPPORT%' OR
  	                UPPER (product) LIKE '%CRM%' OR
		        UPPER (product) LIKE '%CUSTOMER%RELATION%' OR
			UPPER (product) LIKE '%SUPPORT%' then 1 else 0 end),0,'N','Y') CRM, 
DECODE(sum(case when UPPER (description) LIKE '%APPLICATIONS%' OR
			UPPER (description) LIKE '%APPS%' OR
			UPPER (description) LIKE '%ERP%' OR
			UPPER (product) LIKE '%APPLICATIONS%' OR
			UPPER (product) LIKE '%APPS%' OR
			UPPER (product) LIKE '%ERP%'  then 1 else 0 end),0,'N','Y') ERP
            FROM gcd_dw.gcd_gcm_activities
          WHERE activity_date >= ADD_MONTHS (SYSDATE, -36)
               AND classification NOT IN ('TM QUALIFICATION','LIST','PROFILING')
               AND ( UPPER (description) LIKE '%DATABASE%' OR
  	                UPPER (description) LIKE '%CRM%' OR
		        UPPER (description) LIKE '%CUSTOMER%RELATION%' OR
			UPPER (description) LIKE '%SUPPORT%' OR
			UPPER (description) LIKE '%APPLICATIONS%' OR
			UPPER (description) LIKE '%APPS%' OR
			UPPER (description) LIKE '%ERP%' OR
			UPPER (product) LIKE '%DATABASE%' OR
  	                UPPER (product) LIKE '%CRM%' OR
		        UPPER (product) LIKE '%CUSTOMER%RELATION%' OR
			UPPER (product) LIKE '%SUPPORT%' OR
			UPPER (product) LIKE '%APPLICATIONS%' OR
			UPPER (product) LIKE '%APPS%' OR
			UPPER (product) LIKE '%ERP%' 
                )
group by individual_id
;

-- 

create index  LMOUNL_OTN_INDS_indv on LMOUNL_OTN_INDS(individual_id) tablespace disc_indx  
;

grant select on LMOUNL_OTN_INDS to public;

/*****************************************************************************/
/* SECTION III : Creating Base Individual tables	 	                   */
/***************************************************************************/

  /*---------------------------------------------------------------------------------------------------------*/
 /* 	SECTION IIIB  JOIN the orgs,OTN AND/OR Product ref If it's already created in Sections II and/or III */ 
/*---------------------------------------------------------------------------------------------------------*/

CREATE TABLE LMOUNL_Base_INDS NOLOGGING 
AS
    SELECT a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id,  'Y' contact_email,
           contact_phone,contact_postal,ind_last_activity,  b.email_address ,
       DECODE(sum(case when standard_title= 'DATABASE ADMINISTRATOR'  or UPPER (TITLE_GIVEN) LIKE '%DATABASE%'  or UPPER (job_role_function_given) LIKE '%DATABASE%' then 1 else 0 end),0,'N','Y') TECH, 
       DECODE(sum(case when  upper(TITLE_GIVEN) like '%APPS%'
            OR upper(TITLE_GIVEN) like '%APPLICATION%'
            OR upper(TITLE_GIVEN) like '%ERP%' 
            OR upper(TITLE_GIVEN) like '%APP%DEVELOPER%' 
            OR upper(TITLE_GIVEN) like '%APP%PROGRAM%' 
            OR upper(job_role_function_given) like '%APPS%' 
            OR upper(job_role_function_given) like '%APPLICATION%'
            OR upper(job_role_function_given) like '%ERP%' 
            OR upper(job_role_function_given) like '%APP%DEVELOPER%' 
            OR upper(job_role_function_given) like '%APP%PROGRAM%' then 1 else 0 end),0,'N','Y')   ERP,
DECODE(sum(case when upper(TITLE_GIVEN) like '%CRM%'
            OR upper(TITLE_GIVEN) like '%CUSTOMER%RELATION%'
            OR upper(TITLE_GIVEN) like '%SUPPORT%'            
        OR upper(job_role_function_given) like '%CRM%'
            OR upper(job_role_function_given) like '%CUSTOMER%RELATION%'
            OR upper(job_role_function_given) like '%SUPPORT%' then 1 else 0 end),0,'N','Y') CRM
    FROM gcd_dw.lb_individuals_eu_vw a, kcierpisz.emea_optins_prfl b                                                        
    where 
     a.country_id in (select country_id from OU_NL_country_cluster)
     and
     (
            standard_title= 'DATABASE ADMINISTRATOR'
            OR upper(TITLE_GIVEN) like '%DATABASE%'
            OR upper(TITLE_GIVEN) like '%APPS%'
            OR upper(TITLE_GIVEN) like '%APPLICATION%'
            OR upper(TITLE_GIVEN) like '%ERP%'
            OR upper(TITLE_GIVEN) like '%CRM%'
            OR upper(TITLE_GIVEN) like '%CUSTOMER%RELATION%'
            OR upper(TITLE_GIVEN) like '%SUPPORT%'
            OR upper(TITLE_GIVEN) like '%APP%DEVELOPER%' 
            OR upper(TITLE_GIVEN) like '%APP%PROGRAM%' 
        OR upper(job_role_function_given) like '%DATABASE%'
            OR upper(job_role_function_given) like '%APPS%'
            OR upper(job_role_function_given) like '%APPLICATION%'
            OR upper(job_role_function_given) like '%ERP%'
            OR upper(job_role_function_given) like '%CRM%'
            OR upper(job_role_function_given) like '%CUSTOMER%RELATION%'
            OR upper(job_role_function_given) like '%SUPPORT%'
            OR upper(job_role_function_given) like '%APP%DEVELOPER%' 
            OR upper(job_role_function_given) like '%APP%PROGRAM%'
        )
    and a.individual_id=b.individual_id
group by a.individual_id,a.country_id, standard_title,TITLE_GIVEN,DERIVED_LOB,job_role_function_given,region_name,    
   org_id,contact_email, contact_phone,contact_postal,ind_last_activity,  b.email_address
union
    SELECT a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id, 'Y' contact_email,
           contact_phone,contact_postal,ind_last_activity,  c.email_address ,
       TECH,   ERP,  CRM
    FROM gcd_dw.lb_individuals_eu_vw a,   LMOUNL_otn_inds b,kcierpisz.emea_optins_prfl c                                                      
    where a.country_id in (select country_id from OU_NL_country_cluster) and
          a.individual_id=b.individual_id and a.individual_id=c.individual_id
;

--


/*****************************************************************************/
/* SECTION IV : Applying Recency	                                    */
/***************************************************************************/

/* for Recency  */

create table LMOUNL_unique_contacts nologging as
select  a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id, contact_email,
           contact_phone,contact_postal,ind_last_activity,  email_address ,
       max(TECH) TECH,  max(ERP) ERP,  max(CRM) CRM
from  LMOUNL_Base_INDS a, LMOUNL_email_inds b
where a.individual_id=b.individual_id and ind_last_activity >= add_months(sysdate,-36)
group by 
a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id, contact_email,
           contact_phone,contact_postal,ind_last_activity,  email_address
;
--

create index LMOUNL_unique_contacts_indv on LMOUNL_unique_contacts (individual_id) tablespace disc_indx
;

grant select on LMOUNL_unique_contacts to public;

/******************************************************************/
/* SECTION V: Updations                                           */            
/******************************************************************/

Alter table LMOUNL_UNIQUE_CONTACTS
add
(first_name                     VARCHAR2(240),
 last_name                      VARCHAR2(240),
 COMPANY_GIVEN                  VARCHAR2(240),
 COUNTRY_GIVEN                  VARCHAR2(50),
 ORG_NAME                       VARCHAR2(240),
 MARKETING_STATUS               VARCHAR2(20),
 country_name                   VARCHAR2(50),
 num_of_employees		number(10) ,
 ANNUAL_REVENUE_AMT          	NUMBER(15),                    
 PROGRAM_CODE		        VARCHAR2(30)  Default '', 
 org_marketing_status		VARCHAR2(20),
 over_targeted                  VARCHAR2(1)   DEFAULT 'N',	
CONTACT_PROSPECT_ROW_ID    VARCHAR2(15) ,
 POSTAL_CODE                    VARCHAR2(50),
 postal_code_org		VARCHAR2(50),
 sub_region_name varchar2(240),
 cluster_name 		VARCHAR2(100)
)
;

/* Updating Contact/Prospect Row Id */  --> Anand 040408
UPDATE LMOUNL_unique_contacts a SET
(
CONTACT_PROSPECT_ROW_ID
)
=
(
SELECT
NVL(CONTACT_ROWID, PROSPECT_ROWID)
FROM GCD_DW.GCD_INDIVIDUALS_ALL
WHERE
INDIVIDUAL_ID=a.INDIVIDUAL_ID
);

commit
;

update LMOUNL_unique_contacts a set (
 first_name               ,
 last_name                      ,
 COMPANY_GIVEN,
 MARKETING_STATUS,
 POSTAL_CODE
 ) 
= 
(
select 
 first_name               ,
 last_name                      ,
 COMPANY_GIVEN,
 MARKETING_STATUS,
 POSTAL_CODE
from  gcd_dw.lb_individuals_eu_vw
where  
individual_id = a.individual_id 
)
;

commit
;


update 
LMOUNL_unique_contacts a  set (
 org_name,
 num_of_employees,
 ANNUAL_REVENUE_AMT,
 org_marketing_status,
 POSTAL_CODE_org
) = 
( select 
 org_name ,
 COALESCE (EMPLOYEES_HERE, EMPLOYEES_TOTAL),
 ANNUAL_REVENUE_AMT,
 marketing_status	,
 POSTAL_CODE
from
gcd_dw.lb_organizations_eu_vw
where org_id =a.org_id 
)
;

commit
;


UPDATE     LMOUNL_unique_contacts a
SET       ( a.country_name) = 
(SELECT  NAME
FROM     gcd_dw.gcd_countries 
WHERE    country_id = a.country_id)
;

commit
;

update LMOUNL_unique_contacts a  set 
  (a.sub_region_name, a.country_name)
 = 
 ( select c.sub_region_name, c.name
   from (
         select  countries.country_id, sub_reg.sub_region_name, countries.name
 	 from gcd_dw.gcd_countries countries, gcd_dw.gcd_sub_region_vw sub_reg
	 where countries.region_id = sub_reg.new_region_id
   	) c
   where c.country_id =a.country_id 
 );

commit;




/******************************************************************/
/* SECTION VI: DELETIONS                                          */
/******************************************************************/

/* COMPUTER PROFILE: DELETING MARKETING STATUS INDIVIDUAL  */		--> Added * 30jUNE2008

 DELETE FROM  LMOUNL_unique_contacts
    WHERE  INDIVIDUAL_ID in (select individual_id from kcierpisz.cp_to_delete)
 ;

COMMIT;

/* SECTION VIA: DELETE ORACLE EMPLOYEES  */

  call PKG_LM.delete_employees('LMOUNL_unique_contacts');

/* SECTION VIB: DELETE EMBARGO COUNTRIES  Chris*/

  call pkg_lm.delete_embargo_countries('LMOUNL_unique_contacts')   ;  


/* SECTION VIC: DELETE MARKETING STATUS for Individuals OTHER THAN ACTIVE, NEW, INAPPROPRIATE CONTACT  */

DELETE FROM         LMOUNL_unique_contacts
WHERE               marketing_status NOT IN ('ACTIVE','NEW','INAPPROP CONTACT')
;

commit
;


DELETE FROM  LMOUNL_unique_contacts
WHERE  org_marketing_status in ('BAD DATA','DELETED')
;

commit
;

/******************************************************************/
/* SECTION VII: CLEANSING                                         */
/******************************************************************/

call PKG_LM.do_cleansing('LMOUNL_unique_contacts');


/******************************************************************/
/* SECTION VIII : Email Suppression Rules 	                  */
/******************************************************************/


update                  LMOUNL_unique_contacts
set             	Contact_email = 'N'
where 	email_address is null                  
;

commit;

update  LMOUNL_unique_contacts  set email_address = trim(upper(email_address)) ;

commit
;

select count(distinct email_address) from LMOUNL_unique_contacts where contact_email='Y'
;

 --

update LMOUNL_unique_contacts set cluster_name='GB-IE' where country_id in (224,105);

commit;

update LMOUNL_unique_contacts set cluster_name='BENELUX' where country_id in (21,126,152);

commit;

update LMOUNL_unique_contacts set cluster_name='NORDICS' where country_id in (58, 73, 162, 205);

commit;

update LMOUNL_unique_contacts set cluster_name='AA' where country_id in (37, 83, 91, 112, 146, 158, 187, 123, 53, 216,3 );

commit;


update LMOUNL_unique_contacts set cluster_name='ZA' where country_id in (195);

commit;

update LMOUNL_unique_contacts set cluster_name='ME' where country_id in (17, 64, 103, 104, 110, 116, 120, 163, 175, 186, 207, 223, 236, 246);

commit;

update LMOUNL_unique_contacts set cluster_name='DACH' where country_id in (14,82) or (country_id=206 and (
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '3%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '4%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '5%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '6%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '7%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '8%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '9%' 
)
)
;

commit;

update LMOUNL_unique_contacts set cluster_name='CH-FR' where country_id=206 and (
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '1%' or
trim(replace(coalesce(postal_code,postal_code_org),'CH','')) like '2%' 
) 
;

commit;

update LMOUNL_unique_contacts set cluster_name='FR' where country_id in (74);

commit;

update LMOUNL_unique_contacts set cluster_name='ES' where country_id in (197);

commit;

update LMOUNL_unique_contacts set cluster_name='IT' where country_id in (107);

commit;

update LMOUNL_unique_contacts set cluster_name='PT' where country_id in (173);

commit;

--****************************************************************************************************************
/* Creating table to insert local contacts*/

/* Merging Local & OTA contacts with previous consolidated List*/

create table OU_Newsletter_EL nologging
as
select * from OU_Newsletter_EL_previous 
union
select * from OU_NL_local   
union
select * from OU_NL_ota
;

update OU_Newsletter_EL  set email_address = trim(upper(email_address)) ;

commit
;


BEGIN execute immediate ('drop table OU_Newsletter_EL_previous');EXCEPTION WHEN OTHERS THEN NULL; END;
/

create table OU_Newsletter_EL_previous   nologging
as
select * from OU_Newsletter_EL
;


-- 58296 (58266 unique)

alter table OU_Newsletter_EL add individual_id  NUMBER(12);


/* For Suppression */ 

DELETE From  OU_Newsletter_EL
  WHERE upper(email_address) in
  (SELECT  email_address 
  FROM  dm_metrics.email_suppression)
;

COMMIT;

--

/* Matching the Individuals  */

CREATE TABLE LMOUNL_EL_contacts NOLOGGING
AS
SELECT MAX(a.individual_id) individual_id,a.email_address, cluster_name,segment_name,list_source
FROM gcd_dw.lb_individuals_eu_vw a, OU_Newsletter_EL b
WHERE 
(
   ( a.email_address = upper(b.email_address)
   )
  and a.email_address IS NOT NULL
)
GROUP BY a.email_address, cluster_name,segment_name,list_source
;

SELECT COUNT(1) FROM LMOUNL_EL_contacts;

--

/* for the left out individuals after supression and gcd individual matching [UN MATCHED]- Temp table no 1 */

CREATE TABLE LMOUNL_unmatch_inds NOLOGGING
AS
select trim(upper(email_address)) email_address, cluster_name,segment_name,list_source from OU_Newsletter_EL
where trim(upper(email_address)) in
(
SELECT trim(upper(email_address)) email_address FROM OU_Newsletter_EL 
MINUS
SELECT trim(upper(email_address)) email_address FROM LMOUNL_EL_contacts
)
;

SELECT COUNT(1) FROM LMOUNL_unmatch_inds;

-- 


/* For Optout */

DELETE  LMOUNL_EL_contacts a 
WHERE   individual_id in 
(SELECT new_individual_id FROM dm_metrics.vg_prfl_email_subscriptions b
	WHERE CASE <> 'OTHERS' and use_this_email = 'Y' AND email_opt_in_flag_aftr_sup = 'N'
)
;

COMMIT;

--

ALTER TABLE LMOUNL_unmatch_inds 
ADD (Individual_id number(12))
;

CREATE TABLE LMOUNL_EL_contacts1 nologging as
SELECT email_Address, individual_id, cluster_name,segment_name,list_source FROM LMOUNL_unmatch_inds
UNION
SELECT email_address, individual_id, cluster_name,segment_name,list_source  FROM LMOUNL_EL_contacts 
;


SELECT COUNT(1) FROM LMOUNL_EL_contacts1;

--

DROP TABLE LMOUNL_EL_contacts PURGE
;


CREATE TABLE LMOUNL_EL_contacts NOLOGGING 
AS 
SELECT * FROM LMOUNL_EL_contacts1
;

CREATE INDEX LMOUNL_EL_contacts_indv on LMOUNL_EL_contacts (individual_id) tablespace disc_indx           
;

drop table LMOUNL_EL_contacts1 PURGE
;


Alter table LMOUNL_EL_contacts
add
( over_targeted      VARCHAR2(1)   DEFAULT 'N',	
  contact_email      varchar2(1) default 'Y' 
)
;

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

create table LMOUNL_tech_contacts nologging
as
select email_address, contact_email,individual_id,cluster_name,'GCD' list_source  from LMOUNL_unique_contacts where
         TECH='Y' and cluster_name is not null
union
select email_address, contact_email,individual_id,cluster_name,list_source  from LMOUNL_el_contacts 
where segment_name='TECH'
;

select count(distinct email_address) from  LMOUNL_tech_contacts
;
--


create table LMOUNL_crm_all nologging
as
select email_address, contact_email,individual_id,cluster_name,'GCD' list_source from LMOUNL_unique_contacts where
         CRM='Y' and cluster_name is not null
union
select email_address, contact_email,individual_id,cluster_name, list_source  from LMOUNL_el_contacts 
 where segment_name='CRM'
;
--


create table LMOUNL_crm_contacts nologging
as
select email_address, contact_email,individual_id,cluster_name, list_source 
from  LMOUNL_crm_all where email_address in 
(select email_address from  LMOUNL_crm_all
minus
select email_address from LMOUNL_tech_contacts
)
;

select count(distinct email_address) from  LMOUNL_crm_contacts
;

--  

create table LMOUNL_erp_all nologging
as
select email_address, contact_email,individual_id,cluster_name,'GCD' list_source from LMOUNL_unique_contacts where
         ERP='Y' and  cluster_name is not null
union
select email_address, contact_email,individual_id,cluster_name, list_source  from LMOUNL_el_contacts 
  where segment_name='ERP'
;
-- 


create table LMOUNL_erp_contacts nologging
as
select email_address, contact_email,individual_id,cluster_name, list_source 
from LMOUNL_erp_all where email_address in 
(select email_address from LMOUNL_erp_all
minus
select email_address from LMOUNL_tech_contacts
minus
select email_address from LMOUNL_crm_contacts
)
;


select count(distinct email_address) from   LMOUNL_erp_contacts ;

-- 

