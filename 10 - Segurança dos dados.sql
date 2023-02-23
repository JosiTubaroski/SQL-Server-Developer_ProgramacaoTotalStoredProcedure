/*
Nesta aula veremos como impor restrições de acesso as procedures.

Vamos simuluar com um suposto usuário do banco de dados que tem permissão
de acesso a base eBook.

Três cenários:

1. Acesso total. 
2. Acesso parcial. Acesso somente de leitura e gravação de dados como acesso a procedures.
3. Acesso restrito. Somente para executar a procedure e realizar leitura de dados em visões.

Esses cenários serão aplicados somente no banco de dados Ebook

*/


/*
Criado o usuário
*/
use master
go

/*
Cria um login na instância do SQL SERVER e define o 
banco de dados padrão de conexão com eBook. 
Se o banco estiver online, ele pode conectar, apenas !!!
*/

Create Login usrjoao 
  With Password = '@123456', 
  Default_Database = eBook, 
  Check_Expiration = off,     -- Conta não expira
  Check_Policy = off          -- Não aplicar as políticas de senha do Windows 
go


/*
Com um login definido, agora você tem que criar um usuário no banco de dados 
e relacionar login com usuário. 

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
Aqui que definimos o nível de segurança de acesso da conta no banco de dados.
Definimos uma regra de banco de dados de nome db_owner que é o database owner ou
o dono do banco de dados. Ele faz tudo no banco de dados. 
*/
Alter Role db_owner add member usrjoao
GO

/*
Link para entender a parte de criação de login e user 
https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-login-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-user-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/relational-databases/security/authentication-access/database-level-roles?view=sql-server-2017
*/
 

/*
Simulando o acesso em outra conexão com a conta usrJoao . 
*/


/*
Cenario 02 - Acesso parcial 
*/

/*
Vamos começar a reduzir essas permissões, tirando o acesso de db_owner e colocando 
as permissões de leitura, gravação e execução de procedure. 
*/
use eBook
go

/*
Retira a permissão de dono do banco de dados 
*/
Alter Role db_owner 
 Drop member usrjoao
GO

/*
Adiciona a permissão de Leitura dos dados 
*/
Alter Role db_datareader 
  add member usrjoao
go

/*
Adiciona a permissão de Gravar dos dados. Isso permite a conta incluir, altear e excluir dados 

*/

Alter Role db_datawriter 
  add member usrjoao
go

/*
Define pontualmente para a procedure stp_IncluirPedido a permissão de executar o 
o seu conteúdo. 
*/

Grant Execute 
   on dbo.stp_incluirpedido 
   to usrjoao

Grant Execute 
   on dbo.stp_ManipulaErro
   to usrjoao


/*
As próximo dois comandos garante que a conta tem permissão de ver o conteúdo da procedures
como também realizar alterações 
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
Adiciona a permissão de Gravar dos dados. Isso permite a conta incluir, altear e excluir dados 

*/

Alter Role db_datawriter 
  Drop member usrjoao
go


Deny View Definition 
   on dbo.stp_incluirpedido 
   to usrjoao
go





/*
Outras permissões 
*/

Grant Execute on schema::dbo to usrjoao 

Grant Select on vCADClientesSemCredito to usrJoao 
Grant Select on vLOGEvenctos to usrJoao 


