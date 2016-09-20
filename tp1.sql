CREATE TABLE Hotels (
  NumHo NUMERIC(10) PRIMARY KEY,
  NomHo CHAR(40) NOT NULL,
  RueAdrHo CHAR(40) NOT NULL,
  VilleHo Char(40) NOT NULL,
  NbEtoilesHo NUMERIC(1) 
);

INSERT INTO Hotels VALUES
  (0, 'F1', 'Rue 150', 'Cuers', 5);
  
INSERT INTO Hotels VALUES
  (1, 'GrandH', 'Avenue de Luminy', 'Toulon', 1);


CREATE TABLE TypesChambre (
  NumTy NUMERIC(10) PRIMARY KEY,
  NomTy CHAR(20) NOT NULL,
  PrixTy Numeric(3, 2) CHECK (PrixTy > 0) NOT NULL
);

INSERT INTO TypesChambre VALUES
  (0, 'simple', 5);

INSERT INTO TypesChambre VALUES
  (1, 'double', 9);

CREATE TABLE Chambres (
  NumCh NUMERIC(10) NOT NULL,
  NumHo NUMERIC(10) REFERENCES Hotels,
  NumTy NUMERIC(10) REFERENCES TypesChambre,
  PRIMARY KEY(NumCh, NumHo)
);

INSERT INTO Chambres VALUES
(0, 0, 0);

INSERT INTO Chambres VALUES
(1, 1, 0);

INSERT INTO Chambres VALUES
(2, 1, 1);

CREATE TABLE Clients (
  NumCl NUMERIC(10) PRIMARY KEY,
  NomCl CHAR(20) NOT NULL,
  PrenomCl CHAR(20) NOT NULL,
  RueAdrCl CHAR(40) NOT NULL,
  VilleCl CHAR(40) NOT NULL
);

INSERT INTO Clients VALUES
(0 ,'Henri', 'H', 'rue', 'Toulon');

INSERT INTO Clients VALUES
(1 ,'Celine', 'H', 'rue', 'Toulon');

CREATE TABLE Reservations (
  NumCl NUMERIC(10) REFERENCES Clients,
  NumHo NUMERIC(10) REFERENCES Hotels,
  NumTy NUMERIC(10) REFERENCES TypesChambre,
  DateA TIMESTAMP(0) NOT NULL,
  NbJours INTERVAL DAY TO SECOND(0) DEFAULT INTERVAL '1' DAY,
  NbChambres NUMERIC(3) NOT NULL,
  PRIMARY KEY(NumCl, NumHo, NumTy, DateA)
);

INSERT INTO RESERVATIONs VALUES
(0, 0, 0, '2015-02-01 10:30:20', '2', 1);

CREATE TABLE Occupations (
  NumCl NUMERIC(10) REFERENCES Clients,
  NumHo NUMERIC(10) REFERENCES Hotels,
  NumCh NUMERIC(10),
  DateA TIMESTAMP(0),
  DateD TIMESTAMP(0) NOT NULL,
  PRIMARY KEY (NumHo, NumCh, DateA),
  FOREIGN KEY (NumCh, NumHo) REFERENCES Chambres
);

SELECT NomHo
FROM Hotels
WHERE NbEtoilesHo > 2;

SELECT count(*) AS NbHotels
From Hotels;

SELECT NumCl, NomTy
FROM Chambres c, Occupations o, TypesChambre t
WHERE c.NumCh = c.NumCh
AND c.NumTy = t.NumTy;

SELECT NomCl, DateA
FROM CLients c,Hotels h, Reservations r
WHERE c.NumCl = r.NumCl
AND r.NumHo = h.NumHo
ORDER BY NomCl, DateA;



/*TP2*/
DROP TABLE OCCUPATIONS;




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
  DureeEp INTERVAL   DAY TO SECOND(0) NOT NULL
  );

CREATE TABLE Inscriptions(
  NumEtu NUMERIC(6) REFERENCES Etudiants,
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  PRIMARY KEY (NumEtu, NumEpr)
  );

CREATE TABLE HORAIRES(
  NumEpr NUMERIC(6) REFERENCES Epreuves,
  DateHeureDebut TIMESTAMP NOT NULL,
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

CREATE OR REPLACE TRIGGER C1
AFTER INSERT OR UPDATE
ON Horaires
DECLARE
  n INTEGER;
BEGIN
  SELECT 1 INTO N
  FROM  (SELECT * FROM Epreuves E, Inscriptions I, Horraires H
        WHERE E.NumEpr = I.NumEpr
        AND   H.NumEpr = E.NumEpr) T1,
        (SELECT * FROM Epreuves E, Inscriptions I, Horraires H
        WHERE E.NumEpr = I.NumEpr
        AND   H.NumEpr = E.NumEpr) T2
  WHERE T1.NumEtu = T2.NumEtu
  AND T1.NumEpr <> T2.NumEpr
  /* (T1.DateHeureDebut, T1.DureeEpr + T1.DateHeureDebut) OVERLAPS (T2.DateHeureDebut, T2.DureeEpr + T2.DateHeureDebut);*/
  
  RAISE to_many_row;
  
  EXCEPTION
    WHEN to_many_row   THEN RAISE application_error(-20000,'Erreur C1');
    WHEN no_data_found THEN NULL;

END; /
 

  