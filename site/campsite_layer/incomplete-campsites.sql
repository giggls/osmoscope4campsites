SELECT jsonb_build_object(
    'type',     'FeatureCollection',
    'features', jsonb_agg(features.feature)
)
FROM (
  SELECT json_build_object('type', 'Feature', 'id', osm_id, 'geometry',
    ST_AsGeoJSON(geom)::json, 'properties', json_build_object('type', 'point', 'node_id', osm_id)) as feature
    FROM osm_poi_campsites
    WHERE osm_type = 'node' AND ((array_length(akeys(tags), 1) = 2) OR ((array_length(akeys(tags), 1) = 3) AND (tags ? 'name')))
  UNION ALL  
  SELECT json_build_object('type', 'Feature', 'id', osm_id, 'geometry',
    ST_AsGeoJSON(geom)::json, 'properties', json_build_object('type', 'poly', 'way_id', osm_id)) as feature
    FROM osm_poi_campsites
    WHERE osm_type = 'way' AND ((array_length(akeys(tags), 1) = 2) OR ((array_length(akeys(tags), 1) = 3) AND (tags ? 'name')))
  UNION ALL
  SELECT json_build_object('type', 'Feature', 'id', osm_id, 'geometry',
    ST_AsGeoJSON(geom)::json, 'properties', json_build_object('type', 'poly', 'relation_id', osm_id)) as feature
    FROM osm_poi_campsites
    WHERE osm_type = 'relation' AND ((array_length(akeys(tags), 1) = 2) OR ((array_length(akeys(tags), 1) = 3) AND (tags ? 'name')))
) features;

