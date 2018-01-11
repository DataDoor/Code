DECLARE @Email VARCHAR(100)

SET @Email = 'Neilgelder@gmail.com'

SELECT CASE WHEN @Email LIKE '%@%_._%' THEN 1 ELSE 0 END 