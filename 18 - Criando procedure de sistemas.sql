/*
Procedure de sistema.

S�o procedures criadas pelo SQL Server no momento da instala��o
de uma inst�ncia. 

Elas s�o criadas no banco de dados MASTER e tem as fun��es
para administra��o e coletar informa��es.

Exemplos: 

Todas as procedures de sistemas s�o iniciada com "SP_"  ou "XP_"

As que come�am com SP_, na grande maioria dos casos 
tem associado um c�digo em T-SQL.

SP_HELP - Retorna informa��es sobre um objeto do banco de dados. 

SP_HELPTEXT - Retorna as defini��es de regras (em alguns caso, c�digo) de
              procedure, fun��o, trigger, coluna computada ou restri��o 

SP_OACREATE - Cria um inst�ncia de um objeto OLE (Object Linked Embedding)

As que come�am com XP_, tem associado uma DLL.

XP_CMDSHELL - Executa um comando do Windows.

XP_FILEEXIST - Verificar se um arquivo existe (Procedure n�o documentada pela Microsoft) 

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
N�o importa em qual banco de dados voce est� conectado.
A execu��o da procedure de sistema considera que ela est� 
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
Voc� pode criar uma procedure de sistemas para atender as
suas necessidades de administra��o do banco de dados 
ou at� mesmo para atender a regras de neg�cio.

No meu caso, tenho uma procedure que criei para um melhor
suporte no momento de administrar �ndices para uma tabela ou v�rias tabelas.

Nativamento, o SQL SERVER tem uma procedure para visualizar os �ndices 
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
a cria��o e execu��o. 

1. Procedure de sistemas deve come�ar com SP_. 
*/


use Master
go
Create Or Alter Procedure sp_versaoSQL 
as
Begin
    Raiserror('A vers�o do SQL Server : %s',10,1,@@version)
End 
go

Create Or Alter Procedure stp_versaoSQL 
as
Begin
    Raiserror('A vers�o do SQL Server : %s',10,1,@@version)
End 

use eBook
go

Execute sp_versaoSQL 
GO
Execute stp_versaoSQL 

/*
Dica Importante: No seu banco de dados da sua aplica��o, voce N�O deve
criar procedure que come�a com SP_.

Se voce tem procedure nomeadas com SP_, toda vez que ocorrer a execu��o dessa 
procedure, a primeira verifica��o que o SQL Server ir� realizar e tentar encontrar
a procedure no banco de dados MASTER. Se n�o encontrar, ela ir� executar a procedure
no banco de dados da sua aplica��o.

*/


/*
2. Procedure de sistemas criadas por voc� devem ser 
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
Utilize a procedure (n�o documentada pela Microsoft) sp_ms_marksystemobject para marcar 
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


