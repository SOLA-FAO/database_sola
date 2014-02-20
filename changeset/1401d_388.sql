-- #388 Business Rule - False Failure - Convert to Digital Title service completion 
UPDATE "system".br_definition
   SET body='SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
AND ba.status_code != ''pending''
order by 1 desc
limit 1'
 WHERE br_id= 'service-check-no-previous-digital-title-service';