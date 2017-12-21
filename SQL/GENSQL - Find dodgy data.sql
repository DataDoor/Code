USE DQS_STAGING_DATA;
WITH freqCTE AS
(
SELECT Occupation,
ROW_NUMBER() OVER(PARTITION BY Occupation
ORDER BY Occupation, CustomerKey) AS Rn_AbsFreq,
ROW_NUMBER() OVER(
ORDER BY Occupation, CustomerKey) AS Rn_CumFreq,
ROUND(100 * PERCENT_RANK()
OVER(ORDER BY Occupation), 0) AS Pr_AbsPerc,
ROUND(100 * CUME_DIST()
OVER(ORDER BY Occupation, CustomerKey), 0) AS Cd_CumPerc
FROM dbo.TK463CustomersDirty
)
SELECT Occupation,
MAX(Rn_AbsFreq) AS AbsFreq,
MAX(Rn_CumFreq) AS CumFreq,
MAX(Cd_CumPerc) - MAX(Pr_Absperc) AS AbsPerc,
MAX(Cd_CumPerc) AS CumPerc,
CAST(REPLICATE('/',MAX(Cd_CumPerc) - MAX(Pr_Absperc)) AS varchar(100)) AS Histogram
FROM freqCTE
GROUP BY Occupation
ORDER BY Occupation;


