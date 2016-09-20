 /*TP2*/


DROP TABLE SURVEILLANCES;
DROP TABLE OCCUPATIONS;
DROP TABLE HORAIRES;
DROP TABLE INSCRIPTIONS;
DROP TABLE SALLES;
DROP TABLE EPREUVES;
DROP TABLE ENSEIGNANTS;
DROP TABLE ETUDIANTS;


CREATE TABLE Etudiants(
  NumEtu    NUMERIC(6) PRIMARY KEY,
  NomEtu    CHAR(20)   NOT NULL,
  PrenomEtu CHAR(20)   NOT NULL
  );

CREATE TABLE Enseignants(
  NumEns    NUMERIC(6) PRIMARY KEY,
  NomEns    CHAR(20)   NOT NULL,
  PrenomEns CHAR(20)   NOT NULL
  );
  
CREATE TABLE Salles(
  NumSal      NUMERIC(6) PRIMARY KEY,
  NomSal      CHAR(10)   NOT NULL,
  CapaciteSal NUMERIC(3) NOT NULL
  );
  
CREATE TABLE Epreuves(
  NumEpr  NUMERIC(6) PRIMARY KEY,
  NomEpr  CHAR(20)   NOT NULL,
  DureeEpr INTERVAL DAY TO SECOND(0) NOT NULL
  );

CREATE TABLE Inscriptions(
  NumEtu NUMERIC(6) REFERENCES Etudiants,
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  PRIMARY KEY (NumEtu, NumEpr)
  );

CREATE TABLE HORAIRES(
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  DateHeureDebut TIMESTAMP(0) NOT NULL,
  PRIMARY KEY (NumEpr)
  );

CREATE TABLE Occupations(
  NumSal NUMERIC(6) REFERENCES Salles,
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  NbPlacesOcc NUMERIC(6) NOT NULL,
  PRIMARY KEY(NumSal, NumEpr)
  );
  

CREATE TABLE Surveillances(
  NumEns         NUMERIC(6) REFERENCES Enseignants,
  DateHeureDebut TIMESTAMP  NOT NULL,
  NumSal         NUMERIC(6) REFERENCES Salles,
  PRIMARY KEY (NumEns, DateHeureDebut)
  );
  
/*C1*/


CREATE OR REPLACE TRIGGER C1_horaire_I_U
AFTER INSERT OR UPDATE
ON Horaires
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C1_inscription_I_U
AFTER INSERT OR UPDATE
ON Inscriptions
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END; 
/

CREATE OR REPLACE TRIGGER C1_epreuves_I_U
AFTER UPDATE
ON Epreuves
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, I.NumEtu, H.DateHeureDebut
         FROM Epreuves E, Inscriptions I, Horaires H
         WHERE E.NumEpr = I.NumEpr
         AND   H.NumEpr = E.NumEpr) b
  WHERE a.NumEtu = b.NumEtu
  AND a.NumEpr > b.NumEpr
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END; 
/

/*C2*/

CREATE OR REPLACE TRIGGER C2_epreuve_I_U
AFTER INSERT OR UPDATE
ON Epreuves
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C2_horaires_I_U
AFTER INSERT OR UPDATE
ON Horaires
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C2_occupations_I_U
AFTER INSERT OR UPDATE
ON occupations
DECLARE
  N binary_integer;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) a, 
        (SELECT E.NumEpr, E.DureeEpr, H.DateHeureDebut, O.NumSal
         FROM Epreuves E, Occupations O, Horaires H
         WHERE E.NumEpr = H.NumEpr
         AND   O.NumEpr = E.NumEpr) b
  WHERE a.NumSal = b.NumSal
  AND a.NumEpr > b.NumEpr
  AND a.DateHeureDebut <> b.DateHeureDebut
  AND (a.DateHeureDebut, a.DureeEpr) OVERLAPS (b.DateHeureDebut, b.DureeEpr);

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END;
/

CREATE OR REPLACE TRIGGER C4_Surveillances_I_U
BEFORE INSERT OR UPDATE
ON Surveillances
FOR EACH ROW
DECLARE
  N binary_integer;
BEGIN
  
  SELECT 1 INTO N
  FROM Surveillance S, HORAIRES H
  WHERE
  
  

  RAISE too_many_rows;
  
  EXCEPTION
    WHEN too_many_rows   THEN  raise_application_error(-20000,'Erreur C1_ins');
    WHEN no_data_found THEN NULL;

END;