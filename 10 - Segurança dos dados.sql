/*
Nesta aula veremos como impor restri��es de acesso as procedures.

Vamos simuluar com um suposto usu�rio do banco de dados que tem permiss�o
de acesso a base eBook.

Tr�s cen�rios:

1. Acesso total. 
2. Acesso parcial. Acesso somente de leitura e grava��o de dados como acesso a procedures.
3. Acesso restrito. Somente para executar a procedure e realizar leitura de dados em vis�es.

Esses cen�rios ser�o aplicados somente no banco de dados Ebook

*/


/*
Criado o usu�rio
*/
use master
go

/*
Cria um login na inst�ncia do SQL SERVER e define o 
banco de dados padr�o de conex�o com eBook. 
Se o banco estiver online, ele pode conectar, apenas !!!
*/

Create Login usrjoao 
  With Password = '@123456', 
  Default_Database = eBook, 
  Check_Expiration = off,     -- Conta n�o expira
  Check_Policy = off          -- N�o aplicar as pol�ticas de senha do Windows 
go


/*
Com um login definido, agora voc� tem que criar um usu�rio no banco de dados 
e relacionar login com usu�rio. 

*/
use eBook
go

Create User usrjoao 
   For Login usrjoao 
   With Default_Schema = dbo
go


/*
Cenario 01 - Acesso total ao banco de dados 
*/

/*
Aqui que definimos o n�vel de seguran�a de acesso da conta no banco de dados.
Definimos uma regra de banco de dados de nome db_owner que � o database owner ou
o dono do banco de dados. Ele faz tudo no banco de dados. 
*/
Alter Role db_owner add member usrjoao
GO

/*
Link para entender a parte de cria��o de login e user 
https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-login-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-user-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/relational-databases/security/authentication-access/database-level-roles?view=sql-server-2017
*/
 

/*
Simulando o acesso em outra conex�o com a conta usrJoao . 
*/


/*
Cenario 02 - Acesso parcial 
*/

/*
Vamos come�ar a reduzir essas permiss�es, tirando o acesso de db_owner e colocando 
as permiss�es de leitura, grava��o e execu��o de procedure. 
*/
use eBook
go

/*
Retira a permiss�o de dono do banco de dados 
*/
Alter Role db_owner 
 Drop member usrjoao
GO

/*
Adiciona a permiss�o de Leitura dos dados 
*/
Alter Role db_datareader 
  add member usrjoao
go

/*
Adiciona a permiss�o de Gravar dos dados. Isso permite a conta incluir, altear e excluir dados 

*/

Alter Role db_datawriter 
  add member usrjoao
go

/*
Define pontualmente para a procedure stp_IncluirPedido a permiss�o de executar o 
o seu conte�do. 
*/

Grant Execute 
   on dbo.stp_incluirpedido 
   to usrjoao

Grant Execute 
   on dbo.stp_ManipulaErro
   to usrjoao


/*
As pr�ximo dois comandos garante que a conta tem permiss�o de ver o conte�do da procedures
como tamb�m realizar altera��es 
*/
Grant View Definition 
   on dbo.stp_incluirpedido 
   to usrjoao
go


Grant Alter 
   on dbo.stp_incluirpedido 
   to usrjoao
go


/*
Simulando o acesso. 
*/



/*
Cenario 03 - Acesso restrito 
*/

Alter Role db_datareader 
  Drop member usrjoao
go

/*
Adiciona a permiss�o de Gravar dos dados. Isso permite a conta incluir, altear e excluir dados 

*/

Alter Role db_datawriter 
  Drop member usrjoao
go


Deny View Definition 
   on dbo.stp_incluirpedido 
   to usrjoao
go





/*
Outras permiss�es 
*/

Grant Execute on schema::dbo to usrjoao 

Grant Select on vCADClientesSemCredito to usrJoao 
Grant Select on vLOGEvenctos to usrJoao 


