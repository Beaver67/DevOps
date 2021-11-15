/****** Object:  Schema [Covid]    Script Date: 11/15/2021 12:58:19 AM ******/
CREATE SCHEMA [Covid]
GO
/****** Object:  UserDefinedFunction [Covid].[returnLastUpdate]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
** Author:		Don Branthwaite, www.bluelizard.com
** Create date: 04/01/2021
** Description:	Had data issues related to the insertion of inconsistent dates in the files from the Johns Hopkins
				Dashboard Repo (CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/)
				Example: File for 03/01/2021 would contain dates that referenced later (04/01/2021).
				When loading a bunch of files for the month, this can be problematic and MAX(File_Date) could not be used.

*****************************************************************************************************************/

CREATE FUNCTION [Covid].[returnLastUpdate] ()
RETURNS DATE
AS
BEGIN
    RETURN
	(SELECT CAST(MAX(Last_Update) AS DATE) as LastUpdate
    FROM
        (SELECT Last_Update, COUNT(Last_Update) MyCount
        FROM Covid.DailyDataAllBL
        GROUP BY Last_Update) as MaxDate
    WHERE MyCount > 1000)

END
GO
/****** Object:  Table [Covid].[DailyDataAllBL]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Covid].[DailyDataAllBL]
(
    [FIPS] [varchar](10) NULL,
    [Admin2] [varchar](50) NULL,
    [Province_State] [varchar](50) NULL,
    [Country_Region] [varchar](50) NULL,
    [Last_Update] [datetime] NULL,
    [Lat] [numeric](15, 8) NULL,
    [Long] [numeric](15, 8) NULL,
    [Confirmed] [int] NULL,
    [Deaths] [int] NULL,
    [Recovered] [int] NULL,
    [Active] [int] NULL,
    [Combined_Key] [varchar](150) NULL,
    [Combined_KeyBL] [varchar](100) NULL,
    [ConfirmedDiff] [int] NULL,
    [DeathsDiff] [int] NULL,
    [RecoveredDiff] [int] NULL,
    [ActiveDiff] [int] NULL,
    [ConfirmedDiffP] [numeric](15, 5) NULL,
    [DeathsDiffP] [numeric](15, 5) NULL,
    [RecoveredDiffP] [numeric](15, 5) NULL,
    [ActiveDiffP] [numeric](10, 5) NULL,
    [Incident_Rate] [numeric](25, 18) NULL,
    [Case_Fatality_Ratio] [numeric](25, 18) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Covid].[DailyDataRawSingle]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Covid].[DailyDataRawSingle]
(
    [FIPS] [varchar](10) NULL,
    [Admin2] [varchar](50) NULL,
    [Province_State] [varchar](50) NULL,
    [Country_Region] [varchar](50) NULL,
    [Last_Update] [datetime] NULL,
    [Lat] [numeric](15, 8) NULL,
    [Long] [numeric](15, 8) NULL,
    [Confirmed] [int] NULL,
    [Deaths] [int] NULL,
    [Recovered] [int] NULL,
    [Active] [int] NULL,
    [Combined_Key] [varchar](150) NULL,
    [Incident_Rate] [numeric](25, 18) NULL,
    [Case_Fatality_Ratio] [numeric](25, 18) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Covid].[DailyDataUS]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Covid].[DailyDataUS]
(
    [Admin2] [varchar](50) NULL,
    [Province_State] [varchar](50) NULL,
    [Last_Update] [datetime] NULL,
    [Lat] [numeric](15, 8) NULL,
    [Long] [numeric](15, 8) NULL,
    [Confirmed] [int] NULL,
    [Deaths] [int] NULL,
    [Combined_Key] [varchar](150) NULL,
    [Combined_KeyBL] [varchar](100) NULL,
    [ConfirmedDiff] [int] NULL,
    [DeathsDiff] [int] NULL,
    [Incident_Rate] [numeric](25, 18) NULL,
    [Case_Fatality_Ratio] [numeric](25, 18) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [Covid].[Cleanup]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Don Branthwaite, www.bluelizard.com
-- Create date: 12/11/2018
-- Description:	Calls the SP removeDuplicatesFromTable 
-- =============================================
CREATE		 PROCEDURE [Covid].[Cleanup]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Remove records with bad data
    DELETE FROM [Covid].DailyDataAllBL
		WHERE Combined_Key IN ('Unknown, China', 'Copper River, Alaska, US', 'Chugach, Alaska, US', 'Summer Olympics 2020', 'Kiribati')

    --Table name, Order by field, list of fields that are used for the duplicate comparison
    EXEC dbo.removeDuplicatesFromTable 'Covid.[DailyDataAllBL]', 'Last_Update','[FIPS],[Admin2],[Province_State],[Country_Region],[Last_Update],[Lat],[Long],[Confirmed],[Deaths],[Recovered],[Active],[Combined_Key],[Incident_Rate],[Case_Fatality_Ratio]'
END
GO
/****** Object:  StoredProcedure [Covid].[processCovidDaily]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************************
** Author:		Don Branthwaite, www.bluelizard.com
** Create date: 02/18/2021
** Description:	Stored Proc to load the various data files (deaths/confirmed/recovered) from the Johns Hopkins
				Dashboard Repo (CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/)

*****************************************************************************************************************
** Change History
**************************
** #    Date        Author		Description 
** --   --------   -------		------------------------------------
** 1    03/29/2020  DB			
*******************************/

CREATE PROCEDURE [Covid].[processCovidDaily]
AS

BEGIN
    SET NOCOUNT ON
    --SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET ARITHABORT ON
    SET XACT_ABORT ON
    -- open transaction is rolled back and execution is aborted

    BEGIN TRY
      BEGIN TRANSACTION

--************************ DECLARE VARIABLES ********************************************************************
		DECLARE @myDate date

		SELECT @myDate = Covid.returnLastUpdate() --MAX([Last_Update]) from DailyDataAllBL_TEST
--************************ INSERT CODE HERE *********************************************************************

		DROP TABLE IF Exists #tmp
		DROP TABLE IF Exists #tmp2

		-- Populate the #tmp table with data from the main data table (DailyDataALLBL for Covid-19 counts) with the last_update = most recent day of data
		SELECT *
    INTO #tmp
    FROM
        (
		SELECT TOP 10000000
            [FIPS], [Admin2], [Province_State], [Country_Region], [Last_Update], [Lat], [Long], [Confirmed], [Deaths], [Recovered], [Active], [Combined_Key], Combined_keyBL, [Incident_Rate], [Case_Fatality_Ratio]
        FROM AzureData.Covid.DailyDataAllBL
        WHERE  [Last_Update] = @myDate
        ORDER BY  Combined_key, Last_Update DESC
		) x

		-- Populate the #tmp table with all data from the table ([DailyDataRawSingle]) that was populated via the SSIS package (Covid.dtsx)
		;INSERT INTO #tmp
    SELECT [FIPS], [Admin2], [Province_State], [Country_Region], [Last_Update], [Lat], [Long], [Confirmed], [Deaths], [Recovered], [Active], [Combined_Key], '', [Incident_Rate], [Case_Fatality_Ratio]
    FROM [DailyDataRawSingle]
    ORDER BY  Combined_key, Last_Update DESC

		-- Populate the data into a new #tmp2 table with new sorting that will allow for accurate calculations using LEAD
		SELECT *
    INTO #tmp2
    FROM
        (
		SELECT TOP 1000000
            [FIPS], [Admin2], [Province_State], [Country_Region], [Last_Update], [Lat], [Long], [Confirmed], [Deaths], [Recovered], [Active], [Combined_Key], Combined_keyBL, [Incident_Rate], [Case_Fatality_Ratio]
        FROM #tmp
        ORDER BY  Combined_key, Last_Update DESC
		) x

		-- Populate the cte with the LEAD calculations for a difference between one day vs the previous day in terms of Covid-19 counts
		;WITH
        [cte]
        AS
        (
            SELECT
                FIPS, Admin2, [Province_State], [Country_Region], Last_Update, Lat, Long, Confirmed, Deaths, Recovered, Active, Combined_Key, Combined_keyBL,
                CASE
				WHEN LEAD(Combined_key) OVER(ORDER BY Combined_key DESC) = Combined_key
					Then Confirmed - LEAD(Confirmed) OVER(ORDER BY Combined_key DESC)
				ELSE
					0
			END AS ConfirmedDiff,

                CASE
			WHEN LEAD(Combined_key) OVER(ORDER BY Combined_key DESC) = Combined_key
				Then Deaths - LEAD(Deaths) OVER(ORDER BY Combined_key DESC)
			ELSE
				0
			END AS DeathsDiff,

                CASE
				WHEN LEAD(Combined_key) OVER(ORDER BY Combined_key DESC) = Combined_key
					Then Recovered - LEAD(Recovered) OVER(ORDER BY Combined_key DESC)
				ELSE
					0
			END AS RecoveredDiff,

                CASE
				WHEN LEAD(Combined_key) OVER(ORDER BY Combined_key DESC) = Combined_key
					Then Active - LEAD(Active) OVER(ORDER BY Combined_key DESC)
				ELSE
					0
			END AS ActiveDiff

			, [Incident_Rate]
			, [Case_Fatality_Ratio]

            FROM #tmp2
        )

    -- Populate the main data table (DailyDataALLBL for Covid-19 counts)
    INSERT INTO AzureData.Covid.DailyDataAllBL
    SELECT [FIPS], [Admin2], [Province_State], [Country_Region], [Last_Update], [Lat], [Long], [Confirmed], [Deaths], [Recovered], [Active], [Combined_Key], Combined_keyBL, ConfirmedDiff, DeathsDiff, RecoveredDiff, ActiveDiff
			, 0 AS ConfirmedDiffP
			, 0 AS DeathsDiffP
			, 0 AS RecoveredDiffP
			, 0 AS ActiveDiffP
			, [Incident_Rate], [Case_Fatality_Ratio]
    FROM cte
    WHERE [Last_Update] > @myDate

	COMMIT TRANSACTION
	END TRY

--************************ ERROR HANDLING ************************************************************************
BEGIN CATCH
    DECLARE @lineNum VarChar(1000)
    DECLARE @errMessage nVarChar(1000)
    
    SELECT @lineNum = CAST(ERROR_LINE() As Varchar(MAX))
    SELECT @errMessage = 'Proc ' + OBJECT_NAME(@@PROCID) + ' - error line #' + @lineNum + ': ' + ERROR_MESSAGE()
        
    IF XACT_STATE() = -1 AND @@TRANCOUNT >= 1
        BEGIN
        Rollback Transaction
    END
        
    RAISERROR(@errMessage, 16, 1)
END CATCH

    SET NOCOUNT OFF
END
GO
/****** Object:  StoredProcedure [Covid].[returnMaxDate]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Don Branthwaite, www.bluelizard.com
-- Create date: 12/11/2018
-- Description:	Calls the SP removeDuplicatesFromTable 
-- =============================================
CREATE		 PROCEDURE [Covid].[returnMaxDate]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT MAX(Last_Update)
    FROM
        (SELECT Last_Update, COUNT(Last_Update) MyCount
        FROM Covid.DailyDataAllBL
        GROUP BY Last_Update) as MaxDate
    WHERE MyCount > 1000


--1000 is used because sometimes there are dates in the file that are much later than the file name. There are not very many of those values, so if we use 1000, we are guaranteed to get the maximum TRUE date.
--For example, 03-01-2021 is the file name and all of the dates should be for 03-02-2021 data. There are a couple of dates listed as 04-02-2021. Using a plain MAX(Last_Update) will yield incorrect results for what we are trying to accomplish.
END
GO
/****** Object:  StoredProcedure [dbo].[removeDuplicatesFromSpecificTables]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Don Branthwaite, www.bluelizard.com
-- Create date: 12/11/2018
-- Description:	Calls the SP removeDuplicatesFromTable 
-- =============================================
CREATE		 PROCEDURE [dbo].[removeDuplicatesFromSpecificTables]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;
    --Table name, Order by field, list of fields that are used for the duplicate comparison
    EXEC dbo.removeDuplicatesFromTable 'Covid.[DailyDataAllBL]', 'Last_Update','[FIPS],[Admin2],[Province_State],[Country_Region],[Last_Update],[Lat],[Long],[Confirmed],[Deaths],[Recovered],[Active],[Combined_Key],[Incident_Rate],[Case_Fatality_Ratio]'
END
GO
/****** Object:  StoredProcedure [dbo].[removeDuplicatesFromTable]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Don Branthwaite, www.bluelizard.com
-- Create date: 12/11/2018
-- Description:	Removes all duplicate values based on table and columns specified 
-- =============================================
CREATE		 PROCEDURE [dbo].[removeDuplicatesFromTable]
    (
    @tb NVARCHAR(200),
    @orderField NVARCHAR(100),
    @strColumns NVARCHAR(1000)
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX)

    SET @SQL = '
		;WITH CTE AS(
		   SELECT ' + @strColumns + ',
			   RN = ROW_NUMBER()OVER(PARTITION BY ' + @strColumns + ' ORDER BY ' + @orderField + ')
		   FROM ' + @TB + '
		   Where last_update > ''2021-7-1'' 
		)
		DELETE FROM CTE WHERE RN > 1
		'

    --Execute the SQL Statement
    EXEC sp_executesql @SQL


END
GO
/****** Object:  StoredProcedure [dbo].[removeExtraWhiteSpacesFromColumns]    Script Date: 11/15/2021 12:58:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Don Branthwaite, www.bluelizard.com
-- Create date: 11/20/2014
-- Description:	Removes all extra whitespace characters from ALL varchar/nvarchar columns in a table 
-- =============================================
Create		 PROCEDURE [dbo].[removeExtraWhiteSpacesFromColumns]
    (
    @tb VARCHAR(200)
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    --Create temp table to get column names and a row id
    SELECT COLUMN_NAME ,
        ROW_NUMBER() OVER ( ORDER BY COLUMN_NAME ) AS id
    INTO    #tempcols
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE   DATA_TYPE IN ( 'varchar', 'nvarchar' )
        AND TABLE_NAME = @tb

    DECLARE @tri INT
    SELECT @tri = COUNT(*)
    FROM #tempcols
    DECLARE @i INT
    SELECT @i = 0

    DECLARE @trimmer NVARCHAR(MAX)

    DECLARE @comma VARCHAR(1)
    SET @comma = ', '

    --Build Update query
    SELECT @trimmer = 'UPDATE [dbo].[' + @tb + '] SET '

    WHILE @i <= @tri
            BEGIN

        IF ( @i = @tri )
                    BEGIN
            SET @comma = ''
        END

        --SQL Statement to replace white spaces and trim L/R
        --Using CHAR(17)/CHAR(18) as replacements in a string, then the statement reverses the 17/18 to get rid of the extras. Finally, the values are replaced with a space yielding 1 space only
        SELECT @trimmer = @trimmer + CHAR(10) + '[' + COLUMN_NAME
                        + '] = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(['
                        + COLUMN_NAME + '],' + ''' ''' + ','
                        + '''CHAR(17)CHAR(18)''' + '),'
                        + '''CHAR(18)CHAR(17)''' + ',' + '''''' + '),'
                        + '''CHAR(17)CHAR(18)''' + ',' + ''' ''' + ')))'
                        + @comma
        FROM #tempcols
        WHERE   id = @i

        SELECT @i = @i + 1
    END

    --Execute the SQL Statement
    EXEC sp_executesql @trimmer

    DROP TABLE #tempcols
END
GO
