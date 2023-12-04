--v3

CREATE TABLE Prestazione_Staffetta(
	Societa integer REFERENCES Societa(Codice),
	TipologiaGara integer REFERENCES tipologia_gara(id) ON DELETE CASCADE ON UPDATE CASCADE,
	NomeCompetizione varchar(50),
	DataInizioCompetizione date,
	NumBatteria integer NOT NULL DEFAULT 1,
	Corsia integer NOT NULL,
	TempoRealizzato time(2),
	PRIMARY KEY (Societa, Tipologiagara, NomeCompetizione, DataInizioCompetizione),
	FOREIGN KEY (NomeCompetizione, DataInizioCompetizione)
		REFERENCES Competizione(Nome, DataInizio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Prestazione_Individuale(
	Atleta char(16) REFERENCES Atleta(CF),
	TipologiaGara integer REFERENCES tipologia_gara(id) ON DELETE CASCADE ON UPDATE CASCADE,
	NomeCompetizione varchar(50),
	DataInizioCompetizione date,
	NumBatteria integer NOT NULL DEFAULT 1,
	Corsia integer NOT NULL,
	TempoRealizzato time(2),
	PRIMARY KEY (Atleta, Tipologiagara, NomeCompetizione, DataInizioCompetizione),
	FOREIGN KEY (NomeCompetizione, DataInizioCompetizione)
		REFERENCES Competizione(Nome, DataInizio) ON DELETE CASCADE ON UPDATE CASCADE
);
--check isindivudual
CREATE OR REPLACE FUNCTION individuale_o_staffetta(tipologia_di_gara integer)
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
is_individual integer;
BEGIN
	SELECT isIndividuale INTO is_individual FROM tipologia_gara WHERE id=tipologia_di_gara;
	RETURN is_individual;
END;
$BODY$;

ALTER TABLE prestazione_individuale
ADD CONSTRAINT CHK_is_individuale
CHECK (individuale_o_staffetta(tipologiagara)=1);

ALTER TABLE prestazione_staffetta
ADD CONSTRAINT CHK_is_individuale
CHECK (individuale_o_staffetta(tipologiagara)=0);

CREATE TABLE Appartenenza(
	Atleta char(16) REFERENCES Atleta(CF),
	StagioneAgonistica char(9) REFERENCES Stagione_Agonistica(Codice),
	CodiceCategoria varchar(3) REFERENCES Categoria(Codice) NOT NULL,
	PRIMARY KEY (Atleta, StagioneAgonistica)
);

CREATE TABLE Tempo_Limite(
	CodiceCategoria varchar(3) REFERENCES Categoria(Codice),
	TipologiaGara integer REFERENCES tipologia_gara(id) ON DELETE CASCADE ON UPDATE CASCADE,
	NomeCompetizione varchar(50),
	DataInizioCompetizione date,
	TempoLimite time(2),
	PRIMARY KEY (CodiceCategoria, Tipologiagara, NomeCompetizione, DataInizioCompetizione),
	FOREIGN KEY (NomeCompetizione, DataInizioCompetizione)
		REFERENCES Competizione(Nome, DataInizio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Possesso_Componente(
	IdBrevetto varchar(10) PRIMARY KEY REFERENCES Brevetto(ID),
	Componente char(16) REFERENCES Componente(CF),
	DataInizio date NOT NULL
);

CREATE TABLE Possesso_Atleta(
	IdBrevetto varchar(10) PRIMARY KEY REFERENCES Brevetto(ID),
	Atleta char(16) REFERENCES Atleta(CF),
	DataInizio date NOT NULL
);

CREATE TABLE Possesso_Allenatore(
	IdBrevetto varchar(10) PRIMARY KEY REFERENCES Brevetto(ID),
	Allenatore char(16) REFERENCES Allenatore(CF),
	DataInizio date NOT NULL
);

CREATE TABLE Allenatore_Di_Categoria(
	Allenatore char(16) REFERENCES Allenatore(CF),
	CodiceCategoria varchar(3) REFERENCES Categoria(Codice),
	PRIMARY KEY(Allenatore, CodiceCategoria)
);

CREATE TABLE Amministrazione(
	Componente char(16) REFERENCES Componente(CF),
	Societa integer REFERENCES Societa(Codice),
	Ruolo varchar(50) NOT NULL,
	PRIMARY KEY(Componente, Societa),
	UNIQUE(Societa, Ruolo)
);

CREATE TABLE Affiliazione(
	Comitato varchar(10) REFERENCES Comitato(Acronimo),
	Societa integer REFERENCES Societa(Codice),
	Regione varchar(30) NOT NULL,
	PRIMARY KEY(Comitato, Societa)
);

CREATE TABLE Utilizzo(
	Societa integer REFERENCES Societa(Codice),
	Piscina integer REFERENCES Piscina(Codice),
	PRIMARY KEY (Societa, Piscina)
);