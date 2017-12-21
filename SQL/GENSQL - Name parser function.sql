USE [SRM_ATYPON]
GO

/****** Object:  UserDefinedFunction [dbo].[udf_ParseName]    Script Date: 26/03/2015 13:29:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_ParseName](@NameString varchar(100), @NameFormat varchar(20))
    RETURNS VARCHAR(100) AS
    BEGIN


/*============================================= 
      
Author:      MCB_BFD1\GELDERN 
 
Create date: 26/03/2015 13:20:43 
Database:    N/A
DB Object: udf_ParseName
 
Description: 

This function decodes a NameString into its component parts and returns it in a requested format.
@NameString is the raw value to be parsed.
@NameFormat is a string that defines the output format.  Each letter in the string represents
a component of the name in the order that it is to be returned.
    [H] = Full honorific
    [h] = Abbreviated honorific
    [F] = First name
    [f] = First initial
    [M] = Middle name
    [m] = Middle initial
    [L] = Last name
    [l] = Last initial
    [S] = Full suffix
    [s] = Abbreviated suffix
    [.] = Period
    [,] = Comma
    [ ] = Space
	 
 
Modifications: 
=============================================*/


/*Test variables
    declare    @NameString varchar(50)
    declare    @NameFormat varchar(20)
    set    @NameFormat = 'F M L S'
    set    @NameString = 'Melvin Carter, Jr'*/

    Declare    @Honorific varchar(20)
    Declare @FirstName varchar(20)
    Declare @MiddleName varchar(30)
    Declare @LastName varchar(30)
    Declare @Suffix varchar(20)
    Declare    @TempString varchar(100)
    Declare    @TempString2 varchar(100)
    Declare    @IgnorePeriod char(1)

    /*Prepare the string*/

    /*Make sure each period is followed by a space character.*/
    set    @NameString = rtrim(ltrim(replace(@NameString, '.', '. ')))

    /*Remove disallowed characters*/
    declare    @PatternString varchar(50)
    set    @PatternString = '%[^a-z ,-]%'
    while    patindex(@PatternString, @NameString) > 0 set @NameString = stuff(@NameString, patindex(@PatternString, @NameString), 1, ' ')

    /*Remove telephone ext*/
    set    @NameString = ltrim(rtrim(replace(' ' + @NameString + ' ', ' EXT ', ' ')))

    /*Eliminate double-spaces.*/
    while  charindex('  ', @NameString) > 0 set @NameString = replace(@NameString, '  ', ' ')

    /*Eliminate periods*/
    while  charindex('.', @NameString) > 0 set @NameString = replace(@NameString, '.', '')

    /*Remove spaces around hyphenated names*/
    set    @NameString = replace(replace(@NameString, '- ', '-'), ' -', '-')

    /*Remove commas before suffixes*/
    set    @NameString = replace(@NameString, ', Jr', ' Jr')
    set    @NameString = replace(@NameString, ', Sr', ' Sr')
    set    @NameString = replace(@NameString, ', II', ' II')
    set    @NameString = replace(@NameString, ', III', ' III')

    /*Temporarily join multi-word surnames*/
    set    @NameString = ltrim(replace(' ' + @NameString, ' Del ', ' Del~'))
    set    @NameString = ltrim(replace(' ' + @NameString, ' Van ', ' Van~'))
    set    @NameString = ltrim(replace(' ' + @NameString, ' Von ', ' Von~'))
    set    @NameString = ltrim(replace(' ' + @NameString, ' Mc ', ' Mc~'))
    set    @NameString = ltrim(replace(' ' + @NameString, ' Mac ', ' Mac~'))
    set    @NameString = ltrim(replace(' ' + @NameString, ' La ', ' La~')) --Must be checked before "De", to handle "De La [Surname]"s.
    set    @NameString = ltrim(replace(' ' + @NameString, ' De ', ' De~'))

    /*If the lastname is listed first, strip it off.*/
    set    @TempString = rtrim(left(@NameString, charindex(' ', @NameString)))
    /*Below logic now handled by joining multi-word surnames above.
    --if    @TempString in ('VAN', 'VON', 'MC', 'Mac', 'DE') set @TempString = rtrim(left(@NameString, charindex(' ', @NameString, len(@TempString)+2)))*/

    /*Search for suffixes trailing the LastName*/
    set    @TempString2 = ltrim(right(@NameString, len(@NameString) - len(@TempString)))
    set    @TempString2 = rtrim(left(@TempString2, charindex(' ', @TempString2)))

    if    right(@TempString2, 1) = ','
    begin
    set @Suffix = left(@TempString2, len(@TempString2)-1)
    set @LastName = left(@TempString, len(@TempString))
    end
    if    right(@TempString, 1) = ',' set @LastName = left(@TempString, len(@TempString)-1)
    if    len(@LastName) > 0 set    @NameString = ltrim(right(@NameString, len(@NameString) - len(@TempString)))
    if    len(@Suffix) > 0 set    @NameString = ltrim(right(@NameString, len(@NameString) - len(@TempString2)))

    /*Get rid of any remaining commas*/
    while  charindex(',', @NameString) > 0 set @NameString = replace(@NameString, ',', '')
    /*Get Honorific and strip it out of the string*/
    set    @TempString = rtrim(left(@NameString, charindex(' ', @NameString + ' ')))
    if    @TempString in (
    'Admiral', 'Adm',
    'Captain', 'Cpt', 'Capt',
    'Commander', 'Cmd',
    'Corporal', 'Cpl',
    'Doctor', 'Dr',
    'Father', 'Fr',
    'General', 'Gen',
    'Governor', 'Gov',
    'Honorable', 'Hon',
    'Lieutenant', 'Lt',
    'Madam', 'Mdm',
    'Madame', 'Mme',
    'Mademoiselle', 'Mlle',
    'Major', 'Maj',
    'Miss', 
	'Ms',
    'Mr',
    'Mrs',
    'President', 'Pres',
    'Private', 'Pvt',
    'Professor', 'Prof',
    'Rabbi',
    'Reverend', 'Rev',
    'Senior', 'Sr',
    'Seniora', 'Sra',
    'Seniorita', 'Srta',
    'Sergeant', 'Sgt',
    'Sir',
    'Sister') set @Honorific = @TempString
    if    len(@Honorific) > 0 set    @NameString = ltrim(right(@NameString, len(@NameString) - len(@TempString)))
    /*Get Suffix and strip it out of the string*/
    if @Suffix is null
    begin
    set    @TempString = ltrim(right(@NameString, charindex(' ', Reverse(@NameString) + ' ')))
    if    @TempString in (
    'Attorney', 'Att', 'Atty',
    'BA',
    'BS',
    'CPA',
    'DDS',
    'DVM',
    'Esquire', 'Esq',
    'II',
    'III',
    'IV',
    'Junior', 'Jr',
    'MBA',
    'MD',
    'OD',
    'PHD',
    'Senior', 'Sr') set @Suffix = @TempString
    if    len(@Suffix) > 0 set @NameString = rtrim(left(@NameString, len(@NameString) - len(@TempString)))
    end

    if @LastName is null
    begin
    /*Get LastName and strip it out of the string*/
    set    @LastName = ltrim(right(@NameString, charindex(' ', Reverse(@NameString) + ' ')))
    set    @NameString = rtrim(left(@NameString, len(@NameString) - len(@LastName)))
    /*Below logic now handled by joining multi-word surnames above.*/
    /*    --Check to see if the last name has two parts
    set    @TempString = ltrim(right(@NameString, charindex(' ', Reverse(@NameString) + ' ')))
    if    @TempString in ('VAN', 'VON', 'MC', 'Mac', 'DE')
    begin
    set @LastName = @TempString + ' ' + @LastName
    set @NameString = rtrim(left(@NameString, len(@NameString) - len(@TempString)))
    end
    */
    end
    /*Get FirstName and strip it out of the string*/
    set    @FirstName = rtrim(left(@NameString, charindex(' ', @NameString + ' ')))
    set    @NameString = ltrim(right(@NameString, len(@NameString) - len(@FirstName)))
    /*Anything remaining is MiddleName*/
    set    @MiddleName = @NameString
    /*Create the output string*/
    set    @TempString = ''
    while len(@NameFormat) > 0
    begin
    if @IgnorePeriod = 'F' or left(@NameFormat, 1) <> '.'
    begin
    set @IgnorePeriod = 'F'
    set @TempString = @TempString +
    case ascii(left(@NameFormat, 1))
    when '32' then case right(@TempString, 1)
    when ' ' then ''
    else ' '
    end
    when '44' then case right(@TempString, 1)
    when ' ' then ''
    else ','
    end
    when '46' then case right(@TempString, 1)
    when ' ' then ''
    else '.'
    end
    when '70' then isnull(@FirstName, '')
    when '72' then case @Honorific
    when 'Adm' then 'Admiral'
    when 'Capt' then 'Captain'
    when 'Cmd' then 'Commander'
    when 'Cpl' then 'Corporal'
    when 'Cpt' then 'Captain'
    --when 'Dr' then 'Doctor'
    when 'Fr' then 'Father'
    when 'Gen' then 'General'
    when 'Gov' then 'Governor'
    when 'Hon' then 'Honorable'
    when 'Lt' then 'Lieutenant'
    when 'Maj' then 'Major'
    when 'Mdm' then 'Madam'
    when 'Mlle' then 'Mademoiselle'
    when 'Mme' then 'Madame'
    --when 'Ms' then 'Miss'
    when 'Pres' then 'President'
    --when 'Prof' then 'Professor'
    when 'Pvt' then 'Private'
    when 'Sr' then 'Senior'
    when 'Sra' then 'Seniora'
    when 'Srta' then 'Seniorita'
    when 'Rev' then 'Reverend'
    when 'Sgt' then 'Sergeant'
    else isnull(@Honorific, '')
    end
    when '76' then isnull(@LastName, '')
    when '77' then isnull(@MiddleName, '')
    when '83' then case @Suffix
    when 'Att' then 'Attorney'
    when 'Atty' then 'Attorney'
    when 'Esq' then 'Esquire'
    when 'Jr' then 'Junior'
    when 'Sr' then 'Senior'
    else isnull(@Suffix, '')
    end
    when '102' then isnull(left(@FirstName, 1), '')
    when '104' then case @Honorific
    when 'Admiral' then 'Adm'
    when 'Captain' then 'Capt'
    when 'Commander' then 'Cmd'
    when 'Corporal' then 'Cpl'
    when 'Doctor' then 'Dr'
    when 'Father' then 'Fr'
    when 'General' then 'Gen'
    when 'Governor' then 'Gov'
    when 'Honorable' then 'Hon'
    when 'Lieutenant' then 'Lt'
    when 'Madam' then 'Mdm'
    when 'Madame' then 'Mme'
    when 'Mademoiselle' then 'Mlle'
    when 'Major' then 'Maj'
    when 'Miss' then 'Ms'
    when 'President' then 'Pres'
    when 'Private' then 'Pvt'
    when 'Professor' then 'Prof'
    when 'Reverend' then 'Rev'
    when 'Senior' then 'Sr'
    when 'Seniora' then 'Sra'
    when 'Seniorita' then 'Srta'
    when 'Sergeant' then 'Sgt'
    else isnull(@Honorific, '')
    end
    when '108' then isnull(left(@LastName, 1), '')
    when '109' then isnull(left(@MiddleName, 1), '')
    when '115' then case @Suffix
    when 'Attorney' then 'Atty'
    when 'Esquire' then 'Esq'
    when 'Junior' then 'Jr'
    when 'Senior' then 'Sr'
    else isnull(@Suffix, '')
    end
    else ''
    end
    /*The following honorifics and suffixes have no further abbreviations, and so should not be followed by a period:*/
    if ((ascii(left(@NameFormat, 1)) = 72 and @Honorific in ('Rabbi', 'Sister'))
    or (ascii(left(@NameFormat, 1)) = 115 and @Suffix in ('BA', 'BS', 'DDS', 'DVM', 'II', 'III', 'IV', 'V', 'MBA', 'MD', 'PHD')))
    set @IgnorePeriod = 'T'
    end
    set @NameFormat = right(@NameFormat, len(@NameFormat) - 1)
    end
    /*select    replace(@TempString, '~', ' ')*/
    Return NULLIF(REPLACE(@TempString, '~', ' '),'')
    end
GO




