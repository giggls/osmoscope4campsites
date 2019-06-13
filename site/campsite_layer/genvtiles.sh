#!/bin/bash
#
# generate vector tiles for inclomplete campsites
#
# (c) 2018 Sven Geggus <sven-osm@geggus.net>
#
# This is done by converting a json file generated
# by a PostGIS query to vector tiles
#
# See https://github.com/joto/osmoscope/blob/master/doc/creating-layers.md
# for instructions

TMPDIR=/tmp

TIPPECANOE=/home/sven/tippecanoe/tippecanoe

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $SCRIPTDIR

psql -t -X -f incomplete-campsites.sql poi >$TMPDIR/incomplete-campsites.json

rm -rf ../campsite_tiles.tmp

$TIPPECANOE --output-to-directory ../campsite_tiles.tmp \
           --no-tile-compression \
           --layer=incomplete_campsites \
           --name="Incomplete campsites" \
           --description="Campsites with incomplete tagging" \
           --attribution='Copyright OpenStreetMap contributors' \
           --base-zoom=6 \
           --maximum-tile-bytes=50000 \
           --drop-densest-as-needed \
           --quiet $TMPDIR/incomplete-campsites.json

if [ -d ../campsite_tiles ]; then
  mv ../campsite_tiles ../campsite_tiles.old
fi

mv ../campsite_tiles.tmp ../campsite_tiles
rm -rf ../campsite_tiles.old

rm -f $TMPDIR/incomplete-campsites.json
