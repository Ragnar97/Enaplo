-----------------------------------------------------------------------------------------------------
--1.	a hibás tantervek (amik szerint valamely szakon egy félévben a heti óraszám 30 óra felett lenne)
create procedure hibas_Tanterv 
as
begin
--1.feladat
Select Tanterv.hanyadik_szem, szakid,hanyadik_szem,Tanterv.tantárgy,heti_óraszám from Tanterv
Inner join órarend on Tanterv.szakid=Órarend.szak
Inner join tantárgy on tantárgy.tantárgyid=tanterv.tantárgy
group by Tanterv.hanyadik_szem, szakid, hanyadik_szem,tanterv.tantárgy, heti_óraszám 
having heti_óraszám>30
end
go


-----------------------------------------------------------------------------------------------------
--2.	tanmenet elõállítása adott szakra és adott tantárgyra az elõírt csoportokkal

-----------------------------------------------------------------------------------------------------
--3.	a hibás tanmenetek (amikben nem alkalmas a tanár)
create procedure sp3
as
begin
	SELECT *
	FROM Tanmenetfélév t
	WHERE NOT EXISTS
	(
		SELECT *
        FROM Képes k
        WHERE t.tanár = k.tanár AND t.tantárgy = k.tantárgy
	)
end
-----------------------------------------------------------------------------------------------------
--4.	mely tanárok elõírt heti óraszáma haladja meg a 26 órát
create procedure max26ora
as 
begin 

		SELECT  tanár,SUM(heti_óraszám) as össz into #temp
			FROM Tanmenetfélév tf, Tantárgy t
				where tf.tantárgy=t.tantárgyid 
					group by  tanár,heti_óraszám
		
		
		select név,  sum(össz) as óraszám into #temp2
			from #temp t, Tanár ta where t.tanár = ta.tanárid
				group by  név,  össz
					having össz > 7;
		
		select név, sum(óraszám) as összo into #temp3
			from #temp2
				group by név;

		select * from #temp3 where összo>26 ;
		

		drop table #temp
		drop table #temp2
		drop table #temp3
		--exec max26ora
end 
go
-----------------------------------------------------------------------------------------------------
--5.	a hibás órarendi alkalmak (amik terme nem megfelelõ)
create procedure sp5
as
begin
	SELECT tantárgy,terem
	FROM Órarend
	WHERE tantárgy NOT IN
	(
		SELECT tantárgy.id
		FROM Tantárgy,Speci
		WHERE Tantárgy.teremigény = Speci.id
	)
end
-----------------------------------------------------------------------------------------------------
--6.	mely csoportok mikor ütköznek az órarend szerint



-----------------------------------------------------------------------------------------------------
--7.	mely teremben mikor van ütközés az órarend szerint

create view  terem_Utkozes 
as
--7.feladat
SELECT nap, óra,terem
FROM órarend
GROUP BY csoport,terem, nap, óra
HAVING count(terem)>1


-----------------------------------------------------------------------------------------------------
--8. mely tanárnak mikor van ütközése az órarend szerint



-----------------------------------------------------------------------------------------------------
--9.	adott csoportnak melyik tárgyból hány órája nincs még leütemezve


create procedure sp9
	@szak int,
	@évfolyam tinyint,
	@betû nvarchar(1),
	@csoport tinyint
as
begin
	
	create table #Leütemezett
	(
		tantárgy int, 
		darab tinyint
	)
	INSERT INTO #Leütemezett
	SELECT tantárgy, Count(*) 
	FROM Órarend ó
	WHERE 
		ó.szak = @szak AND 
		ó.évfolyam = @évfolyam AND 
		ó.betû = @betû AND 
		ó.csoport = @csoport
	GROUP BY tantárgy


	create table #Szükséges
	(
		tantárgy int, 
		darab tinyint
	)
	INSERT INTO #Szükséges
	SELECT tmf.tantárgy, tt.heti_óraszám
	FROM Tanmenetfélév tmf, Tantárgy tt
	WHERE 
		tmf.szak = @szak AND 
		tmf.évfolyam = @évfolyam AND 
		tmf.betû = @betû AND 
		tmf.csoport = @csoport AND 
		tmf.tantárgy = tt.id


	 
	 SELECT sz.tantárgy, sz.darab - l.darab
	 FROM #Leütemezett l, #Szükséges sz
	 WHERE l.tantárgy = sz.tantárgy
	 UNION
	 SELECT tantárgy, darab
	 FROM #Szükséges
	 WHERE tantárgy NOT IN (SELECT tantárgy FROM #Leütemezett)


	Drop Table #Leütemezett
	Drop Table #Szükséges

end



-----------------------------------------------------------------------------------------------------
--10.	a hibás hiányzások (amik szerint nem is az órarendi órájáról hiányzott a diák)
create procedure rosszhianyzas
as 
begin 

	select distinct (DATEPART(dw, dátum) + 5) % 7 + 1 as nap ,óra  into #valami  from HiányzásFélév
	 
	 select * 
		from #valami 
			where concat(nap,óra) not in (select CONCAT(nap, óra) 
											from Órarend) 

	 drop table #valami
end
go

exec rosszhianyzas


-----------------------------------------------------------------------------------------------------
--11.	a hibás évközi jegyek (amiket nem a tanmenet szerinti tárgyból kapta a diák)

create procedure sp11
as
begin
	SELECT minõsítés
	FROM Diák,Jegyfelev
	WHERE Diák.diákid = Jegyfelev.diák
	AND tantárgy not in
	(
		SELECT tantárgy
		FROM Tanmenetfélév
	)
end


-----------------------------------------------------------------------------------------------------
--12.	az adott tanárt melyik tárgyból kik helyettesítették név szerint 



-----------------------------------------------------------------------------------------------------
--13.	adott félévben mely diákok mibõl nem osztályozhatók
CREATE PROCEDURE nem_Osztalyozhato
	 @felev int
AS
BEGIN
	
Select diák.diákid,tantárgy,szak.hány_szem
from diák
inner join jegyfelev on diák.diákid=Jegyfelev.diák
Inner join Osztály on Osztály.szak=diák.szak and Osztály.évf=diák.évf and Osztály.betû=diák.betû
Inner join Szak on szak.szakid=Osztály.szak
group by diák.diákid,tantárgy,szak.hány_szem
having  diák.diákid not in (Select diák from Jegyfelev) and szak.hány_szem=@felev
END
GO



-----------------------------------------------------------------------------------------------------
--14.	adott csoport félévi jegyeinek kiszámítása
create procedure sp14
	@szak int,
	@évfolyam tinyint,
	@betû nvarchar(1),
	@csoport tinyint
as
begin
	
	create table #seged
	(
		diakok int,
	)
	Insert into #seged (diakok) values ((select diákid from Diák where szak=@szak and évf=@évfolyam and betû=@betû and csoport=@csoport))

	
	select avg(jegy)as átlag from Bizonyítvány where diákid in (select * from #seged)
	drop table #seged
end


-----------------------------------------------------------------------------------------------------
--15.	a bizonyítvány jóváhagyott jegyei szerinti osztályátlagok
create procedure sp15
as
begin
   SELECT o.szak, o.évf, o.betû, AVG(b.jegy) AS átlag
   FROM Osztály o, Bizonyítvány b
   WHERE b.jóváhagyás = 1
   GROUP BY o.szak, o.évf, o.betû
end


-----------------------------------------------------------------------------------------------------
--16.	a bizonyítvány jóváhagyott jegyei szerinti tantárgyi átlagok
create view fel16
as 
(
	select megnevezés, avg(jegy) as átlag from Bizonyítvány b , Tantárgy t
	where jóváhagyás=1 and b.tantárgyid = t.tantárgyid
	group by megnevezés
)


-----------------------------------------------------------------------------------------------------
--17.	a bizonyítvány jóváhagyott jegyei szerint az egyes osztályok diákjai hány tárgyból buknak 
create procedure sp17
as
begin
	--count!!!
	SELECT DISTINCT tantárgyid,diákid,COUNT(tantárgyid)
	FROM Diák,Tanterv,Tantárgy
	WHERE Diák.szak = Tanterv.szakid 
	AND Tanterv.tantárgy = Tantárgy.tantárgyid
	AND tantárgyid in
	(
		SELECT tantárgyid
		FROM Bizonyítvány
		WHERE jegy=1 AND jóváhagyás=1
	)
	GROUP BY Tantárgy.tantárgyid, diákid
end

-----------------------------------------------------------------------------------------------------
--18.	ki tanít több tárgyat egy csoportnak



-----------------------------------------------------------------------------------------------------
--19.	név szerint kiknek mit tanít az adott tanár 
create procedure mit_Tanít as
begin
--19.feladat
Select diák.név, tantárgy.megnevezés,Tanár.név from Tanmenetfélév
Inner join Képes on képes.tanárid=Tanmenetfélév.tanár
Inner join Tantárgy on Képes.tantárgyid=Tantárgy.tantárgyid
inner join tanár on képes.tanárid=tanár.tanárid
Inner join diák on diák.szak=Tanmenetfélév.szak and diák.évf=Tanmenetfélév.évf and diák.betû=Tanmenetfélév.betû end

go



-----------------------------------------------------------------------------------------------------
--20.	melyik osztálynak az osztályfõnöke nem tanít a saját osztályában
as
Begin
(
	select osztályfõnök
	from Osztály 
    where 
	(
		select count(*) from Osztály, Tanmenetfélév 
		where Tanmenetfélév.évf=Osztály.évf and Tanmenetfélév.szak=Osztály.szak and Tanmenetfélév.betû=Osztály.betû and Osztály.osztályfõnök=Tanmenetfélév.tanár
	) <1

)
END


-----------------------------------------------------------------------------------------------------
--21.	melyik terem szabad az adott tanórában
create procedure sp21
	@nap tinyint,
	@óra tinyint
as
begin
	SELECT * 
	FROM TEREM
	WHERE tszám NOT IN 
	(
		SELECT terem 
		FROM Órarend 
		WHERE óra = @óra AND nap = @nap
	)
end

-----------------------------------------------------------------------------------------------------
--22.	melyik diáknak a hiányzása érte el a 30%-ot az adott tárgyból
CREATE FUNCTION adottTant30szScalart 
(
	@tantargy int ,
	@heteksz int
)
RETURNS int
AS
begin
return(
	
	--declare @tantargy int;
	--declare @heteksz int;
	--set @tantargy = 22;

	select  round(((@heteksz*heti_óraszám)*0.30),0) as összóra 

	from Tantárgy
	
	where @tantargy= tantárgyid
	
)
end
go

create procedure diakh30felett

	 @tantid int
as 
begin

declare @ora30sz int ;
declare @heteksz int;
select @heteksz = DATEDIFF(DAY,kezdete,vége)/7 from Tanév;
select @ora30sz = dbo.adottTant30szScalart(@tantid,@heteksz)

select diákid , count(óra) as hianyzas into #temp
from HiányzásFélév
group by diákid

--drop table #temp

--select * from Diák
select név from #temp te, Diák d
where te.diákid = d.diákid and @ora30sz<hianyzas

drop table #temp

end
go

exec diakh30felette 22


-----------------------------------------------------------------------------------------------------
--23.	melyik tárgyból van a legtöbb elégtelen évközi jegy az adott osztályban

create procedure sp23
	@szak int,
	@évf tinyint,
	@betû char(1)
as
begin
	declare @tantargyid int
	SELECT @tantargyid = MAX(COUNT(minõsítés))
	FROM Diák,Jegyfelev
	WHERE Diák.diákid = Jegyfelev.diák 
	AND @szak=Diák.szak
	AND @évf = Diák.évf
	AND @betû = Diák.betû
	AND Jegyfelev.minõsítés=1
	GROUP BY tantárgy
	
	return @tantargyid
	
end

-----------------------------------------------------------------------------------------------------
--24.	az adott diák jegyeinek adatai a jegyet beíró tanárral
