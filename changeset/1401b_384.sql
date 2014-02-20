-- #384 Systematic Registration Report Issues.
CREATE OR REPLACE FUNCTION administrative.getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	TotAppLod		decimal:=0 ;	
        TotParcLoaded		varchar:='none' ;	
        TotRecObj		decimal:=0 ;	
        TotSolvedObj		decimal:=0 ;	
        TotAppPDisp		decimal:=0 ;	
        TotPrepCertificate      decimal:=0 ;	
        TotIssuedCertificate	decimal:=0 ;	


        Total  			varchar;	
       	TotalAppLod		decimal:=0 ;	
        TotalParcLoaded		varchar:='none' ;	
        TotalRecObj		decimal:=0 ;	
        TotalSolvedObj		decimal:=0 ;	
        TotalAppPDisp		decimal:=0 ;	
        TotalPrepCertificate      decimal:=0 ;	
        TotalIssuedCertificate	decimal:=0 ;	


  
      
       rec     record;
       sqlSt varchar;
       workFound boolean;
       recToReturn record;

       recTotalToReturn record;

        -- From Neil's email 9 march 2013
	    -- PROGRESS REPORT
		--0. Block	
		--1. Total Number of Applications Lodged	
		--2. No of Parcel loaded	
		--3. No of Objections received
		--4. No of Objections resolved
		--5. No of Applications in Public Display	               
		--6. No of Applications with Prepared Certificate	
		--7. No of Applications with Issued Certificate	
		
    
BEGIN  


   sqlSt:= '';
    
  
 sqlSt:= 'select  distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
         -- sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
   
    end if;
    --raise exception '%',sqlSt;
       workFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) + 
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   aa.action_code='lodge'
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp
          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.cadastre_object co, 
		 cadastre.spatial_value_area sa, 
		 administrative.ba_unit_contains_spatial_unit su,
		 application.application aa, 
		 application.service s, 
		 administrative.ba_unit bu, 
		 transaction.transaction t 
		    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
            AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
	    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	    AND s.status_code::text = 'completed'::text 
	    AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND  co.name_lastpart = ''|| rec.area ||''
                            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
                    	    
	     )

	   )
                 ,  ---TotParcelLoaded
                  
               (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			  -- AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                          AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			   --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                           AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
		            AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
			
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
                   cadastre.cadastre_object co,
		   administrative.ba_unit_contains_spatial_unit su,
		   administrative.ba_unit bu,
                   transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart = ''|| rec.area ||'' 
			    AND s.request_type_code::text = 'systematicRegn'::text
		            AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										  where ss.type_code='title'
										  and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										  and ss.reference_nr = ''|| rec.area ||''
                                                                                )   
					           )
	
                 ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                   application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes = ''|| rec.area ||'')  --TotCertificatesIssued

                    
              INTO       TotAppLod,
                         TotParcLoaded,
                         TotRecObj,
                         TotSolvedObj,
                         TotAppPDisp,
                         TotPrepCertificate,
                         TotIssuedCertificate
          ;        

                block = rec.area;
                TotAppLod = TotAppLod;
                TotParcLoaded = TotParcLoaded;
                TotRecObj = TotRecObj;
                TotSolvedObj = TotSolvedObj;
                TotAppPDisp = TotAppPDisp;
                TotPrepCertificate = TotPrepCertificate;
                TotIssuedCertificate = TotIssuedCertificate;
	  
	  select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;	
		                         
		return next recToReturn;
		workFound = true;
          
    end loop;
   
    if (not workFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;		
		                         
		return next recToReturn;

    end if;

------ TOTALS ------------------
                
              select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) +
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp

		   
	          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.land_use_type lu, 
	    cadastre.spatial_value_area sa, 
	    application.application aa, 
	    application.service s, 
            cadastre.cadastre_object co,
	    administrative.ba_unit_contains_spatial_unit su,
	    administrative.ba_unit bu,
            transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	                    AND s.request_type_code::text = 'systematicRegn'::text 
	                    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
	    )

	   ),  ---TotParcelLoaded
                  
                    (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s
		  WHERE  s.application_id::text = aa.id::text 
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
		
		
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
		 				      from   source.source ss 
							where ss.type_code='publicNotification'
							AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
					              from   source.source ss 
					              where ss.type_code='publicNotification'
					              and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										 where ss.type_code='title'
										 and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										)   
					            ) 
	         ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                       application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes is not null )  --TotCertificatesIssued

      

                     
              INTO       TotalAppLod,
                         TotalParcLoaded,
                         TotalRecObj,
                         TotalSolvedObj,
                         TotalAppPDisp,
                         TotalPrepCertificate,
                         TotalIssuedCertificate
               ;        
                Total = 'Total';
                TotalAppLod = TotalAppLod;
                TotalParcLoaded = TotalParcLoaded;
                TotalRecObj = TotalRecObj;
                TotalSolvedObj = TotalSolvedObj;
                TotalAppPDisp = TotalAppPDisp;
                TotalPrepCertificate = TotalPrepCertificate;
                TotalIssuedCertificate = TotalIssuedCertificate;
	  
	  select into recTotalToReturn
                Total::                 varchar, 
                TotalAppLod::  		decimal,	
		TotalParcLoaded::  	varchar,	
		TotalRecObj::  		decimal,	
		TotalSolvedObj::  	decimal,	
		TotalAppPDisp::  	decimal,	
		TotalPrepCertificate:: 	decimal,	
		TotalIssuedCertificate::  decimal;	

	                         
		return next recTotalToReturn;

                
    return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregprogress(character varying, character varying, character varying) OWNER TO postgres;


----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION administrative.getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	appLodgedNoSP 		decimal:=0 ;	
       	appLodgedSP   		decimal:=0 ;	
       	SPnoApp 		decimal:=0 ;	
       	appPendObj		decimal:=0 ;	
       	appIncDoc		decimal:=0 ;	
       	appPDisp		decimal:=0 ;	
       	appCompPDispNoCert	decimal:=0 ;	
       	appCertificate		decimal:=0 ;
       	appPrLand		decimal:=0 ;	
       	appPubLand		decimal:=0 ;	
       	TotApp			decimal:=0 ;	
       	TotSurvPar		decimal:=0 ;	



      
       rec     record;
       sqlSt varchar;
       statusFound boolean;
       recToReturn record;

        -- From Neil's email 9 march 2013
	    -- STATUS REPORT
		--Block	
		--1. Total Number of Applications	
		--2. No of Applications Lodged with Surveyed Parcel	
		--3. No of Applications Lodged no Surveyed Parcel	     
		--4. No of Surveyed Parcels with no application	
		--5. No of Applications with pending Objection	        
		--6. No of Applications with incomplete Documentation	
		--7. No of Applications in Public Display	               
		--8. No of Applications with Completed Public Display but Certificates not Issued	 
		--9. No of Applications with Issued Certificate	
		--10. No of Applications for Private Land	
		--11. No of Applications for Public Land 	
		--12. Total Number of Surveyed Parcels	

    
BEGIN  


    sqlSt:= '';
    
  
 sqlSt:= 'select   distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
          --sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
    
    end if;

    --raise exception '%',sqlSt;
       statusFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select        ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ),

		    (SELECT count (distinct(aa.id))
		     FROM application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			 AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),

	          (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND   co.id not in (SELECT su.spatial_unit_id FROM administrative.ba_unit_contains_spatial_unit su)
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	          ),

                 (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text != 'cancelled'::text
		  --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		  AND  co.name_lastpart =  ''|| rec.area ||''
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		),


		  ( WITH appSys AS 	(SELECT  
		    distinct on (aa.id) aa.id as id
		    FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),
		     sourceSys AS	
		     (
		     SELECT  DISTINCT (sc.id) FROM  application.application_uses_source a_s,
							   source.source sc,
							   appSys app
						where sc.type_code='systematicRegn'
						 and  sc.id = a_s.source_id
						 and a_s.application_id=app.id
						 AND  (
						  (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
						   or
						  (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
						  )
						
				)
		      SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM appSys) THEN 0
				WHEN ((SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys) >= 0) THEN (SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys)
				ELSE 0
			END 
				  ),
     
                 (select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
		                             select ss.reference_nr from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''   
					   )
		 ),

                 ( 
                   select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						       from   source.source ss 
						       where ss.type_code='publicNotification'
						       and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						       and   ss.reference_nr not in ( select ss.reference_nr from   source.source ss 
										     where ss.type_code='title'
										     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										     and ss.reference_nr = ''|| rec.area ||''
	 								           )   
		                                     )
                 ),

                 (
                   select count(distinct (aa.id))
                   from application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										   where ss.type_code='title'
										   and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										   and ss.reference_nr = ''|| rec.area ||''
									        )   
					            )  
                ),
		 (SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr, 
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text 
			    AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		              or
		             (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            )
			    AND 
			    (rrr.type_code::text = 'ownership'::text 
			     OR rrr.type_code::text = 'apartment'::text 
			     OR rrr.type_code::text = 'commonOwnership'::text 
			     ) 
		 ),		
		 ( SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr,
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND   sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		             or
		            (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            ) 
	  	 ), 	
                 (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
		    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	         )    
              INTO       TotApp,
                         appLodgedSP,
                         SPnoApp,
                         appPendObj,
                         appIncDoc,
                         appPDisp,
                         appCompPDispNoCert,
                         appCertificate,
                         appPrLand,
                         appPubLand,
                         TotSurvPar
                
              FROM        application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  
	  ;        

                block = rec.area;
                TotApp = TotApp;
		appLodgedSP = appLodgedSP;
		SPnoApp = SPnoApp;
                appPendObj = appPendObj;
		appIncDoc = appIncDoc;
		appPDisp = appPDisp;
		appCompPDispNoCert = appCompPDispNoCert;
		appCertificate = appCertificate;
		appPrLand = appPrLand;
		appPubLand = appPubLand;
		TotSurvPar = TotSurvPar;
		appLodgedNoSP = TotApp-appLodgedSP;
		


	  
	  select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;
          statusFound = true;
          
    end loop;
   
    if (not statusFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;

    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregstatus(character varying, character varying, character varying) OWNER TO postgres;