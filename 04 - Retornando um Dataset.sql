https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/return-data-from-a-stored-procedure?view=sql-server-2017

/*
A store procedure pode ser utlizada para retornar
um conjunto de dados no formato de um dataset.

Voce utiliza esse recurso para retornar um conjunto de dados:

1. Para popular tabelas com dados definitivos ou temporários.
2. Para enviar dados para interface de uma aplicação. Grid ou saída HTML.
3. Para compor um relátorio.
4. Ou até mesmo integração com Excel.

Basta a execução de uma instrução SELECT, de preferência no 
final da procedure. 

*/

execute sp_configure
go

/*
*/
use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_MovimentoDoDia
Objetivo   : Apresenta a movimentação de pedidos
------------------------------------------------------------*/
Create or Alter Procedure stp_MovimentoDoDia
as
Begin
   
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
      and Pedido.dPedido between '2010-07-05' and '2010-07-06'
    Group by Cliente.cNome,       
             Pedido.nNumero,
             Pedido.dPedido 

End 
/*
Fim da Procedure stp_MovimentoDoDia
*/
go

execute stp_MovimentoDoDia
go



/*
Dos exemplos citados acima, vou demonstrar o uso com tabelas e 
depois como utilizar o EXCEL par executar uma procedure. 


Capturando os dados pelo SQL SERVER 

- A captura será feita gravando os dados direto em uma tabela.
- Real
- Temporária
- Variável de tabela 
*/

/*
01. Tabela Real 
*/

drop table if exists tTMPMovimentoDoDia
go


Create Table tTMPMovimentoDoDia 
(
   cCliente       varchar(50) not null,
   nNumeroPedido  int not null,
   dDataPedido    date not null,
   mValorPedido   smallmoney not null,
   nQtdItem       int not null 
)
go

Insert into tTMPMovimentoDoDia execute stp_MovimentoDoDia
go

Select * from tTMPMovimentoDoDia


/*
02. Table Temporária 
*/
Create Table #tTMPMovimentoDoDia 
(
   cCliente       varchar(50) not null,
   nNumeroPedido  int not null,
   dDataPedido    date not null,
   mValorPedido   smallmoney not null,
   nQtdItem       int not null 
)
go

Insert into #tTMPMovimentoDoDia execute stp_MovimentoDoDia
go

Select * from #tTMPMovimentoDoDia


/*
03. Variável Table 
*/
Declare @TMPMovimentoDoDia Table (
   cCliente       varchar(50) not null,
   nNumeroPedido  int not null,
   dDataPedido    date not null,
   mValorPedido   smallmoney not null,
   nQtdItem       int not null 
)

Insert into @TMPMovimentoDoDia execute stp_MovimentoDoDia


Select * from @TMPMovimentoDoDia



/*

Como utilizar no Excel 


*/

use eBook
go
execute stp_MovimentoDoDia