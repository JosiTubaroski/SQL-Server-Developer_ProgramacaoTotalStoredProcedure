/*
Básico

BEGIN TRANSACTION 

- Marca o início da unidade lógica de trabalho. 
- Tudo que é realizado na modificação dos dados são controlado pela transação.

COMMIT TRANSACTION 

- Confirma que a unidade lógica de trabalho foi concluída com sucesso. 
- Os dados modificados são persistido na base de dados. 

ROLLBACK TRANSACTION

- Cancela tudo que foi modificado na unidade lógica de trabalho, voltando os dados 
  ao status antes de iniciar a transação. 

Observação:

- Você como o desenvolvedor e conhecedor das regras aplicadas no código,
  deve saber onde começa a sua unidade de trabalho e onde ela termina. 


*/


/*
Exemplos 
------------------
*/

use eBook
go

/*
Utilizando Commit 
*/
Select iIDLivro, cTitulo, nPaginas , nPeso 
  From tCADLivro
 Where iIDLivro = 1 

-- Marca inicio da transação 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 600 
    Where iIDLivro = 1 

-- Confirma a transação
Commit 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro
  Where iIDLivro = 1 


/*
Utilizando Rollback 
*/

-- Marca inicio da transação 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 0 
    Where iIDLivro = 1 

-- Cancela a transação
Rollback 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro
  Where iIDLivro = 1 


/*
Famoso UPDATE SEM WHERE 
*/
use eBook
go

-- Marca inicio da transação 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 0 ,
	      cTitulo = 'Cem anos de Guerra'

   Select iIDLivro, cTitulo, nPaginas, nPeso 
     From tCADLivro
    

-- Cancela a transação
Rollback 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro


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

   raiserror('Incluindo Item de Pedido...',10,1) with nowait 
   
   -- Inseri o Item do Pedido
   Insert Into tMOVPedidoItem
   (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
   Values
   (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

   raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
   -- Atualiza o saldo do estoque do livro para a loja
   Update tRELEstoque 
      Set nQuantidade = nQuantidade - @nQuantidade 
    Where iIDLivro = @iidLivro 
      and iIDLoja = @iidLoja 

   raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 
   -- Atualiza o crédito do cliente. 
   Update tCADCliente 
      Set mCredito = mCredito - @mValor 
    Where iIDCliente = @iidCliente

   --Commit 
   
   --Rollback

End 
/*
Finaliza a Operacação.
*/

/*
Dicas -

Transações curtas
Comando que não afetam transação, manter fora da transação. 

*/

