CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
        MARKA VARCHAR2(20),
        MODEL VARCHAR2(20),
        KILOMETRY NUMBER,
        DATA_PRODUKCJI DATE,
        CENA NUMBER(10, 2)
    );
DESC SAMOCHOD;
CREATE TABLE SAMOCHODY OF SAMOCHOD;
INSERT INTO samochody
VALUES (
        NEW SAMOCHOD('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000)
    );
INSERT INTO samochody
VALUES (
        NEW SAMOCHOD(
            'FORD',
            'MONDEO',
            80000,
            DATE '1997-05-10',
            45000
        )
    );
INSERT INTO samochody
VALUES (
        NEW SAMOCHOD('MAZDA', '323', 12000, DATE '2000-09-22', 52000)
    );
select *
from samochody;
CREATE TABLE WLASCICIELE(
    IMIE VARCHAR(100),
    NAZWISKO VARCHAR(100),
    AUTO SAMOCHOD
);
DESC WLASCICIELE;
INSERT INTO wlasciciele
VALUES (
        'JAN',
        'KOWALSKI',
        SAMOCHOD(
            'FIAT',
            'SEICENTO',
            30000,
            DATE '0010-12-2',
            19500
        )
    );
INSERT INTO wlasciciele
VALUES (
        'ADAM',
        'NOWAK',
        SAMOCHOD('OPEL', 'ASTRA', 34000, DATE '0009-06-1', 33700)
    );
SELECT *
FROM wlasciciele;
-- 3
ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY SAMOCHOD AS MEMBER FUNCTION WARTOSC RETURN NUMBER IS BEGIN RETURN POWER(
        0.9,
        EXTRACT(
            YEAR
            FROM CURRENT_DATE
        ) - EXTRACT(
            YEAR
            FROM DATA_PRODUKCJI
        )
    ) * CENA;
END WARTOSC;
END;
SELECT S.WARTOSC(),
    S.*
FROM SAMOCHODY S;
-- 4
ALTER TYPE SAMOCHOD
ADD MAP MEMBER FUNCTION ODWZOROJ RETURN NUMBER CASCADE INCLUDING TABLE DATA;
CREATE OR REPLACE TYPE BODY SAMOCHOD AS MEMBER FUNCTION WARTOSC RETURN NUMBER IS BEGIN RETURN POWER(
        0.9,
        EXTRACT(
            YEAR
            FROM CURRENT_DATE
        ) - EXTRACT(
            YEAR
            FROM DATA_PRODUKCJI
        )
    ) * CENA;
END WARTOSC;
MAP MEMBER FUNCTION ODWZOROJ RETURN NUMBER IS BEGIN RETURN EXTRACT(
    YEAR
    FROM CURRENT_DATE
) - EXTRACT(
    YEAR
    FROM DATA_PRODUKCJI
) + (KILOMETRY / 10000);
END ODWZOROJ;
END;
SELECT *
FROM SAMOCHODY s
ORDER BY VALUE(s);
-- 5
CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT(
        IMIE VARCHAR(100),
        NAZWISKO VARCHAR(100),
        AUTO REF SAMOCHOD
    );
CREATE TABLE WLASCICIELE_OBJ OF WLASCICIEL;
ALTER TABLE WLASCICIELE_OBJ
ADD SCOPE FOR (AUTO) IS SAMOCHODY;
INSERT INTO WLASCICIELE_OBJ
VALUES (NEW WLASCICIEL('JAN', 'KOWALSKI', null));
INSERT INTO WLASCICIELE_OBJ
VALUES (NEW WLASCICIEL('ADAM', 'NOWAK', null));
SELECT *
FROM WLASCICIELE_OBJ;
UPDATE WLASCICIELE_OBJ w
SET w.AUTO = (
        SELECT REF(a)
        FROM SAMOCHODY a
        WHERE a.marka = 'FORD'
    )
WHERE w.NAZWISKO = 'KOWALSKI';
UPDATE WLASCICIELE_OBJ w
SET w.AUTO = (
        SELECT REF(a)
        FROM SAMOCHODY a
        WHERE a.marka = 'MAZDA'
    )
WHERE w.NAZWISKO = 'NOWAK';
-- 5.5
ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER,
    MAP MEMBER FUNCTION ODWZOROJ RETURN NUMBER,
    WLASCICIEL REF WLASCICIEL
);
-- KOLEKLCJE
-- 6
DECLARE TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN moje_przedmioty(1) := 'MATEMATYKA';
moje_przedmioty.EXTEND(9);
FOR i IN 2..10 LOOP moje_przedmioty(i) := 'PRZEDMIOT_' || i;
END LOOP;
FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
END LOOP;
moje_przedmioty.TRIM(2);
FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
moje_przedmioty.EXTEND();
moje_przedmioty(9) := 9;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
moje_przedmioty.DELETE();
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;
DROP TABLE SAMOCHODY;
DROP TABLE WLASCICIELE;
-- 7
DECLARE TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(50);
moje_ksiazki t_ksiazki := t_ksiazki();
BEGIN moje_ksiazki.extend(3);
moje_ksiazki(1) := 'Ziemiomorze';
moje_ksiazki(2) := '1984';
moje_ksiazki(3) := 'FUTU.RE';
moje_ksiazki.extend(6);
FOR i IN 4..7 LOOP moje_ksiazki(i) := 'Ksiazka ' || i;
END LOOP;
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
moje_ksiazki.TRIM(3);
FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
moje_ksiazki.EXTEND();
moje_ksiazki(3) := 'Ksiazka';
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
moje_ksiazki.DELETE();
DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;
-- 8
DECLARE TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN moi_wykladowcy.extend(2);
moi_wykladowcy(1) := 'MORZY';
moi_wykladowcy(2) := 'WOJCIECHOWSKI';
moi_wykladowcy.extend(8);
FOR i IN 3..10 LOOP moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
END LOOP;
FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP dbms_output.put_line(moi_wykladowcy(i));
END LOOP;
moi_wykladowcy.trim(2);
FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP dbms_output.put_line(moi_wykladowcy(i));
END LOOP;
moi_wykladowcy.DELETE(5, 7);
dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP IF moi_wykladowcy.EXISTS(i) THEN dbms_output.put_line(moi_wykladowcy(i));
END IF;
END LOOP;
moi_wykladowcy(5) := 'ZAKRZEWICZ';
moi_wykladowcy(6) := 'KROLIKOWSKI';
moi_wykladowcy(7) := 'KOSZLAJDA';
FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP IF moi_wykladowcy.EXISTS(i) THEN dbms_output.put_line(moi_wykladowcy(i));
END IF;
END LOOP;
dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
END;
-- 9
DECLARE TYPE t_miesiace IS TABLE OF VARCHAR2(20);
moje_miesiace t_miesiace := t_miesiace();
BEGIN moje_miesiace.extend(12);
moje_miesiace(1) := 'Styczen';
moje_miesiace(2) := 'Luty';
moje_miesiace(3) := 'Marzec';
moje_miesiace(4) := 'Kwiecien';
moje_miesiace(5) := 'Maj';
moje_miesiace(6) := 'Czerwiec';
moje_miesiace(7) := 'Lipiec';
moje_miesiace(8) := 'Sierpien';
moje_miesiace(9) := 'Wrzesien';
moje_miesiace(10) := 'Pazdziernik';
moje_miesiace(11) := 'Listopad';
moje_miesiace(12) := 'Grudzien';
FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP dbms_output.put_line(moje_miesiace(i));
END LOOP;
dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());
moje_miesiace.trim(3);
FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP dbms_output.put_line(moje_miesiace(i));
END LOOP;
dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());
moje_miesiace.DELETE(7, 8);
FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP IF moje_miesiace.EXISTS(i) THEN dbms_output.put_line(moje_miesiace(i));
END IF;
END LOOP;
dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());
moje_miesiace(7) := 'Lipiec';
moje_miesiace(8) := 'Sierpien';
FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP IF moje_miesiace.EXISTS(i) THEN dbms_output.put_line(moje_miesiace(i));
END IF;
END LOOP;
dbms_output.put_line('Liczba elementow: ' || moje_miesiace.count());
END;
-- 10
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
CREATE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj VARCHAR2(30),
    jezyki jezyki_obce
);
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia
VALUES (
        'SOKRATES',
        'FRANCJA',
        jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI')
    );
INSERT INTO stypendia
VALUES (
        'ERASMUS',
        'NIEMCY',
        jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI')
    );
SELECT *
FROM stypendia;
SELECT s.jezyki
FROM stypendia s;
UPDATE stypendia
SET jezyki = jezyki_obce(
        'ANGIELSKI',
        'NIEMIECKI',
        'HISZPANSKI',
        'FRANCUSKI'
    )
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
CREATE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
CREATE TABLE semestry OF semestr NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry
VALUES (
        semestr(
            1,
            lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')
        )
    );
INSERT INTO semestry
VALUES (
        semestr(
            2,
            lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')
        )
    );
SELECT s.numer,
    e.*
FROM semestry s,
    TABLE (s.egzaminy) e;
SELECT e.*
FROM semestry s,
    TABLE (s.egzaminy) e;
SELECT *
FROM TABLE (
        SELECT s.egzaminy
        FROM semestry s
        WHERE numer = 1
    );
INSERT INTO TABLE (
        SELECT s.egzaminy
        FROM semestry s
        WHERE numer = 2
    )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE (
        SELECT s.egzaminy
        FROM semestry s
        WHERE numer = 2
    ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE (
        SELECT s.egzaminy
        FROM semestry s
        WHERE numer = 2
    ) e
WHERE e.column_value = 'BAZY DANYCH';
-- 11
CREATE TYPE koszyk_produktow AS TABLE OF VARCHAR2(20);
CREATE TYPE zakup AS OBJECT (
    id NUMBER,
    produkty koszyk_produktow
);
CREATE TABLE zakupy OF zakup NESTED TABLE produkty STORE AS tab_produkty;
INSERT ALL INTO zakupy
VALUES (
        zakup(1, koszyk_produktow('MASLO', 'SER', 'SZYNKA'))
    ) INTO zakupy
VALUES (
        zakup(2, koszyk_produktow('SER', 'MLEKO', 'SOK'))
    ) INTO zakupy
VALUES (
        zakup(3, koszyk_produktow('JAJKA', 'WODA', 'BANAN'))
    )
SELECT 1
FROM sys.DUAL;
SELECT *
FROM zakupy;
DELETE FROM zakupy a
WHERE a.id IN (
        SELECT a.id
        FROM zakupy z,
            TABLE (a.produkty) b
        WHERE b.column_value = 'MASLO'
    );
-- 12
CREATE TYPE instrument AS OBJECT (
    nazwa VARCHAR2(20),
    dzwiek VARCHAR2(20),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
CREATE TYPE BODY instrument AS MEMBER FUNCTION graj RETURN VARCHAR2 IS BEGIN RETURN dzwiek;
END;
END;
/ CREATE TYPE instrument_dety UNDER instrument (
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
CREATE OR REPLACE TYPE BODY instrument_dety AS OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS BEGIN RETURN 'dmucham: ' || dzwiek;
END;
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN glosnosc || ':' || dzwiek;
END;
END;
/ CREATE TYPE instrument_klawiszowy UNDER instrument (
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS BEGIN RETURN 'stukam w klawisze: ' || dzwiek;
END;
END;
/
DECLARE tamburyn instrument := instrument('tamburyn', 'brzdek-brzdek');
trabka instrument_dety := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian', 'pingping', 'steinway');
BEGIN dbms_output.put_line(tamburyn.graj);
dbms_output.put_line(trabka.graj);
dbms_output.put_line(trabka.graj('glosno'));
dbms_output.put_line(fortepian.graj);
END;
-- 13
CREATE TYPE istota AS OBJECT (
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
CREATE OR REPLACE TYPE BODY lew AS OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS BEGIN RETURN 'upolowana ofiara: ' || ofiara;
END;
END;
DECLARE KrolLew lew := lew('LEW', 4);
InnaIstota istota := istota('JAKIES ZWIERZE');
-- nie mozna utworzyc
BEGIN DBMS_OUTPUT.PUT_LINE(KrolLew.poluj('antylopa'));
END;
-- 14
DECLARE tamburyn instrument;
cymbalki instrument;
trabka instrument_dety;
saksofon instrument_dety;
BEGIN tamburyn := instrument('tamburyn', 'brzdek-brzdek');
cymbalki := instrument_dety('cymbalki', 'ding-ding', 'metalowe');
trabka := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
-- saksofon := instrument('saksofon','tra-taaaa');
-- saksofon := TREAT(instrument('saksofon','tra-taaaa') AS instrument_dety);
END;
-- 15
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty
VALUES (instrument('tamburyn', 'brzdek-brzdek'));
INSERT INTO instrumenty
VALUES (
        instrument_dety('trabka', 'tra-ta-ta', 'metalowa')
    );
INSERT INTO instrumenty
VALUES (
        instrument_klawiszowy('fortepian', 'ping-ping', 'steinway')
    );
SELECT i.nazwa,
    i.graj()
FROM instrumenty i;
-- 16
CREATE TABLE przedmioty (
    nazwa VARCHAR2(50),
    nauczyciel NUMBER REFERENCES pracownicy (id_prac)
);
INSERT INTO PRZEDMIOTY
VALUES ('BAZY DANYCH', 100);
INSERT INTO PRZEDMIOTY
VALUES ('SYSTEMY OPERACYJNE', 100);
INSERT INTO PRZEDMIOTY
VALUES ('PROGRAMOWANIE', 110);
INSERT INTO PRZEDMIOTY
VALUES ('SIECI KOMPUTEROWE', 110);
INSERT INTO PRZEDMIOTY
VALUES ('BADANIA OPERACYJNE', 120);
INSERT INTO PRZEDMIOTY
VALUES ('GRAFIKA KOMPUTEROWA', 120);
INSERT INTO PRZEDMIOTY
VALUES ('BAZY DANYCH', 130);
INSERT INTO PRZEDMIOTY
VALUES ('SYSTEMY OPERACYJNE', 140);
INSERT INTO PRZEDMIOTY
VALUES ('PROGRAMOWANIE', 140);
INSERT INTO PRZEDMIOTY
VALUES ('SIECI KOMPUTEROWE', 140);
INSERT INTO PRZEDMIOTY
VALUES ('BADANIA OPERACYJNE', 150);
INSERT INTO PRZEDMIOTY
VALUES ('GRAFIKA KOMPUTEROWA', 150);
INSERT INTO PRZEDMIOTY
VALUES ('BAZY DANYCH', 160);
INSERT INTO PRZEDMIOTY
VALUES ('SYSTEMY OPERACYJNE', 160);
INSERT INTO PRZEDMIOTY
VALUES ('PROGRAMOWANIE', 170);
INSERT INTO PRZEDMIOTY
VALUES ('SIECI KOMPUTEROWE', 180);
INSERT INTO PRZEDMIOTY
VALUES ('BADANIA OPERACYJNE', 180);
INSERT INTO PRZEDMIOTY
VALUES ('GRAFIKA KOMPUTEROWA', 190);
INSERT INTO PRZEDMIOTY
VALUES ('GRAFIKA KOMPUTEROWA', 200);
INSERT INTO PRZEDMIOTY
VALUES ('GRAFIKA KOMPUTEROWA', 210);
INSERT INTO PRZEDMIOTY
VALUES ('PROGRAMOWANIE', 220);
INSERT INTO PRZEDMIOTY
VALUES ('SIECI KOMPUTEROWE', 220);
INSERT INTO PRZEDMIOTY
VALUES ('BADANIA OPERACYJNE', 230);
-- 17
CREATE TYPE ZESPOL AS OBJECT (
    id_zesp NUMBER,
    nazwa VARCHAR2(50),
    adres VARCHAR2(100)
);
-- 18
CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL WITH OBJECT IDENTIFIER(ID_ZESP) AS
SELECT ID_ZESP,
    NAZWA,
    ADRES
FROM ZESPOLY;
-- 19
CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/ CREATE TYPE PRACOWNIK AS OBJECT (
    ID_PRAC NUMBER,
    NAZWISKO VARCHAR2(30),
    ETAT VARCHAR2(20),
    ZATRUDNIONY DATE,
    PLACA_POD NUMBER(10, 2),
    MIEJSCE_PRACY REF ZESPOL,
    PRZEDMIOTY PRZEDMIOTY_TAB,
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY PRACOWNIK AS MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS BEGIN RETURN PRZEDMIOTY.COUNT();
END ILE_PRZEDMIOTOW;
END;
-- 20 
CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK WITH OBJECT IDENTIFIER (ID_PRAC) AS
SELECT ID_PRAC,
    NAZWISKO,
    ETAT,
    ZATRUDNIONY,
    PLACA_POD,
    MAKE_REF(ZESPOLY_V, ID_ZESP),
    CAST(
        MULTISET(
            SELECT NAZWA
            FROM PRZEDMIOTY
            WHERE NAUCZYCIEL = P.ID_PRAC
        ) AS PRZEDMIOTY_TAB
    )
FROM PRACOWNICY P;
-- 21
SELECT *
FROM PRACOWNICY_V;
SELECT P.NAZWISKO,
    P.ETAT,
    P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;
SELECT P.NAZWISKO,
    P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;
SELECT *
FROM TABLE(
        SELECT PRZEDMIOTY
        FROM PRACOWNICY_V
        WHERE NAZWISKO = 'WEGLARZ'
    );
SELECT NAZWISKO,
    CURSOR(
        SELECT PRZEDMIOTY
        FROM PRACOWNICY_V
        WHERE ID_PRAC = P.ID_PRAC
    )
FROM PRACOWNICY_V P;
-- 22
CREATE TABLE PISARZE (
    ID_PISARZA NUMBER PRIMARY KEY,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE
);
CREATE TABLE KSIAZKI (
    ID_KSIAZKI NUMBER PRIMARY KEY,
    ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL VARCHAR2(50),
    DATA_WYDANIE DATE
);
INSERT INTO PISARZE
VALUES(10, 'SIENKIEWICZ', DATE '1880-01-01');
INSERT INTO PISARZE
VALUES(20, 'PRUS', DATE '1890-04-12');
INSERT INTO PISARZE
VALUES(30, 'ZEROMSKI', DATE '1899-09-11');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(10, 10, 'OGNIEM I
MIECZEM', DATE '1990-01-05');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(20, 10, 'POTOP', DATE '1975-12-09');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(30, 10, 'PAN
WOLODYJOWSKI', DATE '1987-02-15');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(40, 20, 'FARAON', DATE '1948-01-21');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(50, 20, 'LALKA', DATE '1994-08-01');
INSERT INTO KSIAZKI(
        ID_KSIAZKI,
        ID_PISARZA,
        TYTUL,
        DATA_WYDANIA
        VALUES(60, 30, 'PRZEDWIOSNIE', DATE '1938-02-02');
CREATE TYPE t_ksiazki AS TABLE OF VARCHAR2(50);
CREATE TYPE pisarz AS OBJECT (
    id_pisarza NUMBER,
    nazwisko VARCHAR2(20),
    data_ur DATE,
    ksiazki t_ksiazki,
    MEMBER FUNCTION ilosc_ksiazek RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY pisarz AS MEMBER FUNCTION ilosc_ksiazek RETURN NUMBER IS BEGIN RETURN ksiazki.count();
END ilosc_ksiazek;
END;
CREATE TYPE ksiazka AS OBJECT (
    id_ksiazki NUMBER,
    tytul VARCHAR2(50),
    data_wydania DATE,
    ksiazki t_ksiazki,
    autor REF pisarz,
    MEMBER FUNCTION wiek RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY ksiazka AS MEMBER FUNCTION wiek RETURN NUMBER IS BEGIN RETURN extract(
        YEAR
        FROM SYSDATE
    ) - extract(
        YEAR
        FROM data_wydania
    );
END wiek;
END;
CREATE OR REPLACE VIEW PISARZE_V OF pisarz WITH OBJECT IDENTIFIER (id_pisarza) AS
SELECT id_pisarza,
    nazwisko,
    data_ur,
    CAST(
        MULTISET(
            SELECT tytul
            FROM ksiazki
            WHERE id_pisarza = p.id_pisarza
        ) AS t_ksiazki
    )
FROM pisarze p;
CREATE OR REPLACE VIEW KSIAZKI_V OF ksiazka WITH OBJECT IDENTIFIER (id_ksiazki) AS
SELECT id_ksiazki,
    MAKE_REF(PISARZE_V, id_pisarza),
    tytul,
    data_wydania
FROM ksiazki;
-- 23
CREATE TYPE AUTO AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY AUTO AS MEMBER FUNCTION WARTOSC RETURN NUMBER IS WIEK NUMBER;
WARTOSC NUMBER;
BEGIN WIEK := ROUND(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12);
WARTOSC := CENA - (WIEK * 0.1 * CENA);
IF (WARTOSC < 0) THEN WARTOSC := 0;
END IF;
RETURN WARTOSC;
END WARTOSC;
END;
CREATE TABLE AUTA OF AUTO;
INSERT INTO AUTA
VALUES (
        AUTO('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000)
    );
INSERT INTO AUTA
VALUES (
        AUTO(
            'FORD',
            'MONDEO',
            80000,
            DATE '1997-05-10',
            45000
        )
    );
INSERT INTO AUTA
VALUES (
        AUTO('MAZDA', '323', 12000, DATE '2000-09-22', 52000)
    );
CREATE TYPE auto_osobowe UNDER auto (
    liczba_miejsc NUMBER,
    klimatyzacja VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY auto_osobowe AS OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER IS wartosc NUMBER;
BEGIN wartosc := cena;
IF (klimatyzacja = 'tak') THEN wartosc := wartosc * 1.5;
END IF;
RETURN wartosc;
END wartosc;
END;
CREATE TYPE auto_ciezarowe UNDER auto (
    maksymalna_ladownosc NUMBER,
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY auto_ciezarowe AS OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER IS wartosc NUMBER;
BEGIN wartosc := cena;
IF (maksymalna_ladownosc > 10000) THEN wartosc := wartosc * 2;
END IF;
RETURN wartosc;
END wartosc;
END;
INSERT INTO AUTA
VALUES (
        AUTO_OSOBOWE(
            'OPEL',
            'ASTRA',
            10000,
            DATE '2007-07-07',
            3000,
            5,
            'nie'
        )
    );
INSERT INTO AUTA
VALUES (
        AUTO_OSOBOWE(
            'OPEL',
            'VECTRA',
            10000,
            DATE '2012-12-12',
            3000,
            5,
            'tak'
        )
    );
INSERT INTO AUTA
VALUES (
        AUTO_CIEZAROWE(
            'VOLVO',
            '1',
            20000,
            DATE '2002-02-02',
            30000,
            5000
        )
    );