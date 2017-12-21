STUFF((SELECT '; ' +'TRUNCATE TABLE '+ name AS [text()]
        FROM  
        (
SELECT schema_name(schema_id)+'.'+Name [name]
FROM sys.tables
WHERE name NOT IN
('AbstractsReview_Products','Country_Convert')
         ) x
        For XML PATH ('')),1,1,'')
