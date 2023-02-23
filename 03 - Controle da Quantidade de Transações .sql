 /*
@@TRANCOUNT

Use essa função de sistema para controlar se existe transação abertas
e quantas transações atualmente estão aberta na conexão/sessão atual.

@@TRANCOUNT retorna um número inteiro com a quantidade de transação.

Se 0, não tem transação aberta.
Se maior ou igual a 1, indica que tem transação aberta e o número indica
a quantidade de transações em aberto. 

Vamos usar também a função @@ERROR para controlar o COMMIT e o ROLLBACK.

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
-- transações abertas. 

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
Exemplo da utilização do @@TRANCOUNT para controlar a execução do fluxo
do processo de confirmar ou reverter uma transação.
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
      raiserror('Desfazendo. Código do erro gerado %d',10,1,@nNumeroError) 
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
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go

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
      Set mCredito = mCredito - @mValor 
    Where iIDCliente = @iidCliente
	
   Set @nNumeroError = @@ERROR

   If @@TRANCOUNT > 0 -- Primeiro teste, tem transação aberta? 
	  If @nNumeroError = 0 Begin -- Ocorreu um erro? Não, então confirma.
	     Commit 
		 Raiserror('Confirmando.',10,1) 
	  End 
	  Else Begin -- Sim, então desfaz!!!
	     Rollback 
		 Raiserror('Desfazendo. Código do erro gerado %d',10,1,@nNumeroError) 
	  end 

End 
/*
Finaliza a Operacação.
*/