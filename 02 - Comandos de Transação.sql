/*
B�sico

BEGIN TRANSACTION 

- Marca o in�cio da unidade l�gica de trabalho. 
- Tudo que � realizado na modifica��o dos dados s�o controlado pela transa��o.

COMMIT TRANSACTION 

- Confirma que a unidade l�gica de trabalho foi conclu�da com sucesso. 
- Os dados modificados s�o persistido na base de dados. 

ROLLBACK TRANSACTION

- Cancela tudo que foi modificado na unidade l�gica de trabalho, voltando os dados 
  ao status antes de iniciar a transa��o. 

Observa��o:

- Voc� como o desenvolvedor e conhecedor das regras aplicadas no c�digo,
  deve saber onde come�a a sua unidade de trabalho e onde ela termina. 


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

-- Marca inicio da transa��o 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 600 
    Where iIDLivro = 1 

-- Confirma a transa��o
Commit 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro
  Where iIDLivro = 1 


/*
Utilizando Rollback 
*/

-- Marca inicio da transa��o 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 0 
    Where iIDLivro = 1 

-- Cancela a transa��o
Rollback 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro
  Where iIDLivro = 1 


/*
Famoso UPDATE SEM WHERE 
*/
use eBook
go

-- Marca inicio da transa��o 
Begin Transaction

   Update tCADLivro 
      Set nPaginas = 0 ,
	      cTitulo = 'Cem anos de Guerra'

   Select iIDLivro, cTitulo, nPaginas, nPeso 
     From tCADLivro
    

-- Cancela a transa��o
Rollback 

Select iIDLivro, cTitulo, nPaginas, nPeso 
  From tCADLivro


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

   raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 
   -- Atualiza o cr�dito do cliente. 
   Update tCADCliente 
      Set mCredito = mCredito - @mValor 
    Where iIDCliente = @iidCliente

   --Commit 
   
   --Rollback

End 
/*
Finaliza a Operaca��o.
*/

/*
Dicas -

Transa��es curtas
Comando que n�o afetam transa��o, manter fora da transa��o. 

*/

