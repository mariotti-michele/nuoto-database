--op.1
CREATE OR REPLACE FUNCTION aggiungi_competizione(nome_competizione varchar(100), data_inizio date, data_fine date, livello_agonistico varchar(20), 
	metodo_cronometraggio varchar(20), acronimo_comitato varchar(10), codice_piscina integer, codice_stagione_agonistica character(9))
RETURNS TABLE (new_nome_competizione varchar(100), new_data_inizio date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO competizione(nome, DataInizio, DataFine, LivelloAgonistico, MetodoCronometraggio, Comitato, Piscina, StagioneAgonistica)
		VALUES (nome_competizione, data_inizio, data_fine, livello_agonistico, metodo_cronometraggio, acronimo_comitato, codice_piscina, codice_stagione_agonistica)
		RETURNING nome, DataInizio;
END;
$BODY$;

--op.2
CREATE OR REPLACE FUNCTION aggiungi_atleta(cod_fiscale char(16), nome_par varchar(50), cognome_par varchar(50), data_nascita date, luogo_nascita varchar(50), sesso_par char(1))
RETURNS TABLE (new_cf char(16))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO atleta(CF, Nome, Cognome, DataNascita, LuogoNascita, Sesso)
		VALUES (cod_fiscale, nome_par, cognome_par, data_nascita, luogo_nascita, sesso_par)
		RETURNING CF;
END;
$BODY$;

--op.3
CREATE OR REPLACE FUNCTION aggiungi_gara(nome_competizione varchar(50), data_inizio_competizione date, tipologia_gara integer, data_par date)
RETURNS TABLE (new_nome_competizione varchar(50), new_data_inizio_competizione date, new_tipologia_gara integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO gara(NomeCompetizione, DataInizioCompetizione, TipologiaGara, Data)
		VALUES (nome_competizione, data_inizio_competizione, tipologia_gara, data_par)
		RETURNING NomeCompetizione, DataInizioCompetizione, TipologiaGara;
END;
$BODY$;

--op.4
CREATE OR REPLACE FUNCTION registra_prestazione_individuale(cf_atleta char(16), tipologia_gara integer, nome_competizione varchar(50), 
	data_inizio_competizione date, numero_batteria integer, corsia_par integer, tempo_realizzato time(2))
RETURNS TABLE (new_cf_atleta char(16), new_tipologia_gara integer, new_nome_competizione varchar(50), new_data_inizio_competizione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO prestazione_individuale(Atleta, TipologiaGara, NomeCompetizione, DataInizioCompetizione, NumBatteria, Corsia, TempoRealizzato)
		VALUES (cf_atleta, tipologia_gara, nome_competizione, data_inizio_competizione, numero_batteria, corsia_par, tempo_realizzato)
		RETURNING Atleta, TipologiaGara, NomeCompetizione, DataInizioCompetizione;
END;
$BODY$;

--op.5
CREATE OR REPLACE FUNCTION aggiungi_piscina(codice_piscina integer, nome_par varchar(255), lunghezza_par integer, numero_corsie integer,
	telefono_par varchar(13), email_par varchar(50), indirizzo_par varchar(255), comitato_omologante varchar(10), scadenza_omologazione date)
RETURNS TABLE (new_codice_piscina integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Piscina(Codice, Nome, Lunghezza, NumCorsie, Telefono, Email, Indirizzo, ComitatoOmologante, ScadenzaOmologazione)
		VALUES (codice_piscina, nome_par, lunghezza_par, numero_corsie, telefono_par, email_par, indirizzo_par, comitato_omologante, scadenza_omologazione)
		RETURNING Codice;
END;
$BODY$;

--op.6
CREATE OR REPLACE FUNCTION aggiungi_societa(codice_societa integer, nome_par varchar(255), email_par varchar(50), sede_par varchar(255), num_atleti_attualmente_tesserati integer)
RETURNS TABLE (new_codice_societa integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Societa(Codice, Nome, Email, Sede, NumeroAtletiAttualmenteTesserati)
		VALUES (codice_societa, nome_par, email_par, sede_par, num_atleti_attualmente_tesserati)
		RETURNING Codice;
END;
$BODY$;

--op.7
CREATE OR REPLACE FUNCTION aggiungi_allenatore(cod_fiscale char(16), nome_par varchar(50), cognome_par varchar(50), data_nascita date, luogo_nascita varchar(50), sesso_par char(1), livello_formazione varchar(50))
RETURNS TABLE (new_cf char(16))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO allenatore(CF, Nome, Cognome, DataNascita, LuogoNascita, Sesso, LivelloFormazione)
		VALUES (cod_fiscale, nome_par, cognome_par, data_nascita, luogo_nascita, sesso_par, livello_formazione)
		RETURNING CF;
END;
$BODY$;

--op 34
CREATE OR REPLACE FUNCTION aggiungi_tessera(numero_tessera integer, data_inizio date, data_scadenza date, tipo_vincolo char(10),
	cf_atleta char(16), acronimo_comitato varchar(10), codice_societa integer)
RETURNS TABLE (new_numero_tessera integer)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
value integer;
BEGIN
	SELECT NumeroAtletiAttualmenteTesserati INTO value FROM Societa WHERE Codice=codice_societa;
	IF(data_scadenza>NOW() AND (SELECT COUNT(*) FROM tessera WHERE atleta=cf_atleta AND societa=codice_societa AND datascadenza>NOW())=0) THEN
		UPDATE Societa
		SET NumeroAtletiAttualmenteTesserati=(value+1)
		WHERE Codice = codice_societa;
	END IF;
	RETURN QUERY
		INSERT INTO Tessera(NumeroTessera, DataInizio, DataScadenza, TipoVincolo, Atleta, Comitato, Societa)
		VALUES (numero_tessera, data_inizio, data_scadenza, tipo_vincolo, cf_atleta, acronimo_comitato, codice_societa)
		RETURNING NumeroTessera;
END;
$BODY$;

--op.35
CREATE OR REPLACE FUNCTION prolunga_tesseramento_atleta(numero_tessera_atleta integer, nuova_scadenza date)
RETURNS TABLE(numero_tessera integer, new_scadenza date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	UPDATE tessera
	SET
	DataScadenza=nuova_scadenza
	WHERE NumeroTessera=numero_tessera_atleta
	RETURNING NumeroTessera, DataScadenza;
END;
$BODY$;

--op.36
CREATE OR REPLACE FUNCTION termina_tesseramento_atleta(numero_tessera_atleta integer)
RETURNS void
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
value integer := (SELECT NumeroAtletiAttualmenteTesserati FROM Societa WHERE Codice=(SELECT Societa FROM Tessera WHERE NumeroTessera=numero_tessera_atleta));
BEGIN
	UPDATE tessera
	SET DataScadenza=NOW()
	WHERE NumeroTessera=numero_tessera_atleta;
	
	UPDATE Societa
	SET NumeroAtletiAttualmenteTesserati=(value-1)
	WHERE Codice = (SELECT Societa FROM Tessera WHERE NumeroTessera=numero_tessera_atleta);
END;
$BODY$;

--op.38
CREATE OR REPLACE FUNCTION aggiungi_contatto_societa(telefono_par varchar(13), codice_societa integer)
RETURNS TABLE (new_telefono varchar(13), new_codice_societa integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Telefono(numero, societa)
		VALUES (telefono_par, codice_societa)
		RETURNING numero, societa;
END;
$BODY$;

--op.40
CREATE OR REPLACE FUNCTION elimina_contatto(telefono_par varchar(13))
RETURNS TABLE (old_telefono varchar(13))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		DELETE FROM Telefono
		WHERE numero=telefono_par
		RETURNING numero;
END;
$BODY$;

--op.42
CREATE OR REPLACE FUNCTION aggiungi_brevetto(id_brevetto varchar(10), tipologia_brevetto varchar(50), durata_brevetto integer)
RETURNS TABLE (new_id_brevetto varchar(10))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO brevetto(ID,Tipologia, Durata)
		VALUES (id_brevetto, tipologia_brevetto, durata_brevetto)
		RETURNING ID;
END;
$BODY$;

--op.43
CREATE OR REPLACE FUNCTION aggiungi_stagione_agonistica(codice_stagione character(9), data_inizio date, data_fine date)
RETURNS TABLE (new_codice_stagione character(9))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Stagione_Agonistica(Codice, DataInizio, DataFine)
		VALUES (codice_stagione, data_inizio, data_fine)
		RETURNING Codice;
END;
$BODY$;

--op.44
CREATE OR REPLACE FUNCTION aggiungi_utilizzo_piscina(codice_societa integer, codice_piscina integer)
RETURNS TABLE (new_codice_societa integer, new_codice_piscina integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Utilizzo(Societa, Piscina)
		VALUES (codice_societa, codice_piscina)
		RETURNING Societa, Piscina;
END;
$BODY$;

--op.45
CREATE OR REPLACE FUNCTION termina_utilizzo(codice_societa integer, codice_piscina integer)
RETURNS TABLE(new_codice_societa integer, new_codice_piscina integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	DELETE 
	FROM Utilizzo
	WHERE Societa=codice_societa AND Piscina=codice_piscina
	RETURNING Societa, Piscina;
END;
$BODY$;

--op.46
CREATE OR REPLACE FUNCTION aggiungi_amministrazione(componente_par char(16), codice_societa_par integer, ruolo_par varchar(50))
RETURNS TABLE (new_componente_par char(16), new_codice_societa_par integer, new_ruolo_par varchar(50))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO Amministrazione(Componente, Societa, Ruolo)
		VALUES (componente_par, codice_societa_par, ruolo_par)
		RETURNING Componente, Societa, Ruolo;
END;
$BODY$;

--op.37
CREATE OR REPLACE FUNCTION piscine_utilizzate_da_societa(codice_societa integer)
RETURNS TABLE (new_piscina integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT Piscina
		FROM Utilizzo
		WHERE Societa=codice_societa;
END;
$BODY$;

--op.39
CREATE OR REPLACE FUNCTION contatti_societa(codice_societa integer)
RETURNS TABLE (new_numero varchar(13))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT Numero
		FROM Telefono
		WHERE Societa=codice_societa;
END;
$BODY$;

--op.41
CREATE OR REPLACE FUNCTION persone_con_brevetto_societa(codice_societa integer)
RETURNS TABLE (codice_fiscale char(16), new_nome varchar(50), new_cognome varchar(50), id_brevetto varchar(10), tipologia_brevetto varchar(50))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT CF, Nome, Cognome, IDBrevetto, Tipologia
		FROM Allenatore a join Possesso_Allenatore pa on a.CF=pa.allenatore join Brevetto b on pa.IDBrevetto=b.id join Tessera_Allenatore ta on a.cf=ta.allenatore
		WHERE ta.Societa=codice_societa
		UNION
		SELECT CF, Nome, Cognome, IDBrevetto, Tipologia
		FROM Atleta a join Possesso_Atleta pa on a.CF=pa.atleta join Brevetto b on pa.IDBrevetto=b.id join Tessera t on a.cf=t.atleta
		WHERE t.Societa=codice_societa
		UNION
		SELECT CF, Nome, Cognome, IDBrevetto, Tipologia
		FROM Componente c join Possesso_Componente pc on c.CF=pc.Componente join Brevetto b on pc.IDBrevetto=b.id join Amministrazione amm on c.cf=amm.Componente
		WHERE amm.Societa=codice_societa;
END;
$BODY$;

--op.24
CREATE OR REPLACE FUNCTION tempi_gara_individuale(id_tipologia_gara integer, nome_competizione varchar(100), data_inizio_competizione date, sesso_par char(1), codice_categoria varchar(3))
RETURNS TABLE(posizione bigint, cognome_atleta varchar(50), nome_atleta varchar(50), cf_atleta char(16), tempo time(2))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	IF(codice_categoria IS NULL) THEN
		RETURN QUERY
		SELECT ROW_NUMBER () OVER (ORDER BY pi.temporealizzato), at.cognome, at.nome, at.cf, pi.temporealizzato
		FROM prestazione_individuale pi join atleta at on atleta=cf
		WHERE pi.tipologiagara=id_tipologia_gara AND pi.NomeCompetizione=nome_competizione AND pi.DataInizioCompetizione=data_inizio_competizione
			AND at.sesso=sesso_par
		ORDER BY pi.temporealizzato ASC;
	ELSE
	RETURN QUERY
	SELECT ROW_NUMBER () OVER (ORDER BY pi.temporealizzato), at.cognome, at.nome, at.cf, pi.temporealizzato
		FROM prestazione_individuale pi join atleta at on pi.atleta=at.cf join appartenenza ap on at.cf=ap.atleta join competizione c on pi.NomeCompetizione=c.Nome AND pi.DataInizioCompetizione=c.DataInizio
		WHERE pi.tipologiagara=id_tipologia_gara AND pi.NomeCompetizione=nome_competizione AND pi.DataInizioCompetizione=data_inizio_competizione
			AND at.sesso=sesso_par AND ap.codicecategoria=codice_categoria AND c.StagioneAgonistica=ap.StagioneAgonistica
		ORDER BY pi.temporealizzato ASC;
	END IF;
END;
$BODY$;

--op.26
CREATE OR REPLACE FUNCTION tempi_atleta_tipologia_gara_ordine_data(cf_atleta char(16), id_tipologia_gara integer, lunghezza_vasca integer)
RETURNS TABLE(tempo time(2), new_nome_competizione varchar(100), new_data_inizio_competizione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	SELECT pi.temporealizzato, pi.NomeCompetizione, pi.DataInizioCompetizione
		FROM prestazione_individuale pi join atleta at on pi.atleta=at.cf join competizione c on pi.NomeCompetizione=c.Nome AND pi.DataInizioCompetizione=c.DataInizio
			join piscina pis on c.piscina=pis.codice
		WHERE at.cf=cf_atleta AND pis.lunghezza=lunghezza_vasca AND pi.tipologiagara=id_tipologia_gara
		ORDER BY pi.DataInizioCompetizione DESC;
END;
$BODY$;

--op.27
CREATE OR REPLACE FUNCTION tempi_atleta_tipologia_gara_ordine_tempo(cf_atleta char(16), id_tipologia_gara integer, lunghezza_vasca integer)
RETURNS TABLE(tempo time(2), new_nome_competizione varchar(100), new_data_inizio_competizione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	SELECT pi.temporealizzato, pi.NomeCompetizione, pi.DataInizioCompetizione
		FROM prestazione_individuale pi join atleta at on pi.atleta=at.cf join competizione c on pi.NomeCompetizione=c.Nome AND pi.DataInizioCompetizione=c.DataInizio
			join piscina pis on c.piscina=pis.codice
		WHERE at.cf=cf_atleta AND pis.lunghezza=lunghezza_vasca AND pi.tipologiagara=id_tipologia_gara
		ORDER BY pi.temporealizzato ASC;
END;
$BODY$;

--op.10
CREATE OR REPLACE FUNCTION info_piscina(codice_piscina integer)
RETURNS TABLE (Codice integer,
	Nome varchar(255),
	Lunghezza integer,
	Numero_Corsie integer,
	Telefono varchar(13),
	Email varchar(50),
	Indirizzo varchar(255),
	Comitato_Omologante varchar(10),
	Scadenza_Omologazione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM piscina
		WHERE piscina.Codice=codice_piscina;
END;
$BODY$;

--op.8
CREATE OR REPLACE FUNCTION info_competizione(nome_competizione varchar(50), data_inizio_competizione date)
RETURNS TABLE (Nome varchar(50),
	Data_Inizio date,
	Data_Fine date,
	Livello_Agonistico varchar(20),
	Metodo_Cronometraggio varchar(20),
	Comitato varchar(10),
	Piscina integer,
	Stagione_Agonistica character(9))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT *
		FROM competizione
		WHERE competizione.nome=nome_competizione AND competizione.datainizio = data_inizio_competizione;
END;
$BODY$;

--op.9
CREATE OR REPLACE FUNCTION info_atleta(codice_fiscale char(16))
RETURNS TABLE (CF char(16),
	Nome varchar(50),
	Cognome varchar(50),
	Data_Nascita date,
	Luogo_Nascita varchar(50), 
	Sesso char(1),
	Numero_Tessera integer ,
	Data_Inizio_tesseramento date ,
	Data_Scadenza_tesseramento date ,
	Tipo_Vincolo char(10),
	Comitato varchar(10),
	Societa varchar(255))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT atleta.CF, atleta.nome, atleta.cognome, atleta.datanascita, atleta.luogonascita, atleta.sesso, 
		tessera.numerotessera, tessera.datainizio, tessera.datascadenza, tessera.tipovincolo, tessera.comitato,
		societa.nome
		FROM atleta,societa,tessera
		WHERE atleta.CF=codice_fiscale AND societa.codice=tessera.societa AND atleta.CF=tessera.atleta;
END;
$BODY$;

--op.12
CREATE OR REPLACE FUNCTION info_allenatore(codice_fiscale char(16))
RETURNS TABLE (CF char(16),
	Nome varchar(50),
	Cognome varchar(50),
	Data_Nascita date,
	Luogo_Nascita varchar(50), 
	Sesso char(1),
	Livello_formazione varchar(50))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT a.CF, a.nome, a.cognome, a.datanascita, a.luogonascita, a.sesso, a.livelloformazione 
		FROM allenatore a
		WHERE a.CF=codice_fiscale;
END;
$BODY$;

--op.11
CREATE OR REPLACE FUNCTION info_societa(codice_societa integer)
RETURNS TABLE (Codice integer,
	Nome varchar(255),
	Email varchar(50),
	Sede varchar(255),
	Numero_Atleti_Attualmente_Tesserati integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		SELECT * 
		FROM societa s
		WHERE s.codice=codice_societa;
END;
$BODY$;

--op.13
CREATE OR REPLACE FUNCTION modifica_atleta(CF_atleta char(16), new_CF char(16) DEFAULT NULL,
	new_Nome varchar(50) DEFAULT NULL,
	new_Cognome varchar(50) DEFAULT NULL,
	new_Data_Nascita date DEFAULT NULL,
	new_Luogo_Nascita varchar(50) DEFAULT NULL, 
	new_Sesso char(1) DEFAULT NULL)
RETURNS char(16)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
actual_cf char(16);
actual_nome varchar(50);
actual_cognome varchar(50);
actual_Data_Nascita date;
actual_Luogo_Nascita varchar(50);
actual_Sesso char(1);
return_value char(16);
BEGIN
	SELECT CF, nome,cognome,datanascita,luogonascita,sesso 
	INTO actual_cf,actual_nome, actual_cognome, actual_data_nascita, actual_luogo_nascita, actual_sesso
	FROM atleta 
	WHERE CF=CF_atleta;
	IF(new_CF IS NOT NULL) THEN
		actual_cf:=new_CF;
		END IF;
	IF(new_nome IS NOT NULL) THEN
		actual_nome:=new_nome;
		END IF;
	IF(new_cognome IS NOT NULL) THEN
		actual_cognome:=new_cognome;
		END IF;
	IF(new_data_nascita IS NOT NULL) THEN
		actual_data_nascita:=new_data_nascita;
		END IF;
	IF(new_luogo_nascita IS NOT NULL) THEN
		actual_luogo_nascita:=new_luogo_nascita;
		END IF;
	IF(new_sesso IS NOT NULL) THEN
		actual_sesso:=new_sesso;
		END IF;
	UPDATE atleta
	SET
	CF=actual_CF,
	nome=actual_nome,
	cognome=actual_cognome,
	datanascita=actual_data_nascita,
	luogonascita=actual_luogo_nascita,
	sesso=actual_sesso
	WHERE CF=CF_atleta
	RETURNING CF INTO return_value;
	RETURN return_value AS CF_atleta_aggiornato;
END;
$BODY$;

--op.14
CREATE OR REPLACE FUNCTION modifica_piscina(codice_piscina integer, new_codice_piscina integer DEFAULT NULL,
	new_Nome varchar(255) DEFAULT NULL,
	new_Lunghezza integer DEFAULT NULL,
	new_Num_corsie integer DEFAULT NULL,
	new_Telefono varchar(13) DEFAULT NULL, 
	new_email varchar(50) DEFAULT NULL,
	new_Indirizzo varchar(255) DEFAULT NULL,
	new_Comitato_Omologante varchar(10) DEFAULT NULL,
	new_Scadenza_Omologazione date DEFAULT NULL
)
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
actual_codice_piscina integer;
actual_nome varchar(255);
actual_Lunghezza integer;
actual_Num_corsie integer;
actual_Telefono varchar(13);
actual_email varchar(50);
actual_indirizzo varchar(255);
actual_comitato_omologante varchar(10);
actual_scadenza_omologazione date;
return_value integer;
BEGIN
	SELECT codice, nome,Lunghezza,numcorsie,telefono,email, indirizzo, comitatoOmologante, scadenzaOmologazione
	INTO actual_codice_piscina,actual_nome, actual_Lunghezza, actual_Num_corsie, actual_Telefono, actual_email, 
		actual_comitato_omologante, actual_scadenza_omologazione
	FROM piscina 
	WHERE codice=codice_piscina;
	IF(new_codice_piscina IS NOT NULL) THEN
		actual_codice_piscina:=new_codice_piscina;
		END IF;
	IF(new_nome IS NOT NULL) THEN
		actual_nome:=new_nome;
		END IF;
	IF(new_Lunghezza IS NOT NULL) THEN
		actual_Lunghezza:=new_Lunghezza;
		END IF;
	IF(new_Num_corsie IS NOT NULL) THEN
		actual_Num_corsie:=new_Num_corsie;
		END IF;
	IF(new_Telefono IS NOT NULL) THEN
		actual_Telefono:=new_Telefono;
		END IF;
	IF(new_email IS NOT NULL) THEN
		actual_email:=new_email;
		END IF;
	IF(new_indirizzo IS NOT NULL) THEN
		actual_indirizzo:=new_indirizzo;
		END IF;
	IF(new_comitato_omologante IS NOT NULL) THEN
		actual_comitato_omologante:=new_comitato_omologante;
		END IF;
	IF(new_scadenza_omologazione IS NOT NULL) THEN
		actual_scadenza_omologazione:=new_scadenza_omologazione;
		END IF;
	UPDATE piscina
	SET
	codice=actual_codice_piscina,
	nome=actual_nome,
	Lunghezza=actual_Lunghezza,
	numcorsie=actual_Num_corsie,
	telefono=actual_telefono,
	email=actual_email,
	comitatoomologante=actual_comitato_omologante,
	scadenzaOmologazione = actual_scadenza_omologazione
	WHERE codice_piscina=codice_piscina
	RETURNING codice_piscina INTO return_value;
	RETURN return_value;
END;
$BODY$;

--op.15
CREATE OR REPLACE FUNCTION modifica_societa(codice_societa integer, new_codice_societa integer DEFAULT NULL,
	new_nome varchar(255) DEFAULT NULL, 
	new_email varchar(50) DEFAULT NULL,
	new_Sede varchar(255) DEFAULT NULL
)
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
actual_codice_societa integer;
actual_nome varchar(255);
actual_email varchar(50);
actual_Sede varchar(255);
return_value integer;
BEGIN
	SELECT codice, nome, email, sede
	INTO actual_codice_societa,actual_nome, actual_email, actual_sede
	FROM societa 
	WHERE codice=codice_societa;
	IF(new_codice_societa IS NOT NULL) THEN
		actual_codice_societa:=new_codice_societa;
		END IF;
	IF(new_nome IS NOT NULL) THEN
		actual_nome:=new_nome;
		END IF;
	IF(new_email IS NOT NULL) THEN
		actual_email:=new_email;
		END IF;
	IF(new_sede IS NOT NULL) THEN
		actual_sede:=new_sede;
		END IF;
	UPDATE societa
	SET
	codice=actual_codice_societa,
	nome=actual_nome,
	email=actual_email,
	sede=actual_sede
	WHERE codice_societa=codice_societa
	RETURNING codice_societa INTO return_value;
	RETURN return_value;
END;
$BODY$;

--op.16
CREATE OR REPLACE FUNCTION modifica_allenatore(CF_allenatore char(16), new_CF char(16) DEFAULT NULL,
	new_Nome varchar(50) DEFAULT NULL,
	new_Cognome varchar(50) DEFAULT NULL,
	new_Data_Nascita date DEFAULT NULL,
	new_Luogo_Nascita varchar(50) DEFAULT NULL, 
	new_Sesso char(1) DEFAULT NULL,
	new_livello_formazione varchar(50) DEFAULT NULL)
RETURNS char(16)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
actual_cf char(16);
actual_nome varchar(50);
actual_cognome varchar(50);
actual_Data_Nascita date;
actual_Luogo_Nascita varchar(50);
actual_Sesso char(1);
actual_livello_formazione varchar(50);
return_value char(16);
BEGIN
	SELECT CF, nome,cognome,datanascita,luogonascita,sesso 
	INTO actual_cf,actual_nome, actual_cognome, actual_data_nascita, actual_luogo_nascita, actual_sesso
	FROM allenatore 
	WHERE CF=CF_allenatore;
	IF(new_CF IS NOT NULL) THEN
		actual_cf:=new_CF;
		END IF;
	IF(new_nome IS NOT NULL) THEN
		actual_nome:=new_nome;
		END IF;
	IF(new_cognome IS NOT NULL) THEN
		actual_cognome:=new_cognome;
		END IF;
	IF(new_data_nascita IS NOT NULL) THEN
		actual_data_nascita:=new_data_nascita;
		END IF;
	IF(new_luogo_nascita IS NOT NULL) THEN
		actual_luogo_nascita:=new_luogo_nascita;
		END IF;
	IF(new_sesso IS NOT NULL) THEN
		actual_sesso:=new_sesso;
		END IF;
	IF(new_livello_formazione IS NOT NULL) THEN
		actual_livello_formazione:=new_livello_formazione;
		END IF;
	UPDATE allenatore
	SET
	CF=actual_CF,
	nome=actual_nome,
	cognome=actual_cognome,
	datanascita=actual_data_nascita,
	luogonascita=actual_luogo_nascita,
	sesso=actual_sesso,
	livelloFormazione=actual_livello_formazione
	WHERE CF=CF_allenatore
	RETURNING CF INTO return_value;
	RETURN return_value AS CF_allenatore_aggiornato;
END;
$BODY$;

--op.17
CREATE OR REPLACE FUNCTION elimina_competizione(nome_competizione varchar(50), data_inizio_competizione date)
RETURNS TABLE (nome varchar(50), 
			   data date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		DELETE FROM competizione
		WHERE competizione.nome=nome_competizione AND competizione.datainizio=data_inizio_competizione
		RETURNING competizione.nome,competizione.datainizio;
END;
$BODY$;

--op.18
CREATE OR REPLACE FUNCTION omologa_piscina(codice_piscina integer, comitato_omologante varchar(10), scadenza_omologazione date)
RETURNS TABLE(piscina integer, new_comitato_omologante varchar(10), new_scadenza_omologazione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	UPDATE piscina
	SET
	comitatoOmologante=comitato_omologante,
	scadenzaOmologazione=scadenza_omologazione
	WHERE Codice=codice_piscina
	RETURNING codice, comitatoOmologante, scadenzaOmologazione;
END;
$BODY$;

--op.19
CREATE OR REPLACE FUNCTION elimina_prestazione_individuale(CF_atleta char(16), nome_competizione varchar(50), data_inizio_competizione date, ID_tipologia_gara integer)
RETURNS TABLE (CF_atleta_del char(16), nome_competizione_del varchar(50), data_inizio_competizione_del date, ID_tipologia_gara_del integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		DELETE FROM prestazione_individuale
		WHERE nomecompetizione=nome_competizione AND datainiziocompetizione=data_inizio_competizione AND tipologiagara=ID_tipologia_gara AND atleta=CF_atleta
		RETURNING atleta,nomecompetizione,datainiziocompetizione,tipologiagara;
END;
$BODY$;

--op.20
CREATE OR REPLACE FUNCTION elimina_prestazione_staffetta(codice_societa integer, nome_competizione varchar(50), data_inizio_competizione date, ID_tipologia_gara integer)
RETURNS TABLE (societa_del integer, nome_competizione_del varchar(50), data_inizio_competizione_del date, ID_tipologia_gara_del integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		DELETE FROM prestazione_staffetta
		WHERE nomecompetizione=nome_competizione AND datainiziocompetizione=data_inizio_competizione AND tipologiagara=ID_tipologia_gara AND societa=codice_societa
		RETURNING societa,nomecompetizione,datainiziocompetizione,tipologiagara;
END;
$BODY$;

--op.21
CREATE OR REPLACE FUNCTION aggiungi_tesseramento_allenatore(codice_tessera integer, CF_allenatore char(16), codice_societa integer, data_inizio date, data_scadenza date)
RETURNS TABLE (new_codice_tessera integer, new_CF_allenatore char(16))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		INSERT INTO tessera_allenatore(codice, datainizio, datascadenza, allenatore, societa)
		VALUES (codice_tessera, data_inizio, data_scadenza, CF_allenatore, codice_societa)
		RETURNING codice, allenatore;
END;
$BODY$;

--op.22
CREATE OR REPLACE FUNCTION prolunga_tesseramento_allenatore(codice_tessera_allenatore integer, nuova_scadenza date)
RETURNS TABLE(codice_tessera integer, new_scadenza date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	UPDATE tessera_allenatore
	SET
	dataScadenza=nuova_scadenza
	WHERE codice=codice_tessera_allenatore
	RETURNING codice, dataScadenza;
END;
$BODY$;

--op.23
CREATE OR REPLACE FUNCTION interruzione_tesseramento_allenatore(codice_tessera_allenatore integer)
RETURNS TABLE(codice_tessera integer, data_interruzione date)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	UPDATE tessera_allenatore
	SET
	dataScadenza=CURRENT_DATE
	WHERE codice=codice_tessera_allenatore
	RETURNING codice, dataScadenza;
END;
$BODY$;

--op.28
CREATE OR REPLACE FUNCTION graduatoria_tempi_atleti(ID_tipologia_gara integer, sesso_par char(1), lunghezza_vasca integer, stagione char(9))
RETURNS TABLE(posizione bigint, CF_atleta char(16), tempo time(2))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	IF(stagione IS NOT NULL) THEN
		RETURN QUERY
		SELECT ROW_NUMBER () OVER (ORDER BY MIN(pi.temporealizzato)), atleta, MIN(pi.temporealizzato)
		FROM prestazione_individuale pi, atleta ath, competizione c, piscina pis
		WHERE pi.NomeCompetizione=c.Nome AND pi.DataInizioCompetizione=c.DataInizio AND c.piscina=pis.codice AND pi.atleta=ath.cf 
		AND pi.tipologiagara=ID_tipologia_gara AND ath.sesso=sesso_par AND pis.lunghezza=lunghezza_vasca AND stagioneagonistica=stagione
		GROUP BY atleta
		ORDER BY MIN(pi.temporealizzato);
	ELSE
	RETURN QUERY
	SELECT ROW_NUMBER () OVER (ORDER BY MIN(pi.temporealizzato)), atleta, MIN(pi.temporealizzato)
		FROM prestazione_individuale pi, atleta ath, competizione c, piscina pis
		WHERE pi.NomeCompetizione=c.Nome AND pi.DataInizioCompetizione=c.DataInizio AND c.piscina=pis.codice AND pi.atleta=ath.cf 
		AND pi.tipologiagara=ID_tipologia_gara AND ath.sesso=sesso_par AND pis.lunghezza=lunghezza_vasca
		GROUP BY atleta
		ORDER BY MIN(pi.temporealizzato);
	END IF;
END;
$BODY$;

--op.30
CREATE OR REPLACE FUNCTION migliori_tempi_atleta(CF_atleta char(16), lunghezza_vasca integer, stagione_par char(9))
RETURNS TABLE(tempo time(2), data_realizzazione date, codice_luogo_realizzazione integer, codice_tipologia_gara integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DROP TABLE IF EXISTS MigliorTempoStagione;
	CREATE TEMP TABLE MigliorTempoStagione(Tempo time(2), TipologiaGara integer);
	IF(stagione_par IS NOT NULL) THEN
		INSERT INTO MigliorTempoStagione SELECT min(pi.temporealizzato), pi.tipologiagara
		FROM prestazione_individuale pi, competizione c, piscina p
		WHERE pi.atleta=CF_atleta AND pi.nomecompetizione=c.nome AND pi.datainiziocompetizione=c.datainizio AND c.piscina = p.codice AND p.lunghezza=lunghezza_vasca AND
			c.stagioneagonistica=stagione_par
		GROUP BY tipologiagara;
	ELSE
		INSERT INTO MigliorTempoStagione SELECT min(pi.temporealizzato), tipologiagara
		FROM prestazione_individuale pi, competizione c, piscina p
		WHERE pi.atleta=CF_atleta AND pi.nomecompetizione=c.nome AND pi.datainiziocompetizione=c.datainizio AND c.piscina = p.codice AND p.lunghezza=lunghezza_vasca
		GROUP BY tipologiagara;
	END IF;
	RETURN QUERY
	SELECT DISTINCT mtapt.tempo, c.datainizio, c.piscina, pi.tipologiagara
	FROM MigliorTempoStagione mtapt, gara g, competizione c, prestazione_individuale pi
	WHERE 
	pi.atleta=CF_atleta AND pi.tipologiagara=mtapt.tipologiagara AND mtapt.tempo=pi.temporealizzato AND pi.datainiziocompetizione=c.datainizio AND
		pi.nomecompetizione = c.nome AND g.datainiziocompetizione=c.datainizio AND g.nomecompetizione = c.nome AND g.tipologiagara=pi.tipologiagara;
END;
$BODY$;

--op.47
CREATE OR REPLACE FUNCTION rimuovere_ruolo(CF_componente char(16), codice_societa integer)
RETURNS TABLE (CF_componente_del char(16), codice_societa_del integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
		DELETE FROM amministrazione
		WHERE  componente=CF_componente AND societa=codice_societa
		RETURNING componente,codice_societa;
END;
$BODY$;

--op.49
CREATE OR REPLACE FUNCTION definisci_categoria(CF_atleta char(16), stagione char(9), codice_categoria_par varchar(3))
RETURNS TABLE (new_cf_atleta char(16), new_stagione_agonistica char(9), new_codice_categoria varchar(3))
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
age integer;
BEGIN
	RETURN QUERY
		INSERT INTO appartenenza(atleta, stagioneagonistica, codicecategoria)
		VALUES (cf_atleta, stagione, codice_categoria_par)
		RETURNING atleta, stagioneagonistica, codicecategoria;
END;
$BODY$;

--op.48
CREATE OR REPLACE FUNCTION persone_in_societa(codice_societa integer)
RETURNS TABLE (CF char(16),
	Nome varchar(50),
	Cognome varchar(50),
	DataNascita date,
	LuogoNascita varchar(50), 
	Sesso char(1),
	Ruolo varchar(50))
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DROP TABLE IF EXISTS atleti_in_societa;
	DROP TABLE IF EXISTS allenatori_in_societa;
	DROP TABLE IF EXISTS role_atleta;
	DROP TABLE IF EXISTS role_allenatore;
	CREATE TEMP TABLE atleti_in_societa(CF char(16),
	Nome varchar(50),
	Cognome varchar(50),
	DataNascita date,
	LuogoNascita varchar(50), 
	Sesso char(1),
	Ruolo varchar(50));
	CREATE TEMP TABLE allenatori_in_societa(CF char(16),
	Nome varchar(50),
	Cognome varchar(50),
	DataNascita date,
	LuogoNascita varchar(50), 
	Sesso char(1),
	Ruolo varchar(50));
	CREATE TEMP TABLE role_atleta(Ruolo varchar(50));
	INSERT INTO role_atleta(Ruolo) VALUES ('Atleta');
	CREATE TEMP TABLE role_allenatore(Ruolo varchar(50));
	INSERT INTO role_allenatore(Ruolo) VALUES ('Allenatore');
	INSERT INTO atleti_in_societa SELECT atleta.*,role_atleta.* FROM atleta,tessera,role_atleta WHERE atleta.cf=tessera.atleta
		AND tessera.societa=codice_societa;
	INSERT INTO allenatori_in_societa SELECT a.cf, a.nome, a.cognome, a.datanascita, a.luogonascita, a.sesso, role_allenatore.*
										FROM allenatore a, tessera_allenatore, role_allenatore
										WHERE a.cf=tessera_allenatore.allenatore AND tessera_allenatore.societa=codice_societa;
	RETURN QUERY
		SELECT *
		FROM atleti_in_societa
		UNION
		SELECT componente.*, amministrazione.ruolo
		FROM componente, amministrazione
		WHERE componente.cf=amministrazione.componente AND amministrazione.societa=codice_societa
		UNION
		SELECT *
		FROM allenatori_in_societa;
END;
$BODY$;

--op.50
CREATE OR REPLACE FUNCTION affiliazione_societa(acronimo_comitato varchar(10), codice_societa integer, regione_appartenenza varchar(30))
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO affiliazione(comitato,societa,regione) VALUES (acronimo_comitato, codice_societa, regione_appartenenza);
	RETURN 1;
END;
$BODY$;

--op.51
CREATE OR REPLACE FUNCTION revoca_affiliazione_societa(acronimo_comitato varchar(10), codice_societa integer)
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	DELETE FROM affiliazione
	WHERE comitato=acronimo_comitato AND societa=codice_societa;
	RETURN codice_societa;
END;
$BODY$;

--op.52
CREATE OR REPLACE FUNCTION impostare_tempo_limite(codice_categoria varchar(3), tipologia_gara integer,
	Nome_Competizione varchar(50),
	Data_Inizio_Competizione date,
	Tempo_Limite time(2))
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO tempo_limite(codicecategoria,tipologiagara,nomecompetizione,datainiziocompetizione,tempolimite)
	VALUES (codice_categoria, tipologia_gara, Nome_Competizione, Data_Inizio_Competizione, Tempo_Limite);
	RETURN 1;
END;
$BODY$;

-- op_new
CREATE OR REPLACE FUNCTION aggiorna_numero_atleti(cod_societa integer)
RETURNS integer
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
num_atleti integer;
BEGIN
	SELECT count(atleta) INTO num_atleti FROM tessera WHERE societa=cod_societa AND datascadenza>NOW();
	UPDATE Societa SET numeroatletiattualmentetesserati=num_atleti WHERE codice=cod_societa;
	RETURN 1;
END;
$BODY$;