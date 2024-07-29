create table skola (
skola_id int primary key,
naziv varchar2(30),
adresa varchar2(40),
grad varchar2(30),
telefon varchar2(15),
email varchar2(30)
);
alter table skola add constraint chk_email_skola check (email like '%@gmail.com');
create table predmet (
predmet_id int primary key,
naziv varchar2(20)
);
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
);
alter table profesor add constraint chk_email_prof check (email like '%@gmail.com');
create table odeljenje (
odeljenje_id int primary key,
skola_id int,
naziv varchar2(30),
godina int,
foreign key (skola_id) references skola (skola_id)
);
create table razredni (
razredni_id int primary key,
profesor_id int,
odeljenje_id int,
godina int,
foreign key (profesor_id) references profesor(profesor_id),
foreign key (odeljenje_id) references odeljenje(odeljenje_id)
);
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
);
alter table ucenik add constraint chk_pol_ucenik CHECK (pol IN ('M', 'Z'));
alter table ucenik add constraint chk_email_ucenik check (email like '%@gmail.com');
create table ucionica (
ucionica_id int primary key,
skola_id int,
naziv varchar2(20),
kapacitet int,
foreign key (skola_id) references skola (skola_id)
);
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
);
create table ocena (
ocena_id int primary key,
ucenik_id int,
cas_id int,
ocena int,
datum date,
foreign key (ucenik_id) references ucenik (ucenik_id),
foreign key (cas_id) references cas (cas_id)
);
create table prisustvo (
prisustvo_id int primary key,
ucenik_id int,
cas_id int,
prisutan char(1) default 'Y' CHECK (Prisutan IN ('Y', 'N')),
foreign key (cas_id) references cas (cas_id),
foreign key (ucenik_id) references ucenik (ucenik_id)
);
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

create or replace procedure unos_ucionica (
p_skola_id int,
p_naziv varchar2,
p_kapacitet int
) as
begin
  insert into ucionica values (ucionica_seq.nextval,p_skola_id,p_naziv,p_kapacitet);
  dbms_output.put_line('Uspesno ste uneli ucionicu '''||p_naziv||''' u bazu podataka u tabelu ''ucionica''');
end;

create or replace procedure unos_predmet (
p_naziv varchar2
) as
begin
  insert into predmet values (predmet_seq.nextval,p_naziv);
  dbms_output.put_line('Uspesno ste uneli predmet '''||p_naziv||''' u bazu podataka u tabelu ''predmet''');
end;

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

create or replace procedure unos_razredni (
p_profesor_id int,
p_odeljenje_id int,
p_godina int
) as
begin
  insert into razredni values (razredni_seq.nextval,p_profesor_id,p_odeljenje_id,p_godina);
end;

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
/*
create or replace trigger ocena_datum
before insert on ocena
for each row
begin
  :new.datum := sysdate;
end;
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

exec unos_skola('Ekonomska skola','Gospodar Jovanova 1','Cacak','0645389244','ekonomskacacak@gmail.com');
exec unos_predmet('Srpski');
exec unos_predmet('Matematika');
exec unos_predmet('Istorija');
exec unos_predmet('Geografija');
exec unos_predmet('Engleski');
exec unos_predmet('Fizicko');
exec unos_predmet('Komercijala');
exec unos_profesor('Danijela','Nikolic',to_date('03/08/1977','dd/mm/yyyy'),'Z','Kulinovci bb', 'Cacak','0623584367','daca@gmail.com',7);
exec unos_profesor('Vesna','Petric',to_date('15/03/1968','dd/mm/yyyy'),'Z','Kulinovacko polje bb', 'Cacak','0652389146','vesnaca@gmail.com',5);
exec unos_profesor('Jelena','Katic',to_date('22/06/1974','dd/mm/yyyy'),'Z','Zablace bb', 'Cacak','0697584322','jelenajeca@gmail.com',1);
exec unos_profesor('Danijel','Ciric',to_date('07/09/1989','dd/mm/yyyy'),'M','Balkanska 16', 'Cacak','0623584692','dakici@gmail.com',2);
exec unos_profesor('Branko','Matic',to_date('27/01/1965','dd/mm/yyyy'),'M','Kursulina 11', 'Cacak','0612237864','brankoff@gmail.com',6);

exec unos_odeljenje(1,'Komercijalista',1);
exec unos_odeljenje(1,'Sluzbenik u BiO',1);
exec unos_odeljenje(1,'Ekonomski tehnicar',1);




exec unos_razredni(1,1,1);
exec unos_razredni(2,2,1);
exec unos_razredni(3,3,1);


exec unos_ucenik('Lazar','Savovic',to_date('06/03/2001','dd/mm/yyyy'),'M','Mrcajevci bb', 'Cacak','0641215894','ricke@gmail.com',1);
exec unos_ucenik('Lazar','Nikolic',to_date('11/05/2001','dd/mm/yyyy'),'M','Ljubic bb', 'Cacak','0658974235','zola@gmail.com',1);
exec unos_ucenik('Jovan','Stanic',to_date('09/07/2001','dd/mm/yyyy'),'M','Usicka 12', 'Veliko Gradiste','0612358964','stankec@gmail.com',1);
exec unos_ucenik('Vanja','Jankovic',to_date('15/10/2001','dd/mm/yyyy'),'M','Pristinska 23', 'Cacak','0627841295','njava@gmail.com',1);
exec unos_ucenik('Marija','Jerotijevic',to_date('31/03/2001','dd/mm/yyyy'),'Z','Kruzni put 147', 'Cacak','0657428935','jami@gmail.com',1);
exec unos_ucenik('Mina','Jevremovic',to_date('20/09/2001','dd/mm/yyyy'),'Z','Bulevar Vuka 53', 'Cacak','062147933','nami@gmail.com',1);

exec unos_ucenik('Nikola','Jerotijevic',to_date('12/11/2001','dd/mm/yyyy'),'M','Zenevska 1', 'Cacak','0663528947','dzoni@gmail.com',2);
exec unos_ucenik('Jovan','Jankovic',to_date('29/11/2001','dd/mm/yyyy'),'M','Mojsinje bb', 'Cacak','0613527981','jocko@gmail.com',2);
exec unos_ucenik('Marijana','Kucic',to_date('07/02/2001','dd/mm/yyyy'),'Z','Skopska 11', 'Kraljevo','0632598861','rimajana@gmail.com',2);
exec unos_ucenik('Ivona','Grujovic',to_date('19/04/2001','dd/mm/yyyy'),'Z','Kulinovci bb', 'Cacak','0659327342','ivona@gmail.com',2);






exec unos_ucionica(1,'Knjizevnost',30);
exec unos_ucionica(1,'Algebra',30);
exec unos_ucionica(1,'Fiskulturna sala',100);
exec unos_ucionica(1,'Ekonomija',15);
exec unos_ucionica(1,'Istorijat',30);
exec unos_ucionica(1,'Globus',30);
exec unos_ucionica(1,'Anglosaksonski',30);
exec unos_ucionica(4,'Hemikalije',45);
exec unos_ucionica(5,'Fizikalije',30);
exec unos_ucionica(6,'Saobracaj',30);
exec unos_cas(7,1,1,8,sysdate-5);
exec unos_cas(1,3,1,5,sysdate-5);
exec unos_cas(2,4,1,6,sysdate-5);
exec unos_cas(6,5,1,7,sysdate-5);
exec unos_prisustvo(2,1,'N');
exec unos_prisustvo(2,2,'N');
exec unos_prisustvo(2,3,'N');
exec unos_prisustvo(2,4,'N');
exec unos_prisustvo(3,4,'N');
exec unos_cas(3,6,2,9,sysdate - 5);
exec unos_cas(4,7,2,10,sysdate - 5);
exec unos_cas(5,2,2,11,sysdate - 5);
exec unos_cas(6,5,2,7,sysdate - 5);
exec unos_prisustvo(7,5,'N');
exec unos_prisustvo(8,5,'N');
exec unos_prisustvo(7,6,'N');
exec unos_cas(1,3,2,5,sysdate-4);
exec unos_cas(7,1,2,8,sysdate-4);
exec unos_cas(6,5,2,7,sysdate-4);
exec unos_cas(2,4,2,6,sysdate-4);
exec unos_prisustvo(9,16,'N');
exec unos_prisustvo(10,16,'N');
exec unos_prisustvo(10,16,'N');
exec unos_cas(5,2,1,11,sysdate-4);
exec unos_cas(6,5,1,7,sysdate-4);
exec unos_cas(3,6,1,9,sysdate-4);
exec unos_cas(4,7,1,10,sysdate-4);
exec unos_prisustvo(4,9,'N');
exec unos_prisustvo(4,10,'N');
exec unos_prisustvo(3,12,'N');
exec unos_prisustvo(3,12,'N');
exec unos_cas(2,4,1,6,sysdate-3);
exec unos_cas(5,2,1,11,sysdate-3);
exec unos_cas(7,1,1,8,sysdate-3);
exec unos_cas(3,6,1,9,sysdate-3);
exec unos_prisustvo(5,17,'N');
exec unos_prisustvo(6,17,'N');
exec unos_prisustvo(5,18,'N');
exec unos_prisustvo(6,18,'N');
exec unos_prisustvo(5,20,'N');
exec unos_prisustvo(6,20,'N');
exec unos_cas(3,6,2,9,sysdate-3);
exec unos_cas(4,7,2,10,sysdate-3);
exec unos_cas(1,3,2,5,sysdate-3);
exec unos_cas(2,4,2,6,sysdate-3);
exec unos_prisustvo(7,24,'N');
exec unos_cas(7,1,2,8,sysdate-2);
exec unos_cas(2,4,2,6,sysdate-2);
exec unos_cas(3,6,2,9,sysdate-2);
exec unos_cas(5,2,2,11,sysdate-2);
exec unos_prisustvo(9,32,'N');
exec unos_cas(3,6,1,9,sysdate-2);
exec unos_cas(1,3,1,5,sysdate-2);
exec unos_cas(2,4,1,6,sysdate-2);
exec unos_cas(4,7,1,10,sysdate-2);
exec unos_prisustvo(2,28,'N');
exec unos_cas(2,4,1,6,sysdate-1);
exec unos_cas(7,1,1,8,sysdate-1);
exec unos_cas(1,3,1,5,sysdate-1);
exec unos_cas(3,6,1,9,sysdate-1);
exec unos_prisustvo(5,35,'N');
exec unos_prisustvo(6,35,'N');
exec unos_prisustvo(5,36,'N');
exec unos_prisustvo(6,36,'N');
exec unos_cas(3,6,2,9,sysdate-1);
exec unos_cas(5,2,2,11,sysdate-1);
exec unos_cas(6,5,2,7,sysdate-1);
exec unos_cas(4,7,2,10,sysdate-1);

exec lista_ucenika_odeljenja(2);

exec unos_ocena(1,2,5);
exec unos_ocena(3,2,5);
exec unos_ocena(4,2,4);
exec unos_ocena(2,2,3);
exec unos_ocena(1,3,5);
exec unos_ocena(3,3,4);
exec unos_ocena(4,3,4);
exec unos_ocena(1,4,5);
exec unos_ocena(3,4,5);
exec unos_ocena(4,4,2);
exec unos_ocena(8,5,4);
exec unos_ocena(9,5,3);
exec unos_ocena(10,5,2);
exec unos_ocena(7,5,3);
exec unos_ocena(8,6,4);
exec unos_ocena(9,6,5);
exec unos_ocena(10,6,5);
exec unos_ocena(8,7,4);
exec unos_ocena(9,7,3);
exec unos_ocena(10,7,2);
-----