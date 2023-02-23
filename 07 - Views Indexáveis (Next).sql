/*
Visão Indexada é uma visão que tem um índice clusterizado 
e índices não clusterizados.

Obs.: Antes, se você precisa de uma explicação sobre índice, então voce pode
assistir a aula "O que é um índice no SQL SERVER" na seção Aulas Complementares.

*/
use eBook
go


/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vVendasPorCliente
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
------------------------------------------------------------*/
Create or Alter View vVendasPorCliente
With SchemaBinding 
as 
Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
       Count(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 Group by Cliente.cNome,       
          Pedido.nNumero,
          Cast(Pedido.dPedido as date)

go
/*
Fim da view vVendasPorCliente
*/
go

set statistics io on 
go

Select * 
  From vVendasPorCliente 
 Where nNumeroPedido = 1777709
 

/*
Configuração da conexão antes de criar a view indexada.
*/
set numeric_roundabort off  
set ansi_padding on   
set ansi_warnings on   
set concat_null_yields_null on   
set arithabort on   
set quoted_identifier on  
set ansi_nulls on  

/*
*/
drop view if exists vVendasPorCliente
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vVendasPorCliente
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
------------------------------------------------------------*/
Create or Alter View vVendasPorCliente
With SchemaBinding 
as 
Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
       Count(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 Group by Cliente.cNome,       
          Pedido.nNumero,
          Cast(Pedido.dPedido as date)

go
/*
Fim da view vVendasPorCliente
*/
go

/*
Agora devemos criar o primeiro indices que deve ser clusterizado e 
único
*/
Create Unique Clustered 
Index idcPedidoMes on vVendasPorCliente (nNumeroPedido,cCliente)
go
/*
Msg 10125, Level 16, State 1, Line 61
Cannot create index on view "eBook.dbo.vVendasPorCliente" because it uses 
aggregate "MAX". Consider eliminating the aggregate, not 
indexing the view, or using alternate aggregates. 
For example, for AVG substitute SUM and COUNT_BIG, or for COUNT, 
substitute COUNT_BIG.

-- Não pode conter a função MAX()
*/


/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vVendasPorCliente
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
------------------------------------------------------------*/
Create or Alter View vVendasPorCliente
With SchemaBinding 
as 
Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto) as mValorPedido ,
       Count(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 Group by Cliente.cNome,       
          Pedido.nNumero,
          Cast(Pedido.dPedido as date)

go
/*
Fim da view vVendasPorCliente
*/
go


Create Unique Clustered 
Index idcPedidoMes on vVendasPorCliente (nNumeroPedido,cCliente)
go

/*
Msg 10136, Level 16, State 1, Line 100
Cannot create index on view "eBook.dbo.vVendasPorCliente" because it uses the 
aggregate COUNT. Use COUNT_BIG instead.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vVendasPorCliente
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
------------------------------------------------------------*/
Create or Alter View vVendasPorCliente
With SchemaBinding 
as 
Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto) as mValorPedido ,
       Count_big(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 Group by Pedido.nNumero,
          Cliente.cNome,       
          Cast(Pedido.dPedido as date)

go
/*
Fim da view vVendasPorCliente
*/
go


Create Unique Clustered Index idcPedidoMes on vVendasPorCliente (nNumeroPedido,cCliente)
/*
*/

Select * 
  From vVendasPorCliente 
 Where nNumeroPedido = 1777709






/*
*/
Select Cliente.cNome,
       Pedido.nNumero,
       Cast(Pedido.dPedido as date) as dPedido, 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto) as mValor ,
       Count_big(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 and nNumero = 1777709
 Group by Pedido.nNumero,
          Cliente.cNome,       
          Cast(Pedido.dPedido as date) 


Select * from tMOVPedido where nNumero = 587885




















