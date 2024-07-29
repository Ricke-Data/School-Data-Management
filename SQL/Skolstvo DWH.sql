--Kreiranje tabela
CREATE TABLE Dim_Skola (
    Dim_Skola_ID INT PRIMARY KEY,
    skola_id int,
    NazivSkole VARCHAR2(100),
    Adresa VARCHAR2(100),
    Grad VARCHAR2(50),
    Telefon VARCHAR2(20),
    Email VARCHAR2(100)
);
/
CREATE TABLE Dim_Odeljenje (
    Dim_Odeljenje_ID INT PRIMARY KEY,
    odeljenje_id int,
    NazivOdeljenja VARCHAR2(50),
    godina int
);
/
CREATE TABLE Dim_Ucenik (
    dim_Ucenik_ID INT PRIMARY KEY,
    ucenik_id int,
    Ime VARCHAR2(50),
    Prezime VARCHAR2(50),
    DatumRodjenja DATE,
    Pol CHAR(1),
    Adresa VARCHAR2(100),
    Grad VARCHAR2(50),
    Telefon VARCHAR2(20),
    Email VARCHAR2(100)
);
/
create table dim_razredni (
dim_razredni_id int primary key,
razredni_id int,
naziv_odeljenja varchar2(30),
godina int
);
/
CREATE TABLE Dim_Profesor (
    dim_Profesor_ID INT PRIMARY KEY,
    profesor_id int,
    Ime VARCHAR2(50),
    Prezime VARCHAR2(50),
    Datum_Rodjenja DATE,
    Pol CHAR(1),
    Adresa VARCHAR2(100),
    Grad VARCHAR2(50),
    Telefon VARCHAR2(20),
    Email VARCHAR2(100),
    Naziv_Predmeta varchar2(20),
    dim_razredni_id int,
    foreign key (dim_razredni_id) references dim_razredni (dim_razredni_id)
);
/
CREATE TABLE Dim_Ucionica (
    dim_Ucionica_ID INT PRIMARY KEY,
    ucionica_id int,
    Naziv_ucionice varchar2(20),
    Kapacitet INT
);
/
CREATE TABLE Dim_Predmet (
    dim_Predmet_ID INT PRIMARY KEY,
    predmet_id int,
    NazivPredmeta VARCHAR2(100)
);
/
create table dim_datum (
dim_datum_id int primary key,
datum date,
godina int,
mesec varchar2(20),
dan int,
dan_u_nedelji varchar2(11),
nedelja int,
kvartal char(2),
polugodiste char(2),
broj_dana_u_mesecu int,
radni_dan_indikator char(1)
);
/
CREATE TABLE Fact_Cas (
    fact_Cas_ID INT PRIMARY KEY,
    cas_id int,
    dim_datum_id int,
    dim_Predmet_ID INT,
    dim_Profesor_ID INT,
    dim_Ucionica_ID INT,
    dim_Odeljenje_ID INT,
    FOREIGN KEY (dim_Predmet_ID) REFERENCES Dim_Predmet(dim_Predmet_ID),
    FOREIGN KEY (dim_Profesor_ID) REFERENCES Dim_Profesor(dim_Profesor_ID),
    FOREIGN KEY (dim_Ucionica_ID) REFERENCES Dim_Ucionica(dim_Ucionica_ID),
    FOREIGN KEY (dim_Odeljenje_ID) REFERENCES Dim_Odeljenje(dim_Odeljenje_ID),
    FOREIGN KEY (dim_datum_ID) REFERENCES Dim_datum(dim_datum_ID)
);
/
CREATE TABLE Fact_Prisustvo (
    fact_Prisustvo_ID INT PRIMARY KEY,
    prisustvo_id int,
    dim_datum_id int references dim_Datum(dim_datum_id),
    dim_Ucenik_ID INT REFERENCES Dim_Ucenik(dim_Ucenik_ID),
    cas_ID INT,
    Prisutan CHAR(1)
);
/
CREATE TABLE Fact_Ocena (
    fact_Ocena_ID INT PRIMARY KEY,
    ocena_id int,
    dim_datum_id int references dim_datum(dim_datum_id),
    dim_Ucenik_ID INT REFERENCES Dim_Ucenik(dim_Ucenik_ID),
    cas_ID INT,
    Ocena number(4, 2)
);
/
--Kreiranje sekvenci
create sequence dim_odeljenje_seq start with 1 increment by 1;
create sequence dim_predmet_seq start with 1 increment by 1;
create sequence dim_profesor_seq start with 1 increment by 1;
create sequence dim_razredni_seq start with 1 increment by 1;
create sequence dim_skola_seq start with 1 increment by 1;
create sequence dim_ucenik_seq start with 1 increment by 1;
create sequence dim_ucionica_seq start with 1 increment by 1;
create sequence fact_cas_seq start with 1 increment by 1;
create sequence fact_ocena_seq start with 1 increment by 1;
create sequence fact_prisustvo_seq start with 1 increment by 1;

--Brisanje podataka iz tabela (ciscenje tabela)
truncate table dim_skola;
truncate table dim_odeljenje;
truncate table dim_ucionica;
truncate table dim_profesor;
truncate table dim_razredni;
truncate table dim_ucenik;
truncate table dim_predmet;
truncate table fact_prisustvo;
truncate table fact_ocena;
truncate table fact_cas;