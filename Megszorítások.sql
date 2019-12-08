---------------------------------------------------------------------------------------------------------------------
--Az adatrendszerek adatbázisában megvalósítandó megszorítások megfogalmazása Adatbáziskezelésből.
--minden a megfelelő félév-státusz esetén
---------------------------------------------------------------------------------------------------------------------
--1. egy tanár csak egyetlen osztálynak lehessen az osztályfőnöke DONE
CREATE TRIGGER trg_Upd_Ins_Tanár
ON dbo.Osztály
FOR UPDATE, INSERT
AS BEGIN

	DECLARE @tanár INT;
	
	SELECT @tanár= osztályfőnök FROM inserted
	
    IF UPDATE(@tanár) AND (SELECT COUNT(*) FROM dbo.Osztály WHERE osztályfőnök = @tanár) > 1
	ROLLBACK TRANSACTION
	
END
---------------------------------------------------------------------------------------------------------------------
--2. a tanév féléveinek státusza csak egyesével felfelé módosítható

CREATE TRIGGER trg_Upd_Státusz
ON dbo.Tanév
FOR UPDATE
AS BEGIN

	DECLARE @inserted_státusz INT, @deleted_státusz INT
	
	SElect @inserted_státusz =  státusz FROM inserted
	SElect  @deleted_státusz =  státusz FROM deleted

	IF UPDATE(státusz) AND @inserted_státusz-1 != @deleted_státusz 
    ROLLBACK TRANSACTION
	
END
---------------------------------------------------------------------------------------------------------------------
--3. a tanév 2 félévet tartalmazhat és a 2 félév egymást kizáró időszakból állhat

---------------------------------------------------------------------------------------------------------------------
--4. bármely szakon egy félévben a heti össz-óraszám legfeljebb 30 óra lehet
--ha szakhoz adnak tárgyat a tantervben
ALTER TRIGGER [dbo].[feladat4]
   ON  [dbo].[Tanterv] 
   after  INSERT
AS 

BEGIN
	declare @jelenosz int;
	declare @szak int;
	declare @statusz int

	select @statusz = státusz from Tanév
	select @szak=i.szakid from inserted i
	select @jelenosz = dbo.szakhanyóra(@szak)
	 
		
		if @jelenosz>30 and @statusz  != 1
		begin
		
			print 'Feltöltés sikertelen. Nem lehet több egy szakon 30 óránál!'
			Rollback;
		
		end	

END

------------
ALTER FUNCTION [dbo].[szakhanyóra]
(
	
	@szak int
)
RETURNS int
AS
BEGIN
	
	-- Return the result of the function
	RETURN (
	
		--declare @szak int;
		--set @szak = 331;
		select sum(heti_óraszám) as hetioszam from Tantárgy tt, Tanterv tv
		where tt.tantárgyid = tv.tantárgy and szakid = @szak
	)

END

---------------------------------------------------------------------------------------------------------------------
--5. a tanmenet legyártása előtt még módosíthatók a tantárgyak adatai
--ha a tanmenet üres
CREATE TRIGGER trg_Upd_Ins_Del_All
ON dbo.Tantárgy
FOR UPDATE, INSERT, DELETE
AS BEGIN
	IF EXIST (SELECT * FROM Tanmenetfélév)
	ROLLBACK TRANSACTION
END

---------------------------------------------------------------------------------------------------------------------
--6. a tanmenet legenerálása (elég adott szakra és adott tantárgyra az előírt csoportokkal) PIROS

ALTER TRIGGER [dbo].[tanmenetGeneralas]
   ON  [dbo].[Tanév]
   AFTER UPDATE
AS 
BEGIN
    declare @statusz tinyint;	
	
	select @statusz = státusz from inserted

	if
		@statusz = 2

    insert into Tanmenetfélév 

	select szak, évf, betű, 0, null, tantárgy 
	from Tanterv tv, Osztály o 
	where tv. szakid = o.szak

END

---------------------------------------------------------------------------------------------------------------------
--7. a tanmenethez alkalmas tanár hozzárendelése (de bármely tanár heti óraszáma legfeljebb 26 óra)
--az alkalmasságot a képes tábla garantálja (KK) - DONE
CREATE TRIGGER trg_Upd_Tanár
ON dbo.Tanmenetfélév
FOR UPDATE
AS BEGIN
	DECLARE @tanár INT;
	SELECT @tanár=  tanár FROM inserted
    IF UPDATE(tanár) AND (SELECT dbo.hetiOraszam(@tanár)) > 26 
	ROLLBACK TRANSACTION
END

--segédfügvény a heti óraszámhoz
CREATE FUNCTION dbo.hetiOraszam (@tanarId int) 
RETURNS INT
AS BEGIN
	return 
	(
		SELECT SUM(heti_óraszám) 
		FROM Tanmenetfélév 
		INNER JOIN Tantárgy ON Tanmenetfélév.tantárgy = Tantárgy.tantárgyid
		WHERE Tanmenetfélév.tanár = @tanarId
	)
END
---------------------------------------------------------------------------------------------------------------------
--8.	órarendi alkalmak felvitele normál/ spéci teremmel (a csoport, a terem és a tanár sem ütközhet) az előírt heti óraszám erejéig PIROS

---------------------------------------------------------------------------------------------------------------------
--9.	heti órarend készítésének lezárása (a félév státuszának módosításával, ha minden tanóra le van ütemezve)

---------------------------------------------------------------------------------------------------------------------
--10.	függvény: adott csoportnak melyik tárgyból hány órája nincs még leütemezve

---------------------------------------------------------------------------------------------------------------------
--11.	függvény: adott dátum a hét hányadik napja - DONE
CREATE FUNCTION dbo.day_of_week (@date DATE) 
RETURNS INT
AS BEGIN
	return (DATEPART(dw, @date) + 5) % 7 + 1
END
--test
select dbo.day_of_week('2019-04-01') as 'Hét napja'
select dbo.day_of_week('2019-04-02') as 'Hét napja'
select dbo.day_of_week('2019-04-03') as 'Hét napja'
select dbo.day_of_week('2019-04-04') as 'Hét napja'
select dbo.day_of_week('2019-04-05') as 'Hét napja'
select dbo.day_of_week('2019-04-06') as 'Hét napja'
select dbo.day_of_week('2019-04-07') as 'Hét napja'
select dbo.day_of_week('2019-04-08') as 'Hét napja'
---------------------------------------------------------------------------------------------------------------------
--12.	hiányzások felvitele (csak órarendi órájáról hiányozhat bármely diák)

---------------------------------------------------------------------------------------------------------------------
--13.	a hiányzás igazolása (20 napon belül és csak egyszer)
ALTER TRIGGER [dbo].[hiányzásmax20]
   ON [dbo].[HiányzásFélév]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @fdátum date;
	declare @maxd date;
	declare @diákid bigint
  
  select * from HiányzásFélév
   select @fdátum = GETDATE(),@diákid= diákid from inserted
   select @fdátum = dbo.diákhiányzása(@diákid)

   select @maxd = dateAdd(day, 20,@fdátum)

   if
		@fdátum > @maxd

		print 'csak 20 napig lehet igazolni a hiányzást'
		rollback;

END
enable trigger hiányzásmax20
on HiányzásFélév
---------------------segéd függvény------
ALTER FUNCTION [dbo].[diákhiányzása]
(
	-- Add the parameters for the function here
	@diákid bigint
)
RETURNS date
AS
BEGIN
	

	-- Return the result of the function
	RETURN (
	select distinct dátum from HiányzásFélév
	where @diákid=diákid
	)
END

---------------------------------------------------------------------------------------------------------------------
--14.	évközi jegyek felvitele (csak tanmenet szerinti tárgyból kaphat a diák jegyet)


ALTER TRIGGER [dbo].[feladat14]
   ON  [dbo].[Jegyfelev]
   AFTER INSERT
AS 
BEGIN
	
	declare @tantargy int;
	declare @statusz tinyint;
	declare @osztid nvarchar(20);
	declare @diak bigint;
	
	
	select @statusz = státusz from Tanév
	select @tantargy =  tantárgy from inserted

	select @diak = diák, @tantargy =  tantárgy from inserted
	 select  @osztid = dbo.osztalyId(@diak)
	if
	--@tantargy not in (
	--select szak , évf, betű from Tanmenetfélév)
	
	 @tantargy not in (select * from dbo.oszttantargya(@osztid)) 
	begin

	print 'csak a tanmenet szereplő tantárgyból lehet osztályzatot adni egy diáknak'
	rollback;
	end
    if @statusz != 3
	begin
		
		print 'nem lehet ebben a fázisban adatot feltölteni'
		Rollback;

	end

END
-----------------segéd függvény---------------------

ALTER FUNCTION [dbo].[oszttantargya]
(	
	-- Add the parameters for the function here
	@osztid nvarchar(20)
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	--declare @osztid nvarchar(20);
	--set @osztid = '3311a'
	SELECT tantárgy from Tanmenetfélév
	where @osztid = concat(szak,évf, betű)
)

---------------------------------------------------------------------------------------------------------------------
--15.	helyettesítés naplózása

ALTER TRIGGER [dbo].[feladat15]
   ON  [dbo].[Tanmenetfélév] 
   for UPDATE
AS 
BEGIN
	
	declare @rtanár int;
	declare @dátum date;
	declare @szak int
	declare @évf int;
	declare @betű char;
	declare @tantargy int;
	declare @csoport tinyint;

	select @rtanár=tanár, @szak= szak,@évf = évf,@betű = betű , @tantargy = tantárgy, @csoport = csoport from deleted
	
	insert into Helyett values (@szak,@évf,@betű,@csoport,@tantargy, @rtanár,GETDATE())

END


-----segéd tábla -------------------
ALTER FUNCTION [dbo].[tanévbol]
(	
	-- Add the parameters for the function here
	@tanár int
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	-- Add the SELECT statement with parameter references here
	SELECT szak, évf, betű, csoport , tantárgy  from Tanmenetfélév 
	where @tanár=tanár
)

---------------------------------------------------------------------------------------------------------------------
--16.	félévi vagy évvégi osztályozás (bizonyítvány legenerálása az évközi jegyek átlagával vagy 0-val, ha a diák egy tárgyból nem osztályozható) PIROS

alter TRIGGER bizonyitvanyGeneral 
   ON tanév
   after UPDATE
AS 
BEGIN
	declare @statusz tinyint;


	select @statusz = státusz from inserted;
	

	if @statusz = 4

		insert into Bizonyítvány
		select diák ,tantárgy ,case when count(minősítés)>=3 then round(sum(Cast((minősítés*súlyozás) as float))/sum(Cast(súlyozás as float)),0)
									when count(minősítés)<3 then 0 end, 0 from Jegyfelev
		group by tantárgy,diák	

end

---------------------------------------------------------------------------------------------------------------------
--17.	félévi vagy évvégi jegyek jóváhagyása (jegyek módosítása le/fel 1 értékkel megengedhető)

--átlag segédfüggvény
CREATE FUNCTION dbo.atlag (@diakId int, @tantárgyId int) 
RETURNS FLOAT
AS BEGIN
	return 
	(
		SELECT SUM(minősítés*súlyozás) FROM dbo.Jegyfelev WHERE diák = @diakId AND tantárgy = @tantárgyId /
		(SELECT SUM(súlyozás) FROM dbo.Jegyfelev WHERE diák = @diakId AND tantárgy = @tantárgyId)
	) 
END

---------------------------------------------------------------------------------------------------------------------
--18.	jóváhagyott jegy nem módosítható és bizonyítvány-jegy nem törölhető
CREATE TRIGGER trg_Upd_Jegy
ON dbo.Bizonyítvány
FOR UPDATE, DELETE
AS BEGIN

	DECLARE @jóváhagyott BIT;
	
	SELECT @jóváhagyott = jóváhagyás FROM deleted
	
    IF UPDATE(jegy) AND @jóváhagyott = 1 
	ROLLBACK TRANSACTION

	
END
---------------------------------------------------------------------------------------------------------------------
--19.	félévzárás (a státusz módosítása váltsa ki a hiányzások, jegyek, órarend, helyettesítés és tanmenet ürítését)PIROS

---------------------------------------------------------------------------------------------------------------------
create TRIGGER dbo.[felev_zaras]
   ON  dbo.[Tanév]
   instead of update
AS 
BEGIN
declare @statusz tinyint

if 1<(Select count(vége) from Tanév where vége is not null)
begin
delete from HiányzásFélév;
delete from Jegyfelev;
delete from Órarend;
delete from Helyett;
delete from Tanmenetfélév;
end
END
GO

