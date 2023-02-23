/*

Existem opções para voce configurar o comportamento do
bloqueio e do deadlocks.

SET LOCK_TIMEOUT 

Define o tempo de "timeout" de um bloqueio que a sessão espera. 

Utilize um valor em milisegundos.

*/

Set lock_timeout 5000 -- Define um tempo de 5 segundos.

Set lock_timeout 0    -- Não define tempo para bloqueio.

Set lock_timeout -1   -- Espera indefinidamente.

/*
Por padrão, a conexão espera indefinidamente pela liberação do bloqueio.
A dica aqui é usar esse comando de forma pontual, onde existe processos com 
uma grande incidência de bloqueios e que a regra de negócio 
permite interromper a transação.

Exemplo:
*/

----------------------------------------------------------
-- Conexão 1 
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
Abrir um outra sessão e copiar o código abaixo 
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

Como ocorre uma mensagem de erro, a mesma deve ser tratada no código.
*/

/*
Utilizando o SET LOCK_TIMEOUT 0 

Com essa configuração, não existe "timeout" de bloqueio.
Assim que a conexão identifica que um recurso está bloqueado e ela não consegue
obter qualquer modo de bloqueio, ele emite imediatamente a mensagem 1222 

*/

----------------------------------------------------------
-- Conexão 1 
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
-- Conexão 2 
use eBook
go

Set lock_timeout 0 -- Não tem TIMEOUT de bloqueio.

SELECT @@SPID
go

Select mCredito
  From tCADCliente
 Where iIDCliente = 1 


/*
SET DEADLOCK_PRIORITY 

Define a prioridade das conexões durante a fase de resolução de um DEADLOCK.

Como vimos, quando ocorre um deadlock, o SQL Server escolhe a vítima da 
transação que consumiu menos recursos, desde que as conexões tenham a 
mesma prioridade na resolução do deadlock.

Quando alteramos a prioridade do deadlock, a conexão que tem a prioridade 
maior que as outras NÃO será eleita a vitima do deadlock, mesmo que ele 
tenha consumido poucos recursos.

A faixa de prioridade é de  -10 até 10, sendo o 10 a maior prioridade e o -10 
a menor prioridade.

Valores 

NORMAL - que representa o valor 0 (zero) é o padrão de prioridade.
HIGH   - representa o valor 5 e tem prioridade sobre as conexões com valor -10 até 4.
LOW    - tem o valor -5 e será eleita vítima sobre as conexões com valor -4 até 10.

Voce tem a opção de definir também um número entre -10 até 10.

Exemplos 
*/


-- Conexão 01 - Temos três instruções e, pela definição irá consumir mais recursos.
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

