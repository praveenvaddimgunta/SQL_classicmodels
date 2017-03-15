CREATE TABLE geotest (code int(5),descrip varchar(50), g GEOMETRY);
desc geotest;
ALTER TABLE geotest ADD pt_loca POINT; 
ALTER TABLE geotest DROP pt_loca ;

Point Properties;
------------------
X-coordinate value.
Y-coordinate value.
Point is defined as a zero-dimensional geometry.
The boundary of a Point is the empty set.;

 SELECT X(geomfromtext('POINT(18 23)'));
 SELECT X(GeomFromText('POINT(18 23)'));