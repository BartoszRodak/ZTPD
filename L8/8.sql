-- 1
CREATE TABLE CYTATY AS
SELECT *
FROM ZSBD_TOOLS.CYTATY;
-- 2
SELECT *
FROM CYTATY
WHERE UPPER(TEKST) LIKE '%PESYMISTA%'
    AND UPPER(TEKST) LIKE '%OPTYMISTA%';
-- 3
CREATE INDEX CYTATY_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;
-- 4
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista and optymista') > 0;
-- 5
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista not optymista') > 0;
-- 6
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'near((pesymista, optymista), 3)') > 0;
-- 7
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'near((pesymista, optymista), 10)') > 0;
-- 8
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, '$?yci%') > 0;
-- 9
SELECT AUTOR,
    TEKST,
    CONTAINS(TEKST, '$?yci%')
FROM CYTATY
WHERE CONTAINS(TEKST, '$?yci%') > 0;
-- 10
SELECT AUTOR,
    TEKST,
    CONTAINS(TEKST, '$?yci%')
FROM CYTATY
WHERE CONTAINS(TEKST, '$?yci%') > 0
    AND rownum = 1
ORDER BY DOPASOWANIE DESC;
-- 11
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'fuzzy(probelm)') > 0;
-- 12
INSERT INTO CYTATY(ID, AUTOR, TEKST)
VALUES (
        39,
        'Bertrand Russell',
        'To smutne, ?e g?upcy s? tacy pewni siebie, a ludzie rozs?dni tacy pe?ni w?tpliwo?ci'
    );
commit;
-- 13
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'g?upcy') > 0;
-- brak indexu
-- 14
SELECT *
FROM DR $CYTATY_IDX$I;
SELECT *
FROM DR $CYTATY_IDX$I
WHERE TOKEN_TEXT LIKE 'G?UP%';
-- brak s?owa
-- 15
DROP INDEX CYTATY_IDX;
CREATE INDEX CYTATY_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;
-- 16
SELECT *
FROM DR $CYTATY_IDX$I
WHERE TOKEN_TEXT LIKE 'G?UP%';
SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'g?upcy') > 0;
-- 17
DROP INDEX CYTATY_IDX;
DROP TABLE CYTATY;
-- 1
CREATE TABLE QUOTES AS
SELECT *
FROM ZSBD_TOOLS.QUOTES;
-- 2
CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;
-- 3
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'work') > 0;
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '$work') > 0;
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'working') > 0;
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '$working') > 0;
-- 4
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'it') > 0;
-- s?owo nie jest indexowane
-- 5
SELECT *
FROM CTX_STOPLISTS;
--  domy?lne 'DEFAULT_STOPLIST'
-- 6
SELECT *
FROM CTX_STOPWORDS;
SELECT *
FROM CTX_STOPWORDS
WHERE SPW_WORD = 'it';
-- 7
DROP INDEX QUOTES_IDX;
CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');
-- 8
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'it') > 0;
-- zwr�ci? wyniki
-- 9
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool and humans') > 0;
-- 10
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool and computer') > 0;
-- 11
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) WITHIN SENTENCE') > 0;
-- 12
DROP INDEX QUOTES_IDX;
-- 13
begin ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;
-- 14
CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS (
    'stoplist CTXSYS.EMPTY_STOPLIST
                section group nullgroup'
);
-- 15
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) WITHIN SENTENCE') > 0;
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and computer) WITHIN SENTENCE') > 0;
-- 16
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans') > 0;
--  my?lnik sprawie ?e s?owa s? rozbite dla indexu 
-- 17
DROP INDEX QUOTES_IDX;
begin ctx_ddl.create_preference('lex_z_m', 'BASIC_LEXER');
ctx_ddl.set_attribute('lex_z_m', 'printjoins', '-');
ctx_ddl.set_attribute ('lex_z_m', 'index_TEXT', 'YES');
end;
CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('section group nullgroup LEXER lex_z_m');
-- 18
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans') > 0;
-- poprawny brak
-- 19
SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'non\-humans') > 0;
--20
begin ctx_ddl.drop_preference('lex_z_m');
end;
DROP INDEX QUOTES_IDX;