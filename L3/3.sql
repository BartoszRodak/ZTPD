-- 1
CREATE TABLE DOKUMENTY (ID NUMBER(12) PRIMARY KEY, DOKUMENT CLOB);
-- 2
DECLARE lobd clob;
text VARCHAR2(11) := 'Oto tekst. ';
BEGIN lobd := NULL;
FOR i IN 1..100 LOOP lobd := lobd || text;
END LOOP;
INSERT INTO DOKUMENTY
VALUES (1, lobd);
COMMIT;
END;
-- 3
SELECT id,
    dokument
FROM DOKUMENTY;
SELECT id,
    UPPER(dokument)
FROM DOKUMENTY;
SELECT id,
    LENGTH(dokument)
FROM DOKUMENTY;
SELECT id,
    DBMS_LOB.GETLENGTH(dokument)
FROM DOKUMENTY;
SELECT id,
    SUBSTR(dokument, 5, 1000)
FROM DOKUMENTY;
SELECT id,
    dbms_lob.SUBSTR(dokument, 1000, 5)
FROM DOKUMENTY;
-- 4
INSERT INTO DOKUMENTY
VALUES (2, empty_clob());
-- 5
INSERT INTO DOKUMENTY
VALUES (3, NULL);
COMMIT;
-- 6
SELECT id,
    dokument
FROM DOKUMENTY;
SELECT id,
    UPPER(dokument)
FROM DOKUMENTY;
SELECT id,
    LENGTH(dokument)
FROM DOKUMENTY;
SELECT id,
    DBMS_LOB.GETLENGTH(dokument)
FROM DOKUMENTY;
SELECT id,
    SUBSTR(dokument, 5, 1000)
FROM DOKUMENTY;
SELECT id,
    dbms_lob.SUBSTR(dokument, 1000, 5)
FROM DOKUMENTY;
-- 7
SELECT *
FROM dba_directories;
DECLARE lobd clob;
fils BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
doffset integer := 1;
soffset integer := 1;
langctx integer := 0;
warn integer := NULL;
-- 8
BEGIN
SELECT dokument INTO lobd
FROM DOKUMENTY
WHERE id = 2 FOR
UPDATE;
DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
DBMS_LOB.LOADCLOBFROMFILE(
    lobd,
    fils,
    DBMS_LOB.LOBMAXSIZE,
    doffset,
    soffset,
    0,
    langctx,
    warn
);
DBMS_LOB.FILECLOSE(fils);
COMMIT;
-- DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;
-- 9
DECLARE fils BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
BEGIN DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
UPDATE DOKUMENTY
SET dokument = TO_CLOB(fils)
WHERE id = 3;
DBMS_LOB.FILECLOSE(fils);
COMMIT;
--DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;
-- 10
SELECT *
FROM DOKUMENTY;
-- 11
SELECT id,
    DBMS_LOB.GETLENGTH(dokument)
FROM DOKUMENTY;
-- 12
drop table DOKUMENTY;
-- 13
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(lobd IN OUT CLOB, word IN VARCHAR2) AS word_count number;
idx number;
word_length number;
buffer VARCHAR2(32767);
BEGIN word_count := REGEXP_COUNT(lobd, word);
word_length := LENGTH(word);
for a in 1..word_length LOOP buffer := buffer || '.';
end loop;
DBMS_OUTPUT.PUT_LINE(buffer);
FOR i in 1..word_count LOOP idx := DBMS_LOB.INSTR(lobd, word, 1, 1);
DBMS_LOB.WRITE(lobd, word_length, idx, buffer);
end loop;
end CLOB_CENSOR;
-- 14
CREATE TABLE BIOGRAPHIES AS
SELECT *
FROM ZSBD_TOOLS.BIOGRAPHIES;
DECLARE lobd CLOB;
BEGIN
SELECT BIO INTO lobd
FROM BIOGRAPHIES
WHERE id = 1 FOR
UPDATE;
CLOB_CENSOR(lobd, 'Cimrman');
END;
-- 15
DROP TABLE BIOGRAPHIES;