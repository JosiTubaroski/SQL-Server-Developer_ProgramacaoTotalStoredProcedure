https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-2017

/*
Stored Procedure ou procedimentos armazenados, são objetos de programação com
comandos T-SQL armazenados no banco de dados com um nome.

Elas aceitam parâmetros no momento da execução.
Podem retornar um status ou um conjunto de valores.

A execução desse procedimentos armazenado pode ser feito por 
uma chamada direta do nome do procedimento pela aplicação ou por
uma ferramente de edição de query pelo comando EXECUTE.
*/

use eBook
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaEstoque
Objetivo   : Atualiza o Saldo de Estoque do Livro. 
------------------------------------------------------------*/
Create or Alter Procedure stp_AtualizaEstoque
@iidLivro int ,    -- Identificação do Livro 
@iidLoja int ,
@nQuantidade int 
as 
Begin
   
   Set Nocount on 

   Begin Try 
      
      Update tRELEstoque 
         Set nQuantidade -= @nQuantidade ,
             dUltimoConsumo = GETDATE()
       Where iIDLivro = @iidLivro
         and iIDLoja = @iidLoja 
      
      If @@rowcount = 0
         raiserror('Não existe Livro e/ou Loja para atualizar.',16,1) 

    End Try

    Begin Catch

       Declare @cMensagem varchar(200)  = error_message()
       Insert into tLOGEventos (cMensagem) values (@cMensagem) 
       Return -1 

    End Catch
End  
Return 0
/*
Fim da Procedure 
*/

Declare @nSaida int  = 0 
Execute @nSaida = stp_AtualizaEstoque 106,9,35
print  @nSaida


/*
-----------------------------
https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-2017#benefits-of-using-stored-procedures

*/

-- Redução no tráfego de Rede 
-- Segurança mais forte
-- Código reutilizado
-- Fácil Manutenção 
-- Melhora o desempenho 


/*
Tipos de Procedimentos. 

-- Definido pelo Usuário.
-- Sistema
-- Temporário.
*/



/*
1. Redução do trafego de Rede.
*/

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
go 100

stp_MovimentoDoDia
go 100


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
go


/*
2. Segurança mais forte
*/

-- Neste exemplo, vamos criar uma conta com permissões
-- somente para executar a SP.

use master
go
Create Login lgnJoao 
  With password='123456', 
  Default_database=eBook, 
  Check_expiration=off, 
  Check_policy=off
go

use eBook
go

Create User usrJoao for login lgnJoao 
go
Alter user usrJoao with default_schema=dbo 
go
Grant Execute on stp_MovimentoDoDia to usrJoao
go

/*
Em uma outra sessão, efetuar a autenticação com o login lgnJoao
*/
use eBook
go

execute stp_MovimentoDoDia
go

sp_helptext stp_MovimentoDoDia
go

select * from sys.sql_modules
where object_id = object_id('stp_MovimentoDoDia')

go

select * from tMOVPedido


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


