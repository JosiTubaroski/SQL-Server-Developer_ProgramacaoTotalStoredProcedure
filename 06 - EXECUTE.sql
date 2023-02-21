/*
Você utiliza a instrução EXECUTE para:

Stored Procedure
Instrução Dinâmica 

*/

-- Stored Procedure 
use eBook
go

Execute sp_helpdb

Execute stp_UltimoPedido


/*
Observação!! Pelo Management Studio, voce pode executar as procedures
sem a instrução EXECUTE 
*/


sp_helpdb
stp_UltimoPedido



sp_helpdb
go
stp_UltimoPedido
go

-- Boa Prática!! Utilize o EXECUTE sempre para 
-- executar Stored Procedure 





-- Instruções Dinâmica 


Declare @cTabela char(20) = 'tCADCliente'
execute ('Select * from ' + @cTabela )
go

Declare @cTabela char(20) = 'tCADLivro'
execute ('Select * from ' + @cTabela )
go

/*
Alterando as colunas de um resultado.
*/
Declare @cTabela char(20) = 'tCADCliente'
execute ('Select iidCliente, cNome  from ' + @cTabela )
with result sets 
(
  (ID int NOT NULL,  
   Cliente varchar(150) NOT NULL  
  )
);  




