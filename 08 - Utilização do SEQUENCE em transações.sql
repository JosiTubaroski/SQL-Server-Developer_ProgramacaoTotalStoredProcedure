/*
SEQUENCE com transa��es. 

A numera��o gerada pelo SEQUENCE � utilizada em um processo de transa��o, 
independente se a transa��o foi confirmada ou revertida. 

Isso significa que uma ver utilizado o NEXT VALUE FOR para obter o
pr�ximo n�mero, ele j� foi recuperado mesmo que voc� n�o utiliza ele.

Diferente do IDENTITY(), que em um processo de transa��o revertido, o 
n�mero n�o � perdido.


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
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 
*/

use eBook
go

set nocount on 

Declare @iidCliente int = 8834	-- C�digo do Cliente que comprar� o livro
Declare @iidLivro int = 106		-- C�digo do Livro que ser� comprado
Declare @iidLoja int = 9		-- C�digo da loja onde a compra foi feita 
Declare @nQuantidade int = 1	-- Quantidade de livros. 
Declare @iIDPedido int			-- C�digo do Pedido 
Declare @mValor smallmoney		-- Valor do Livro

Declare @nNumeroError int 

Begin 

   -- Recupera qual o valor do livro de uma determinada loja.
   Select @mValor = mValor 
	 From tRELEstoque 
	Where iIDLivro = @iidLivro 
	  and iIDLoja = @iidLoja 
    
   Raiserror('Incluindo Pedido...',10,1) with nowait; 
   
   Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.

   print 'Numero do pedido'
   print @iIDPedido 

   Begin Transaction 

   -- Inseri o cabe�alho do Pedido.
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

   Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 
   -- Atualiza o cr�dito do cliente. 
   Update tCADCliente 
      Set mCredito = mCredito*0 - @mValor --< Simulando um erro!!!
    Where iIDCliente = @iidCliente
	
   Set @nNumeroError = @@ERROR

   If @@TRANCOUNT > 0 -- Primeiro teste, tem transa��o aberta? 
	  If @nNumeroError = 0 Begin -- Ocorreu um erro? N�o, ent�o confirma.
	     Commit 
		 Raiserror('Confirmando a transa��o.',10,1) 
	  End 
	  Else Begin -- Sim, ent�o desfaz!!!
	     Rollback 
		  Raiserror('Desfazendo a transa��o. C�digo do erro gerado %d',10,1,@nNumeroError) 
	  end 

End 
/*
Finaliza a Operaca��o.
*/