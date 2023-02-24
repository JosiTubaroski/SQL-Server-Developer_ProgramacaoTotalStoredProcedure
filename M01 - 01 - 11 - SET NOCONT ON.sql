/*
Desativar o SET NOCOUNT ON 

- Quando executamos uma instrução INSERT, UPDATE, DELETE, MERGE ou um procedimento 
  armazenado, as vezes recebemos a mensagem:

  (XX rows affected)

  que indica o total de linhas processadas pelos comandos.

*/

use eBook go
select * from tCADCliente where dAniversario <= '1940-01-01'


/*
- Toda a execução de comandos que afetam um determinado número de linhas de uma tabela,
  sempre retornam para a sessão ativa ( ou para a conexão da aplicação) o total dessas linhas.

- Voce deve utilizar o SET NOCOUNT ON na fase de programação para evitar esse trânsito de dados
  na rede e, de alguma forma, reduzir o tempo de processamento das instruções. 

- De acordo com site da Microsoft. 
  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/statements/set-nocount-transact-sql?view=sql-server-2017

  "SET NOCOUNT ON evita o envio de mensagens DONE_IN_PROC ao cliente para cada instrução em 
   um procedimento armazenado. Para procedimentos armazenados que contêm várias instruções 
   que não retornam muitos dados reais, ou para procedimentos que contêm loops Transact-SQL, 
   configurar SET NOCOUNT como ON pode fornecer um aumento significativo no desempenho, 
   porque o tráfego de rede é reduzido consideravelmente."

*/


/*
Configurando o SET NOCOUNT ON na conexão atual, essa configuração somente tera efeito somente 
nos comandos dessa conexão. 

*/
use eBook
go

set nocount off 

update tCADCliente set mCredito = mCredito + 10 where dAniversario <= '1950-01-01'
update tCADCliente set mCredito = mCredito - 10 where dAniversario <= '1950-01-01'
update tMOVPedido set mDesconto = mDesconto +10 where dPedido >= '2018-09-01'
update tMOVPedido set mDesconto = mDesconto -10 where dPedido >= '2018-09-01'

go 100

set nocount on 

update tCADCliente set mCredito = mCredito + 10 where dAniversario <= '1950-01-01'
update tCADCliente set mCredito = mCredito - 10 where dAniversario <= '1950-01-01'
update tMOVPedido set mDesconto = mDesconto +10 where dPedido >= '2018-09-01'
update tMOVPedido set mDesconto = mDesconto -10 where dPedido >= '2018-09-01'

go 100

/*
Dicas: 
Utilizar SET NOCOUNT ON nos objetos de programação.
*/
