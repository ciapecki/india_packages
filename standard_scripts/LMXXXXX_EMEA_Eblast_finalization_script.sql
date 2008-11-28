/* Updated on 8th May 2008
 Changed Optins Table from  kcierpisz.emea_optins_me to kcierpisz.emea_optins_prfl
*/

/*****************************************************************************/
/* LIST MANAGEMENT GROUP - EMEA  (Eblast Finalization)     		            */  
/***************************************************************************/

-- Updated on 21/02/2008
-- changes done in over targeted section to encorporate OU optins

--------------------------------------------------------------------------------
drop table LMXXXXX_input_individuals;

Create table LMXXXXX_input_individuals
( 	individual_id 				NUMBER(12),
	email_address			    VARCHAR2(240)
);

--Import the data from the file to the LMXXXXX_input_individuals 

drop table LMXXXXX_unique_contacts;

create table LMXXXXX_unique_contacts as
select a.individual_id,a.email_address,'N' Contact_email,  'N' over_targeted, standard_title,DERIVED_LOB                                  --<<RAM 29th Aug>>                 
from gcd_dw.lb_individuals_eu_vw a, LMXXXXX_INPUT_INDIVIDUALS b					--# chris #-- 18.06.07 changed from list_build_individuals_eu      
where 
(
	( 
		a.individual_id = b.individual_id 
 		and b.individual_id is not null 
		and a.email_address is not null )
	or
	(
		upper(trim(a.email_address)) = upper(trim(b.email_address) )
		and b.email_address is not null 
	)
)
;

select  count(1) from LMXXXXX_unique_contacts;

update 					LMXXXXX_unique_contacts a
set	   					Contact_email = 'N';

commit;

update                  LMXXXXX_unique_contacts  
set                     email_address = null
where                   EMAIL_ADDRESS NOT LIKE '%@%.%';

update                  LMXXXXX_unique_contacts          
set             		Contact_email = 'Y'
where                   individual_id in 
(select individual_id
 from kcierpisz.email_optins_vw where email_permission = 'Y')     -->28th Nov 2008               
;

commit;

select count(1) from LMXXXXX_unique_contacts where Contact_email = 'Y';


update                  LMXXXXX_unique_contacts
set             		email_address = null
where                   Contact_email = 'N';

update                  LMXXXXX_unique_contacts
set             	Contact_email = 'N'
where 	email_address is null;

commit;

-- Changes done on 21st Feb 2008 to encorporate OU Optins.

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

/***********************DELETIONS*********************************/
/*****************************************************************/

/* COMPUTER PROFILE: DELETING MARKETING STATUS INDIVIDUAL  */		--> Added * 30jUNE2008

	DELETE FROM  LMXXXXX_unique_contacts
	WHERE  INDIVIDUAL_ID in (select individual_id from kcierpisz.cp_to_delete)
	;

	COMMIT;

/*****************************************************************/


-- provide these counts to the consern Area Manager and Maik

select over_targeted,count(1)
from LMXXXXX_unique_contacts
where contact_email  = 'Y'
group by over_targeted;



/******************* Contact History Update *********************/
/****************************************************************/
/* ONLY RUN THIS SECTION ONCE COUNT SUMMARY LIST/ PREVIEW LIST HAS BEEN CREATED AND APPROVED BY THE REQESTOR */
/****************************************************************/

-- Updated on 21st Feb 2008 

declare 

table_name Varchar2(100) := '&Table_Name';

omocode varchar2(20) := '&OMO_Code';

list_desc Varchar2(100) := '&List_Description';

ls_file_name Varchar2(150) := '&List_File_Name';

req_name Varchar2(50) := '&Requester_Name';

lead_tp Varchar2(100) := '&Lead_Type';

pgm_name Varchar2(100) := '&pgm_Name';    -- Enter program name provided by requester  or in request form

campn_name Varchar2(300) := '&campn_name';  -- Enter campaign name provided by requester or in request form

Phone Varchar2(1) := '&Phone';

Postal Varchar2(1) := '&Psotal';

email Varchar2(1) := '&Email';

eblastfilename Varchar2(150) := '&Eblast_File_Name';

sentdate Date := '&Sent_Date';

Begin

Contact_history (table_name,omocode,list_desc,ls_file_name,req_name,lead_tp,pgm_name,campn_name,Phone,Postal,email,eblastfilename,sentdate);

End;

 
-------------------------------------------------------------------------------

set linesize 4000
set pagesize 0
set feedback off
set echo off
set heading off
set verify off
set termout off
set trimspool on
 
spool 'c:\LMXXXXX_email_out.csv' /* ENTER FILE NAME AND PATH */
 
select '"'||email_address||'",'||'"'||max(individual_id)||'"'
from LMXXXXX_unique_contacts
where contact_email  = 'Y' and over_targeted = 'N'
group by email_address
;
 
Spool off;