USE [master]
GO
/****** Object:  Database [eNaplo]    Script Date: 2019. 04. 16. 19:38:25 ******/
CREATE DATABASE [eNaplo]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'eNaplo', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\eNaplo.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'eNaplo_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\eNaplo_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [eNaplo] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [eNaplo].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [eNaplo] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [eNaplo] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [eNaplo] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [eNaplo] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [eNaplo] SET ARITHABORT OFF 
GO
ALTER DATABASE [eNaplo] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [eNaplo] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [eNaplo] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [eNaplo] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [eNaplo] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [eNaplo] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [eNaplo] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [eNaplo] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [eNaplo] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [eNaplo] SET  DISABLE_BROKER 
GO
ALTER DATABASE [eNaplo] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [eNaplo] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [eNaplo] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [eNaplo] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [eNaplo] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [eNaplo] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [eNaplo] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [eNaplo] SET RECOVERY FULL 
GO
ALTER DATABASE [eNaplo] SET  MULTI_USER 
GO
ALTER DATABASE [eNaplo] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [eNaplo] SET DB_CHAINING OFF 
GO
ALTER DATABASE [eNaplo] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [eNaplo] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [eNaplo] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'eNaplo', N'ON'
GO
ALTER DATABASE [eNaplo] SET QUERY_STORE = OFF
GO
USE [eNaplo]
GO
/****** Object:  UserDefinedFunction [dbo].[adottTant30szScalart]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[adottTant30szScalart] 
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
GO
/****** Object:  UserDefinedFunction [dbo].[atlag]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[atlag] (@diakId int, @tantárgyId int) 
RETURNS FLOAT
AS BEGIN
	return 
	(
		SELECT SUM(minősítés*súlyozás) FROM dbo.Jegyfelev WHERE diák = @diakId AND tantárgy = @tantárgyId /
		(SELECT SUM(súlyozás) FROM dbo.Jegyfelev WHERE diák = @diakId AND tantárgy = @tantárgyId)
	) 
END
GO
/****** Object:  UserDefinedFunction [dbo].[day_of_week]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[day_of_week] (@date DATE) 
RETURNS INT
AS BEGIN
	return (DATEPART(dw, @date) + 5) % 7 + 1
END
GO
/****** Object:  UserDefinedFunction [dbo].[diákhianyzasa]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[diákhianyzasa]
(	
	
	@diákid bigint
	
)
RETURNS int 
AS
begin
return
(
--declare @diákid bigint;
--declare @óra int;
--set @diákid = 72171552
	select  count(óra) as össz from HiányzásFélév
		where diákid=@diákid
			group by diákid


	)
	end
GO
/****** Object:  UserDefinedFunction [dbo].[diákhiányzása]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[diákhiányzása]
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
GO
/****** Object:  UserDefinedFunction [dbo].[hetiOraszam]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[hetiOraszam] (@tanarId int) 
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
GO
/****** Object:  UserDefinedFunction [dbo].[jegydb]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[jegydb]
(
	-- Add the parameters for the function here
	@tantárgy int,
	@diak bigint
)
RETURNS int
AS
BEGIN

	RETURN (
	
	
	select count(tantárgy) as jegydb  from Jegyfelev
		where tantárgy=@tantárgy and diák=@diak
			 group by  diák,tantárgy
	)

END
GO
/****** Object:  UserDefinedFunction [dbo].[osztalyId]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[osztalyId]
(
	-- Add the parameters for the function here
	@diák bigint
)
RETURNS char(20)
AS
BEGIN
	
	
	RETURN (
	
	SELECT concat(szak, évf, betű ) as osztid 
	from  Diák d
	where
	diákid = @diák
	)
END
GO
/****** Object:  UserDefinedFunction [dbo].[szakhanyóra]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[szakhanyóra]
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
GO
/****** Object:  Table [dbo].[Tanmenetfélév]    Script Date: 2019. 04. 16. 19:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tanmenetfélév](
	[szak] [int] NOT NULL,
	[évf] [tinyint] NOT NULL,
	[betű] [char](1) NOT NULL,
	[csoport] [tinyint] NOT NULL,
	[tanár] [int] NULL,
	[tantárgy] [int] NOT NULL,
 CONSTRAINT [PK_Tanmenetfélév] PRIMARY KEY CLUSTERED 
(
	[szak] ASC,
	[évf] ASC,
	[betű] ASC,
	[csoport] ASC,
	[tantárgy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[tanévbol]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[tanévbol]
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
GO
/****** Object:  UserDefinedFunction [dbo].[oszttantargya]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[oszttantargya]
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
GO
/****** Object:  Table [dbo].[HiányzásFélév]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HiányzásFélév](
	[diákid] [bigint] NOT NULL,
	[dátum] [date] NOT NULL,
	[óra] [tinyint] NOT NULL,
	[igazolt] [bit] NOT NULL,
 CONSTRAINT [PK_HiányzásFélév] PRIMARY KEY CLUSTERED 
(
	[diákid] ASC,
	[dátum] ASC,
	[óra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[diakhianyzas]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[diakhianyzas] 
(	
	-- Add the parameters for the function here
	@diákid bigint 
	
)
RETURNS TABLE 
AS
RETURN 
(
	select dátum from HiányzásFélév
	where @diákid=diákid
)
GO
/****** Object:  UserDefinedFunction [dbo].[diák30hiányzás]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[diák30hiányzás]
(	
	
	@diákid bigint
	
)
RETURNS TABLE 
AS
RETURN 
(
--declare @diákid bigint;
--declare @óra int;
--set @diákid = 72171552
	select  count(óra) as össz from HiányzásFélév
		where diákid=@diákid
			group by diákid


	)
GO
/****** Object:  Table [dbo].[Tantárgy]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tantárgy](
	[tantárgyid] [int] NOT NULL,
	[megnevezés] [nvarchar](50) NULL,
	[teremigény] [int] NULL,
	[csoportbontás] [bit] NULL,
	[heti_óraszám] [tinyint] NULL,
 CONSTRAINT [PK_Tantárgy] PRIMARY KEY CLUSTERED 
(
	[tantárgyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[adottTant30sz]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[adottTant30sz] 
(
	@tantargy int ,
	@heteksz int
)
RETURNS table
AS
return(
	
	--declare @tantargy int;
	--declare @heteksz int;
	--set @tantargy = 22;

	

	

	select megnevezés, round(((@heteksz*heti_óraszám)*0.30),0) as összóra 

	from Tantárgy
	
	where @tantargy= tantárgyid
	

)
GO
/****** Object:  Table [dbo].[Bizonyítvány]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bizonyítvány](
	[diákid] [bigint] NOT NULL,
	[tantárgyid] [int] NOT NULL,
	[jegy] [tinyint] NOT NULL,
	[jóváhagyás] [bit] NOT NULL,
 CONSTRAINT [PK_Bizonyítvány] PRIMARY KEY CLUSTERED 
(
	[diákid] ASC,
	[tantárgyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[fel16]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[fel16]
as 
(
	select megnevezés, avg(jegy) as átlag from Bizonyítvány b , Tantárgy t
	where jóváhagyás=1 and b.tantárgyid = t.tantárgyid
	group by megnevezés
)
GO
/****** Object:  Table [dbo].[Diák]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diák](
	[diákid] [bigint] NOT NULL,
	[név] [varchar](50) NOT NULL,
	[szül_dátum] [date] NOT NULL,
	[szak] [int] NOT NULL,
	[évf] [tinyint] NOT NULL,
	[betű] [char](1) NOT NULL,
	[csoport] [tinyint] NOT NULL,
 CONSTRAINT [PK_Diák] PRIMARY KEY CLUSTERED 
(
	[diákid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Helyett]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Helyett](
	[szak] [int] NOT NULL,
	[évf] [tinyint] NOT NULL,
	[betű] [char](1) NOT NULL,
	[csoport] [tinyint] NOT NULL,
	[tantárgy] [int] NOT NULL,
	[régiTanár] [int] NOT NULL,
	[date] [date] NOT NULL,
 CONSTRAINT [PK_Helyett] PRIMARY KEY CLUSTERED 
(
	[szak] ASC,
	[évf] ASC,
	[betű] ASC,
	[csoport] ASC,
	[tantárgy] ASC,
	[régiTanár] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Jegyfelev]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jegyfelev](
	[diák] [bigint] NOT NULL,
	[tantárgy] [int] NOT NULL,
	[mikor] [date] NOT NULL,
	[súlyozás] [tinyint] NOT NULL,
	[minősítés] [tinyint] NOT NULL,
 CONSTRAINT [PK_Jegyfelev] PRIMARY KEY CLUSTERED 
(
	[diák] ASC,
	[tantárgy] ASC,
	[mikor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Képes]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Képes](
	[tanárid] [int] NOT NULL,
	[tantárgyid] [int] NOT NULL,
 CONSTRAINT [PK_Képes] PRIMARY KEY CLUSTERED 
(
	[tanárid] ASC,
	[tantárgyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Órarend]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Órarend](
	[nap] [tinyint] NOT NULL,
	[óra] [tinyint] NOT NULL,
	[szak] [int] NOT NULL,
	[évfolyam] [tinyint] NOT NULL,
	[betű] [char](1) NOT NULL,
	[csoport] [tinyint] NOT NULL,
	[tantárgy] [int] NOT NULL,
	[terem] [int] NOT NULL,
 CONSTRAINT [PK_Órarend_1] PRIMARY KEY CLUSTERED 
(
	[nap] ASC,
	[óra] ASC,
	[szak] ASC,
	[évfolyam] ASC,
	[betű] ASC,
	[csoport] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Osztály]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Osztály](
	[szak] [int] NOT NULL,
	[évf] [tinyint] NOT NULL,
	[betű] [char](1) NOT NULL,
	[osztályfőnök] [int] NULL,
 CONSTRAINT [PK_Osztály] PRIMARY KEY CLUSTERED 
(
	[szak] ASC,
	[évf] ASC,
	[betű] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Speci]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Speci](
	[azon] [int] NOT NULL,
	[elnevezés] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Speci] PRIMARY KEY CLUSTERED 
(
	[azon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Szak]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Szak](
	[szakid] [int] NOT NULL,
	[hány_szem] [int] NOT NULL,
	[megnevezés] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Szak] PRIMARY KEY CLUSTERED 
(
	[szakid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tanár]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tanár](
	[tanárid] [int] NOT NULL,
	[név] [varchar](50) NOT NULL,
	[születésiDátum] [date] NOT NULL,
	[csatlakozásiDátum] [date] NOT NULL,
 CONSTRAINT [PK_Tanár] PRIMARY KEY CLUSTERED 
(
	[tanárid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tanév]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tanév](
	[félév] [tinyint] NOT NULL,
	[státusz] [tinyint] NOT NULL,
	[kezdete] [date] NOT NULL,
	[vége] [date] NOT NULL,
 CONSTRAINT [PK_Tanév] PRIMARY KEY CLUSTERED 
(
	[félév] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tanterv]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tanterv](
	[szakid] [int] NOT NULL,
	[tantárgy] [int] NOT NULL,
	[hanyadik_szem] [tinyint] NOT NULL,
 CONSTRAINT [PK_Tanterv_1] PRIMARY KEY CLUSTERED 
(
	[szakid] ASC,
	[tantárgy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Terem]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Terem](
	[tszám] [int] NOT NULL,
	[speci] [int] NULL,
	[férőhely] [int] NOT NULL,
 CONSTRAINT [PK_Terem_1] PRIMARY KEY CLUSTERED 
(
	[tszám] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Terem]    Script Date: 2019. 04. 16. 19:38:26 ******/
CREATE NONCLUSTERED INDEX [IX_Terem] ON [dbo].[Terem]
(
	[speci] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Bizonyítvány] ADD  CONSTRAINT [DF_Bizonyítvány_jóváhagyás]  DEFAULT ((0)) FOR [jóváhagyás]
GO
ALTER TABLE [dbo].[HiányzásFélév] ADD  CONSTRAINT [DF_HiányzásFélév_igazolt]  DEFAULT ((0)) FOR [igazolt]
GO
ALTER TABLE [dbo].[Tanár] ADD  CONSTRAINT [DF_Tanár_csatlakozásiDátum]  DEFAULT (getdate()) FOR [csatlakozásiDátum]
GO
ALTER TABLE [dbo].[Tanmenetfélév] ADD  CONSTRAINT [DF_Tanmenetfélév_tanár]  DEFAULT ((0)) FOR [tanár]
GO
ALTER TABLE [dbo].[Diák]  WITH CHECK ADD  CONSTRAINT [FK_Diák_Osztály] FOREIGN KEY([szak], [évf], [betű])
REFERENCES [dbo].[Osztály] ([szak], [évf], [betű])
GO
ALTER TABLE [dbo].[Diák] CHECK CONSTRAINT [FK_Diák_Osztály]
GO
ALTER TABLE [dbo].[Helyett]  WITH CHECK ADD  CONSTRAINT [FK_Helyett_Tanmenetfélév] FOREIGN KEY([szak], [évf], [betű], [csoport], [tantárgy])
REFERENCES [dbo].[Tanmenetfélév] ([szak], [évf], [betű], [csoport], [tantárgy])
GO
ALTER TABLE [dbo].[Helyett] CHECK CONSTRAINT [FK_Helyett_Tanmenetfélév]
GO
ALTER TABLE [dbo].[HiányzásFélév]  WITH CHECK ADD  CONSTRAINT [FK_HiányzásFélév_Diák] FOREIGN KEY([diákid])
REFERENCES [dbo].[Diák] ([diákid])
GO
ALTER TABLE [dbo].[HiányzásFélév] CHECK CONSTRAINT [FK_HiányzásFélév_Diák]
GO
ALTER TABLE [dbo].[Jegyfelev]  WITH CHECK ADD  CONSTRAINT [FK_Jegyfelev_Diák] FOREIGN KEY([diák])
REFERENCES [dbo].[Diák] ([diákid])
GO
ALTER TABLE [dbo].[Jegyfelev] CHECK CONSTRAINT [FK_Jegyfelev_Diák]
GO
ALTER TABLE [dbo].[Képes]  WITH CHECK ADD  CONSTRAINT [FK_Képes_Tanár] FOREIGN KEY([tanárid])
REFERENCES [dbo].[Tanár] ([tanárid])
GO
ALTER TABLE [dbo].[Képes] CHECK CONSTRAINT [FK_Képes_Tanár]
GO
ALTER TABLE [dbo].[Képes]  WITH CHECK ADD  CONSTRAINT [FK_Képes_Tantárgy] FOREIGN KEY([tantárgyid])
REFERENCES [dbo].[Tantárgy] ([tantárgyid])
GO
ALTER TABLE [dbo].[Képes] CHECK CONSTRAINT [FK_Képes_Tantárgy]
GO
ALTER TABLE [dbo].[Órarend]  WITH CHECK ADD  CONSTRAINT [FK_Órarend_Órarend] FOREIGN KEY([szak], [évfolyam], [betű], [csoport], [tantárgy])
REFERENCES [dbo].[Tanmenetfélév] ([szak], [évf], [betű], [csoport], [tantárgy])
GO
ALTER TABLE [dbo].[Órarend] CHECK CONSTRAINT [FK_Órarend_Órarend]
GO
ALTER TABLE [dbo].[Osztály]  WITH CHECK ADD  CONSTRAINT [FK_Osztály_Szak] FOREIGN KEY([szak])
REFERENCES [dbo].[Szak] ([szakid])
GO
ALTER TABLE [dbo].[Osztály] CHECK CONSTRAINT [FK_Osztály_Szak]
GO
ALTER TABLE [dbo].[Osztály]  WITH CHECK ADD  CONSTRAINT [FK_Osztály_Tanár] FOREIGN KEY([osztályfőnök])
REFERENCES [dbo].[Tanár] ([tanárid])
GO
ALTER TABLE [dbo].[Osztály] CHECK CONSTRAINT [FK_Osztály_Tanár]
GO
ALTER TABLE [dbo].[Tanmenetfélév]  WITH CHECK ADD  CONSTRAINT [FK_Tanmenetfélév_Képes] FOREIGN KEY([tanár], [tantárgy])
REFERENCES [dbo].[Képes] ([tanárid], [tantárgyid])
GO
ALTER TABLE [dbo].[Tanmenetfélév] CHECK CONSTRAINT [FK_Tanmenetfélév_Képes]
GO
ALTER TABLE [dbo].[Tantárgy]  WITH CHECK ADD  CONSTRAINT [FK_Tantárgy_Speci] FOREIGN KEY([teremigény])
REFERENCES [dbo].[Speci] ([azon])
GO
ALTER TABLE [dbo].[Tantárgy] CHECK CONSTRAINT [FK_Tantárgy_Speci]
GO
ALTER TABLE [dbo].[Tanterv]  WITH CHECK ADD  CONSTRAINT [FK_Tanterv_Szak] FOREIGN KEY([szakid])
REFERENCES [dbo].[Szak] ([szakid])
GO
ALTER TABLE [dbo].[Tanterv] CHECK CONSTRAINT [FK_Tanterv_Szak]
GO
ALTER TABLE [dbo].[Tanterv]  WITH CHECK ADD  CONSTRAINT [FK_Tanterv_Tantárgy] FOREIGN KEY([tantárgy])
REFERENCES [dbo].[Tantárgy] ([tantárgyid])
GO
ALTER TABLE [dbo].[Tanterv] CHECK CONSTRAINT [FK_Tanterv_Tantárgy]
GO
ALTER TABLE [dbo].[Terem]  WITH CHECK ADD  CONSTRAINT [FK_Terem_Speci] FOREIGN KEY([speci])
REFERENCES [dbo].[Speci] ([azon])
GO
ALTER TABLE [dbo].[Terem] CHECK CONSTRAINT [FK_Terem_Speci]
GO
ALTER TABLE [dbo].[Tanév]  WITH CHECK ADD  CONSTRAINT [CK_TanításiÉvFéléve] CHECK  (([félév]>(0)))
GO
ALTER TABLE [dbo].[Tanév] CHECK CONSTRAINT [CK_TanításiÉvFéléve]
GO
ALTER TABLE [dbo].[Tanév]  WITH CHECK ADD  CONSTRAINT [CK_TanításiÉvFéléve_1] CHECK  (([félév]<(5)))
GO
ALTER TABLE [dbo].[Tanév] CHECK CONSTRAINT [CK_TanításiÉvFéléve_1]
GO
/****** Object:  StoredProcedure [dbo].[diakh30felett]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[diakh30felett]

as 
begin
declare @tantid int;
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
GO
/****** Object:  StoredProcedure [dbo].[diakh30felette]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[diakh30felette]

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
GO
/****** Object:  StoredProcedure [dbo].[hianyzastant30]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[hianyzastant30]
AS
BEGIN
	declare @óra int;
	  select @óra=dbo.diákhianyzasa(72171552)
	declare @heteksz int;

	select @heteksz = DATEDIFF(DAY,kezdete,vége)/7 from Tanév

	print @heteksz;

	select megnevezés, round(((@heteksz*heti_óraszám)*0.30),0) as összóra into #temp

	from Tantárgy

	select megnevezés from #temp
	where összóra<@óra
	drop table #temp

end 
GO
/****** Object:  StoredProcedure [dbo].[max26ora]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[max26ora]
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
GO
/****** Object:  StoredProcedure [dbo].[rosszhianyzas]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rosszhianyzas]
as 
begin 

	select distinct (DATEPART(dw, dátum) + 5) % 7 + 1 as nap ,óra  into #valami  from HiányzásFélév
	 
	 select * from #valami where concat(nap,óra) not in 
															
															(select CONCAT(nap, óra) 
																from Órarend) 

	 drop table #valami
end
GO
/****** Object:  StoredProcedure [dbo].[sp11]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create procedure [dbo].[sp11]
as
begin
	SELECT minősítés
	FROM Diák,Jegyfelev
	WHERE Diák.diákid = Jegyfelev.diák
	AND tantárgy not in
	(
		SELECT tantárgy
		FROM Tanmenetfélév
	)
end
GO
/****** Object:  StoredProcedure [dbo].[sp14]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp14]
	@szak int,
	@évfolyam tinyint,
	@betű nvarchar(1),
	@csoport tinyint
as
begin
	
	create table #seged
	(
		diakok int,
	)
	Insert into #seged (diakok) values ((select diákid from Diák where szak=@szak and évf=@évfolyam and betű=@betű and csoport=@csoport))

	
	select avg(jegy)as átlag from Bizonyítvány where diákid in (select * from #seged)
	drop table #seged
end	
GO
/****** Object:  StoredProcedure [dbo].[sp15]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp15]
as
begin
   SELECT o.szak, o.évf, o.betű, AVG(b.jegy) AS átlag
   FROM Osztály o, Bizonyítvány b
   WHERE b.jóváhagyás = 1
   GROUP BY o.szak, o.évf, o.betű
end
GO
/****** Object:  StoredProcedure [dbo].[sp17]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp17]
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
GO
/****** Object:  StoredProcedure [dbo].[sp20]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp20]
as
Begin
(
	select osztályfőnök
	from Osztály 
    where 
	(
		select count(*) from Osztály, Tanmenetfélév 
		where Tanmenetfélév.évf=Osztály.évf and Tanmenetfélév.szak=Osztály.szak and Tanmenetfélév.betű=Osztály.betű and Osztály.osztályfőnök=Tanmenetfélév.tanár
	) <1

)
END
GO
/****** Object:  StoredProcedure [dbo].[sp21]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp21]
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
GO
/****** Object:  StoredProcedure [dbo].[sp3]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp3]
as
begin
	SELECT *
	FROM Tanmenetfélév t
	WHERE NOT EXISTS
	(
		SELECT *
        FROM Képes k
        WHERE t.tanár = k.tanárid AND t.tantárgy = k.tantárgyid
	)
end
GO
/****** Object:  StoredProcedure [dbo].[sp5]    Script Date: 2019. 04. 16. 19:38:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create procedure [dbo].[sp5]
as
begin
	SELECT tantárgy,terem
	FROM Órarend
	WHERE tantárgy NOT IN
	(
		SELECT tantárgy.tantárgyid
		FROM Tantárgy,Speci
		WHERE Tantárgy.teremigény = Speci.azon
	)
end	
GO
USE [master]
GO
ALTER DATABASE [eNaplo] SET  READ_WRITE 
GO
