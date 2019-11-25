/*
	Test Query
*/
WITH cte AS
(
	SELECT 
		*,
		PrevSLOAt = LAG(InsertedAt, 1) OVER (ORDER BY Id),
		PrevSLO = LAG(CurrentSLO, 1) OVER (ORDER BY Id)
	FROM 
		dbo.[TestResiliency] 
)
SELECT
	FromSLO = [cte].[PrevSLO],
	ToSLO = [cte].[CurrentSLO],
	[StartedAt] = cte.[PrevSLOAt],
	FinishedAt = [cte].[InsertedAt],
	DATEDIFF(SECOND, [cte].[PrevSLOAt], [cte].[InsertedAt]) AS ElapsedSecs
FROM
	[cte]
WHERE
	[cte].[CurrentSLO] != [cte].[PrevSLO]
ORDER BY 
	Id
;