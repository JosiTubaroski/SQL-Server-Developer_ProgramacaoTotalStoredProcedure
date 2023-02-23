use eBook
go

/*
Compila��o 
*/
https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/recompile-a-stored-procedure?view=sql-server-2017


/*
Quando submetemos uma instru��o t-SQL para o servidor executar, enviamos um 
conjunto de instru��es onde pedimos quais as informa��es que queremos obter. 
Exemplo:
*/

Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome
  From tCADCliente as Cliente
  Join tMOVPedido as Pedido
    On Cliente.iIDCliente = Pedido.iIDCliente  
 Where Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
Order by Pedido.nNumero
go

/*
N�o citamos por exemplo, para ele pesquisar as data de pedido no 
�ndice idxDataPedido da tabela tMOVPedido. Ou mesmo pesquisar primeiro 
na tabela tCADCliente, encontrar os dados e depois pesquisar 
na tabela tMOVPedido.
*/

/*
Esse papel de escolher a melhor forma de como extrair os dados � feito
por um componentes (entre v�rios que tem o SQL SERVER) que � o Query Processor
ou o Processador de Consulta. Como ele funciona:
























*/


/*
Etapas de execu��o do Processador de Query

PARSE
ALGEBRIZER
OPTIMIZATION
EXECUTION 

*/


/*
Vamos executar a instru��o abaixo para entender a defini��o de Otimiza��o de Query. 
*/

With cteItensPedido as (
   Select iidPedido , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValor - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADCliente as Cliente
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null 
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
go


/*
Provocar dois tipos de erros na instru��o acima. 

1. Sintaxe errada.
2. Objetos do banco de dados utilizado de forma errada.

No exemplo abaixo, temos 2 erros de sintaxe e 
3 erros de nome de objetos utilizados de forma errada.

*/

With cteItensPedido as (
   Select iIDPedidoItem , 
          Count(*) as nQtdItens,,
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValorx - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADClientes as Cliente            --< Tabela de Cliente (tCADCliente) com nome errado. 
    on iIDCliente = iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
 Where Cliente.dExclusao is null  --< Instru��o WHERE duplicada
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
go


/*
A sintaxe foi avaliada como um todo. Isso quer dizer 
que toda a instru��o foi avaliada e os erros encontrados 
foram apresentados no formato de mensagem de erro do SQL SERVER.

Primero erro :

Msg 102, Level 15, State 1, Line 57
Incorrect syntax near ','.

Segundo erro:

Msg 156, Level 15, State 1, Line 74
Incorrect syntax near the keyword 'Where'.

Essa avali��o determina se a instru��o SELECT foi escrita corretamente. 

Corrigindo o os erros, temos o c�digo abaixo:

** Desativar o Intellisense 

*/



With cteItensPedido as (
   Select iIDPedidoItem , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValorx - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADClientes as Cliente            
    on iIDCliente = iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null  
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
go

/*
O pr�ximo erro apresentado.

Msg 8120, Level 16, State 1, Line 171
Column 'tMOVPedidoItem.iIDPedidoItem' is invalid in the select list because it is not 
contained in either an aggregate function or the GROUP BY clause.

Corrigido o erro acima e executando a query novamente,

Msg 208, Level 16, State 1, Line 86
Invalid object name 'tCADClientes'.

Corrigido o erro acima e executando a query novamente,

Msg 209, Level 16, State 1, Line 185
Ambiguous column name 'iIDCliente'.

Msg 209, Level 16, State 1, Line 185
Ambiguous column name 'iIDCliente'.

Msg 207, Level 16, State 1, Line 111
Invalid column name 'mValorx'.

Essa avalia��o determina se todos os objetos referenciados no SELECT
existem no banco de dados ou est�o montados corretamente. 

*/

With cteItensPedido as (
   Select iIDPedidoItem , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValorx - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADClientes as Cliente            --< Tabela de Cliente (tCADCliente) com nome errado. 
    on iIDCliente = iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null  
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
go




/*
At� aqui, conhecemos as duas primeiras fases da otimiza��o da query que 
o SQL Server aplica ao executaremos uma instru��o SELECT.

PARSE       - Que avalia a sintaxe da instru��o.
ALGEBRIZER  - Que identifica a exist�ncias do objetos da instru��o, a forma como os objetos
              est�o montados, 
            

*/

/*
Ap�s essa fase, o SQL SERVER tem certeza que a instru��o est� correta e 
pronto para executar a pr�ximo fase conhecida como Otimizador.
*/

/*
Para simular o otimizador, vamos aplicar a instru��o SET SHOWPLAN_XML ON 
para mostrar o Plano de Execu��o. 

obs.: Essa instru��o mostra o plano de execu��o, sem retornar os dados da query.
      Ele deve ser executada fora do lote de execu��o da instru��o. 
      Lembre-se sempre de desligar o uso da instru��o.
*/

set showplan_xml on 
go

With cteItensPedido as (
   Select iidPedido , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValor - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADCliente as Cliente
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null 
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
go
set showplan_xml off
go


/*
Otimizador simula diveras formas de acesso ao dados com base em:

1. Quantidade de recursos disponiveis como CPU, Mem�ria;
2. Estimativa de linhas que a consulta pode afetar;
3. Hints utilizadas na consultas para mudar o comportamento da execu��o;
4. Par�metros de configura��es como usar ou n�o paralelismo;
5. Informa��es sobre os �ndices dispon�veis em cada tabela ou vis�o;
6. Se tabelas est�o particionadas, local dentro de grupos de arquivos

Com isso, o SQL Server obtem o melhor e mais barato Plano de Execu��o
(Execution Plan) da consulta que � colocando no cache de plano (Plan Cache) 
onde ele pode ser aproveitado para a outro consulta id�ntica. 
*/


/*
Uma vez encontrado a melhor forma de executar uma instru��o (Real Plan), 
o otimizado de query passa para o mecanismo de armazenamento (Store Engine)
executar a fase de Execu��o. 
*/

use eBook
go

With cteItensPedido_02 as (
   Select iidPedido , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido -- AAAAAAA
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValor - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido_02 as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADCliente as Cliente
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null 
   and Pedido.dPedido >= '2018-01-10'
   and Pedido.dPedido <= '2018-01-10 23:59:59'
GO
/*

*/

Select sql_text.text, 
       plans.creation_time, 
       plans.last_execution_time ,
       plans.execution_count  ,
       query_plan.query_plan  
  From sys.dm_exec_query_stats plans
 Cross Apply sys.dm_exec_query_plan(plans.plan_handle) as query_plan 
 Cross Apply sys.dm_exec_sql_text(plans.plan_handle) as sql_text 
 Where sql_text.text like '%cteItensPedido%'




With cteItensPedido_01 as (
   Select iidPedido , 
          Count(*) as nQtdItens, 
          Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
     From tMOVPedidoItem
     Group by iIDPedido
)
Select Pedido.nNumero, Pedido.dPedido,
       Cliente.cNome,
       ItensPedido.nQtdItens,
       ItensPedido.mValor - Pedido.mDesconto as mValor 
  From tMOVPedido as Pedido
  Join cteItensPedido_01 as ItensPedido 
    on ItensPedido.iIDPedido = Pedido.iIDPedido
  Join tCADCliente as Cliente
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join tCADEndereco as Endereco
    on Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.dExclusao is null 
   and Pedido.dPedido >= '2017-01-10'
   and Pedido.dPedido <= '2017-01-10 23:59:59'
go
go 10


Select sql_text.text, 
       plans.creation_time, 
       plans.last_execution_time ,
       plans.execution_count  ,
       query_plan.query_plan  
  From sys.dm_exec_query_stats plans
 Cross Apply sys.dm_exec_query_plan(plans.plan_handle) as query_plan 
 Cross Apply sys.dm_exec_sql_text(plans.plan_handle) as sql_text 
 Where sql_text.text like '%cteItensPedido%'


/*
Mas como ocorre essas fases para um STORE PROCEDURE? 

Diferente de uma instru��o SELECT que voc� envia para o servidor 
SQL Server executar, a procedure voce primeiro cria ela no servidor
para depois executar. 

A forma como o SQL Server trata as fases de PARSE, ALGEBRIZER, OPTIMIZATION e EXECUTION 
e um pouco diferente da execu��o da instru��o. 

Na fase de cria��o, o SQL Server executa a fase do PARSE 

*/
use eBook
go

Create or Alter Procedure stp_ConsultaPedido 
@dInicial datetime = null,
@dFinal datetime = null 
as
Begin

   Declare @nRetorno int = 0;
   
   With cteItensPedido as (
      Select iidPedido, 
             Count(*) as nQtdItens, ,
             Sum((nQuantidade*mValorUnitario)-mDesconto) as mValor   
        From tMOVPedidoItem
       Group by iIDPedido
   )
   Select Pedido.nNumero, Pedido.dPedido,
          Cliente.cNome,
          ItensPedido.nQtdItens,
          ItensPedido.mValor - Pedido.mDesconto as mValor 
     From tMOVPedido as Pedido
     Join cteItensPedido as ItensPedido 
       on ItensPedido.iIDPedido = Pedido.iIDPedido
     Join tCADCliente as Cliente                   
       on Pedido.iIDCliente = Cliente.iIDCliente
     Join tCADEndereco as Endereco
       on Cliente.iIDCliente = Endereco.iIDCliente 
    Where Endereco.iIDTipoEndereco = 1
    Where Cliente.dExclusao is null 
      and Pedido.dPedido >= @dInicial 
      and Pedido.dPedido <= @dFinal
   
   Return @nRetorno  

End 
go
/*
*/


/*
Erros com os nomes do objetos 
*/

use eBook
go

Create or Alter Procedure stp_ConsultaPedido 
@dInicial datetime = null,
@dFinal datetime = null 
as
Begin

   Declare @nRetorno int = 0;
   
   With cteItensPedido as (
      Select iIDPedido ,
             Count(*) as nQtdItens, 
             Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor   
        From tMOVPedidoItem
       Group by iIDPedido
   )
   Select Pedido.nNumero, Pedido.dPedido,
          Cliente.cNome,
          ItensPedido.nQtdItens,
          ItensPedido.mValor - Pedido.mDesconto as mValor 
     From tMOVPedido as Pedido
     Join cteItensPedido as ItensPedido 
       on ItensPedido.iIDPedido = Pedido.iIDPedido
     Join tCADCliente as Cliente                   
       on Cliente.iIDCliente = Pedido.iIDCliente
     Join tCADEndereco as Endereco
       on Cliente.iIDCliente = Endereco.iIDCliente 
    Where Endereco.iIDTipoEndereco = 1
      and Cliente.dExclusao is null 
      and Pedido.dPedido >= @dInicial 
      and Pedido.dPedido <= @dFinal
   
   Return @nRetorno  

End 
go


/*
Msg 8120, Level 16, State 1, Procedure stp_ConsultaPedido, Line 10 [Batch Start Line 469]
Column 'tMOVPedidoItem.iIDPedidoItem' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

Msg 209, Level 16, State 1, Procedure stp_ConsultaPedido, Line 24 [Batch Start Line 469]
Ambiguous column name 'iIDCliente'.

Msg 209, Level 16, State 1, Procedure stp_ConsultaPedido, Line 24 [Batch Start Line 469]
Ambiguous column name 'iIDCliente'.

Msg 207, Level 16, State 1, Procedure stp_ConsultaPedido, Line 19 [Batch Start Line 469]
Invalid column name 'mValorx'.

*/

execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2018-01-10 23:59:59'



/*
*/

use eBook
go

Create or Alter Procedure stp_ConsultaPedido 
@dInicial datetime = null,
@dFinal datetime = null 
as
Begin

   Declare @nRetorno int = 0;
   
   With cteItensPedido as (
      Select iIDPedido ,
             Count(*) as nQtdItens, 
             Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor   
        From tMOVPedidoItem
       Group by iIDPedido
   )
   Select Pedido.nNumero, Pedido.dPedido,
          Cliente.cNome,
          ItensPedido.nQtdItens,
          ItensPedido.mValor - Pedido.mDesconto as mValor 
     From tMOVPedido as Pedido
     Join cteItensPedido as ItensPedido 
       on ItensPedido.iIDPedido = Pedido.iIDPedido
     Join tCADCliente as Cliente                   
       on Cliente.iIDCliente = Pedido.iIDCliente
     Join tCADEndereco as Endereco
       on Cliente.iIDCliente = Endereco.iIDCliente 
    Where Endereco.iIDTipoEndereco = 1
      and Cliente.dExclusao is null 
      and Pedido.dPedido >= @dInicial 
      and Pedido.dPedido <= @dFinal
   
   Return @nRetorno  

End 
go


execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2018-01-10 23:59:59'


/*
https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms190686(v=sql.105)
10/03/2012 - Rereferente ao SQL SERVER 2008.



*/
go


/*
Agora a fase do gerar o plano de execu��o.
*/

use eBook
go

set showplan_xml on 
go
execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2018-01-10 23:59:59' 
go
set showplan_xml off
go


execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2018-01-10 23:59:59' 


Select sql_text.text ,
       procstats.cached_time, 
       last_execution_time, 
       execution_count, 
       query_plan.query_plan
From sys.dm_exec_procedure_stats procstats
CROSS APPLY sys.dm_exec_query_plan(procstats.plan_handle) as query_plan 
CROSS APPLY sys.dm_exec_sql_text(procstats.plan_handle) as sql_text 
Where object_id = object_id('stp_ConsultaPedido')


select * from sys.dm_os_host_info
select cpu_count , physical_memory_kb from sys.dm_os_sys_info


/*
Trocando valores na passagem de parametros 
*/



execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2018-01-10 23:59:59'
go
execute stp_ConsultaPedido @dInicial = '2018-01-10' , 
                           @dFinal = '2019-01-10 23:59:59'
go

Select sql_text.text ,
       procstats.cached_time, 
       last_execution_time, 
       execution_count, 
       query_plan.query_plan
From sys.dm_exec_procedure_stats procstats
CROSS APPLY sys.dm_exec_query_plan(procstats.plan_handle) as query_plan 
CROSS APPLY sys.dm_exec_sql_text(procstats.plan_handle) as sql_text 
Where object_id = object_id('stp_ConsultaPedido')




Create or Alter Procedure stp_ConsultaPedido 
@dInicial datetime = null,
@dFinal datetime = null 
as
Begin

   Declare @nRetorno int = 0;

   declare @dI datetime = @dInicial
   declare @dF datetime = @dFinal ;
      
   With cteItensPedido as (
      Select iidpedido ,--,iIDPedidoItem ,
             Count(*) as nQtdItens, 
             Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor   
        From tMOVPedidoItem
       Group by iIDPedido
   )
   Select Pedido.nNumero, Pedido.dPedido,
          Cliente.cNome,
          ItensPedido.nQtdItens,
          ItensPedido.mValor - Pedido.mDesconto as mValor 
     From tMOVPedido as Pedido
     Join cteItensPedido as ItensPedido 
       on ItensPedido.iIDPedido = Pedido.iIDPedido
     Join tCADCliente as Cliente                   
       on Pedido.iIDCliente = Cliente.iIDCliente
     Join tCADEndereco as Endereco
       on Cliente.iIDCliente = Endereco.iIDCliente 
    Where Endereco.iIDTipoEndereco = 1
      and Cliente.dExclusao is null 
      and Pedido.dPedido >= @dI -- @dInicial 
      and Pedido.dPedido <= @dF -- @dFinal
      --and Pedido.dPedido >= @dInicial 
      --and Pedido.dPedido <= @dFinal
   
   Return @nRetorno  

End 


/*
Fim da Store Procedure !!!!
*/



