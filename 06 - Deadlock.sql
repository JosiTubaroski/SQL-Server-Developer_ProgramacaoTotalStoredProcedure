/*
https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2014#deadlocking

Deadlock ou chamado abra�o mortal ocorre quando existe uma 
depend�ncia c�clica entre duas conex�es.

Os recursos de duas conex�es tem uma depend�ncia entre si. A transa��o A tem uma 
depend�ncia com a transa��o B e vice-versa.










Exemplo:
*/

-- Conex�o 01 
use eBook
go

Begin Transaction

Update tCADCliente 
   Set mCredito  = 1
 Where iIDCliente = 1

Update tCADLivro  
   set nPaginas = 617
 where iIDLivro = 1

Commit 

-- Conex�o 02 

use eBook
go

Begin Transaction

Update tCADLivro  
   set nPaginas = 617
 where iIDLivro = 1

Update tCADCliente 
   Set mCredito  = 1
 Where iIDCliente = 1

Commit 

/*
Mensagem de Erro 

Msg 1205, Level 13, State 51, Line 32
Transaction (Process ID 54) was deadlocked on lock resources with another 
process and has been chosen as the deadlock victim. Rerun the transaction.
*/

/*
Mas como o SQL Server define qual conex�o ser� a v�tima?

Ele avalia as conex�es e elege a que consumiu menos recursos para ser a v�tima.
Como o deadlock ocorrem em transa��es, o custo de rollback ser� menor se a conex�o v�tima da
transa��o consumiu menos recursos que a outra conex�o.

Um dos fatores para calcular esse custo � quanto a transa��o consumiu 
do log de transa��o.

Exemplos:
*/

-- Conex�o 01 - Temos tr�s instru��es e pela 
-- defini��o, ela ir� consumir mais recursos.
use eBook
go

Begin Transaction

update tMOVPedido 
   set dCancelado = GETDATE()
  where iIDCliente = 1 

Update tCADCliente 
   Set mCredito  = 1
 Where iIDCliente = 1

Update tCADLivro  
   set nPaginas = 617
 where iIDLivro = 1

Commit 

-- Conex�o 02 - Temos duas instru��es e consumir� menos recursos que a conex�o 1
use eBook
go

Begin Transaction

Update tCADLivro  
   set nPaginas = 617
 where iIDLivro = 1

Update tCADCliente 
   Set mCredito  = 1
 Where iIDCliente = 1

Commit 



/*
Minimizando a ocorr�ncia de deadlock 

-- Na medida do poss�vel, criar os c�digos com mesma sequ�ncia
   l�gica para atender o processo ou uma regra de n�gocio.

-- Sempre utilizar o mesmo objeto de programa��o para atender
   um processo, evitando ter c�digo igual em objetos diferente.

-- Utilize transa��es curtas, com comandos somente de
   atualiza��o de dados. 

*/

