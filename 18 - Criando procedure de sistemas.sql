/*
Procedure de sistema.

São procedures criadas pelo SQL Server no momento da instalação
de uma instância. 

Elas são criadas no banco de dados MASTER e tem as funções
para administração e coletar informações.

Exemplos: 

Todas as procedures de sistemas são iniciada com "SP_"  ou "XP_"

As que começam com SP_, na grande maioria dos casos 
tem associado um código em T-SQL.

SP_HELP - Retorna informações sobre um objeto do banco de dados. 

SP_HELPTEXT - Retorna as definições de regras (em alguns caso, código) de
              procedure, função, trigger, coluna computada ou restrição 

SP_OACREATE - Cria um instância de um objeto OLE (Object Linked Embedding)

As que começam com XP_, tem associado uma DLL.

XP_CMDSHELL - Executa um comando do Windows.

XP_FILEEXIST - Verificar se um arquivo existe (Procedure não documentada pela Microsoft) 

*/

execute sp_helptext @objname = 'sp_help'
go

execute sp_helptext @objname = 'sp_OACreate'
go

execute sp_helptext @objname = 'xp_fileexist'
go

Select * 
  From sys.objects 
 Where name = 'sp_help'

Select * 
  From sys.system_objects 
 Where name = 'sp_help'
go

/*
Não importa em qual banco de dados voce está conectado.
A execução da procedure de sistema considera que ela está 
no banco de dados MASTER. 
*/

use eBook
go

execute sp_help @objname = 'tCADCliente'
go

use msdb
go
execute sp_help @objname = 'sysjobs'




/*
Você pode criar uma procedure de sistemas para atender as
suas necessidades de administração do banco de dados 
ou até mesmo para atender a regras de negócio.

No meu caso, tenho uma procedure que criei para um melhor
suporte no momento de administrar índices para uma tabela ou várias tabelas.

Nativamento, o SQL SERVER tem uma procedure para visualizar os índices 
de uma tabela : SP_HELPINDEX 
*/


execute sp_Helpindex @objname = 'tMOVPedido'
go

execute sp_Helpindex2 @cTableName = 'tMOVPedido' 

/*
,@cResultTable = 'Tempdb.dbo.tTMPResultadoIndex' 

use tempdb
go

select * from tTMPResultadoIndex


*/
go



/*
Antes de criar a sua procedure de sistema, vamos entender como funciona
a criação e execução. 

1. Procedure de sistemas deve começar com SP_. 
*/


use Master
go
Create Or Alter Procedure sp_versaoSQL 
as
Begin
    Raiserror('A versão do SQL Server : %s',10,1,@@version)
End 
go

Create Or Alter Procedure stp_versaoSQL 
as
Begin
    Raiserror('A versão do SQL Server : %s',10,1,@@version)
End 

use eBook
go

Execute sp_versaoSQL 
GO
Execute stp_versaoSQL 

/*
Dica Importante: No seu banco de dados da sua aplicação, voce NÃO deve
criar procedure que começa com SP_.

Se voce tem procedure nomeadas com SP_, toda vez que ocorrer a execução dessa 
procedure, a primeira verificação que o SQL Server irá realizar e tentar encontrar
a procedure no banco de dados MASTER. Se não encontrar, ela irá executar a procedure
no banco de dados da sua aplicação.

*/


/*
2. Procedure de sistemas criadas por você devem ser 
   marcadas como procedure de sistema do SQL Server. 

*/
use eBook
go
execute sp_help tCADCliente
go



use master
go
Create or Alter Procedure sp_HelpTable
@cTable sysname 
as
Begin

   Select coluna.Column_id, coluna.Name, 
          tipo.name+iif(tipo.user_type_id in (167,175,231,239),'('+iif(Coluna.max_length=-1,'max',cast(Coluna.max_length as varchar(10)))+')','') as Type , 
          iif(coluna.is_nullable=1,'NULL','NOT NULL') Nullable 
     From sys.tables as tabela
     Join sys.columns  as coluna 
      on tabela.object_id = coluna.object_id
     join sys.types tipo 
      on coluna.user_type_id = tipo.user_type_id
    Where tabela.name = @cTable

End 
/*
*/
go



use eBook
go
execute sp_HelpTable 'tCADCliente'
go





/*
Utilize a procedure (não documentada pela Microsoft) sp_ms_marksystemobject para marcar 
o procedure como uma de sistemas nativa do SQL SERVER. 
*/
use master
go
execute sp_ms_marksystemobject sp_HelpTable
go


/*
*/
use eBook
go
execute sp_HelpTable 'tCADCliente'
go
execute sp_HelpTable 'tCADLivro'
go

use msdb
go
execute sp_HelpTable 'sysjobs'
go


