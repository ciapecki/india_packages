-- Updated on 23-Jul-08 ( Section IIC - Creating Individual tables based on OTN Download)

/*Updated on 8th May 2008

1.Altered Table LMXXXXX_UNIQUE_CONTACTS, column CONTACT_PROSPECT_ROW_ID is added
2.Inserted CONTACT_PROSPECT_ROW_ID in the preview list


-- last update on 23-Jul-08 on Section IIC


/*****************************************************************************/
/* LIST MANAGEMENT GROUP - EMEA  (Production)        		            */  
/***************************************************************************/

-- Developed on 08/23/06 

-- Updated on 15/06/07

/*****************************************************************************/
/* SECTION I: Droping Existing tables	                                    */
/***************************************************************************/

BEGIN execute immediate ('drop table LMXXXXX_Base_ORGS');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_Base_INDS');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_unique_contacts');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_OTN_ACTS');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_activity_desc');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_Product_interest');EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate ('drop table LMXXXXX_OTN_INDS');EXCEPTION WHEN OTHERS THEN NULL; END;
/

/*****************************************************************************/
/* SECTION II : Creating initial tables	                   		    */
/***************************************************************************/

/*------------------------------------------------------------------------*/
/* Section IIA	- Creating Organization tables based on product criteria */
/*----------------------------------------------------------------------*/

--Note Please verify the gcd_products data before choosing prod_tier

create table LMXXXXX_BASE_orgs  nologging
as
select distinct org_id 
from 
(
/* -- Use the following code if there is an entry on Products row in SR  */
select a.org_id
 from  gcd_dw.gcd_orgs_products_vw a,gcd_dw.lb_organizations_eu_vw b
 where 
/*  For product Install bases ex:- Application Servers,Database Enterprise Edition,JDE,People soft... */
--	a.prod_tier4 in ('Type prod_tier4  value(s) here') 	
/*  For External Company Products ex:- SAP,MICROSOFT... */
--	a.prod_brand in ('Type prod_brand  value(s) here')
/*  For platform specific install bases ex:- SUN SPARC ,Linux ... */
--	a.prod_platform in ('Type prod_platform  value(s) here')	
and a.org_id = b.org_id 
/***********************************************************************************************
/* -- Use the following union part if there is an entry on Recent Product TAR's  row in SR  */
--union                                                                                                                    ---> chris.05.06.07
--select a.ultimate_org_id org_id
-- from  gcd_dw.gcd_tar_summary a,gcd_dw.gcd_products b,gcd_dw.lb_organizations_eu_vw c
-- where 
/*  For product Install bases ex:- Application Servers,Database Enterprise Edition,JDE,People soft... */
--	b.prod_tier4 in ('Type prod_tier4  value(s) here') 	
/*  For External Company Products ex:- SAP,MICROSOFT... */
--	b.prod_brand in ('Type prod_brand  value(s) here')
/*  For platform specific install bases ex:- SUN SPARC ,Linux ... */
--	b.prod_platform in ('Type prod_platform  value(s) here')	
-- and a.prod_id = b.prod_id
--and a.ultimate_org_id = c.org_id                                                                                         ---> chris.05.06.07
)
;

Note
=====

--For PSFT/JDE
--Use DM_METRICS.PSFT_PROD_REF apart from gcd_dw.gcd_orgs_products_vw 

--for Siebel

--Use gcd_dw.gcd_data_source_details 
-- 22013 for Siebel eBiz Accounts - Customer
-- 22014 for Siebel eBiz Accounts - Prospect

-- for PORTAL.COM, SIEBEL, SUNOPSIS data Check the following SQL's along with the product table                                  << RAM >>

--SELECT * FROM GCD_dW.GCD_DATA_SOURCES WHERE NAME LIKE '%PORTAL_COM_INDIVIDUALS_2007%'

--SELECT COUNT(DISTINCT ORG_ID), DATA_SOURCE_ID FROM gcd_dw.gcd_data_source_details  WHERE DATA_SOURCE_ID IN (24608,24324 ) GROUP BY DATA_SOURCE_ID


create index  LMXXXXX_BASE_orgs_org_id on LMXXXXX_BASE_orgs(org_id) tablespace disc_indx  
;
commit
;

grant select on LMXXXXX_BASE_orgs to public;

/*---------------------------------------------------------------------------------------*/
/* Section IIB	- Creating Organization tables based on SIC/Industry Name/ Ats criteria */
/*-------------------------------------------------------------------------------------*/

/********************************************************************************************************************************/ 
/*																*/
/* ATS Industry name's and SIC Industry Names are given different in Database.							*/
/* Please refer document for Sic code mapping to ATS Industries 								*/
/*																*/
/* Please find the corresponding SIC codes for the industry names (For ex: Insurance ) and use the SIC codes to pull the ORGS   */ 
/*																*/
/* select * from DM_METRICS.SIC2ATS where sic_description like '%INSURANCE%' or ATS_INDUSTRY like '%INSURANCE%'  		*/
/*									    --> KCIERPIS changed to DM_METRICS * Anand 040408   */
/*   																*/	
/* SELECT *   															*/	
/*    FROM dm_metrics.SIC_MAP_NEW    												*/
/*    WHERE 															*/
/*	upper(sic_description) like '%INSURANCE%'    or										*/
/*	upper(one_voice_industry) like '%INSURANCE%' or   									*/
/*	upper(one_voice_segment) like '%INSURANCE%'  or   									*/
/*	upper(ATS_industry) like '%INSURANCE%'   										*/
/*																*/
/*																*/
/*  Please verify the results before proceeding further										*/
/*																*/
/********************************************************************************************************************************/

/* USE THE FOLLOWING CODE IF YOU ALREADY HAVE THE BASE ORGS TABLE generated in the SECTION IIA (Product Criteria) */
   -------------------------------------------------------------------------------------------------------------


create table LMXXXXX_BASE_orgs_temp  nologging
as
select distinct a.org_id 
from gcd_dw.lb_organizations_eu_vw a, LMXXXXX_BASE_orgs b             --> Base_orgs added  * Anand 040408 
where
country_id in ( 'Type the country ids here')
and ( sic_code_4_digit in ('Type the SIC codes here')
      -- or a.ats_industry_code in ('Type the ATS codes here') -- uncomment this for MEA lists !!!   -- changes done on 27/7/2007
    )
and marketing_status not in ('BAD DATA','DELETED')
--) a, LMXXXXX_BASE_orgs b   --> Commented * Anand 040408
and a.org_id = b.org_id      --> "where" replaced by "and" * Anand 040408
;

drop table LMXXXXX_BASE_orgs
;

create table LMXXXXX_BASE_orgs as
select * from LMXXXXX_BASE_orgs_temp
;
/* USE THE FOLLOWING CODE IF YOU DO NOT HAVE THE BASE ORGS TABLE generated in the SECTION IIA (Product Criteria) */
   -------------------------------------------------------------------------------------------------------------

create table LMXXXXX_BASE_orgs  nologging as
select distinct org_id from gcd_dw.lb_organizations_eu_vw
where
country_id in ( 'Type the country ids here')
--and                                                   --> Commented * Anand 040408
and ( sic_code_4_digit in ('Type the SIC codes here')
        -- or ats_industry_code in ('Type the ATS codes here') -- uncomment this for MEA scripts !!!   -- changes done on 27/7/2007
    )
and marketing_status not in ('BAD DATA','DELETED')
;

create index  LMXXXXX_BASE_orgs_org_id on LMXXXXX_BASE_orgs(org_id) tablespace disc_indx  
;

grant select on LMXXXXX_BASE_orgs to public;

drop table  LMXXXXX_BASE_orgs_temp
;

/*-------------------------------------------------------------------*/
/* Section IIC	- Creating Individual tables based on OTN Download  */
/*-----------------------------------------------------------------*/


/*CREATE TABLE LMXXXXX_OTN_ACTS nologging
AS
SELECT activity_type_id
FROM GCD_DW.GCD_ACTIVITY_TYPES
WHERE UPPER(NAME) LIKE ('%TYPE the activity name here%' and
      classification = 'OTN SOFTWARE DOWNLOAD'
;

CREATE TABLE LMXXXXX_OTN_INDS nologging 
AS
SELECT distinct a.INDIVIDUAL_ID
FROM GCD_DW.GCD_GCM_ACTIVITIES a, LMXXXXX_OTN_ACTS b      --> GCD_ACTIVITIES replaced with GCD_GCM_ACTIVITIES * Anand 040408
where activity_date >= add_months(sysdate,-24) and
      a.activity_type_id = b.activity_type_id
;*/

CREATE TABLE lmxxxxx_otn_inds NOLOGGING
AS
SELECT DISTINCT individual_id
            FROM gcd_dw.gcd_gcm_activities       --> GCD_ACTIVITIES replaced with GCD_GCM_ACTIVITIES * Anand 040408
          WHERE activity_date >= ADD_MONTHS (SYSDATE, -24)
               AND classification IN ('OTN SOFTWARE DOWNLOAD', 'SDS', 'Software Downloaded')
 --> Classifications and sting search in product column added * Eliza 23/07/08
               AND (   UPPER (description) LIKE 'Type product here'
                 OR UPPER (product) LIKE 'Type product here'
                );

create index  LMXXXXX_OTN_INDS_indv on LMXXXXX_OTN_INDS(individual_id) tablespace disc_indx  
;

grant select on LMXXXXX_OTN_INDS to public;


/*----------------------------------------------------------------------*/
/* Section IIE	- Creating Individual tables based on Product Interest */
/*--------------------------------------------------------------------*/

create table LMXXXXX_activity_desc no logging
as
select  * from gcd_dw.gcd_gcm_activities 
where lower(description) like  '%TYPE the activity name here%' and
      classification not in ('OU UPLOAD DATA','TM QUALIFICATION','LIST','PROFILING','DM RESPONSE')
;

CREATE TABLE LMXXXXX_Product_interest nologging
as
SELECT a.INDIVIDUAL_ID
FROM LMXXXXX_activity_desc a
where activity_date >= add_months(sysdate,-24);

create index  LMXXXXX_Prod_interest_indv on LMXXXXX_Product_interest(individual_id) tablespace disc_indx  
;

grant select on LMXXXXX_Product_interest to public
;

/*****************************************************************************/
/* SECTION III : Creating Base Individual tables	 	                   */
/***************************************************************************/

/*--------------------------------------------------------------------------------------------*/
/* SECTION IIIA use this section if there is no base tables for org,OTN and product interest  */ 
/*------------------------------------------------------------------------------------------*/


CREATE TABLE LMXXXXX_Base_INDS nologging as
SELECT distinct a.individual_id,a.country_id, standard_title,title_given,derived_lob,job_role_function_given,region_name,org_id,
       decode(partner_type,null,'N','Y') PARTNER_flag, 'Y' as contact_email, contact_phone,contact_postal,ind_last_activity, 
       b.email_address
FROM gcd_dw.lb_individuals_eu_vw a, kcierpisz.email_optins_vw b                                        
where a.individual_id=b.individual_id 
and
b.email_permission = 'Y'
and
/*for Country restriction */
a.Country_id in ('TYpe country IDs Here')
/*for Titles and LOB */
AND
(
  (
     standard_title in 'Type Title Criteria Here ' and DERIVED_LOB in 'Type LOB Criteria Here '   --# chris #-- 18.06.07 removed upper()
   )
   OR upper(TITLE_GIVEN) like '%MANAGER%'
   OR upper(job_role_function_given) like 'Type LOB Criteria Here with % signs'
)
/* when industry based contacts need to be pulled for MEA lists
AND ats_industry_code in ('Type the ATS codes here')
*/
;

  /*---------------------------------------------------------------------------------------------------------*/
 /* 	SECTION IIIB  JOIN the orgs,OTN AND/OR Product ref If it's already created in Sections II and/or III */ 
/*---------------------------------------------------------------------------------------------------------*/

CREATE TABLE LMXXXXX_Base_INDS NOLOGGING 
AS
SELECT DISTINCT individual_id,country_id, standard_title,TITLE_GIVEN,DERIVED_LOB,job_role_function_given,region_name,
       org_id, PARTNER_flag, 'Y' as contact_email, contact_phone,contact_postal,ind_last_activity, email_address
FROM                                                                           	
(   
    SELECT a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id,decode(partner_type,null,'N','Y') partner_flag,
           contact_phone,contact_postal,ind_last_activity,  c.email_address 
    FROM gcd_dw.lb_individuals_eu_vw a,                                                        
    LMXXXXX_BASE_orgs b ,kcierpisz.email_optins_vw c
    where 
    /*for Country restriction */
    a.Country_id in ('TYpe country IDs Here')
    /*for Titles and LOB */
    (
     (
      standard_title in ('Type Title Criteria Here ') and DERIVED_LOB in ('Type LOB Criteria Here ')
     )
     OR upper(TITLE_GIVEN) like 'Type Title Criteria Here with % signs' 
     OR upper(job_role_function_given) like 'Type LOB Criteria Here with % signs' 
    )
    and a.org_id = b.org_id and a.individual_id=c.individual_id and c.email_permission = 'Y'
   union                                                                                                  
   SELECT a.individual_id,a.country_id,  a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
          a.region_name,a.org_id,decode(partner_type,null,'N','Y') PARTNER_flag,
          contact_phone,contact_postal,ind_last_activity, e.email_address 
    FROM gcd_dw.lb_individuals_eu_vw a,                                                            
    LMXXXXX_OTN_INDS d ,kcierpisz.email_optins_vw e 
    where 
    /*for Country restriction */
        a.Country_id in ('TYpe country IDs Here')
        /*for Titles and LOB */
        (
            (
                standard_title in ('Type Title Criteria Here ') and DERIVED_LOB in ('Type LOB Criteria Here ')
            )
            OR upper(TITLE_GIVEN) like 'Type Title Criteria Here with % signs' 
            OR upper(job_role_function_given) like 'Type LOB Criteria Here with % signs' 
        )
        and a.individual_id = d.individual_id and  a.individual_id=e.individual_id and e.email_permission = 'Y'
     union                                                                                                  
    SELECT a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id,decode(partner_type,null,'N','Y') PARTNER_flag,
           contact_phone,contact_postal,ind_last_activity, f.email_address 
    FROM gcd_dw.lb_individuals_eu_vw a,                                                               
    LMXXXXX_activity_desc_dist e,kcierpisz.email_optins_vw f 
    where 
    /*for Country restriction */
    a.Country_id in ('TYpe country IDs Here')
    /*for Titles and LOB */
    (
        (
           standard_title in ('Type Title Criteria Here ') and DERIVED_LOB in ('Type LOB Criteria Here ')
        )
        OR upper(TITLE_GIVEN) like 'Type Title Criteria Here with % signs' 
        OR upper(job_role_function_given) like 'Type LOB Criteria Here with % signs' 
    )
    and a.individual_id = e.individual_id and  a.individual_id=f.individual_id and f.email_permission = 'Y'
  /* -- uncomment only when ATS industry required for MEA lists
    union     
    SELECT a.individual_id,a.country_id, a.standard_title,a.title_given,a.derived_lob,a.job_role_function_given,
           a.region_name,a.org_id,decode(partner_type,null,'N','Y') PARTNER_flag,
           contact_phone,contact_postal,ind_last_activity,b.email_address
    FROM gcd_dw.lb_individuals_eu_vw a, kcierpisz.email_optins_vw b
    where 
    Country_id in ('TYpe country IDs Here')
    and
    (
     (
      standard_title in ('Type Title Criteria Here ') and DERIVED_LOB in ('Type LOB Criteria Here ')
     )
     OR upper(TITLE_GIVEN) like 'Type Title Criteria Here with % signs' 
     OR upper(job_role_function_given) like 'Type LOB Criteria Here with % signs' 
    )
    AND ats_industry_code in ('Type the ATS codes here') 
    and a.individual_id = b.individual_id and b.email_permission = 'Y'
    */
)
;

grant select on LMXXXXX_Base_INDS to public;


/*****************************************************************************/
/* SECTION IV : Applying Recency	                                    */
/***************************************************************************/

/* for Recency  */

create table LMXXXXX_unique_contacts nologging as
select distinct	 a.*
from   		 LMXXXXX_Base_INDS a
--where	ind_last_activity >= add_months(sysdate,-24) /* Type no of months */
;

create index LMXXXXX_unique_contacts_indv on LMXXXXX_unique_contacts (individual_id) tablespace disc_indx
;

create index LMXXXXX_unique_contacts_org on LMXXXXX_unique_contacts (org_id) tablespace disc_indx
;

grant select on LMXXXXX_unique_contacts to public;

/******************************************************************/
/* SECTION V: Updations                                           */            
/******************************************************************/

Alter table LMXXXXX_UNIQUE_CONTACTS
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
-- OMO_CODE		        VARCHAR2(30)  Default 'Type OMOcode here',      --> Commented * Anand 040408
 PROGRAM_CODE		        VARCHAR2(30)  Default 'Type Program code here', --> Added * Anand 040408
 org_marketing_status		VARCHAR2(20),
 over_targeted                  VARCHAR2(1)   DEFAULT 'N',	 --  <<RAM 29th Aug>>
CONTACT_PROSPECT_ROW_ID    VARCHAR2(15) 		-->8th May 2008
)
;

/* Updating Contact/Prospect Row Id */  --> Anand 040408
UPDATE LMXXXXX_unique_contacts a SET
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

update LMXXXXX_unique_contacts a set (
 first_name               ,
 last_name                      ,
 COMPANY_GIVEN,
 MARKETING_STATUS
 ) 
= 
(
select 
 first_name               ,
 last_name                      ,
 COMPANY_GIVEN,
 MARKETING_STATUS
from  gcd_dw.lb_individuals_eu_vw
where  
individual_id = a.individual_id 
)
;

commit
;

update 
LMXXXXX_unique_contacts a  set (
 org_name,
 num_of_employees,
 ANNUAL_REVENUE_AMT,
 org_marketing_status															
) = 
( select 
 org_name ,
 COALESCE (EMPLOYEES_HERE, EMPLOYEES_TOTAL),
 ANNUAL_REVENUE_AMT,
 marketing_status																
from
gcd_dw.lb_organizations_eu_vw
where org_id =a.org_id 
)
;

commit
;

UPDATE     LMXXXXX_unique_contacts a
SET       ( a.country_name) = 
(SELECT  NAME
FROM     gcd_dw.gcd_countries 
WHERE    country_id = a.country_id)
;

commit
;

/******************************************************************/
/* SECTION VI: DELETIONS                                          */
/******************************************************************/

/* COMPUTER PROFILE: DELETING MARKETING STATUS INDIVIDUAL  */		--> Added * 30jUNE2008

DELETE FROM  LMXXXXX_unique_contacts
WHERE  INDIVIDUAL_ID in (select individual_id from kcierpisz.cp_to_delete)
;

COMMIT;

/* SECTION VIA: DELETE ORACLE EMPLOYEES  */

call PKG_LM.delete_employees('LMXXXXX_unique_contacts');

/* SECTION VIB: DELETE EMBARGO COUNTRIES  Chris*/

call pkg_lm.delete_embargo_countries('LMXXXXX_unique_contacts')   ;  

/* SECTION VIC: DELETE MARKETING STATUS for Individuals OTHER THAN ACTIVE, NEW, INAPPROPRIATE CONTACT  */

DELETE FROM         LMXXXXX_unique_contacts
WHERE               marketing_status NOT IN ('ACTIVE','NEW','INAPPROP CONTACT')
;

commit
;


DELETE FROM  LMXXXXX_unique_contacts
WHERE  org_marketing_status in ('BAD DATA','DELETED')
;

commit
;

/* Restrict the contacts based on num_of_employees,MU_ANNUAL_REVENUE_AMT if necessary */        --<<RAM  19-Jul-2007>>
 --- MU_ANNUAL_REVENUE_AMT replace with ANNUAL_REVENUE_AMT
                                   
-- delete LMXXXXX_unique_contacts where num_of_employees not between ('Type range here' ) 
-- ;
-- commit 
-- ;
-- delete LMXXXXX_unique_contacts where MU_ANNUAL_REVENUE_AMT not between ('Type range here' )   ---> MU_ANNUAL_REVENUE_AMT -> ANNUAL_REVENUE_AMT
-- delete LMXXXXX_unique_contacts where ANNUAL_REVENUE_AMT not between ('Type range here' )   ---> MU_ANNUAL_REVENUE_AMT -> ANNUAL_REVENUE_AMT
-- commit 
-- ;


/******************************************************************/
/* SECTION VII: CLEANSING                                         */
/******************************************************************/

call PKG_LM.do_cleansing('LMXXXXX_unique_contacts');									--# chris #-- 19.06.07 in proc


/******************************************************************/
/* SECTION VIII : Email Suppression Rules 	                  */
/******************************************************************/


update                  LMXXXXX_unique_contacts
set             	Contact_email = 'N'
where 	email_address is null                  
;

commit;


-- Changes done on 21st Feb 2008 to incorporate Optout and suppression Rules for OU

UPDATE LMXXXXX_unique_contacts a                                             
SET a.over_targeted = 
   (case when upper(a.email_address) in 
         (select distinct upper(b.email_address)
          from dm_metrics.IND_CONTACT_HIST_PARTS_30 b
          where b.no_times_30 >= 6 )     
         and 
         ( a.standard_title in ('CEO / CHAIRMAN','CIO / CTO','CFO','COO','CMO','CHIEF PURCHASING OFFICER','DIRECTOR','DIRECTOR OF ADMISSIONS','DIRECTOR OF ENVIRONMENTAL SERVICES','DIRECTOR OF MANAGED CARE','DIRECTOR OF MEDICAL RECORDS','DIRECTOR OF OUTPATIENT CARE','DIRECTOR OF PHARMACY','DIRECTOR OF PLANNING '||chr(38)||' DEVELOPMENT','DIRECTOR OF QUALITY ASSURANCE','EVP / SVP / VP','EXECUTIVE '||chr(38)||' COMMAND','PRESIDENT') or a.derived_lob = 'EXECUTIVE MANAGEMENT' )        
   then
             'Y'
   when upper(a.email_address) in 
         (select distinct upper(b.email_address)
          from dm_metrics.IND_CONTACT_HIST_PARTS_30 b
          where b.no_times_30 >= 8)
   then
             'Y'
   else 
            'N'
   end) 
WHERE a.contact_email = 'Y' ;

commit;


-- provide these counts to the Area Manager concerned and Maik

select over_targeted,count(1)
from LMXXXXX_unique_contacts
where contact_email  = 'Y'
group by over_targeted;


--<<<<<<<<>>>>>>><<<<<<<<<<<<<<<<>>>>>>>>>>>>>>><<<<<<<<<<<<<<<>>>>>>>>>>><<<<<<<<<<<<<<>>>>>>>>>>--

/****************************** eBlast preview File  ************************************/ 
/* Add columns depending on the requirement.                                            */
/* BUT DO NOT provide any contact channel columns like email_address, phone, address!!! */
/****************************************************************************************/ 
SELECT DISTINCT 
	NULL AS "MARK 'X' TO EXCLUDE", 
	individual_id AS gcd_id,
	CONTACT_PROSPECT_ROW_ID gcm_id,-->8th May 2008
        first_name, 
	last_name, 
	company_given, 
	org_name, 
	title_given,
        standard_title, 
	derived_lob, 
	job_role_function_given,
        country_name
   FROM lmxxxxx_unique_contacts
  WHERE contact_email = 'Y' 
    AND over_targeted = 'N';


set linesize 4000
set pagesize 0
set feedback off
set echo off
set heading off
set verify off
set termout off
set trimspool on
 
spool 'd:\LMXXXXX_email_out.csv'
 
select email_address||','||max(individual_id)
from LMXXXXX_unique_contacts
where contact_email  = 'Y' and over_targeted = 'N'
group by email_address
;
 
Spool off;

/***************************** Contact History Update **********************************/  --<<RAM>>
/***************************************************************************************/
/* ONLY RUN THIS SECTION ONCE COUNT LIST HAS BEEN CREATED AND APPROVED BY THE REQESTOR */
/***************************************************************************************/

-- Updated on 21st Feb 2008 

DECLARE 
table_name VARCHAR2(100)    := 'LMXXXXX_unique_contacts';
programcode VARCHAR2(20)    := '&Program_Code';
list_desc VARCHAR2(100)     := '&List_Description';
ls_file_name VARCHAR2(150)  := '&List_File_Name';
req_name VARCHAR2(50)       := '&Requester_Name';
lead_tp VARCHAR2(100)       := '&Lead_Type';
pgm_name VARCHAR2(100)      := '&pgm_Name';  
campn_name VARCHAR2(300)    := '&campn_name';
Phone VARCHAR2(1)	    := '&Phone';
Postal VARCHAR2(1)	    := '&Psotal';
email VARCHAR2(1)	    := '&Email';
eblastfilename VARCHAR2(150):= '&Eblast_File_Name';
sentdate Date               := '&Sent_Date';

BEGIN
Contact_history (table_name,programcode,list_desc,ls_file_name,req_name,lead_tp,pgm_name,campn_name,Phone,Postal,email,eblastfilename,sentdate);
END;
/ 

