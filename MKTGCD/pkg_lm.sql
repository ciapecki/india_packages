PACKAGE BODY  PKG_LM AS
    PROCEDURE APPLY_EMAIL_SUPPRESSION_RULES
     ( table_name IN varchar2)
    is
        sqlstmt varchar2(4000) := '';
   BEGIN
        sqlstmt := 'update ' || table_name || ' set	Contact_email = ''N''';
        execute immediate sqlstmt;
        execute immediate 'commit';
        sqlstmt := '
            update ' || table_name || '
            set                     email_address = null
            where                   EMAIL_ADDRESS NOT LIKE ''%@%.%''
        ';
        execute immediate sqlstmt;
        execute immediate 'commit';
        sqlstmt := '
            update ' || table_name || '
            set             		Contact_email = ''Y''
            where                   individual_id in
            (select                 individual_id
            from                    kcierpisz.emea_optins_prfl)
        ';
        execute immediate sqlstmt;
        execute immediate 'commit';
        sqlstmt := '
            update ' || table_name || '
            set             		email_address = null
            where                   Contact_email = ''N''
        ';
        execute immediate sqlstmt;
        execute immediate 'commit';
        sqlstmt := '
            update ' || table_name || '
            set             	Contact_email = ''N''
            where 	email_address is null
        ';
        execute immediate sqlstmt;
        execute immediate 'commit';
	  sqlstmt := 'alter table ' || table_name || ' add (over_targeted VARCHAR2(1) DEFAULT ''N'')';
	  execute immediate sqlstmt;
	  sqlstmt := '
		UPDATE  ' || table_name || ' a
			SET a.over_targeted =
				 (case when upper(a.email_address) in
					(select distinct (upper(email_address))
  	   				from dm_metrics.IND_CONTACT_HIST_PARTS_30 b
  					where b.no_times_30 >= 6)
					and (a.standard_title like ''VP_%''
					or a.standard_title like ''DIR_%''
					or a.standard_title in (''CEO / CHAIRMAN'',''CIO / CTO'',''CFO'',''COO'',''CMO'',''CHIEF PURCHASING OFFICER'',''DIRECTOR'',''DIRECTOR OF ADMISSIONS'',''DIRECTOR OF ENVIRONMENTAL SERVICES'',
		 			''DIRECTOR OF MANAGED CARE'',''DIRECTOR OF MEDICAL RECORDS'',''DIRECTOR OF OUTPATIENT CARE'',''DIRECTOR OF PHARMACY'',''DIRECTOR OF PLANNING ''||chr(38)||'' DEVELOPMENT'',
		 			''DIRECTOR OF QUALITY ASSURANCE'',''EVP / SVP / VP'',''EXECUTIVE ''||chr(38)||'' COMMAND'',''PRESIDENT'') or a.derived_lob = ''EXECUTIVE MANAGEMENT'')
					then ''Y''
					when upper(a.email_address) in (select  distinct (upper(email_address))
		  			from dm_metrics.IND_CONTACT_HIST_PARTS_30 b
		 			where b.no_times_30 >= 8)
					then ''Y''
					else ''N''
					end)
				WHERE a.contact_email = ''Y''										
				';
		execute immediate sqlstmt;
        execute immediate 'commit';
    END; 							-- end of email supression Procedure
   PROCEDURE delete_employees
     ( table_name IN varchar2)
    is
        sqlstmt varchar2(4000) := '';
   BEGIN
        --sqlstmt := 'DELETE FROM ' || table_name || ' WHERE NVL(employee_flg,''N'') = ''Y''';
        --execute immediate sqlstmt;
        sqlstmt := 'DELETE FROM ' || table_name ||
        ' WHERE                   UPPER(email_address) LIKE ''%ORACLE%''';
        execute immediate sqlstmt;
        sqlstmt := 'DELETE FROM ' || table_name ||
        ' WHERE                   UPPER(company_given) LIKE ''%ORACLE%''';
        execute immediate sqlstmt;
        sqlstmt := 'DELETE FROM ' || table_name ||
        ' WHERE                   standard_title = ''ORACLE EMPLOYEE''';
        execute immediate sqlstmt;
        sqlstmt := 'DELETE FROM '				|| table_name ||
        ' WHERE                      UPPER(company_given) LIKE '' %PEOPLESOFT%''
OR                        UPPER(company_given) LIKE ''%PEOPLE SOFT%''
OR                        UPPER(company_given) LIKE ''%J.D. EDWARDS%''
OR                         UPPER(company_given) LIKE ''%JD EDWARDS%''
OR                         UPPER(company_given) LIKE ''%J D EDWARDS%''
OR                         UPPER(company_given) LIKE ''%JD%EDWARDS%''
or                         upper(COMPANY_GIVEN) like ''JDE%''
OR                        UPPER(company_given) LIKE ''%RETEK%''
OR                        UPPER(company_given) LIKE ''%PROFITLOGIC%''
OR                        UPPER(company_given) LIKE ''%SIEBEL%''
or                         upper(COMPANY_GIVEN) like ''OBLIX%''
or                         upper(COMPANY_GIVEN) like ''THOR%''
or                         (upper(COMPANY_GIVEN) like ''TIMES%'' and upper(COMPANY_GIVEN) like ''%TEN%'')
or                         (upper(COMPANY_GIVEN) like ''OCTET%'' and upper(COMPANY_GIVEN) like ''%STRING%'')
or                         upper(COMPANY_GIVEN) like ''SLEEPYCAT%''
or                         (upper(COMPANY_GIVEN) like ''%360%'' and upper(COMPANY_GIVEN) like ''%COMMERCE%'')
or                         upper(COMPANY_GIVEN) like ''%G-LOG%''
or                         upper(COMPANY_GIVEN) like ''HOTSIP%''
or                         upper(COMPANY_GIVEN) = ''IFLEX''
or                         upper(COMPANY_GIVEN) like ''PORTAL%SOFTWARE%''
or                         upper(COMPANY_GIVEN) like ''INETO%''
 or                         upper(COMPANY_GIVEN) like ''SUNOPSIS%''
or                         upper(COMPANY_GIVEN) like ''INNOBASE%''
or                         upper(COMPANY_GIVEN) like ''TRIPLEHOT%''
or                         upper(COMPANY_GIVEN) like ''TEMPLESOFT%''
or                         upper(COMPANY_GIVEN) like ''SIGMA%DYNAMICS%''
or                         upper(COMPANY_GIVEN) like ''CONTEXT%MEDIA%''
or                         upper(COMPANY_GIVEN) like ''NET%4%CALL%''
 or                         upper(COMPANY_GIVEN) like ''HYPERION%''
or                         upper(COMPANY_GIVEN) like ''DEMANTRA%''
or                         upper(COMPANY_GIVEN) like ''STELLENT%''
or                         upper(COMPANY_GIVEN) like ''TANGOSOL%''
or 						   upper(COMPANY_GIVEN) like ''AGILE%''
or 						   upper(COMPANY_GIVEN) like ''METASOLV%''
or 						   upper(COMPANY_GIVEN) like ''APPFORGE%''
or 						   upper(COMPANY_GIVEN) like ''BHAROSA%''
or 						   upper(COMPANY_GIVEN) like ''BRIDGESTREAM%''
or 						   upper(COMPANY_GIVEN) like ''AGILE%''
or 						   upper(COMPANY_GIVEN) like ''LODESTAR%''
or 						   upper(COMPANY_GIVEN) like ''NETSURE%''
or 						   upper(COMPANY_GIVEN) like ''SPLWG%''
or 						   upper(COMPANY_GIVEN) like ''SPL%WORLD%GROUP%''
or 						   upper(COMPANY_GIVEN) like ''SPL%WORLD%GRP%''
or 						   upper(COMPANY_GIVEN) like ''TELEPHONY%AT%WORK%''
or 						   upper(COMPANY_GIVEN) like ''TELEPHONY%@%WORK%''
or       				   upper(COMPANY_GIVEN) like ''LOGICAL%APPS%''
or                         upper(COMPANY_GIVEN) like ''INTERLACE%''
or                         upper(COMPANY_GIVEN) like ''MONIFORCE%''
or                         upper(COMPANY_GIVEN) like ''BEA SYSTEM%''
or                         upper(COMPANY_GIVEN) like ''B E A SYSTEM%''
or                         upper(COMPANY_GIVEN) like ''CAPTOVATION%''
or       				   upper(COMPANY_GIVEN) like ''APUTYMA%''
or       				   upper(COMPANY_GIVEN) like ''ACTIVE%REASONING%''
or                         upper(COMPANY_GIVEN) like ''REVENUE%TECHNOLOGIES%''
or                         upper(COMPANY_GIVEN) like ''CIMMETRY%''
or                         upper(COMPANY_GIVEN) like ''CRYSTAL%BALL%''
or                         upper(COMPANY_GIVEN) like ''EMPIRIX%'''
;
        execute immediate sqlstmt;
        sqlstmt := 'DELETE FROM '     		|| table_name ||
        ' WHERE                   UPPER(email_address) LIKE ''%PEOPLESOFT.COM%''
OR                        UPPER(email_address) LIKE ''%JDEDWARDS.COM%''
OR                        UPPER(email_address) LIKE ''%JDE.COM%''
OR                        (UPPER(email_address) LIKE ''%RETEK.COM%'' and UPPER(email_address) NOT LIKE ''%MITRETEK.%'')
OR                        UPPER(email_address) LIKE ''%SIEBEL.COM%''
OR                        UPPER(email_address) LIKE ''%PROFITLOGIC.COM%''
or                         upper(EMAIL_ADDRESS) like ''%OBLIX.COM''
or                         upper(EMAIL_ADDRESS) like ''%THOR.COM''
or                         upper(EMAIL_ADDRESS) like ''%TIMESTEN.COM''
or                         upper(EMAIL_ADDRESS) like ''%OCTETSTRING.COM''
or                         upper(EMAIL_ADDRESS) like ''%SLEEPYCAT.COM''
or                         upper(EMAIL_ADDRESS) like ''%360COMMERCE.COM''
or                         upper(EMAIL_ADDRESS) like ''%G-LOG.COM''
or                         upper(EMAIL_ADDRESS) like ''%HOTSIP.COM''
or                         upper(EMAIL_ADDRESS) like ''%IFLEX.COM''
or                         upper(EMAIL_ADDRESS) like ''%PORTALSOFTWARE.COM''
or                         upper(EMAIL_ADDRESS) like ''%INETO.COM''
or                         upper(EMAIL_ADDRESS) like ''%SUNOPSIS.COM''
or                         upper(EMAIL_ADDRESS) like ''%INNOBASE.COM''
or                         upper(EMAIL_ADDRESS) like ''%TRIPLEHOT.COM''
or                         upper(EMAIL_ADDRESS) like ''%TEMPLESOFT.COM''
or                         upper(EMAIL_ADDRESS) like ''%SIGMA%DYNAMICS.COM''
or                         upper(EMAIL_ADDRESS) like ''%CONTEXT%MEDIA.COM''
or                         upper(EMAIL_ADDRESS) like ''%NET%4%CALL.COM''
or                         upper(EMAIL_ADDRESS) like ''%HYPERION.COM''
or                         upper(EMAIL_ADDRESS) like ''%DEMANTRA.COM''
or                         upper(EMAIL_ADDRESS) like ''%STELLENT.COM''
or                         upper(EMAIL_ADDRESS) like ''%TANGOSOL.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@AGILE.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@METASOLV.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@APPFORGE.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@BHAROSA.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@BRIDGESTREAM.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@AGILE.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@LODESTAR.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@NETSURE.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@SPLWG.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@TELEPHONYATWORK.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@LOGICALAPPS.COM''
or                         upper(EMAIL_ADDRESS) like ''%@INTERLACESYSTEMS.COM''
or                         upper(EMAIL_ADDRESS) like ''%@MONIFORCE.COM''
or                         upper(EMAIL_ADDRESS) like ''%@CAPTOVATION.COM''
or                         upper(EMAIL_ADDRESS) like ''%@BEA.COM''
or       				   upper(EMAIL_ADDRESS) like ''%@APUTYMA.COM%''
or 						   upper(EMAIL_ADDRESS) like ''%@ACTIVEREASONING.COM''
or 						   upper(EMAIL_ADDRESS) like ''%@REVENUETECHNOLOGIES.COM''
or                         upper(EMAIL_ADDRESS) like ''%@CIMMETRY.COM''
or                         upper(EMAIL_ADDRESS) like ''%@CRYSTALBALL.COM''
or                         upper(EMAIL_ADDRESS) like ''%@EMPIRIX.COM'''
;
        execute immediate sqlstmt;
        execute immediate 'commit';
--   EXCEPTION
--          WHEN others THEN
--              null ;
   END;						-- end of delete employees procedure
   PROCEDURE delete_embargo_countries
     ( table_name IN varchar2)
    is
        sqlstmt varchar2(4000) := '';
    BEGIN
       sqlstmt := 'DELETE FROM ' || table_name ||
        ' WHERE country_id in (207,201,103)'; -- Syria, Sudan, Iran
        execute immediate sqlstmt;
        execute immediate 'commit';
   EXCEPTION WHEN others THEN
      dbms_output.put_line(sqlstmt);
      raise;
   END;	
					-- end of delete embargo countries procedure 
   PROCEDURE do_cleansing
        ( table_name IN varchar2)
   is
        sqlstmt varchar2(10000):= '';
   BEGIN
        sqlstmt := '
            UPDATE ' || table_name || '
            SET      first_name =
		              LTRIM(RTRIM(TRANSLATE(FIRST_NAME,''0123456789!@#$%^&*_+][{}\|":;?/><~``'',''                                    ''),'' ''),'' '')';
        execute immediate sqlstmt;
        sqlstmt := '
            UPDATE ' || table_name || '
            SET                      first_name = NULL
            WHERE                    (
            (LTRIM(RTRIM(TRANSLATE(FIRST_NAME,''0123456789!@#$%^&*()_+][{}\|":;?/>.<,~``'',''                                        ''),'' ''),'' '') IS NULL AND FIRST_NAME IS NOT NULL)
            OR UPPER(FIRST_NAME) LIKE ''AAA%''
            OR UPPER(FIRST_NAME) LIKE ''BBB%''
            OR UPPER(FIRST_NAME) LIKE ''CCC%''
            OR UPPER(FIRST_NAME) LIKE ''DDD%''
            OR UPPER(FIRST_NAME) LIKE ''EEE%''
            OR UPPER(FIRST_NAME) LIKE ''FFF%''
            OR UPPER(FIRST_NAME) LIKE ''GGG%''
            OR UPPER(FIRST_NAME) LIKE ''HHH%''
            OR UPPER(FIRST_NAME) LIKE ''III%''
            OR UPPER(FIRST_NAME) LIKE ''JJJ%''
            OR UPPER(FIRST_NAME) LIKE ''KKK%''
            OR UPPER(FIRST_NAME) LIKE ''LLL%''
            OR UPPER(FIRST_NAME) LIKE ''MMM%''
            OR UPPER(FIRST_NAME) LIKE ''NNN%''
            OR UPPER(FIRST_NAME) LIKE ''OOO%''
            OR UPPER(FIRST_NAME) LIKE ''PPP%''
            OR UPPER(FIRST_NAME) LIKE ''QQQ%''
            OR UPPER(FIRST_NAME) LIKE ''RRR%''
            OR UPPER(FIRST_NAME) LIKE ''SSS%''
            OR UPPER(FIRST_NAME) LIKE ''TTT%''
            OR UPPER(FIRST_NAME) LIKE ''%UUU%''
            OR UPPER(FIRST_NAME) LIKE ''VVV%''
            OR UPPER(FIRST_NAME) LIKE ''%WWW%''
            OR UPPER(FIRST_NAME) LIKE ''%YYY%''
            OR UPPER(FIRST_NAME) LIKE ''ZZZ%''
            OR UPPER(FIRST_NAME) LIKE ''ABC%''
            OR UPPER(FIRST_NAME) LIKE ''ADMIN%''
            OR UPPER(FIRST_NAME) LIKE ''ADSD%''
            OR UPPER(FIRST_NAME) LIKE ''%ASDF%''
            OR UPPER(FIRST_NAME) LIKE ''%DSAFL%''
            OR UPPER(FIRST_NAME) LIKE ''%DFG%''
            OR UPPER(FIRST_NAME) LIKE ''%DFS%''
            OR UPPER(FIRST_NAME) LIKE ''%DGF%''
            OR UPPER(FIRST_NAME) LIKE ''%DGF%''
            OR UPPER(FIRST_NAME) LIKE ''%DKL%''
            OR UPPER(FIRST_NAME) LIKE ''DSD%''
            OR UPPER(FIRST_NAME) LIKE ''FASD%''
            OR UPPER(FIRST_NAME) LIKE ''%FDG%''
            OR UPPER(FIRST_NAME) LIKE ''%FDS%''
            OR UPPER(FIRST_NAME) LIKE ''FIRST%''
            OR UPPER(FIRST_NAME) LIKE ''%FSF%''
            OR UPPER(FIRST_NAME) LIKE ''%GFD%''
            OR UPPER(FIRST_NAME) LIKE ''GHJ%''
            OR UPPER(FIRST_NAME) LIKE ''%HELP%DESK%''
            OR UPPER(FIRST_NAME) LIKE ''%HGF%''
            OR UPPER(FIRST_NAME) LIKE ''%HJK%''
            OR UPPER(FIRST_NAME) LIKE ''%HJJ%''
            OR UPPER(FIRST_NAME) LIKE ''%HJH%''
            OR UPPER(FIRST_NAME) LIKE ''%HLK%''
            OR UPPER(FIRST_NAME) LIKE ''%KJK%''
            OR UPPER(FIRST_NAME) LIKE ''LAST%''
            OR UPPER(FIRST_NAME) LIKE ''%LKJ%''
            OR UPPER(FIRST_NAME) LIKE ''%JKL%''
            OR UPPER(FIRST_NAME) LIKE ''NAME%''
            OR UPPER(FIRST_NAME) LIKE ''XXX%''
            OR UPPER(FIRST_NAME) LIKE ''%SDF%''
            OR UPPER(FIRST_NAME) LIKE ''%SDG%''
            OR UPPER(FIRST_NAME) LIKE ''%SDS%''
            OR UPPER(FIRST_NAME) LIKE ''%STD%''
            OR UPPER(FIRST_NAME) LIKE ''SYTEM%''
            OR UPPER(FIRST_NAME) LIKE ''%WEB%MASTER%''
            OR UPPER(FIRST_NAME) LIKE ''%XYZ%''
            OR UPPER(FIRST_NAME) LIKE ''%ZX%''
            OR UPPER(FIRST_NAME) LIKE ''%?%''
            OR UPPER(FIRST_NAME) LIKE ''%..%''
            OR UPPER(FIRST_NAME) LIKE ''%*%''
            OR UPPER(FIRST_NAME) IN (''ASD'',''ASF'',''ASS'',''ORACLE'',''NONE'',''NO'',''NOT'',''NOBODY'',''NONAME'',
                                                  ''VACANT'',''UNKNOWN'',''N/A'',''NA'',''SDF'',''-'',''.'', ''TEST'',''INFORMATION'',''JUNK'',
                                   				  ''USER'',''TESTER'',''TESTING'',''DBA'', ''ME'', ''SUCK'',''SAD'',''MYSELF'')
            )';
            execute immediate sqlstmt;
/* SECTION VIIB: UPDATE LAST NAME                                */
         sqlstmt := '
            UPDATE ' || table_name || '
            SET      LAST_NAME =
		                  LTRIM(RTRIM(TRANSLATE(LAST_NAME,''0123456789!@#$%^&*_+][{}\|":;?/><~``'',''                                    ''),'' ''),'' '')';
            execute immediate sqlstmt;
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                      LAST_NAME = NULL
            WHERE                    (
            (LTRIM(RTRIM(TRANSLATE(LAST_NAME,''0123456789!@#$%^&*()_+][{}\|":;?/>.<,~``'',''                                        ''),'' ''),'' '') IS NULL AND LAST_NAME IS NOT NULL)
            OR              UPPER(LAST_NAME) LIKE ''AAA%''
            OR              UPPER(LAST_NAME) LIKE ''BBB%''
            OR              UPPER(LAST_NAME) LIKE ''CCC%''
            OR              UPPER(LAST_NAME) LIKE ''DDD%''
            OR              UPPER(LAST_NAME) LIKE ''EEE%''
            OR              UPPER(LAST_NAME) LIKE ''FFF%''
            OR              UPPER(LAST_NAME) LIKE ''GGG%''
            OR              UPPER(LAST_NAME) LIKE ''HHH%''
            OR              UPPER(LAST_NAME) LIKE ''III%''
            OR              UPPER(LAST_NAME) LIKE ''JJJ%''
            OR              UPPER(LAST_NAME) LIKE ''KKK%''
            OR              UPPER(LAST_NAME) LIKE ''LLL%''
            OR              UPPER(LAST_NAME) LIKE ''MMM%''
            OR              UPPER(LAST_NAME) LIKE ''NNN%''
            OR              UPPER(LAST_NAME) LIKE ''OOO%''
            OR              UPPER(LAST_NAME) LIKE ''PPP%''
            OR              UPPER(LAST_NAME) LIKE ''QQQ%''
            OR              UPPER(LAST_NAME) LIKE ''RRR%''
            OR              UPPER(LAST_NAME) LIKE ''SSS%''
            OR              UPPER(LAST_NAME) LIKE ''TTT%''
            OR              UPPER(LAST_NAME) LIKE ''%UUU%''
            OR              UPPER(LAST_NAME) LIKE ''VVV%''
            OR              UPPER(LAST_NAME) LIKE ''%WWW%''
            OR              UPPER(LAST_NAME) LIKE ''%YYY%''
            OR              UPPER(LAST_NAME) LIKE ''ZZZ%''
            OR	   			UPPER(LAST_NAME) LIKE ''ABC%''
            OR	   			UPPER(LAST_NAME) LIKE ''ADMIN%''
            OR	   			UPPER(LAST_NAME) LIKE ''ADSD%''
            OR              UPPER(LAST_NAME) LIKE ''%ASDF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DSAFL%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DFG%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DFS%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DGF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DGF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%DKL%''
            OR	   			UPPER(LAST_NAME) LIKE ''DSD%''
            OR	   			UPPER(LAST_NAME) LIKE ''FASD%''
            OR	   			UPPER(LAST_NAME) LIKE ''%FDG%''
            OR	   			UPPER(LAST_NAME) LIKE ''%FDS%''
            OR	   			UPPER(LAST_NAME) LIKE ''FIRST%''
            OR	   			UPPER(LAST_NAME) LIKE ''%FSF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%GFD%''
            OR              UPPER(LAST_NAME) LIKE ''GHJ%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HELP%DESK%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HGF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HJK%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HJJ%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HJH%''
            OR	   			UPPER(LAST_NAME) LIKE ''%HLK%''
            OR	   			UPPER(LAST_NAME) LIKE ''%KJK%''
            OR	   			UPPER(LAST_NAME) LIKE ''LAST%''
            OR	   			UPPER(LAST_NAME) LIKE ''%LKJ%''
            OR	   			UPPER(LAST_NAME) LIKE ''%JKL%''
            OR	   			UPPER(LAST_NAME) LIKE ''NAME%''
            OR              UPPER(LAST_NAME) LIKE ''XXX%''
            OR	   			UPPER(LAST_NAME) LIKE ''%SDF%''
            OR	   			UPPER(LAST_NAME) LIKE ''%SDG%''
            OR	   			UPPER(LAST_NAME) LIKE ''%SDS%''
            OR	   			UPPER(LAST_NAME) LIKE ''%STD%''
            OR	   			UPPER(LAST_NAME) LIKE ''SYTEM%''
            OR	   			UPPER(LAST_NAME) LIKE ''%WEB%MASTER%''
            OR	   			UPPER(LAST_NAME) LIKE ''%XYZ%''
            OR	   			UPPER(LAST_NAME) LIKE ''%ZX%''
            OR              UPPER(LAST_NAME) LIKE ''%?%''
            OR              UPPER(LAST_NAME) LIKE ''%..%''
            OR              UPPER(LAST_NAME) LIKE ''%*%''
            OR              UPPER(LAST_NAME) IN (''ASD'',''ASF'',''ASS'',''ORACLE'',''NONE'',''NO'',''NOT'',''NOBODY'',''NONAME'',
                                                ''VACANT'',''UNKNOWN'',''N/A'',''NA'',''SDF'',''-'',''.'', ''TEST'',''INFORMATION'',''JUNK'',
                                				''USER'',''TESTER'',''TESTING'',''DBA'', ''ME'', ''SUCK'',''SAD'',''MYSELF'')
            )';
            execute immediate sqlstmt;
/* SECTION VIIC: UPDATE FIRST AND LAST NAME                 */
            sqlstmt := '
            UPDATE ' || table_name || '
            SET	   first_name=NULL,
	               last_name=NULL
            WHERE  UPPER(first_name) = UPPER(last_name)
            OR	   (LENGTH(first_name)=1 AND LENGTH(last_name)=1)
            OR	   (UPPER(first_name) =''JOHN'' AND UPPER(last_name)=''DOE'')
            OR	   (UPPER(first_name) =''JON'' AND UPPER(last_name)=''DOE'')
            OR	   (UPPER(first_name) =''JANE'' AND UPPER(last_name)=''DOE'')
            OR	   (UPPER(first_name) =''MICKEY'' AND UPPER(last_name)=''MOUSE'')
            OR	   (UPPER(first_name) =''J'' AND UPPER(last_name)=''DOE'')';
            execute immediate sqlstmt;
/* SECTION VIID: UPDATE COMPANY GIVEN                    */
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                      company_given = NULL
            WHERE
            (
                            (UPPER(COMPANY_GIVEN) IN
                            (''AA'',''BB'',''CC'',''DD'',''EE'',''FF'',''GG'',''HH'',''II'',''JJ'',''KK'',''LL'',''MM'',''NN'',''OO'',''PP'',''QQ'',''RR'',''SS'',''TT'',''UU'',''VV'',''WW'',''XX'',''YY'',''ZZ'',
                            ''NONE'',''N/A'',''NA'',''ABC'',''NO'',''TEST'',''XYZ'',''COMPANY'',''ME'',''NO COMPANY'', ''BLAH'',''+NONE'')
                    OR               UPPER(COMPANY_GIVEN) LIKE ''_''
                    OR               UPPER(COMPANY_GIVEN) LIKE ''-%''
                    OR               UPPER(COMPANY_GIVEN) LIKE ''.%''
                    OR               UPPER(COMPANY_GIVEN) LIKE ''%ASDF%'')
            )';
            execute immediate sqlstmt;
/* SECTION VIIE: UPDATE TITLE GIVEN                    */     /*  -- This is (TITLE_GIVEN) part is included as we generally provide the preview list that also consists of TITLE_GIVEN Column <<RAM>>  */
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                      title_given = NULL
            WHERE
            (
                            (UPPER(TITLE_GIVEN) LIKE ''AAA%''
            OR               UPPER(TITLE_GIVEN) LIKE ''BBB%''
            OR               UPPER(TITLE_GIVEN) LIKE ''CCC%''
            OR               UPPER(TITLE_GIVEN) LIKE ''DDD%''
            OR               UPPER(TITLE_GIVEN) LIKE ''EEE%''
            OR               UPPER(TITLE_GIVEN) LIKE ''FFF%''
            OR               UPPER(TITLE_GIVEN) LIKE ''GGG%''
            OR               UPPER(TITLE_GIVEN) LIKE ''HHH%''
            OR               UPPER(TITLE_GIVEN) LIKE ''JJJ%''
            OR               UPPER(TITLE_GIVEN) LIKE ''KKK%''
            OR               UPPER(TITLE_GIVEN) LIKE ''LLL%''
            OR               UPPER(TITLE_GIVEN) LIKE ''MMM%''
            OR               UPPER(TITLE_GIVEN) LIKE ''NNN%''
            OR               UPPER(TITLE_GIVEN) LIKE ''OOO%''
            OR               UPPER(TITLE_GIVEN) LIKE ''PPP%''
            OR               UPPER(TITLE_GIVEN) LIKE ''QQQ%''
            OR               UPPER(TITLE_GIVEN) LIKE ''RRR%''
            OR               UPPER(TITLE_GIVEN) LIKE ''SSS%''
            OR               UPPER(TITLE_GIVEN) LIKE ''TTT%''
            OR               UPPER(TITLE_GIVEN) LIKE ''UUU%''
            OR               UPPER(TITLE_GIVEN) LIKE ''VVV%''
            OR               UPPER(TITLE_GIVEN) LIKE ''WWW%''
            OR               UPPER(TITLE_GIVEN) LIKE ''XXX%''
            OR               UPPER(TITLE_GIVEN) LIKE ''YYY%''
            OR               UPPER(TITLE_GIVEN) LIKE ''ZZZ%'')
            )';
            execute immediate sqlstmt;
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                      title_given = NULL
            WHERE                    (UPPER(TITLE_GIVEN) IN
            (''AA'',''BB'',''CC'',''DD'',''FF'',''GG'',''HH'',''II'',''JJ'',''KK'',''LL'',
                 ''MM'',''NN'',''OO'',''PP'',''QQ'',''RR'',''SS'',''TT'',''UU'',''VV'',''WW'',''XX'',''YY'',''ZZ'',
                 ''MR'',''MR.'',''MS'',''MS.'',''MRS'',''MRS.'',''N/A'',''NO'',''TITLE'',''ME'',''BOSS'',''NON'',''TEST'',''NIL'',
                 ''GOD'',''XYZ'',''NOTHING'',''*'',''NULL'',''N A'',''ASD'',''GEEK'', ''BLAH'', ''NONE'')
            )';
            execute immediate sqlstmt;
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                     title_given = NULL
            WHERE                   UPPER(TITLE_GIVEN) LIKE ''_''
            OR              UPPER(TITLE_GIVEN) LIKE ''-%''
            OR              UPPER(TITLE_GIVEN) LIKE ''ABC%''
            OR              UPPER(TITLE_GIVEN) LIKE ''%ASDF%''
            OR              UPPER(TITLE_GIVEN) LIKE ''?%''
            OR              UPPER(TITLE_GIVEN) LIKE ''SDF%''
            ';
            execute immediate sqlstmt;
/* SECTION VIIF: UPDATE EMAIL ADDRESS                    */
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                     email_address = NULL
            WHERE                   EMAIL_ADDRESS NOT LIKE ''%@%.%''
            ';
            execute immediate sqlstmt;
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                     email_address = NULL
            WHERE                   EMAIL_ADDRESS LIKE ''_@_.%''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@TEST.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@NONE.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%ASDF%''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%ADSF%''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@BLAH.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@BB.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@AA.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@ABC.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%@00.COM''
            OR              		UPPER(EMAIL_ADDRESS) LIKE ''%***%''
            OR              		UPPER(EMAIL_ADDRESS) IN (''A@.COM'', ''A@2A.COM'', ''A@B.COM'', ''A@EMAIL.COM'')
            OR						UPPER(EMAIL_ADDRESS) LIKE ''%@HOME%''
            OR						UPPER(EMAIL_ADDRESS) LIKE ''%@REDIFFMAIL%''
            OR						UPPER(EMAIL_ADDRESS) LIKE ''%@SINA%''
			OR						SUBSTR(UPPER(EMAIL_ADDRESS),1,1)=''@''
            ';
/* OR	UPPER(EMAIL_ADDRESS) LIKE ''%@HOTMAIL%''   HOTMAIL CONTACTS NOT SEND IN THE EMAIL LIST 9 AUG 2007
   Hotmail contacts could be contacted  Aug 10 2007
   */
            execute immediate sqlstmt;
/*			
            sqlstmt := '
            UPDATE ' || table_name || '
            SET                      email_address =
            LTRIM(RTRIM(TRANSLATE(email_address,''!#$%^&*()+][{}\|":;?/><,~`'',''                          ''),'' ''),'' '')
            ';
            execute immediate sqlstmt;
--  7/30/04 Changes: Removed empty spaces in email address
            sqlstmt := '
            UPDATE ' || table_name || '
            SET 					email_address = REPLACE(email_address,'' '',NULL)
            ';
            execute immediate sqlstmt;
*/			
            execute immediate 'commit';
   END;								-- end of cleansing procedure 
   PROCEDURE do_cleansing2
        ( table_name IN varchar2)
   is
        sqlstmt varchar2(10000):= '';
   BEGIN
   /* SECTION VIIG: UPDATE WORK PHONE                    */
        sqlstmt := '
            UPDATE ' || table_name || '
            SET    work_phone_no = NULL
            WHERE                    (WORK_PHONE_NO LIKE ''000%''
            OR               WORK_PHONE_NO LIKE ''111%''
            OR               WORK_PHONE_NO LIKE ''222%''
            OR               WORK_PHONE_NO LIKE ''333%''
            OR               WORK_PHONE_NO LIKE ''444%''
            OR               WORK_PHONE_NO LIKE ''555%''
            OR               WORK_PHONE_NO LIKE ''666%''
            OR               WORK_PHONE_NO LIKE ''777%''
            OR               WORK_PHONE_NO LIKE ''888%''
            OR               WORK_PHONE_NO LIKE ''999%''
            OR               WORK_PHONE_NO LIKE ''123%''
            OR               WORK_PHONE_NO LIKE ''%555%1212%''
            OR               WORK_PHONE_NO LIKE ''%555%123%''
            OR               WORK_PHONE_NO LIKE ''%111%1111%''
            OR               WORK_PHONE_NO LIKE ''%222%2222%''
            OR               WORK_PHONE_NO LIKE ''%333%3333%''
            OR               WORK_PHONE_NO LIKE ''%444%4444%''
            OR               WORK_PHONE_NO LIKE ''%555%5555%''
            OR               WORK_PHONE_NO LIKE ''%666%6666%''
            OR               WORK_PHONE_NO LIKE ''%777%7777%''
            OR               WORK_PHONE_NO LIKE ''%888%8888%''
            OR               WORK_PHONE_NO LIKE ''%999%9999%''
            OR               WORK_PHONE_NO LIKE ''%000%0000%''
            OR               LENGTH(WORK_PHONE_NO)<=6)
        ';
        execute immediate sqlstmt;
/* SECTION VIIG: UPDATE ORG PHONE                    */ --                << ORG NEW>>
        sqlstmt := '
            UPDATE ' || table_name || '
            SET                      org_phone_no = NULL
            WHERE                    (org_phone_no LIKE ''000%''
            OR               org_phone_no LIKE ''111%''
            OR               org_phone_no LIKE ''222%''
            OR               org_phone_no LIKE ''333%''
            OR               org_phone_no LIKE ''444%''
            OR               org_phone_no LIKE ''555%''
            OR               org_phone_no LIKE ''666%''
            OR               org_phone_no LIKE ''777%''
            OR               org_phone_no LIKE ''888%''
            OR               org_phone_no LIKE ''999%''
            OR               org_phone_no LIKE ''123%''
            OR               org_phone_no LIKE ''%555%1212%''
            OR               org_phone_no LIKE ''%555%123%''
            OR               org_phone_no LIKE ''%111%1111%''
            OR               org_phone_no LIKE ''%222%2222%''
            OR               org_phone_no LIKE ''%333%3333%''
            OR               org_phone_no LIKE ''%444%4444%''
            OR               org_phone_no LIKE ''%555%5555%''
            OR               org_phone_no LIKE ''%666%6666%''
            OR               org_phone_no LIKE ''%777%7777%''
            OR               org_phone_no LIKE ''%888%8888%''
            OR               org_phone_no LIKE ''%999%9999%''
            OR               org_phone_no LIKE ''%000%0000%''
            OR               LENGTH(org_phone_no)<=6)
        ';
        execute immediate sqlstmt;
        execute immediate 'commit';
   END;						-- end of cleansing2 procedure 
    PROCEDURE DO_ORG_UPDATIONS
     ( table_name IN varchar2)
    is
        sqlstmt varchar2(4000) := '';
   BEGIN
    sqlstmt := '
        update ' || table_name || '
        set addr1 = '''', addr2= '''', addr3='''',city ='''', postal_code=''''
        where is_numeric(addr1)=''Y'' or LENGTH(addr1)=1 or
        UPPER(addr1) LIKE ''AAA%''
        OR              UPPER(ADDR1) LIKE ''BBB%''
        OR              UPPER(ADDR1) LIKE ''CCC%''
        OR              UPPER(ADDR1) LIKE ''DDD%''
        OR              UPPER(ADDR1) LIKE ''EEE%''
        OR              UPPER(ADDR1) LIKE ''FFF%''
        OR              UPPER(ADDR1) LIKE ''GGG%''
        OR              UPPER(ADDR1) LIKE ''HHH%''
        OR              UPPER(ADDR1) LIKE ''III%''
        OR              UPPER(ADDR1) LIKE ''JJJ%''
        OR              UPPER(ADDR1) LIKE ''KKK%''
        OR              UPPER(ADDR1) LIKE ''LLL%''
        OR              UPPER(ADDR1) LIKE ''MMM%''
        OR              UPPER(ADDR1) LIKE ''NNN%''
        OR              UPPER(ADDR1) LIKE ''OOO%''
        OR              UPPER(ADDR1) LIKE ''PPP%''
        OR              UPPER(ADDR1) LIKE ''QQQ%''
        OR              UPPER(ADDR1) LIKE ''RRR%''
        OR              UPPER(ADDR1) LIKE ''SSS%''
        OR              UPPER(ADDR1) LIKE ''TTT%''
        OR              UPPER(ADDR1) LIKE ''%UUU%''
        OR              UPPER(ADDR1) LIKE ''VVV%''
        OR              UPPER(ADDR1) LIKE ''%WWW%''
        OR              UPPER(ADDR1) LIKE ''%YYY%''
        OR              UPPER(ADDR1) LIKE ''ZZZ%''
        OR              TRIM(UPPER(ADDR1)) LIKE ''?%''
        OR              TRIM(UPPER(ADDR1)) LIKE ''.%''
        OR              TRIM(UPPER(ADDR1)) LIKE ''*%''
        OR              TRIM(UPPER(ADDR1)) LIKE ''&%''
        OR              TRIM(UPPER(ADDR1)) LIKE ''-%''
        OR              UPPER(ADDR1) LIKE ''ABC%''
        OR	   			UPPER(ADDR1) LIKE ''ADMIN%''
        OR	   			UPPER(ADDR1) LIKE ''ADSD%''
        OR              UPPER(ADDR1) LIKE ''%ASDF%''
        OR	   			UPPER(ADDR1) LIKE ''%DSAFL%''
        OR	   			UPPER(ADDR1) LIKE ''%DFG%''
        OR	   			UPPER(ADDR1) LIKE ''%DFS%''
        OR	   			UPPER(ADDR1) LIKE ''%DGF%''
        OR	   			UPPER(ADDR1) LIKE ''%DGF%''
        OR	   			UPPER(ADDR1) LIKE ''%DKL%''
        OR	   			UPPER(ADDR1) LIKE ''DSD%''
        OR	   			UPPER(ADDR1) LIKE ''FASD%''
        OR	   			UPPER(ADDR1) LIKE ''%FDG%''
        OR	   			UPPER(ADDR1) LIKE ''%FDS%''
        OR	   			UPPER(ADDR1) LIKE ''FIRST%''
        OR	   			UPPER(ADDR1) LIKE ''%FSF%''
        OR	   			UPPER(ADDR1) LIKE ''%GFD%''
        OR              UPPER(ADDR1) LIKE ''GHJ%''
        OR	   			UPPER(ADDR1) LIKE ''%HELP%DESK%''
        OR	   			UPPER(ADDR1) LIKE ''%HGF%''
        OR	   			UPPER(ADDR1) LIKE ''%HJK%''
        OR	   			UPPER(ADDR1) LIKE ''%HJJ%''
        OR	   			UPPER(ADDR1) LIKE ''%HJH%''
        OR	   			UPPER(ADDR1) LIKE ''%HLK%''
        OR	   			UPPER(ADDR1) LIKE ''%KJK%''
        OR	   			UPPER(ADDR1) LIKE ''LAST%''
        OR	   			UPPER(ADDR1) LIKE ''%LKJ%''
        OR	   			UPPER(ADDR1) LIKE ''%JKL%''
        OR	   			UPPER(ADDR1) LIKE ''NAME%''
        OR              UPPER(ADDR1) LIKE ''XXX%''
        OR	   			UPPER(ADDR1) LIKE ''%SDF%''
        OR	   			UPPER(ADDR1) LIKE ''%SDG%''
        OR	   			UPPER(ADDR1) LIKE ''%SDS%''
        OR	   			UPPER(ADDR1) LIKE ''%STD%''
        OR	   			UPPER(ADDR1) LIKE ''SYTEM%''
        OR	   			UPPER(ADDR1) LIKE ''%WEB%MASTER%''
        OR	   			UPPER(ADDR1) LIKE ''%XYZ%''
        OR	   			UPPER(ADDR1) LIKE ''%ZX%''
        OR              UPPER(ADDR1) IN (''ASD'',''ASF'',''ASS'',''ORACLE'',''NONE'',''NO'',''NOT'',''NOBODY'',''NONAME'',
                        ''VACANT'',''UNKNOWN'',''N/A'',''NA'',''SDF'', ''TEST'',''INFORMATION'',''JUNK'',
        				''USER'',''TESTER'',''TESTING'',''DBA'', ''ME'', ''SUCK'',''SAD'',''MYSELF'')
    ';
    execute immediate sqlstmt;
    sqlstmt := '
        update ' || table_name || '
        set addr1_org = '''', addr2_org= '''', addr3_org='''',city_org ='''', postal_code_org=''''
        where is_numeric(ADDR1_ORG)=''Y'' or LENGTH(addr1_org)=1 or
        UPPER(ADDR1_ORG) LIKE ''AAA%''
        OR              UPPER(ADDR1_ORG) LIKE ''BBB%''
        OR              UPPER(ADDR1_ORG) LIKE ''CCC%''
        OR              UPPER(ADDR1_ORG) LIKE ''DDD%''
        OR              UPPER(ADDR1_ORG) LIKE ''EEE%''
        OR              UPPER(ADDR1_ORG) LIKE ''FFF%''
        OR              UPPER(ADDR1_ORG) LIKE ''GGG%''
        OR              UPPER(ADDR1_ORG) LIKE ''HHH%''
        OR              UPPER(ADDR1_ORG) LIKE ''III%''
        OR              UPPER(ADDR1_ORG) LIKE ''JJJ%''
        OR              UPPER(ADDR1_ORG) LIKE ''KKK%''
        OR              UPPER(ADDR1_ORG) LIKE ''LLL%''
        OR              UPPER(ADDR1_ORG) LIKE ''MMM%''
        OR              UPPER(ADDR1_ORG) LIKE ''NNN%''
        OR              UPPER(ADDR1_ORG) LIKE ''OOO%''
        OR              UPPER(ADDR1_ORG) LIKE ''PPP%''
        OR              UPPER(ADDR1_ORG) LIKE ''QQQ%''
        OR              UPPER(ADDR1_ORG) LIKE ''RRR%''
        OR              UPPER(ADDR1_ORG) LIKE ''SSS%''
        OR              UPPER(ADDR1_ORG) LIKE ''TTT%''
        OR              UPPER(ADDR1_ORG) LIKE ''%UUU%''
        OR              UPPER(ADDR1_ORG) LIKE ''VVV%''
        OR              UPPER(ADDR1_ORG) LIKE ''%WWW%''
        OR              UPPER(ADDR1_ORG) LIKE ''%YYY%''
        OR              UPPER(ADDR1_ORG) LIKE ''ZZZ%''
        OR              TRIM(UPPER(ADDR1_ORG)) LIKE ''?%''
        OR              TRIM(UPPER(ADDR1_ORG)) LIKE ''.%''
        OR              TRIM(UPPER(ADDR1_ORG)) LIKE ''*%''
        OR              TRIM(UPPER(ADDR1_ORG)) LIKE ''&%''
        OR              TRIM(UPPER(ADDR1_ORG)) LIKE ''-%''
        OR              UPPER(ADDR1_ORG) LIKE ''ABC%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''ADMIN%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''ADSD%''
        OR              UPPER(ADDR1_ORG) LIKE ''%ASDF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DSAFL%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DFG%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DFS%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DGF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DGF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%DKL%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''DSD%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''FASD%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%FDG%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%FDS%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''FIRST%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%FSF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%GFD%''
        OR              UPPER(ADDR1_ORG) LIKE ''GHJ%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HELP%DESK%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HGF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HJK%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HJJ%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HJH%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%HLK%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%KJK%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''LAST%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%LKJ%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%JKL%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''NAME%''
        OR              UPPER(ADDR1_ORG) LIKE ''XXX%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%SDF%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%SDG%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%SDS%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%STD%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''SYTEM%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%WEB%MASTER%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%XYZ%''
        OR	   			UPPER(ADDR1_ORG) LIKE ''%ZX%''
         OR UPPER(ADDR1_ORG) IN (''ASD'',''ASF'',''ASS'',''ORACLE'',''NONE'',''NO'',''NOT'',''NOBODY'',''NONAME'',
                        ''VACANT'',''UNKNOWN'',''N/A'',''NA'',''SDF'', ''TEST'',''INFORMATION'',''JUNK'',
        				''USER'',''TESTER'',''TESTING'',''DBA'', ''ME'', ''SUCK'',''SAD'',''MYSELF'')
    ';
    execute immediate sqlstmt;
    execute immediate 'COMMIT';
    END; 					-- end of org updations Procedure
END PKG_LM;

