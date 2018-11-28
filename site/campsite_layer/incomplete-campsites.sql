SELECT jsonb_build_object(
    'type',     'FeatureCollection',
    'features', jsonb_agg(features.feature)
)
FROM (
  SELECT json_build_object('type', 'Feature', 'id', osm_id, 'geometry',
    ST_AsGeoJSON(ST_Transform(way,4326))::json, 'properties', json_build_object('type', 'point', 'node_id', osm_id)) as feature
    FROM planet_osm_hstore_point
    WHERE (tags->'tourism' = 'camp_site')
    AND ((array_length(akeys(tags), 1) = 1) OR ((array_length(akeys(tags), 1) = 2) AND (tags ? 'name')))
  UNION ALL  
  SELECT json_build_object('type', 'Feature', 'id', osm_id, 'geometry',
    ST_AsGeoJSON(ST_Transform(way,4326))::json, 'properties', json_build_object('type', 'poly', 'way_id', osm_id)) as feature
    FROM planet_osm_hstore_polygon
    WHERE (tags->'tourism' = 'camp_site')
    AND ((array_length(akeys(tags), 1) = 1) OR ((array_length(akeys(tags), 1) = 2) AND (tags ? 'name')))
    AND (osm_id > 0)
  UNION ALL
  SELECT json_build_object('type', 'Feature', 'id', ((-1*osm_id)+10000000000), 'geometry',
    ST_AsGeoJSON(ST_Transform(way,4326))::json, 'properties', json_build_object('type', 'poly', 'relation_id', (-1*osm_id))) as feature
    FROM planet_osm_hstore_polygon
    WHERE (tags->'tourism' = 'camp_site')
    AND ((array_length(akeys(tags), 1) = 1) OR ((array_length(akeys(tags), 1) = 2) AND (tags ? 'name')))
    AND (osm_id < 0)
) features;
