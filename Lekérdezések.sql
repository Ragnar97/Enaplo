-----------------------------------------------------------------------------------------------------
--1.	a hib�s tantervek (amik szerint valamely szakon egy f�l�vben a heti �rasz�m 30 �ra felett lenne)
create procedure hibas_Tanterv 
as
begin
--1.feladat
Select Tanterv.hanyadik_szem, szakid,hanyadik_szem,Tanterv.tant�rgy,heti_�rasz�m from Tanterv
Inner join �rarend on Tanterv.szakid=�rarend.szak
Inner join tant�rgy on tant�rgy.tant�rgyid=tanterv.tant�rgy
group by Tanterv.hanyadik_szem, szakid, hanyadik_szem,tanterv.tant�rgy, heti_�rasz�m 
having heti_�rasz�m>30
end
go


-----------------------------------------------------------------------------------------------------
--2.	tanmenet el��ll�t�sa adott szakra �s adott tant�rgyra az el��rt csoportokkal

-----------------------------------------------------------------------------------------------------
--3.	a hib�s tanmenetek (amikben nem alkalmas a tan�r)
create procedure sp3
as
begin
	SELECT *
	FROM Tanmenetf�l�v t
	WHERE NOT EXISTS
	(
		SELECT *
        FROM K�pes k
        WHERE t.tan�r = k.tan�r AND t.tant�rgy = k.tant�rgy
	)
end
-----------------------------------------------------------------------------------------------------
--4.	mely tan�rok el��rt heti �rasz�ma haladja meg a 26 �r�t
create procedure max26ora
as 
begin 

		SELECT  tan�r,SUM(heti_�rasz�m) as �ssz into #temp
			FROM Tanmenetf�l�v tf, Tant�rgy t
				where tf.tant�rgy=t.tant�rgyid 
					group by  tan�r,heti_�rasz�m
		
		
		select n�v,  sum(�ssz) as �rasz�m into #temp2
			from #temp t, Tan�r ta where t.tan�r = ta.tan�rid
				group by  n�v,  �ssz
					having �ssz > 7;
		
		select n�v, sum(�rasz�m) as �sszo into #temp3
			from #temp2
				group by n�v;

		select * from #temp3 where �sszo>26 ;
		

		drop table #temp
		drop table #temp2
		drop table #temp3
		--exec max26ora
end 
go
-----------------------------------------------------------------------------------------------------
--5.	a hib�s �rarendi alkalmak (amik terme nem megfelel�)
create procedure sp5
as
begin
	SELECT tant�rgy,terem
	FROM �rarend
	WHERE tant�rgy NOT IN
	(
		SELECT tant�rgy.id
		FROM Tant�rgy,Speci
		WHERE Tant�rgy.teremig�ny = Speci.id
	)
end
-----------------------------------------------------------------------------------------------------
--6.	mely csoportok mikor �tk�znek az �rarend szerint



-----------------------------------------------------------------------------------------------------
--7.	mely teremben mikor van �tk�z�s az �rarend szerint

create view  terem_Utkozes 
as
--7.feladat
SELECT nap, �ra,terem
FROM �rarend
GROUP BY csoport,terem, nap, �ra
HAVING count(terem)>1


-----------------------------------------------------------------------------------------------------
--8. mely tan�rnak mikor van �tk�z�se az �rarend szerint



-----------------------------------------------------------------------------------------------------
--9.	adott csoportnak melyik t�rgyb�l h�ny �r�ja nincs m�g le�temezve


create procedure sp9
	@szak int,
	@�vfolyam tinyint,
	@bet� nvarchar(1),
	@csoport tinyint
as
begin
	
	create table #Le�temezett
	(
		tant�rgy int, 
		darab tinyint
	)
	INSERT INTO #Le�temezett
	SELECT tant�rgy, Count(*) 
	FROM �rarend �
	WHERE 
		�.szak = @szak AND 
		�.�vfolyam = @�vfolyam AND 
		�.bet� = @bet� AND 
		�.csoport = @csoport
	GROUP BY tant�rgy


	create table #Sz�ks�ges
	(
		tant�rgy int, 
		darab tinyint
	)
	INSERT INTO #Sz�ks�ges
	SELECT tmf.tant�rgy, tt.heti_�rasz�m
	FROM Tanmenetf�l�v tmf, Tant�rgy tt
	WHERE 
		tmf.szak = @szak AND 
		tmf.�vfolyam = @�vfolyam AND 
		tmf.bet� = @bet� AND 
		tmf.csoport = @csoport AND 
		tmf.tant�rgy = tt.id


	 
	 SELECT sz.tant�rgy, sz.darab - l.darab
	 FROM #Le�temezett l, #Sz�ks�ges sz
	 WHERE l.tant�rgy = sz.tant�rgy
	 UNION
	 SELECT tant�rgy, darab
	 FROM #Sz�ks�ges
	 WHERE tant�rgy NOT IN (SELECT tant�rgy FROM #Le�temezett)


	Drop Table #Le�temezett
	Drop Table #Sz�ks�ges

end



-----------------------------------------------------------------------------------------------------
--10.	a hib�s hi�nyz�sok (amik szerint nem is az �rarendi �r�j�r�l hi�nyzott a di�k)
create procedure rosszhianyzas
as 
begin 

	select distinct (DATEPART(dw, d�tum) + 5) % 7 + 1 as nap ,�ra  into #valami  from Hi�nyz�sF�l�v
	 
	 select * 
		from #valami 
			where concat(nap,�ra) not in (select CONCAT(nap, �ra) 
											from �rarend) 

	 drop table #valami
end
go

exec rosszhianyzas


-----------------------------------------------------------------------------------------------------
--11.	a hib�s �vk�zi jegyek (amiket nem a tanmenet szerinti t�rgyb�l kapta a di�k)

create procedure sp11
as
begin
	SELECT min�s�t�s
	FROM Di�k,Jegyfelev
	WHERE Di�k.di�kid = Jegyfelev.di�k
	AND tant�rgy not in
	(
		SELECT tant�rgy
		FROM Tanmenetf�l�v
	)
end


-----------------------------------------------------------------------------------------------------
--12.	az adott tan�rt melyik t�rgyb�l kik helyettes�tett�k n�v szerint 



-----------------------------------------------------------------------------------------------------
--13.	adott f�l�vben mely di�kok mib�l nem oszt�lyozhat�k
CREATE PROCEDURE nem_Osztalyozhato
	 @felev int
AS
BEGIN
	
Select di�k.di�kid,tant�rgy,szak.h�ny_szem
from di�k
inner join jegyfelev on di�k.di�kid=Jegyfelev.di�k
Inner join Oszt�ly on Oszt�ly.szak=di�k.szak and Oszt�ly.�vf=di�k.�vf and Oszt�ly.bet�=di�k.bet�
Inner join Szak on szak.szakid=Oszt�ly.szak
group by di�k.di�kid,tant�rgy,szak.h�ny_szem
having  di�k.di�kid not in (Select di�k from Jegyfelev) and szak.h�ny_szem=@felev
END
GO



-----------------------------------------------------------------------------------------------------
--14.	adott csoport f�l�vi jegyeinek kisz�m�t�sa
create procedure sp14
	@szak int,
	@�vfolyam tinyint,
	@bet� nvarchar(1),
	@csoport tinyint
as
begin
	
	create table #seged
	(
		diakok int,
	)
	Insert into #seged (diakok) values ((select di�kid from Di�k where szak=@szak and �vf=@�vfolyam and bet�=@bet� and csoport=@csoport))

	
	select avg(jegy)as �tlag from Bizony�tv�ny where di�kid in (select * from #seged)
	drop table #seged
end


-----------------------------------------------------------------------------------------------------
--15.	a bizony�tv�ny j�v�hagyott jegyei szerinti oszt�ly�tlagok
create procedure sp15
as
begin
   SELECT o.szak, o.�vf, o.bet�, AVG(b.jegy) AS �tlag
   FROM Oszt�ly o, Bizony�tv�ny b
   WHERE b.j�v�hagy�s = 1
   GROUP BY o.szak, o.�vf, o.bet�
end


-----------------------------------------------------------------------------------------------------
--16.	a bizony�tv�ny j�v�hagyott jegyei szerinti tant�rgyi �tlagok
create view fel16
as 
(
	select megnevez�s, avg(jegy) as �tlag from Bizony�tv�ny b , Tant�rgy t
	where j�v�hagy�s=1 and b.tant�rgyid = t.tant�rgyid
	group by megnevez�s
)


-----------------------------------------------------------------------------------------------------
--17.	a bizony�tv�ny j�v�hagyott jegyei szerint az egyes oszt�lyok di�kjai h�ny t�rgyb�l buknak 
create procedure sp17
as
begin
	--count!!!
	SELECT DISTINCT tant�rgyid,di�kid,COUNT(tant�rgyid)
	FROM Di�k,Tanterv,Tant�rgy
	WHERE Di�k.szak = Tanterv.szakid 
	AND Tanterv.tant�rgy = Tant�rgy.tant�rgyid
	AND tant�rgyid in
	(
		SELECT tant�rgyid
		FROM Bizony�tv�ny
		WHERE jegy=1 AND j�v�hagy�s=1
	)
	GROUP BY Tant�rgy.tant�rgyid, di�kid
end

-----------------------------------------------------------------------------------------------------
--18.	ki tan�t t�bb t�rgyat egy csoportnak



-----------------------------------------------------------------------------------------------------
--19.	n�v szerint kiknek mit tan�t az adott tan�r 
create procedure mit_Tan�t as
begin
--19.feladat
Select di�k.n�v, tant�rgy.megnevez�s,Tan�r.n�v from Tanmenetf�l�v
Inner join K�pes on k�pes.tan�rid=Tanmenetf�l�v.tan�r
Inner join Tant�rgy on K�pes.tant�rgyid=Tant�rgy.tant�rgyid
inner join tan�r on k�pes.tan�rid=tan�r.tan�rid
Inner join di�k on di�k.szak=Tanmenetf�l�v.szak and di�k.�vf=Tanmenetf�l�v.�vf and di�k.bet�=Tanmenetf�l�v.bet� end

go



-----------------------------------------------------------------------------------------------------
--20.	melyik oszt�lynak az oszt�lyf�n�ke nem tan�t a saj�t oszt�ly�ban
as
Begin
(
	select oszt�lyf�n�k
	from Oszt�ly 
    where 
	(
		select count(*) from Oszt�ly, Tanmenetf�l�v 
		where Tanmenetf�l�v.�vf=Oszt�ly.�vf and Tanmenetf�l�v.szak=Oszt�ly.szak and Tanmenetf�l�v.bet�=Oszt�ly.bet� and Oszt�ly.oszt�lyf�n�k=Tanmenetf�l�v.tan�r
	) <1

)
END


-----------------------------------------------------------------------------------------------------
--21.	melyik terem szabad az adott tan�r�ban
create procedure sp21
	@nap tinyint,
	@�ra tinyint
as
begin
	SELECT * 
	FROM TEREM
	WHERE tsz�m NOT IN 
	(
		SELECT terem 
		FROM �rarend 
		WHERE �ra = @�ra AND nap = @nap
	)
end

-----------------------------------------------------------------------------------------------------
--22.	melyik di�knak a hi�nyz�sa �rte el a 30%-ot az adott t�rgyb�l
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

	select  round(((@heteksz*heti_�rasz�m)*0.30),0) as �ssz�ra 

	from Tant�rgy
	
	where @tantargy= tant�rgyid
	
)
end
go

create procedure diakh30felett

	 @tantid int
as 
begin

declare @ora30sz int ;
declare @heteksz int;
select @heteksz = DATEDIFF(DAY,kezdete,v�ge)/7 from Tan�v;
select @ora30sz = dbo.adottTant30szScalart(@tantid,@heteksz)

select di�kid , count(�ra) as hianyzas into #temp
from Hi�nyz�sF�l�v
group by di�kid

--drop table #temp

--select * from Di�k
select n�v from #temp te, Di�k d
where te.di�kid = d.di�kid and @ora30sz<hianyzas

drop table #temp

end
go

exec diakh30felette 22


-----------------------------------------------------------------------------------------------------
--23.	melyik t�rgyb�l van a legt�bb el�gtelen �vk�zi jegy az adott oszt�lyban

create procedure sp23
	@szak int,
	@�vf tinyint,
	@bet� char(1)
as
begin
	declare @tantargyid int
	SELECT @tantargyid = MAX(COUNT(min�s�t�s))
	FROM Di�k,Jegyfelev
	WHERE Di�k.di�kid = Jegyfelev.di�k 
	AND @szak=Di�k.szak
	AND @�vf = Di�k.�vf
	AND @bet� = Di�k.bet�
	AND Jegyfelev.min�s�t�s=1
	GROUP BY tant�rgy
	
	return @tantargyid
	
end

-----------------------------------------------------------------------------------------------------
--24.	az adott di�k jegyeinek adatai a jegyet be�r� tan�rral
