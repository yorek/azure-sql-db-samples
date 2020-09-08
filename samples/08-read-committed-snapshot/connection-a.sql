/*
    Use WideWorldImporters Database
*/

BEGIN TRAN 

    INSERT INTO [Application].[Cities] (CityID, CityName, StateProvinceID, LastEditedBy)
    VALUES (99999, 'Redmond', 50, 1)

    DELETE FROM [Application].[Cities] WHERE CityName = 'Bellevue'

    UPDATE [Application].[Cities] SET LatestRecordedPopulation = 123456
    WHERE CityName = 'Kirkland' AND StateProvinceID = 50

    SELECT * FROM [Application].[Cities] WHERE CityName IN ('Kirkland', 'Redmond', 'Bellevue')

ROLLBACK TRAN
--COMMIT TRAN

SELECT @@TRANCOUNT
