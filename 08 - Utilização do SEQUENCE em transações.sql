/*
SEQUENCE com transações. 

A numeração gerada pelo SEQUENCE é utilizada em um processo de transação, 
independente se a transação foi confirmada ou revertida. 

Isso significa que uma ver utilizado o NEXT VALUE FOR para obter o
próximo número, ele já foi recuperado mesmo que você não utiliza ele.

Diferente do IDENTITY(), que em um processo de transação revertido, o 
número não é perdido.


*/
use eBook
go

Select top 2 * 
  From tMOVPedido 
 Order by iIDPedido desc 

Select current_value 
  From sys.sequences
 Where name = 'seqIDPedido'

/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go

set nocount on 

Declare @iidCliente int = 8834	-- Código do Cliente que comprará o livro
Declare @iidLivro int = 106		-- Código do Livro que será comprado
Declare @iidLoja int = 9		-- Código da loja onde a compra foi feita 
Declare @nQuantidade int = 1	-- Quantidade de livros. 
Declare @iIDPedido int			-- Código do Pedido 
Declare @mValor smallmoney		-- Valor do Livro

Declare @nNumeroError int 

Begin 

   -- Recupera qual o valor do livro de uma determinada loja.
   Select @mValor = mValor 
	 From tRELEstoque 
	Where iIDLivro = @iidLivro 
	  and iIDLoja = @iidLoja 
    
   Raiserror('Incluindo Pedido...',10,1) with nowait; 
   
   Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.

   print 'Numero do pedido'
   print @iIDPedido 

   Begin Transaction 

   -- Inseri o cabeçalho do Pedido.
   Insert Into dbo.tMOVPedido           
   (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
   Values
   (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)
   
   Set @nNumeroError = @@ERROR
   
   raiserror('Incluindo Item de Pedido...',10,1) with nowait 
   
   -- Inseri o Item do Pedido
   Insert Into tMOVPedidoItem
   (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
   Values
   (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)
   
   Set @nNumeroError = @@ERROR

   raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
   -- Atualiza o saldo do estoque do livro para a loja
   Update tRELEstoque 
      Set nQuantidade = nQuantidade - @nQuantidade 
    Where iIDLivro = @iidLivro 
      and iIDLoja = @iidLoja 

   Set @nNumeroError = @@ERROR

   Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 
   -- Atualiza o crédito do cliente. 
   Update tCADCliente 
      Set mCredito = mCredito*0 - @mValor --< Simulando um erro!!!
    Where iIDCliente = @iidCliente
	
   Set @nNumeroError = @@ERROR

   If @@TRANCOUNT > 0 -- Primeiro teste, tem transação aberta? 
	  If @nNumeroError = 0 Begin -- Ocorreu um erro? Não, então confirma.
	     Commit 
		 Raiserror('Confirmando a transação.',10,1) 
	  End 
	  Else Begin -- Sim, então desfaz!!!
	     Rollback 
		  Raiserror('Desfazendo a transação. Código do erro gerado %d',10,1,@nNumeroError) 
	  end 

End 
/*
Finaliza a Operacação.
*/