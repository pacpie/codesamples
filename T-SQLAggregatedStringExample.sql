SELECT DISTINCT semp_act_v.arcfk,
STUFF((SELECT DISTINCT '' + Notes.Descript from [Transaction].dbo.Notes
WHERE semp_act_v.arcfk = Notes.arcfk
FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,0,'')data
FROM [Transaction].dbo.semp_act_v