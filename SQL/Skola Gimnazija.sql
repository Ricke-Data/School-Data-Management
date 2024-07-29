create table skola (
skola_id int primary key,
naziv varchar2(30),
adresa varchar2(40),
grad varchar2(30),
telefon varchar2(15),
email varchar2(30)
);/
alter table skola add constraint chk_email_skola check (email like '%@gmail.com');
create table predmet (
predmet_id int primary key,
naziv varchar2(20)
);/
create table profesor (
profesor_id int primary key,
ime varchar2(15),
prezime varchar2(15),
datum_rodjenja date,
pol char(1),--PROVERA ZA UNOS SAMO M I Z
adresa varchar2(35),
grad varchar2(25),
telefon varchar2(15),
email varchar2(30),
predmet_id int,
foreign key (predmet_id) references predmet (predmet_id)
);/
alter table profesor add constraint chk_email_prof check (email like '%@gmail.com');
create table odeljenje (
odeljenje_id int primary key,
skola_id int,
naziv varchar2(30),
godina int,
foreign key (skola_id) references skola (skola_id)
);/
create table razredni (
razredni_id int primary key,
profesor_id int,
odeljenje_id int,
godina int,
foreign key (profesor_id) references profesor(profesor_id),
foreign key (odeljenje_id) references odeljenje(odeljenje_id)
);/
create table ucenik (
ucenik_id int primary key,
ime varchar2(15),
prezime varchar2(15),
datum_rodjenja date,
pol char(1),--PROVERA ZA UNOS SAMO M I Z
adresa varchar2(35),
grad varchar2(25),
telefon varchar2(15),
email varchar2(30),
odeljenje_id int,
foreign key (odeljenje_id) references odeljenje(odeljenje_id)
);/
alter table ucenik add constraint chk_pol_ucenik CHECK (pol IN ('M', 'Z'));
alter table ucenik add constraint chk_email_ucenik check (email like '%@gmail.com');
create table ucionica (
ucionica_id int primary key,
skola_id int,
naziv varchar2(20),
kapacitet int,
foreign key (skola_id) references skola (skola_id)
);/
create table cas(
cas_id int primary key,
predmet_id int,
profesor_id int,
odeljenje_id int,
ucionica_id int,
datum date,
--moze pocetak i kraj ali necu
foreign key (predmet_id) references predmet (predmet_id),
foreign key (profesor_id) references profesor(profesor_id),
foreign key (odeljenje_id) references odeljenje(odeljenje_id),
foreign key (ucionica_id) references ucionica(ucionica_id)
);/
create table ocena (
ocena_id int primary key,
ucenik_id int,
cas_id int,
ocena int,
datum date,
foreign key (ucenik_id) references ucenik (ucenik_id),
foreign key (cas_id) references cas (cas_id)
);/
create table prisustvo (
prisustvo_id int primary key,
ucenik_id int,
cas_id int,
prisutan char(1) default 'Y' CHECK (Prisutan IN ('Y', 'N')),
foreign key (cas_id) references cas (cas_id),
foreign key (ucenik_id) references ucenik (ucenik_id)
);/
--kreiranje sekvenci
create sequence cas_seq start with 1 increment by 1;
create sequence ocena_seq start with 1 increment by 1;
create sequence odeljenje_seq start with 1 increment by 1;
create sequence predmet_seq start with 1 increment by 1;
create sequence prisustvo_seq start with 1 increment by 1;
create sequence profesor_seq start with 1 increment by 1;
create sequence razredni_seq start with 1 increment by 1;
create sequence skola_seq start with 1 increment by 1;
create sequence ucenik_seq start with 1 increment by 1;
create sequence ucionica_seq start with 1 increment by 1;
--kreiranje trigera i ogranicenja za unos broja telefona
CREATE OR REPLACE TRIGGER format_telefon_prof
BEFORE INSERT OR UPDATE of telefon ON profesor
FOR EACH ROW
BEGIN
    IF :NEW.telefon LIKE '0%' THEN
        :NEW.telefon := '+381/' || SUBSTR(:NEW.telefon, 2);
    ELSE
        :NEW.telefon := '+381/' || :NEW.telefon;
    END IF;
END;
/
alter table profesor add constraint chk_form_tel_prof check (telefon like '+381/6%');
CREATE OR REPLACE TRIGGER format_telefon_skola
BEFORE INSERT OR UPDATE of telefon ON skola
FOR EACH ROW
BEGIN
    IF :NEW.telefon LIKE '0%' THEN
        :NEW.telefon := '+381/' || SUBSTR(:NEW.telefon, 2);
    ELSE
        :NEW.telefon := '+381/' || :NEW.telefon;
    END IF;
END;
/
alter table skola add constraint chk_form_tel_skola check (telefon like '+381/6%');
CREATE OR REPLACE TRIGGER format_telefon_ucenik
BEFORE INSERT OR UPDATE of telefon ON ucenik
FOR EACH ROW
BEGIN
    IF :NEW.telefon LIKE '0%' THEN
        :NEW.telefon := '+381/' || SUBSTR(:NEW.telefon, 2);
    ELSE
        :NEW.telefon := '+381/' || :NEW.telefon;
    END IF;
END;
/
alter table ucenik add constraint chk_form_tel_ucenik check (telefon like '+381/6%');
--kreiranje procedura
create or replace procedure unos_skola (
p_naziv varchar2,
p_adresa varchar2,
p_grad varchar2,
p_telefon varchar2,
p_email varchar2
) as
begin
  insert into skola values (skola_seq.nextval,p_naziv,p_adresa,p_grad,p_telefon,p_email);
  dbms_output.put_line('Uspesno ste uneli skolu '''||p_naziv||''' u bazu podataka u tabelu ''skola''!');
end;
/

create or replace procedure unos_odeljenje (
p_skola_id int,
p_naziv varchar2,
p_godina int
) is
p_skola varchar2(30);
begin
  select naziv into p_skola from skola where skola_id = p_skola_id;
  insert into odeljenje values (odeljenje_seq.nextval,p_skola_id,p_naziv,p_godina);
  dbms_output.put_line('Uspesno ste uneli odeljenje '''||p_naziv||''' iz skole '''||p_skola||
  ''' u bazu podataka u tabelu ''odeljenje''!');
end;
/

create or replace procedure unos_ucenik (
p_ime varchar2,
p_prezime varchar2,
p_datum_rodjenja date,
p_pol char,
p_adresa varchar2,
p_grad varchar2,
p_telefon varchar2,
p_email varchar2,
p_odeljenje_id int
) as
v_odeljenje varchar2(30);
v_skola varchar2(30);
begin
  select naziv into v_skola from skola where skola_id = (select skola_id from odeljenje where
  odeljenje_id = p_odeljenje_id);
  select naziv into v_odeljenje from odeljenje where odeljenje_id = p_odeljenje_id;
  insert into ucenik values (ucenik_seq.nextval,p_ime,p_prezime,p_datum_rodjenja,p_pol,p_adresa,
  p_grad,p_telefon,p_email,p_odeljenje_id);
  dbms_output.put_line('Uspesno ste uneli ucenika '''||p_ime||' '||p_prezime||''', iz odeljenja '''||
  v_odeljenje||''', iz skole '''||v_skola||''' u bazu podataka u tabelu ''ucenik''!');
end;
/

create or replace procedure unos_profesor (
p_ime varchar2,
p_prezime varchar2,
p_datum_rodjenja date,
p_pol char,
p_adresa varchar2,
p_grad varchar2,
p_telefon varchar2,
p_email varchar2,
p_predmet_id int
) as
v_predmet varchar2(20);
begin
  select naziv into v_predmet from predmet where predmet_id = p_predmet_id;
  insert into profesor values (profesor_seq.nextval,p_ime,p_prezime,p_datum_rodjenja,p_pol,p_adresa,
  p_grad,p_telefon,p_email,p_predmet_id);
  dbms_output.put_line('Uspesno ste uneli profesora '''||p_ime||' '||p_prezime||''', koji predaje '''
  ||v_predmet||''' u bazu podataka u tabelu ''profesor''!');
end;
/

create or replace procedure unos_ucionica (
p_skola_id int,
p_naziv varchar2,
p_kapacitet int
) as
begin
  insert into ucionica values (ucionica_seq.nextval,p_skola_id,p_naziv,p_kapacitet);
  dbms_output.put_line('Uspesno ste uneli ucionicu '''||p_naziv||''' u bazu podataka u tabelu ''ucionica''');
end;
/

create or replace procedure unos_predmet (
p_naziv varchar2
) as
begin
  insert into predmet values (predmet_seq.nextval,p_naziv);
  dbms_output.put_line('Uspesno ste uneli predmet '''||p_naziv||''' u bazu podataka u tabelu ''predmet''');
end;
/

create or replace procedure unos_cas (
p_predmet_id int,
p_profesor_id int,
p_odeljenje_id int,
p_ucionica_id int,
p_datum date
) as
p_predmet varchar2(30);
p_odeljenje varchar2(30);
p_skola varchar2(30);
begin
  select naziv into p_predmet from predmet where predmet_id = p_predmet_id;
  select naziv into p_odeljenje from odeljenje where odeljenje_id = p_odeljenje_id;
  select naziv into p_skola from skola where skola_id = (select skola_id from odeljenje where 
  odeljenje_id = p_odeljenje_id);
  insert into cas values (cas_seq.nextval,p_predmet_id,p_profesor_id,p_odeljenje_id,p_ucionica_id,
  p_datum);
  dbms_output.put_line('Uspesno ste uneli cas za predmet '''||p_predmet||''', odeljenje '''||
  p_odeljenje||''' iz skole '''||p_skola||'''');
end;
/

create or replace procedure unos_ocena (
p_ucenik_id int,
p_cas_id int,
p_ocena int
) as
p_predmet varchar2(35);
p_odeljenje varchar2(35);
p_ucenik varchar2(35);
p_datum date;
begin
  select naziv into p_predmet from predmet where predmet_id = (select predmet_id from cas where
  cas_id = p_cas_id);
  select naziv into p_odeljenje from odeljenje where odeljenje_id = (select odeljenje_id from cas
  where cas_id = p_cas_id);
  select ime||' '||prezime into p_ucenik from ucenik where ucenik_id = p_ucenik_id;
  select datum into p_datum from cas where cas_id = p_cas_id;
  insert into ocena values (ocena_seq.nextval,p_ucenik_id,p_cas_id,p_ocena,p_datum);
  dbms_output.put_line('Uspesno ste uneli ocenu '||p_ocena||' za predmet '''||p_predmet||''', 
  odeljenje '''||p_odeljenje||''' za ucenika '''||p_ucenik||'''');
end;
/

create or replace procedure unos_razredni (
p_profesor_id int,
p_odeljenje_id int,
p_godina int
) as
begin
  insert into razredni values (razredni_seq.nextval,p_profesor_id,p_odeljenje_id,p_godina);
end;
/

create or replace procedure unos_prisustvo (
p_ucenik_id int,
p_cas_id int,
p_prisutan char
) as
p_ucenik varchar2(35);
p_predmet varchar2(30);
p_odeljenje varchar2(30);
begin
  select naziv into p_predmet from predmet where predmet_id = (select predmet_id from cas where
  cas_id = p_cas_id);
  select naziv into p_odeljenje from odeljenje where odeljenje_id = (select odeljenje_id from cas
  where cas_id = p_cas_id);
  select ime||' '||prezime into p_ucenik from ucenik where ucenik_id = p_ucenik_id;
  insert into prisustvo values (prisustvo_seq.nextval,p_ucenik_id,p_cas_id,p_prisutan);
  dbms_output.put_line('Uspesno ste uneli odsustvo sa casa za ucenika '||p_ucenik||', za predmet '''
  ||p_predmet||''' iz odeljenja '''||p_odeljenje||'''');
end;
/
/*
create or replace trigger ocena_datum
before insert on ocena
for each row
begin
  :new.datum := sysdate;
end;
/
*/
create or replace trigger prisustvo_provera
before insert on prisustvo
for each row
declare
  v_odeljenje_id odeljenje.odeljenje_id%type;
  v_cas_odeljenje_id cas.odeljenje_id%type;
begin
  select odeljenje_id into v_odeljenje_id from ucenik where ucenik_id = :new.ucenik_id;
  select odeljenje_id into v_cas_odeljenje_id from cas where cas_id = :new.cas_id;
  if v_odeljenje_id != v_cas_odeljenje_id then
    raise_application_error(-20001,'Uneti ucenik ne pripada odeljenju sa unetog casa!');
  end if;
end;
/

create or replace trigger prisustvo_provera
before insert on prisustvo
for each row
declare
  v_odeljenje_id odeljenje.odeljenje_id%type;
  v_cas_odeljenje_id cas.odeljenje_id%type;
begin
  select odeljenje_id into v_odeljenje_id from ucenik where ucenik_id = :new.ucenik_id;
  select odeljenje_id into v_cas_odeljenje_id from cas where cas_id = :new.cas_id;
  if v_odeljenje_id != v_cas_odeljenje_id then
    raise_application_error(-20001,'Uneti ucenik ne pripada odeljenju sa unetog casa!');
  end if;
end;
/

create or replace trigger ocena_provera_prisustvo
before insert on ocena
for each row
declare
  v_odeljenje_id odeljenje.odeljenje_id%type;
  v_cas_odeljenje_id cas.odeljenje_id%type;
begin
  select odeljenje_id into v_odeljenje_id from ucenik where ucenik_id = :new.ucenik_id;
  select odeljenje_id into v_cas_odeljenje_id from cas where cas_id = :new.cas_id;
  if v_odeljenje_id != v_cas_odeljenje_id then
    raise_application_error(-20001,'Uneti ucenik ne pripada odeljenju sa unetog casa!');
  end if;
end;
/

create or replace trigger ocena_provera
before insert on ocena
for each row
declare
  v_count int;
begin
  select count(*) into v_count from prisustvo where ucenik_id = :new.ucenik_id and
  cas_id = :new.cas_id;
  if v_count > 0 then
    raise_application_error(-20002,'Ucenik nije bio prisutan na casu!');
  end if;
end;
/
---------------------------
create or replace procedure lista_ucenika_odeljenja (p_odeljenje_id int)
as
  cursor cur is select ucenik_id,ime,prezime from ucenik where odeljenje_id = p_odeljenje_id;
  v_ucenik_id ucenik.ucenik_id%type;
  v_ime ucenik.ime%type;
  v_prezime ucenik.prezime%type;
  v_odeljenje odeljenje.naziv%type;
begin
  select naziv into v_odeljenje from odeljenje where odeljenje_id = p_odeljenje_id;
  open cur;
    loop
      fetch cur into v_ucenik_id,v_ime,v_prezime;
      exit when cur%notfound;
      dbms_output.put_line('Ucenik broj: '||v_ucenik_id||', ime: '||v_ime||', prezime: '||v_prezime||
      ' iz odeljenja: '||v_odeljenje);
    end loop;
    close cur;
end;
/
----------------------------------

exec unos_skola('Gimnazija','Bate Jankovic 2','Cacak','0659324761','gimnazijacacak@gmail.com');
exec unos_odeljenje(1,'Prirodno-matematicki smer',1);
exec unos_odeljenje(1,'Drustveno-jezicki smer',1);
exec unos_predmet('Srpski');
exec unos_predmet('Matematika');
exec unos_predmet('Istorija');
exec unos_predmet('Geografija');
exec unos_predmet('Engleski');
exec unos_predmet('Fizicko');
exec unos_predmet('Nemacki');
exec unos_predmet('Latinski');
exec unos_profesor('Dejanfeag','Vethrhrsic',to_date('19/11/1985','dd/mm/yyyy'),'M','Nemanjina 4735', 'Cacak','0667263583','dejanvesgr@gmail.com',3);
exec unos_profesor('Nikogtehtla','eththNikic',to_date('21/02/1980','dd/mm/yyyy'),'M','Bate Jankovic 64', 'Cacak','0649834273','nihrehkoni@gmail.com',4);
exec unos_profesor('Dejanfeag','Vethrhrsic',to_date('12/12/1976','dd/mm/yyyy'),'M','Nemanjinaefewa 476', 'Cacak','0667263583','dejanvesgr@gmail.com',1);
exec unos_profesor('Nikogtehtla','eththNikic',to_date('14/05/1983','dd/mm/yyyy'),'M','Bate grehthJankovic 567', 'Cacak','0649834273','nihrehkoni@gmail.com',2);
exec unos_profesor('Dajana','Vethsic',to_date('17/10/1969','dd/mm/yyyy'),'Z','Nemanjitrjzrjztna 87', 'Cacak','0667263583','dajanaafaf@gmail.com',5);
exec unos_profesor('Nikoleta','fwrgkic',to_date('1/06/1971','dd/mm/yyyy'),'Z','Batetkt Jankovic 48', 'Cacak','0649834273','nikoletatata@gmail.com',6);
exec unos_profesor('Vesna','Vetfetzhrhrsic',to_date('19/11/1976','dd/mm/yyyy'),'Z','Nemanjinkt7it7a 46', 'Cacak','0667263583','vesnana@gmail.com',7);
exec unos_profesor('Nikolina','fretteththNikic',to_date('12/07/1965','dd/mm/yyyy'),'Z','Bate Jankt7ik7tkovic 678', 'Cacak','0649834273','nikolinafeg@gmail.com',8);
exec unos_odeljenje(3,'Prirodno-matematicki smer',1);
exec unos_odeljenje(3,'Drustveno-jezicki smer',1);
exec unos_razredni(1,1,1);
exec unos_razredni(2,2,1);

exec unos_ucenik('Anastasija','Vidakovic',to_date('28/05/2001','dd/mm/yyyy'),'Z','Mrcajevci bb', 'Cacak','0635598728','anasvi@gmail.com',1);
exec unos_ucenik('Andjela','Ignjovic',to_date('20/11/2001','dd/mm/yyyy'),'Z','Mrcajevci bb', 'Cacak','0625963148','andja@gmail.com',1);

exec unos_ucenik('Anja','Vidovic',to_date('21/05/2001','dd/mm/yyyy'),'Z','Baluga bb', 'Cacak','0698745621','anafe@gmail.com',2);
exec unos_ucenik('Andja','Ignjic',to_date('15/11/2001','dd/mm/yyyy'),'Z','Slatina bb', 'Cacak','0632145687','andjadjajdaja@gmail.com',2);
insert into ucionica select * from ekonomska.ucionica;
insert into cas select * from ekonomska.cas;

insert into ocena select * from ekonomska.ocena;
exec unos_ucionica(1,'Knjizevnost',30);
exec unos_ucionica(1,'Algebra',30);
exec unos_ucionica(1,'Fiskulturna sala',100);
exec unos_ucionica(1,'Istorijat',30);
exec unos_ucionica(1,'Globus',30);
exec unos_ucionica(1,'Anglosaksonski',30);
exec unos_ucionica(1,'Svabski',28);
exec unos_ucionica(1,'Latino',30);

exec unos_prisustvo(3,4,'N');
exec unos_prisustvo(2,5,'N');
exec unos_prisustvo(2,6,'N');
exec unos_prisustvo(2,7,'N');
exec unos_prisustvo(2,8,'N');
exec unos_prisustvo(1,12,'N');
exec unos_prisustvo(1,13'N');
exec unos_prisustvo(1,14,'N');
exec unos_prisustvo(1,15,'N');

exec unos_ocena(3,1,5);
exec unos_ocena(4,1,5);
exec unos_ocena(4,2,4);
exec unos_ocena(3,2,3);
exec unos_ocena(4,3,5);
exec unos_ocena(3,3,5);
exec unos_ocena(4,4,4);
exec unos_ocena(3,4,3);
exec unos_ocena(3,3,4);
exec unos_ocena(4,3,4);
exec unos_ocena(1,4,5);
exec unos_ocena(3,4,5);
exec unos_ocena(4,4,2);
exec unos_ocena(2,5,4);
exec unos_ocena(1,5,3);
exec unos_ocena(2,5,2);
exec unos_ocena(3,5,3);
exec unos_ocena(4,5,4);
exec unos_ocena(1,6,5);
exec unos_ocena(2,6,5);
exec unos_ocena(3,7,4);
exec unos_ocena(4,7,3);
exec unos_ocena(1,7,2);