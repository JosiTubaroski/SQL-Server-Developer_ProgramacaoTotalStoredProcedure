/*

- Tabelas temporárias (por padrão chamada da Local) 
  são criadas pela instruções Create Table e 
  existem enquanto a conexão que a criou está ativa. 
  Voce pode usar DROP TABLE.

- Somente a conexão que criou a tabela tem acesso.

- Basicamente aceitam as implementações de uma tabela
  permanente, com algunas restrições como definição de 
  Chave Estrangeira.

- Toda tabela temporária são criadas no banco de dados 
  TempDB. 

- Aceita índices e são afetadas pelo comando ALTER TABLE. 

- Tem que ter o prefixo # no nome. 
*/

Use eBook
go


Create Table #tTMPPedidos2018
(
   iIDPedido int not null Primary Key,
   dPedido datetime not null ,
   mValor smallmoney not null check (mValor >= 0),
   nQtdItem smallint 
)
go

Select * from #tTMPPedidos2018

/*
Verificando no banco de dados TEMPDB 
*/

use tempdb
go
Select * from sys.tables

/*
Outra conexão não acessa essa tabelas 
*/

-- Outra Conexão 
use eBook
go
Select * from #tTMPPedidos2018


/*
Verificando se a tabela temporárias já existe
*/

Select OBJECT_ID('tempdb.dbo.#tTMPPedidos2018')
Select OBJECT_ID('tempdb.dbo.#tTMPPedidos2017')

If OBJECT_ID('tempdb.dbo.#tTMPPedidos2018') is not null
   raiserror('Tabela já existe',10,1)
Else 
   raiserror('Tabela não existe',10,1)



/*
Elas são afetadas pela processo de transação 

- Existe o tempo de processamento para preencher, confirmar 
  e registrar/reversão no log de transação, iguais as 
  tabelas convencionais. 

*/
use ebook
go

Begin transaction 
   insert into #tTMPPedidos2018 (iIDPedido,dPedido,mValor,nQtdItem)
   Select Pedido.iidPedido,dPedido, isnull(mValor,0), nQtdItem
     From tMOVPedido Pedido
    Cross Apply (Select sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                        COUNT(*) as nQtdItem  
                   From tMOVPedidoItem 
                  Where iIDPedido = Pedido.iIDPedido
                ) as Item 
    Where Pedido.dPedido >= '2018-01-01'

    Select COUNT(*) from #tTMPPedidos2018

Rollback 

Select COUNT(*) from #tTMPPedidos2018

Drop Table #tTMPPedidos2018


/*
Quando usar ?

Na minha opnião, você deve usar  :

- Primeiro, não conseguir resolver algo somente com os comandos DML.
- Quando você tem dados complexo para manipular com Update e Delete.
- A quantidade de linhas é muito grande e necessidade de índices.
- Preservar e garantir consistência durante uma transação. 

Exemplo:

*/

Create Table #tTMPPedidoMensal2018 
(
   cNome varchar(50),
   nNumero int , 
   dPedido datetime,
   mValor money,
   nQtdItem int ,
   dPagamento datetime,
   cMeio varchar(20),
   mBaseICMS smallmoney,
   mValorICMS smallmoney,
   nPacote tinyint 
)

Insert into #tTMPPedidoMensal2018
      Select Cliente.cNome,
             Pedido.nNumero,
             Pedido.dPedido, 
             isnull(Item.mValor-Pedido.mDesconto,0) as mValor, 
             Item.nQtdItem, 
             Pagto.dPagamento ,
             Pagto.cMeio  , 
             NF.mBaseICMS , 
             NF.mValorICMS , 
             NF.nPacote 
        From tMOVPedido Pedido
        Join tMOVPagamento as Pagto 
          on Pedido.iidPedido = Pagto.iIDPedido
        Join tMOVNotaFiscal as NF
          on Pedido.iIDPedido = NF.iIDPedido
        Join tCADCliente Cliente 
          on Pedido.iIDCliente = Cliente.iIDCliente
        Join (Select iIDPedido ,
                     Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                     Count(*) as nQtdItem  
                From tMOVPedidoItem 
               Group by iIDPedido
             ) as Item 
          on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dPedido >= '2018-01-01'
      and Pedido.dCancelado is null

Select datename(month,dPedido) as cMes ,
       cMeio,
       Sum(mValor) as mValor ,
       Sum(mValorICMS ) as mValorICMS
  From #tTMPPedidoMensal2018
  Group by datename(month,dPedido), 
           cMeio ,
           MONTH(dPedido)
  Order by MONTH(dPedido)

drop table #tTMPPedidoMensal2018


/*
Podemos substituir utilizando uma Commom Table Expression - CTE  :
*/

With ctePedidoMensal2018 as (
      Select Cliente.cNome,
             Pedido.nNumero,
             Pedido.dPedido, 
             isnull(Item.mValor-Pedido.mDesconto,0) as mValor, 
             Item.nQtdItem, 
             Pagto.dPagamento ,
             Pagto.cMeio  , 
             NF.mBaseICMS , 
             NF.mValorICMS , 
             NF.nPacote 
        From tMOVPedido Pedido
        Join tMOVPagamento as Pagto 
          on Pedido.iidPedido = Pagto.iIDPedido
        Join tMOVNotaFiscal as NF
          on Pedido.iIDPedido = NF.iIDPedido
        Join tCADCliente Cliente 
          on Pedido.iIDCliente = Cliente.iIDCliente
        Join (Select iIDPedido ,
                     Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                     Count(*) as nQtdItem  
                From tMOVPedidoItem 
               Group by iIDPedido
             ) as Item 
          on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dPedido >= '2018-01-01'
      and Pedido.dCancelado is null
)
Select datename(month,dPedido) as cMes ,
       cMeio,
       Sum(mValor) as mValor ,
       Sum(mValorICMS ) as mValorICMS
  From ctePedidoMensal2018
  Group by datename(month,dPedido), 
           cMeio ,
           MONTH(dPedido)
  Order by MONTH(dPedido)

/*
*/