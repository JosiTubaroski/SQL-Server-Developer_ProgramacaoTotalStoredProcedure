/*
https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2014#deadlocking

Deadlock ou chamado abraço mortal ocorre quando existe uma 
dependência cíclica entre duas conexões.

Os recursos de duas conexões tem uma dependência entre si. A transação A tem uma 
dependência com a transação B e vice-versa.










Exemplo:
*/

-- Conexão 01 
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

-- Conexão 02 

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
Mas como o SQL Server define qual conexão será a vítima?

Ele avalia as conexões e elege a que consumiu menos recursos para ser a vítima.
Como o deadlock ocorrem em transações, o custo de rollback será menor se a conexão vítima da
transação consumiu menos recursos que a outra conexão.

Um dos fatores para calcular esse custo é quanto a transação consumiu 
do log de transação.

Exemplos:
*/

-- Conexão 01 - Temos três instruções e pela 
-- definição, ela irá consumir mais recursos.
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

-- Conexão 02 - Temos duas instruções e consumirá menos recursos que a conexão 1
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
Minimizando a ocorrência de deadlock 

-- Na medida do possível, criar os códigos com mesma sequência
   lógica para atender o processo ou uma regra de négocio.

-- Sempre utilizar o mesmo objeto de programação para atender
   um processo, evitando ter código igual em objetos diferente.

-- Utilize transações curtas, com comandos somente de
   atualização de dados. 

*/

