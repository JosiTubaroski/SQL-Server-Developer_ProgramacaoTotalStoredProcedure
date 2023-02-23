/*

Existem op��es para voce configurar o comportamento do
bloqueio e do deadlocks.

SET LOCK_TIMEOUT 

Define o tempo de "timeout" de um bloqueio que a sess�o espera. 

Utilize um valor em milisegundos.

*/

Set lock_timeout 5000 -- Define um tempo de 5 segundos.

Set lock_timeout 0    -- N�o define tempo para bloqueio.

Set lock_timeout -1   -- Espera indefinidamente.

/*
Por padr�o, a conex�o espera indefinidamente pela libera��o do bloqueio.
A dica aqui � usar esse comando de forma pontual, onde existe processos com 
uma grande incid�ncia de bloqueios e que a regra de neg�cio 
permite interromper a transa��o.

Exemplo:
*/

----------------------------------------------------------
-- Conex�o 1 
use eBook
go

SELECT @@SPID

Select mCredito
  From tCADCliente
 Where iIDCliente = 1 

Begin Transaction

Update tCADCliente 
   set mCredito = 2
 Where iIDCliente = 1 

Select @@TRANCOUNT

Rollback

/*
Abrir um outra sess�o e copiar o c�digo abaixo 
*/
use eBook
go

Set lock_timeout 5000 -- Define um tempo de 5 segundos.

SELECT @@SPID
go

Update tCADCliente 
   set mCredito = 2
 Where iIDCliente = 1 


/*
Msg 1222, Level 16, State 56, Line 6
Lock request time out period exceeded.

Como ocorre uma mensagem de erro, a mesma deve ser tratada no c�digo.
*/

/*
Utilizando o SET LOCK_TIMEOUT 0 

Com essa configura��o, n�o existe "timeout" de bloqueio.
Assim que a conex�o identifica que um recurso est� bloqueado e ela n�o consegue
obter qualquer modo de bloqueio, ele emite imediatamente a mensagem 1222 

*/

----------------------------------------------------------
-- Conex�o 1 
use eBook
go

SELECT @@SPID

Select mCredito
  From tCADCliente
 Where iIDCliente = 1 

Begin Transaction

Update tCADCliente 
   set mCredito = 2
 Where iIDCliente = 1 

Select @@TRANCOUNT

Rollback

----------------------------------------------------------
-- Conex�o 2 
use eBook
go

Set lock_timeout 0 -- N�o tem TIMEOUT de bloqueio.

SELECT @@SPID
go

Select mCredito
  From tCADCliente
 Where iIDCliente = 1 


/*
SET DEADLOCK_PRIORITY 

Define a prioridade das conex�es durante a fase de resolu��o de um DEADLOCK.

Como vimos, quando ocorre um deadlock, o SQL Server escolhe a v�tima da 
transa��o que consumiu menos recursos, desde que as conex�es tenham a 
mesma prioridade na resolu��o do deadlock.

Quando alteramos a prioridade do deadlock, a conex�o que tem a prioridade 
maior que as outras N�O ser� eleita a vitima do deadlock, mesmo que ele 
tenha consumido poucos recursos.

A faixa de prioridade � de  -10 at� 10, sendo o 10 a maior prioridade e o -10 
a menor prioridade.

Valores 

NORMAL - que representa o valor 0 (zero) � o padr�o de prioridade.
HIGH   - representa o valor 5 e tem prioridade sobre as conex�es com valor -10 at� 4.
LOW    - tem o valor -5 e ser� eleita v�tima sobre as conex�es com valor -4 at� 10.

Voce tem a op��o de definir tamb�m um n�mero entre -10 at� 10.

Exemplos 
*/


-- Conex�o 01 - Temos tr�s instru��es e, pela defini��o ir� consumir mais recursos.
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

Set deadlock_priority HIGH 

Begin Transaction

Update tCADLivro  
   set nPaginas = 617
 where iIDLivro = 1

Update tCADCliente 
   Set mCredito  = 1
 Where iIDCliente = 1

Commit 


/*
https://docs.microsoft.com/pt-br/sql/t-sql/statements/set-deadlock-priority-transact-sql?view=sql-server-2017
https://www.dirceuresende.com/blog/sql-server-como-gerar-um-monitoramento-de-historico-de-deadlocks-para-analise-de-falhas-em-rotinas/
*/

