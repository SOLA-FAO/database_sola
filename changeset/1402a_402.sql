
INSERT INTO system.version SELECT '1402a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1402a');


-- Data not applicable gender
----

delete from party.gender_type where code= 'na';

insert into party.gender_type(code, display_value, status) values('na', 'Not applicable', 'c');

---
-- Data not applicable gender
----

--DROP FUNCTION administrative.get_parcel_ownergender(gender character varying, query character varying);
CREATE OR REPLACE FUNCTION administrative.get_parcel_ownergender(gender character varying, query character varying)
RETURNS SETOF record AS
$BODY$
DECLARE 

  rec record;
  total decimal =0;
  totFem decimal =0;
  totMale decimal =0;
  totMixed decimal =0;
  totJoint decimal =0;
  totEntity decimal =0;
  totNull decimal =0;
  parcel varchar;
  recExt   record;
  sqlSt varchar;
  statusFound	boolean;
  recToReturn	record;
  
BEGIN
     total = 0;
     sqlSt:= '';

     --sqlSt:= 'select sg.name   as area
	--		  from  
	--		  cadastre.spatial_unit_group sg 
	--		  where 
	--		  sg.hierarchy_level=3
	--		  order by area asc
    --';  
    --raise exception '%',sqlSt;
      -- statusFound = false;

    -- Loop through results
    
    --FOR recExt in EXECUTE sqlSt loop
    --statusFound = true; 
     
	for rec in 
	--statusFound = true; 
		SELECT distinct buExt.id as id, 
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.gender_code = 'female') as female,
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.gender_code ='male') as male,
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.type_code ='nonNaturalPerson') as entity,
		     buExt.name_lastpart  as parcel
	             from party.party pp,
			administrative.ba_unit buExt,
			administrative.party_for_rrr pfr,
			administrative.rrr rrr
	WHERE buExt.id=rrr.ba_unit_id 
	and rrr.id = pfr.rrr_id
	and pp.id = pfr.party_id
	AND (rrr.type_code::text = 'ownership'::text 
	OR rrr.type_code::text = 'apartment'::text 
	OR rrr.type_code::text = 'commonOwnership'::text) 
	--AND buExt.name_lastpart = ''||recExt.area||''
		
       loop

		 if rec.female = 0 and rec.male != 0 then
		    totMale = totMale + 1;
		 end if;
		 if rec.female != 0 and rec.male = 0 then
		   totFem = totFem + 1;
		 end if;  
		 if rec.female = 1 and rec.male = 1 then
		   totJoint = totJoint+1;
		 end if;
		 if ((rec.female > 1 and rec.male >= 1)or (rec.female >= 1 and rec.male >1)) then
		   totMixed = totMixed+1;
		 end if; 
		 if ((rec.female = 0 and rec.male = 0) and rec.entity >0) then
		     totEntity =  totEntity + 1;
		 end if;
		 if (rec.female = 0 and rec.male = 0 and rec.entity =0) then
		     totNull =  totNull + 1;
		 end if;
		 total := totMale+totFem+totJoint+totMixed+totEntity+totNull;
        end loop; 
        

          --parcel = recExt.area;
                   parcel = 'Waiheke';
	  select into recToReturn
	        parcel::    varchar,
                total::     decimal,
		totFem::    decimal,
		totMale::   decimal,
		totMixed::  decimal,
		totJoint::  decimal,
		totEntity:: decimal,
		totNull::   decimal;
		                         
           return next recToReturn;
          statusFound = true;
          total     =0;
	  totFem    =0;
	  totMale   =0;
	  totMixed  =0;
	  totJoint  =0;
	  totEntity =0;
	  totNull   =0;
    --end loop;
   
    if (not statusFound) then
         parcel = 'none';
                
        select into recToReturn
	       	parcel::   varchar,
                total::    decimal,
		totFem::   decimal,
		totMale::  decimal,
		totMixed:: decimal,
		totJoint:: decimal,
		totEntity:: decimal,
		totNull::   decimal;
		                         
		                         
          return next recToReturn;

    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_parcel_ownergender(character varying,character varying) OWNER TO postgres;
