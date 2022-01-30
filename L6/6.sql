-- 1A
SELECT lpad('-', 2 *(level - 1), '|-') || t.owner || '.' || t.type_name || ' (FINAL:' || t.final || ', INSTANTIABLE:' || t.instantiable || ', ATTRIBUTES:' || t.attributes || ', METHODS:' || t.methods || ')'
FROM all_types t START WITH t.type_name = 'ST_GEOMETRY' CONNECT BY PRIOR t.type_name = t.supertype_name
    AND PRIOR t.owner = t.owner;
-- 1B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
    and m.owner = 'MDSYS'
order by 1;
-- 1C
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);
-- 1D
INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
SELECT FIPS_CNTRY,
    CITY_NAME,
    TREAT(ST_POINT.FROM_SDO_GEOM(geom) as ST_POINT) STGEOM
FROM MAJOR_CITIES;
-- 2A
INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
VALUES (
        'PL',
        'Szczyrk',
        TREAT(
            ST_POINT.FROM_WKT('POINT (19.036107 49.718655)') as ST_POINT
        )
    );
-- 2B
SELECT r.name,
    r.geom.GET_WKT() as WKT
FROM rivers r;
-- 2C
SELECT SDO_UTIL.TO_GMLGEOMETRY(c.STGEOM.GET_SDO_GEOM()) gml
FROM MYST_MAJOR_CITIES c
WHERE CITY_NAME = 'Szczyrk';
-- 3A
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);
-- 3B
INSERT INTO MYST_COUNTRY_BOUNDARIES (FIPS_CNTRY, CNTRY_NAME, STGEOM)
SELECT FIPS_CNTRY,
    CNTRY_NAME,
    ST_MULTIPOLYGON(geom) STGEOM
FROM COUNTRY_BOUNDARIES;
-- 3C
SELECT b.STGEOM.ST_GEOMETRYTYPE() TYPE,
    COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES b
GROUP BY b.STGEOM.ST_GEOMETRYTYPE();
-- 3D
SELECT b.FIPS_CNTRY,
    b.CNTRY_NAME,
    b.STGEOM.ST_ISSIMPLE()
FROM MYST_COUNTRY_BOUNDARIES b;
-- 4A
-- szczyrk nie ma poprawnego ukladu odniesienia
-- ponowne dodanie
DELETE FROM MYST_MAJOR_CITIES
WHERE CITY_NAME = 'Szczyrk';
INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
VALUES (
        'PL',
        'Szczyrk',
        TREAT(
            ST_POINT.FROM_WKT('POINT (19.036107 49.718655)', 8307) as ST_POINT
        )
    );
SELECT b.CNTRY_NAME,
    COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES b,
    MYST_MAJOR_CITIES c
WHERE c.STGEOM.ST_WITHIN(b.STGEOM) = 1
GROUP BY b.CNTRY_NAME;
-- 4B
SELECT a.CNTRY_NAME as "A NAME",
    b.CNTRY_NAME as "B NAME"
FROM MYST_COUNTRY_BOUNDARIES a,
    MYST_COUNTRY_BOUNDARIES b
WHERE b.CNTRY_NAME = 'Czech Republic'
    AND a.CNTRY_NAME != 'Czech Republic'
    AND ST_INTERSECTS(a.STGEOM, b.STGEOM) = 'TRUE';
-- 4C
SELECT DISTINCT b.CNTRY_NAME,
    r.name
FROM MYST_COUNTRY_BOUNDARIES b,
    rivers r
WHERE b.CNTRY_NAME = 'Czech Republic'
    AND ST_LINESTRING(R.GEOM).ST_INTERSECTS(b.STGEOM) = 1
ORDER BY r.name;
-- 4D
SELECT ROUND(
        TREAT(s.STGEOM.ST_UNION(c.STGEOM) as ST_POLYGON).ST_AREA()
    )
FROM (
        SELECT *
        FROM MYST_COUNTRY_BOUNDARIES
        WHERE CNTRY_NAME = 'Slovakia'
    ) s,
    (
        SELECT *
        FROM MYST_COUNTRY_BOUNDARIES
        WHERE CNTRY_NAME = 'Czech Republic'
    ) c;
-- 4E
SELECT h.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(s.GEOM)).ST_GEOMETRYTYPE()
FROM (
        SELECT *
        FROM WATER_BODIES
        WHERE NAME = 'Balaton'
    ) s,
    (
        SELECT *
        FROM MYST_COUNTRY_BOUNDARIES
        WHERE CNTRY_NAME = 'Hungary'
    ) h -- 5A
SELECT COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES b,
    MYST_MAJOR_CITIES c
WHERE b.CNTRY_NAME = 'Poland'
    AND SDO_WITHIN_DISTANCE(b.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE';
-- 5B
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
        'MYST_MAJOR_CITIES',
        'STGEOM',
        MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 12.8549994, 26.3166674, 1),
            MDSYS.SDO_DIM_ELEMENT('Y', 45.8680002, 57.7859992, 1)
        ),
        8307
    );
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
        'MYST_COUNTRY_BOUNDARIES',
        'STGEOM',
        MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
            MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1)
        ),
        8307
    );
SELECT *
FROM USER_SDO_GEOM_METADATA;
-- 5C
CREATE INDEX MYST_MAJOR_CITIES_STGEOM_IDX ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX MYST_COUNTRY_BOUNDARIES_STGEOM_IDX ON MYST_COUNTRY_BOUNDARIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
-- 5D
SELECT COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES b,
    MYST_MAJOR_CITIES c
WHERE b.CNTRY_NAME = 'Poland'
    AND SDO_WITHIN_DISTANCE(b.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE';
EXPLAIN PLAN FOR
SELECT COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES b,
    MYST_MAJOR_CITIES c
WHERE b.CNTRY_NAME = 'Poland'
    AND SDO_WITHIN_DISTANCE(b.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE';
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
-- indeksy nie zostaly uzywane