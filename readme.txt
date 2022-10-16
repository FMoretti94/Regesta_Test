In questo file readme vengono descritti brevemente l'architettua utilizzata, oltre ai file presenti.

Architettura:
	Software utilizzato: xampp (8.1.10) + phpMyAdmin (5.2.0)
	Database: MariaDB (10.4.25)
	Linguaggio di programmazione: PHP (8.1.10)
	
	xampp è disponibile al seguente link: https://www.apachefriends.org/it/index.html

La progettazione è avvenuta seguendo questi passaggi:
	- Creazione del database;
	- Progettazione delle strutture del database;
	- Inserimento dei dati all'interno del database;
	- Sviluppo lato front-end e back-end;
	- Redazione del testbook;
	- Stesura del file "readme.txt".
	
Tutti i file sono stati inseriti nella cartella: C:\xampp\htdocs\regesta_test
L'applicazione è stata testata con i browser "Google Chrome" e "Mozilla Firefox".
Link: http://localhost/regesta_test/index.php
Prima di eseguire il software, importare il file "createDatabase.sql" all'interno di phpMyAdmin (http://localhost/phpmyadmin)


File: userGuide.pdf
	Contiene una breve guida su come utilizzare il software.
	I casi di esempio sono presenti nel file Testbook.xlsx.

File: createDatabase.sql
	Contiene tutto il necessario per:
	- creazione del database "regestatest";
	- creazione e grant per l'utente "test";
	- stored procedure "GetBestSupplier";
	- creazione delle tabelle;
	- creazione degli indici e delle foreign key;
	- dump dei dati utilizzati per il test.
	
	Stored procedure "Get available suppliers":
		La procedura riceve in input:
		- L'ID dell'articolo selezionato;
		- La quantità richiesta;
		- La data e ora attuale.
		Un primo cursore cicla tutti i fornitori che soddisfano la richiesta iniziale (articolo a stock per la quantità richiesta).
		Per ogni fornitore "valido", viene utilizzato un secondo cursore per recuperare tutti gli sconti validi (per valore dell'ordine, per quantità oppure per data dell'ordine).
		I dati vengono inseriti all'interno di una tabella temporanea (purchase_order), che viene poi utilizzata per popolare la pagina web con i fornitori che possono soddisfare la richiesta iniziale.

File: dbconn.php
	File utilizzato per stabilire la connessione con il database
	Contiene anche la query utilizzata per recupeare gli oggetti acquistabili

File index.php
	Pagina iniziale, dove è possibile selezionare l'articolo da acquistare ed inserire la quantità richiesta.
	Tramite l'uso di AJAX, una volta premuto il pulsante "Get available suppliers", vengono recuperati e mostrati i dati in maniera dinamica.
	Questo permette di effettuare la ricerca senza dover ricaricare la pagina.

File getbest.php
	File .php chiamato nel momento in cui si preme il pulsante "Get available suppliers" nella pagina "index.php".
	Se l'articolo o la quantità non vengono specificati, un popup avvisa l'utente.
	In questo file, viene effettuata la chiamata alla stored procedure "GetBestSupplier", alla quale vengono passati come parametri:
	- L'ID dell'articolo selezionato;
	- La quantità richiesta;
	- La data e ora attuale.
	Al termine della chiamata, i dati vengono elaborati e visualizzati all'interno di una tabella.
	Vengono mostrati sia il miglior venditore (per primo, evidenziando in verde la società ed il prezzo scontato) che gli altri venditori che soddisfano la richiesta iniziale.

File: style.css
	Contiene lo stile utilizzato per la pagina web.

File: Testbook.xlsx
	File Excel all'interno del quale sono presenti i casi di test utilizzati nella simulazione.
	Vengono descritte diverse casistiche possibili:
	- Solo un fornitore ha l'articolo disponibile nella quantità richiesta.
	- Almeno due fornitori hanno l'articolo disponibile nella quantità richiesta.
	
	Vengono affrontati diversi casi, in cui uno o più sconti vengono applicati.
	
	Gli sconti possono essere di tre tipologie diverse:
	- Valore totale della merce ordinata;
	- Quantità richiesta degli articoli;
	- Data dell'ordine all'interno di un range di date.