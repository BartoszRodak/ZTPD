-- 1
CREATE TABLE MOVIES (
    ID NUMBER(12) PRIMARY KEY,
    TITLE VARCHAR2(400) NOT NULL,
    CATEGORY VARCHAR2(50),
    YEAR CHAR(12),
    CAST VARCHAR2(4000),
    DIRECTOR VARCHAR2(4000),
    STORY VARCHAR2(4000),
    PRICE NUMBER(5, 2),
    COVER BLOB,
    MIME_TYPE VARCHAR2(50)
);
-- 2
INSERT INTO MOVIES
SELECT d.*,
    c.IMAGE,
    c.MIME_TYPE
FROM descriptions d
    FULL OUTER JOIN covers c on d.id = c.movie_id;
-- 3
SELECT id,
    title
FROM MOVIES
WHERE cover is null;
-- 4
SELECT id,
    title,
    dbms_lob.getlength(cover) as filesize
FROM MOVIES
WHERE cover is not null;
-- 5
SELECT id,
    title,
    dbms_lob.getlength(cover) as filesize
FROM MOVIES
WHERE cover is null;
-- 6
SELECT *
FROM dba_directories;
-- 7
UPDATE MOVIES
SET cover = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
WHERE id = 66;
COMMIT WORK;
-- 8 
SELECT *
FROM MOVIES
WHERE id = 65
    or id = 66;
SELECT id,
    title,
    dbms_lob.getlength(cover) as filesize
FROM MOVIES
WHERE id = 65
    or id = 66;
-- 9
DECLARE lobd blob;
fils BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
BEGIN
SELECT cover INTO lobd
FROM MOVIES
WHERE id = 66 FOR
UPDATE;
DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
DBMS_LOB.LOADFROMFILE(lobd, fils, DBMS_LOB.GETLENGTH(fils));
DBMS_LOB.FILECLOSE(fils);
COMMIT;
END;
-- 10
CREATE TABLE TEMP_COVERS(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);
-- 11
INSERT INTO TEMP_COVERS(movie_id, image, mime_type)
VALUES (
        65,
        BFILENAME('ZSBD_DIR', 'eagles.jpg'),
        'image/jpeg'
    );
COMMIT WORK;
-- 12
SELECT MOVIE_ID,
    dbms_lob.getlength(image) as filesize
FROM temp_covers
WHERE movie_id = 65;
-- 13
BEGIN
SELECT IMAGE INTO fils
FROM TEMP_COVERS
WHERE movie_id = 65;
SELECT mime_type INTO mts
FROM TEMP_COVERS
WHERE movie_id = 65;
dbms_lob.createtemporary(a, TRUE);
DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
DBMS_LOB.LOADFROMFILE(a, fils, DBMS_LOB.GETLENGTH(fils));
DBMS_LOB.FILECLOSE(fils);
UPDATE MOVIES
SET cover = a,
    mime_type = mts
WHERE id = 65;
dbms_lob.freetemporary(a);
COMMIT;
END;
-- 14
SELECT id,
    title,
    dbms_lob.getlength(cover) as filesize
FROM MOVIES
WHERE id = 65
    or id = 66;
-- 15
DROP TABLE MOVIES;