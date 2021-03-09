/*
    Use WideWorldImporters Database
*/

BEGIN TRAN 

    INSERT INTO [Application].[Cities] (CityID, CityName, StateProvinceID, LastEditedBy)
    VALUES (99999, 'Redmond', 50, 1)

    DELETE FROM [Application].[Cities] WHERE CityName = 'Bellevue'

    UPDATE [Application].[Cities] SET LatestRecordedPopulation = 123456
    WHERE CityName = 'Kirkland' AND StateProvinceID = 50

    -- This connection can see all the changes done to the data by itself
    SELECT * FROM [Application].[Cities] WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

    /* STOP HERE AND EXECUTE IN ANOTHER SESSION THE "connection-b.sql" SCRIPT BEFORE PROCEEDING! */

ROLLBACK TRAN
--or, if you prefer: COMMIT TRAN

SELECT @@TRANCOUNT
