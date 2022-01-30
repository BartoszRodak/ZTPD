-- 1A
CREATE TABLE FIGURY(
    ID number(1) PRIMARY KEY,
    KSZTALT MDSYS.SDO_GEOMETRY
)
-- 1B
INSERT INTO figury
VALUES(
        1,
        MDSYS.SDO_GEOMETRY(
            2003,
            NULL,
            NULL,
            MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 3),
            MDSYS.SDO_ORDINATE_ARRAY(1, 1, 5, 5)
        )
    );
INSERT INTO figury
VALUES(
        2,
        MDSYS.SDO_GEOMETRY(
            2003,
            NULL,
            NULL,
            MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 4),
            MDSYS.SDO_ORDINATE_ARRAY(7, 5, 5, 3, 3, 5)
        )
    );
INSERT INTO figury
VALUES(
        3,
        MDSYS.SDO_GEOMETRY(
            2002,
            NULL,
            NULL,
            MDSYS.SDO_ELEM_INFO_ARRAY(1, 4, 2, 1, 2, 1, 5, 2, 2),
            MDSYS.SDO_ORDINATE_ARRAY(3, 2, 6, 2, 7, 3, 8, 2, 7, 1)
        )
    );
SELECT *
FROM FIGURY;
-- 1C
INSERT INTO figury
VALUES(
        4,
        MDSYS.SDO_GEOMETRY(
            2002,
            NULL,
            NULL,
            MDSYS.SDO_ELEM_INFO_ARRAY(1, 4, 2, 1, 2, 1, 7, 2, 2),
            MDSYS.SDO_ORDINATE_ARRAY(3, 2, 6, 2, 7, 3, 8, 2, 7, 1)
        )
    );
SELECT *
FROM FIGURY;
-- 1D
SELECT SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.01)
FROM FIGURY;
-- 1E
DELETE FROM FIGURY
where ID = 4;
-- 1F
COMMIT WORK;
-- INSERT INTO USER_SDO_GEOM_METADATA VALUES (
-- 'FIGURY',
-- 'KSZTALT',
-- MDSYS.SDO_DIM_ARRAY(
-- MDSYS.SDO_DIM_ELEMENT('X', 1, 8, 0.1),
-- MDSYS.SDO_DIM_ELEMENT('Y', 1, 7, 0.1) ),
-- NULL);