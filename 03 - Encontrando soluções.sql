/*

N�o da para saber 100% de todos os erros e tampouco as suas solu��es.

Entre v�rias fontes na Internet, vamos explicar aqui em como 
achar as mensagens de erros e as solu��es.

A documenta��o da Microsoft mant�m um grupo de erros catalogado,
onde � poss�vel voce encontrar um erro, a causa e quais s�o as 
solu��es poss�veis. 

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/database-engine-events-and-errors?view=sql-server-2017



*/
use eBook 
go



select * from NaoSeiONome

/*
Msg 208, Level 16, State 1, Line 46
Invalid object name 'NaoSeiONome'.

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/mssqlserver-208-database-engine-error?view=sql-server-2017
*/

/*
Msg 1205, Level 13, State 51, Line 32
Transaction (Process ID 54) was deadlocked on lock resources with another 
process and has been chosen as the deadlock victim. Rerun the transaction.
*/

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/mssqlserver-1205-database-engine-error?view=sql-server-2017

/*
Existem erros de severidade 14 que � de permiss�o e que n�o
s�o gerados por programa��o. 

Erro por exemplo de tentativa de logon e ocorre uma falha. 

Error: 18456, Severity: 14, State: 11.
Login failed for user 'Dominio\logon'. Reason: Token-based server access validation failed with an infrastructure error. Check for previous errors. [CLIENT: XXX.XXX.XXX.XXX]

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/mssqlserver-18456-database-engine-error?view=sql-server-2017

*/


/*
SQL Server Logs de Erros 

O SQL Server armazena alguns eventos de avisos e erros em um arquivo em disco (?!)

Acessando pelo SSMS interface:


Acessando via programa��o 

*/

execute sp_readerrorlog  -- Leitura do arquivo atual 

execute sp_readerrorlog  1  --Leitura do arquivo Anterior 

execute sp_readerrorlog  0 , 1, 'Error'




