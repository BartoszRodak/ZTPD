-- 1A
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
        'FIGURY',
        'KSZTALT',
        MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 1, 8, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 1, 7, 0.1)
        ),
        NULL
    );
-- 1B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0)
FROM DUAL;
-- 1C
CREATE INDEX FIGURY_IDX on FIGURY (KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
-- 1D
SELECT ID
FROM FIGURY
WHERE SDO_FILTER(
        KSZTALT,
        SDO_GEOMETRY(
            2001,
            null,
            SDO_POINT_TYPE(3, 3, null),
            null,
            null
        )
    ) = 'TRUE';
--  dostajemy zbiór figur gdzie rówież otaczający prosotnkąt może mieć coś wspólnego z punktem
-- 
-- 1E
SELECT ID
FROM FIGURY
WHERE SDO_RELATE(
        KSZTALT,
        SDO_GEOMETRY(
            2001,
            null,
            SDO_POINT_TYPE(3, 3, null),
            null,
            null
        ),
        'mask=ANYINTERACT'
    ) = 'TRUE';
-- rzeczywiście dopiero ta figura "ma cos wspolnego" z punktem
-- 
-- 2A
SELECT C.CITY_NAME,
    SDO_NN_DISTANCE(1) DISTANCE
FROM MAJOR_CITIES C
WHERE SDO_NN(
        C.GEOM,
        (
            SELECT GEOM
            FROM MAJOR_CITIES
            WHERE CITY_NAME = 'Warsaw'
        ),
        'sdo_num_res=10 unit=km',
        1
    ) = 'TRUE'
    and C.CITY_NAME != 'Warsaw';
-- 2B
SELECT C.CITY_NAME
from MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(
        C.GEOM,
        (
            SELECT GEOM
            FROM MAJOR_CITIES
            WHERE CITY_NAME = 'Warsaw'
        ),
        'distance=100 unit=km'
    ) = 'TRUE'
    AND C.CITY_NAME != 'Warsaw';
-- 2C
SELECT CNTRY_NAME,
    CITY_NAME
FROM MAJOR_CITIES
WHERE SDO_RELATE(
        (
            SELECT GEOM
            FROM COUNTRY_BOUNDARIES
            WHERE CNTRY_NAME LIKE 'Slovakia'
        ),
        GEOM,
        'mask=contains+coveredby'
    ) = 'TRUE';
-- 2D
SELECT C.CNTRY_NAME,
    SDO_GEOM.SDO_DISTANCE(
        (
            SELECT GEOM
            FROM COUNTRY_BOUNDARIES
            WHERE CNTRY_NAME = 'Poland'
        ),
        C.GEOM,
        1,
        'unit=km'
    ) AS DISTANCE
from COUNTRY_BOUNDARIES C
WHERE SDO_RELATE(
        (
            SELECT GEOM
            FROM COUNTRY_BOUNDARIES
            WHERE CNTRY_NAME = 'Poland'
        ),
        geom,
        'mask=anyinteract'
    ) = 'FALSE';
-- 3A
SELECT C.CNTRY_NAME,
    SDO_GEOM.SDO_LENGTH(
        SDO_GEOM.SDO_INTERSECTION(
            C.GEOM,
            (
                SELECT GEOM
                FROM COUNTRY_BOUNDARIES
                WHERE CNTRY_NAME = 'Poland'
            ),
            1
        ),
        1,
        'unit=km'
    ) AS BORDER_LENGTH
from COUNTRY_BOUNDARIES C
WHERE SDO_RELATE(
        (
            SELECT GEOM
            FROM COUNTRY_BOUNDARIES
            WHERE CNTRY_NAME = 'Poland'
        ),
        geom,
        'mask=anyinteract'
    ) = 'TRUE'
    and C.CNTRY_NAME != 'Poland';
-- 3B
SELECT C.CNTRY_NAME
FROM (
        SELECT CNTRY_NAME,
            SDO_GEOM.SDO_AREA(GEOM, 1, 'unit=SQ_KM') AS AREA
        FROM COUNTRY_BOUNDARIES
        ORDER BY AREA DESC
    ) C
WHERE ROWNUM = 1;
-- 3C
SELECT SDO_GEOM.SDO_AREA(
        SDO_GEOM.SDO_MBR(
            SDO_GEOM.SDO_UNION(
                (
                    SELECT GEOM
                    FROM MAJOR_CITIES
                    WHERE CITY_NAME = 'Warsaw'
                ),
                (
                    SELECT GEOM
                    FROM MAJOR_CITIES
                    WHERE CITY_NAME = 'Lodz'
                )
            )
        ),
        1,
        'unit=SQ_KM'
    ) AS SQ_KM
FROM DUAL;
-- 3D
SELECT (
        t.c.GET_DIMS() || t.c.GET_LRS_DIM() || '0' || t.c.GET_GTYPE()
    ) as GTYPE
FROM (
        SELECT SDO_GEOM.SDO_UNION(
                (
                    SELECT GEOM
                    FROM COUNTRY_BOUNDARIES
                    WHERE CNTRY_NAME = 'Poland'
                ),
                (
                    SELECT GEOM
                    FROM MAJOR_CITIES
                    WHERE CITY_NAME = 'Prague'
                ),
                1
            ) c
        FROM DUAL
    ) t;
-- 3E
SELECT d.CITY_NAME,
    d.CNTRY_NAME
FROM (
        SELECT c.CITY_NAME,
            c.CNTRY_NAME,
            SDO_GEOM.SDO_DISTANCE(c.GEOM, c.CENTER, 1, 'unit=km') DIST
        FROM (
                SELECT b.CITY_NAME,
                    b.CNTRY_NAME,
                    b.GEOM,
                    a.CENTER
                FROM MAJOR_CITIES b
                    JOIN (
                        SELECT CNTRY_NAME,
                            SDO_GEOM.SDO_CENTROID(GEOM, 1) CENTER
                        FROM COUNTRY_BOUNDARIES
                    ) a ON a.CNTRY_NAME = b.CNTRY_NAME
            ) c
        ORDER BY DIST
    ) d
WHERE ROWNUM = 1;
-- 3F
SELECT R.NAME,
    SUM(
        SDO_GEOM.SDO_LENGTH(
            SDO_GEOM.SDO_INTERSECTION(
                R.GEOM,
                (
                    SELECT GEOM
                    FROM COUNTRY_BOUNDARIES
                    WHERE CNTRY_NAME = 'Poland'
                ),
                1
            ),
            1,
            'unit=km'
        )
    ) AS BORDER_LENGTH
FROM RIVERS R
WHERE SDO_RELATE(
        (
            SELECT GEOM
            FROM COUNTRY_BOUNDARIES
            WHERE CNTRY_NAME = 'Poland'
        ),
        R.GEOM,
        'mask=anyinteract'
    ) = 'TRUE'
GROUP BY R.NAME;