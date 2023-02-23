 /*
@@TRANCOUNT

Use essa fun��o de sistema para controlar se existe transa��o abertas
e quantas transa��es atualmente est�o aberta na conex�o/sess�o atual.

@@TRANCOUNT retorna um n�mero inteiro com a quantidade de transa��o.

Se 0, n�o tem transa��o aberta.
Se maior ou igual a 1, indica que tem transa��o aberta e o n�mero indica
a quantidade de transa��es em aberto. 

Vamos usar tamb�m a fun��o @@ERROR para controlar o COMMIT e o ROLLBACK.

*/

/*
Exemplo de Begin Transaction e Commit 
*/

use eBook
go

Begin Transaction 
select @@TRANCOUNT

Begin Transaction 
select @@TRANCOUNT

Begin Transaction 
select @@TRANCOUNT

Commit 
select @@TRANCOUNT

Commit 
select @@TRANCOUNT

Commit 
select @@TRANCOUNT

if @@TRANCOUNT > 0 Commit 

-- Dica: Antes de realizar um Commit ou Rollback, verifique se existe 
-- transa��es abertas. 

/*
Exemplo de Begin Transaction e Rollback 
*/

Begin Transaction 
select @@TRANCOUNT

Begin Transaction 
select @@TRANCOUNT

Begin Transaction 
select @@TRANCOUNT

Rollback
select @@TRANCOUNT

if @@TRANCOUNT > 0 Rollback


/*
Exemplo da utiliza��o do @@TRANCOUNT para controlar a execu��o do fluxo
do processo de confirmar ou reverter uma transa��o.
*/

-- Vamos simular um erro com esse comando.  
Delete from tCADLivro 
 Where iIDLivro= 137
   

/*
Exemplo 
*/

Declare @nNumeroError int 

Begin 

   Begin transaction

   Update tCADCliente 
      Set mCredito = 100 
    Where iidcliente = 34
   
   Update tCADLivro 
      Set nPaginas = 100 
	Where iIDLivro = 137

   Delete From tCADLivro -- Aqui vai ocorrer um erro!!!
    Where iIDLivro= 137
   
   set @nNumeroError = @@ERROR

   if @@TRANCOUNT > 0 and @nNumeroError > 0 begin
      raiserror('Desfazendo. C�digo do erro gerado %d',10,1,@nNumeroError) 
      rollback
   end

   if @@TRANCOUNT > 0 and @nNumeroError = 0 begin
      raiserror('Confirmando',10,1)
      Commit
   end 

End 

/*
*/


/*
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 
*/

use eBook
go

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
      Set mCredito = mCredito - @mValor 
    Where iIDCliente = @iidCliente
	
   Set @nNumeroError = @@ERROR

   If @@TRANCOUNT > 0 -- Primeiro teste, tem transa��o aberta? 
	  If @nNumeroError = 0 Begin -- Ocorreu um erro? N�o, ent�o confirma.
	     Commit 
		 Raiserror('Confirmando.',10,1) 
	  End 
	  Else Begin -- Sim, ent�o desfaz!!!
	     Rollback 
		 Raiserror('Desfazendo. C�digo do erro gerado %d',10,1,@nNumeroError) 
	  end 

End 
/*
Finaliza a Operaca��o.
*/