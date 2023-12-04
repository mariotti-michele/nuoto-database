--v3

CREATE TABLE Stagione_Agonistica(
	Codice character(9) NOT NULL PRIMARY KEY UNIQUE,
	DataInizio date NOT NULL,
	DataFine date NOT NULL,
	CHECK (DataInizio<DataFine)
);

CREATE TABLE Categoria(
	Codice varchar(3) NOT NULL PRIMARY KEY UNIQUE,
	Nome varchar(50) NOT NULL,
	EtaMinima integer NOT NULL,
	EtaMassima integer DEFAULT NULL,
);

CREATE TABLE Componente(
	CF char(16) NOT NULL PRIMARY KEY UNIQUE,
	Nome varchar(50) NOT NULL,
	Cognome varchar(50) NOT NULL,
	DataNascita date NOT NULL,
	LuogoNascita varchar(50) NOT NULL, 
	Sesso char(1) NOT NULL,
	CHECK (Sesso='M' OR Sesso='F')
);

CREATE TABLE Atleta(
	CF char(16) NOT NULL PRIMARY KEY UNIQUE,
	Nome varchar(50) NOT NULL,
	Cognome varchar(50) NOT NULL,
	DataNascita date NOT NULL,
	LuogoNascita varchar(50) NOT NULL, 
	Sesso char(1) NOT NULL,
	CHECK (Sesso='M' OR Sesso='F')
);

CREATE TABLE Allenatore(
	CF char(16) NOT NULL PRIMARY KEY UNIQUE,
	Nome varchar(50) NOT NULL,
	Cognome varchar(50) NOT NULL,
	DataNascita date NOT NULL,
	LuogoNascita varchar(50) NOT NULL, 
	Sesso char(1) NOT NULL,
	LivelloFormazione varchar(50) NOT NULL,
	CHECK (Sesso='M' OR Sesso='F')
);

CREATE TABLE Tipologia_Gara(
	ID integer NOT NULL UNIQUE PRIMARY KEY,
	Lunghezza varchar(10) NOT NULL,
	Stile varchar(50) NOT NULL,
	isIndividuale integer NOT NULL,
	CHECK (isIndividuale=0 OR isIndividuale=1)
);

CREATE TABLE Brevetto(
	ID varchar(10) NOT NULL UNIQUE PRIMARY KEY,
	Tipologia varchar(50) NOT NULL,
	Durata integer NOT NULL
);

CREATE TABLE Societa(
	Codice integer NOT NULL UNIQUE PRIMARY KEY,
	Nome varchar(255) NOT NULL,
	Email varchar(50) NOT NULL,
	Sede varchar(255) NOT NULL,
	NumeroAtletiAttualmenteTesserati integer DEFAULT 0,
	CHECK (Email LIKE '%_@_%.__%')
);

CREATE TABLE Comitato(
	Acronimo varchar(10) NOT NULL UNIQUE PRIMARY KEY,
	Nome varchar(255) NOT NULL
);

CREATE TABLE Tessera(
	NumeroTessera integer NOT NULL UNIQUE PRIMARY KEY,
	DataInizio date NOT NULL,
	DataScadenza date NOT NULL,
	TipoVincolo char(10) NOT NULL,
	Atleta char(16) NOT NULL REFERENCES Atleta(CF),
	Comitato varchar(10) NOT NULL REFERENCES Comitato(Acronimo),
	Societa integer NOT NULL REFERENCES Societa(Codice),
	CHECK(DataInizio<DataScadenza)
);

CREATE TABLE Tessera_Allenatore(
	Codice integer NOT NULL UNIQUE PRIMARY KEY,
	DataInizio date NOT NULL,
	DataScadenza date NOT NULL,
	Allenatore char(16) NOT NULL REFERENCES Allenatore(CF),
	Societa integer NOT NULL REFERENCES Societa(Codice),
	CHECK(DataInizio<DataScadenza)
);

CREATE TABLE Piscina(
	Codice integer NOT NULL UNIQUE PRIMARY KEY,
	Nome varchar(255) NOT NULL,
	Lunghezza integer NOT NULL,
	NumCorsie integer NOT NULL,
	Telefono varchar(13) NOT NULL,
	Email varchar(50) NOT NULL,
	Indirizzo varchar(255) NOT NULL,
	ComitatoOmologante varchar(10) REFERENCES Comitato(Acronimo),
	ScadenzaOmologazione date NOT NULL,
	CHECK ((Email LIKE '%_@_%.__%') AND Lunghezza>0 AND NumCorsie>0)
);

CREATE TABLE Telefono(
	Numero varchar(13) NOT NULL UNIQUE PRIMARY KEY,
	Societa integer NOT NULL REFERENCES Societa(Codice)
);

CREATE TABLE Competizione(
	Nome varchar(100) NOT NULL,
	DataInizio date NOT NULL,
	DataFine date NOT NULL,
	LivelloAgonistico varchar(20) NOT NULL,
	MetodoCronometraggio varchar(20) NOT NULL,
	Comitato varchar(10) NOT NULL REFERENCES Comitato(Acronimo),
	Piscina integer NOT NULL REFERENCES Piscina(Codice),
	StagioneAgonistica character(9) NOT NULL REFERENCES Stagione_Agonistica(Codice),
	PRIMARY KEY(Nome, DataInizio),
	CHECK(DataInizio<=DataFine)
);
--check stagione
ALTER TABLE competizione
ADD CONSTRAINT CHK_datainizio_in_stagioneagonistica 
CHECK (datainizio>TO_DATE(CONCAT(SUBSTRING(stagioneagonistica, 1,4), '-09-01'),'YYYY-MM-DD') AND 
	   datainizio<TO_DATE(CONCAT(SUBSTRING(stagioneagonistica, 6,9), '-08-31'),'YYYY-MM-DD'));


CREATE TABLE Gara(
	NomeCompetizione varchar(50) NOT NULL,
	DataInizioCompetizione date NOT NULL,
	TipologiaGara integer NOT NULL REFERENCES Tipologia_gara(ID),
	Data date NOT NULL,
	FOREIGN KEY (NomeCompetizione, DataInizioCompetizione)
		REFERENCES Competizione(Nome, DataInizio) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(NomeCompetizione, DataInizioCompetizione, TipologiaGara),
	CHECK(Data>=DataInizioCompetizione)
);