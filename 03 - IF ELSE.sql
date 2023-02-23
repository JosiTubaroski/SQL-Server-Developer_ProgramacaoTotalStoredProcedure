/*
IF / ELSE

Causa um desvio condicional no fluxo de comandos.

- Precisa de uma express�o l�gica para validar o desvio.
- Else � opcional.

IF <Express�o l�gica>
   <Bloco de comandos>
Else 
   <Bloco de comandos>


*/
use eBook
go

Update tMOVPedido 
   Set dCancelado = getdate() 
 Where iidPedido = 145430000

if @@rowcount > 0 
  raiserror('O comando foi processado', 10,1)


/*
Utilizando o Else 
*/

set nocount on 

update tMOVPedido 
   set dCancelado = getdate() 
 where iidPedido = 14543534543

if @@rowcount > 0 
  raiserror('O comando foi processado', 10,1)
else 
  raiserror('O Pedido n�o foi encontrado', 10,1)



/*
Condi��o l�gica 
*/

-- Uma fun��o do SQL Server 
if datepart(dw,getdate()) in (1,7)

   raiserror('Hoje � um final de semana',10,1)

else 

   raiserror('Hoje � um dia de semana',10,1)



-- Dados escalar de uma tabela. 
if (select iidcliente from tCADcliente where iidcliente = 1)  > 0

   raiserror('Cliente j� cadastrado.',10,1)

else

   raiserror('Cliente n�o cadastrado.',10,1)

/*
Agrupando v�rios comandos.

IF e ELSE tem que utilizar BEGIN/END 
*/

if (Select iidcliente From tCADcliente Where iidcliente = 1)  > 0

   update tCADCliente 
      set dExclusao = getdate() 
    where iidcliente = 1

   raiserror('Cliente foi cancelado.',10,1)

else

   raiserror('Cliente n�o cadastrado.',10,1)

go 

/*
Msg 156, Level 15, State 1, Line 64
Incorrect syntax near the keyword 'else'.

Apesar da mensagem n�o informar a real causa do erro,
o que ocorre � que temos dois comandos depois do IF.
*/

/*
Cancela Nota Fiscal e Pedido 
*/
Begin 
   If (select iidcliente from tCADcliente where iidcliente = 1)  > 0

      Begin

         update tCADCliente 
            set dExclusao = getdate() 
          where iidcliente = 1
         raiserror('Cliente foi cancelado.',10,1)

      End 

   Else

      raiserror('Cliente n�o cadastrado.',10,1)

End


/*
A mesma regra vale para o ELSE. Se voce precisa executar dois
ou mais comandos no ELSE, voce tem que utilizar BEGIN/END 
*/

/*
Dica na utiliza��o do @@rowcount.

- Utilizar o @@rowcount imediatamente ap�s a instru��o DML.
*/
Select COUNT(1) from tCADLivro where iIDDestaque = 1

use eBook
go

Declare @nRetorno int 
Update tCADLivro 
   Set nPaginas = nPaginas -1 
 Where iIDDestaque = 1 
Set @nRetorno = 1 

if @@ROWCOUNT > 1
   raiserror('V�rias linhas foram atualizadas',10,1)

go 

-- Corrigindo 

  
Declare @nRetorno int 
Update tCADLivro 
   Set nPaginas = nPaginas -1 
 Where iIDDestaque = 1 

If @@ROWCOUNT > 1
   raiserror('V�rias linhas foram atualizadas',10,1)

Set @nRetorno = 1 

/*
*/


Begin

   Set nocount on 
    
	/*
	Procedimento para calcular o consumo m�dio
	de um livro nos �ltimo 6 meses, calcular a previs�o
	de consumo para os pr�ximos 12 meses e 
	gerar uma solicitacao de compras de livro. 
	*/
	
   Declare @iidSolicitacao int         -- Identifica��o da solicita��o de compras
	Declare @iIDLivro int				   -- Identifica��o do Livro
	Declare @nPeso numeric(13,1)		   -- Peso atual do Livro 
	Declare @nQtdMesesConsumo int		   -- Quantos meses previsto de consumo
	Declare @nQtdEstoque int			   -- Quantidade de livro no estoque
	Declare @nQtdMediaConsumida int		-- Quantidade m�dia consumida de livros
	Declare @nQtdSolicitada int			-- Quantidade que ser� solicitada para compra
	Declare @mValorEstimado smallmoney  -- Valor estimado da solicita��o de compra. 
   Declare @mPesoEstimado numeric(13,1) -- Peso estimado dos livros.

	Declare @dReferencia datetime  -- Data de Refer�ncia para o consumo. 

	Set @iIDLivro = 8513 -- Identifica o livro que ser� utilizado para o c�lculo 
	Set @dReferencia = '2018-09-15'

	/*
	Recupera o Peso atual do livro e a 
	quantidade de meses prevista para consumo 
	*/
	Select @nPeso = nPeso , 
		    @nQtdMesesConsumo = nMesesConsumo  
	  From tCADLivro 
	 Where iIDLivro = @iIDLivro

	if @@ROWCOUNT = 0
	   raiserror('O ID do livro n�o foi encontrado',10,1)
	Else Begin 
 
      /*
	   Calcula o estoque atual do livro
	   e o valor m�dio para estimativa da compra. 
	   */
	   Select @nQtdEstoque =  SUM(nQuantidade),
		       @mValorEstimado = AVG(mValor) 
	     From tRELEstoque 
	    Where iIDLivro = @iIDLivro

	   /*
	   Calcula a quantidade m�dia consumida 
	   nos �ltimos seis meses. 
	   */
	   Select @nQtdMediaConsumida = AVG(nQuantidade)
	     From tMOVPedido as Pedido 
	     Join tMOVPedidoItem as Item
		    on Pedido.iIDPedido = Item.iIDPedido
	    Where Item.IDLivro = @iIDLivro
	      and dPedido <= dateadd(month,-6,@dReferencia /*getdate()*/ )

	   -- Calcula a quantidade que deve ser solicitada.
	   set @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

	   -- Calcula o valor estimado da quantidade solicitada.
	   set @mValorEstimado = @mValorEstimado * @nQtdSolicitada

      -- Calcula o peso estimado
      set @mPesoEstimado = @nQtdSolicitada * @nPeso

	   -- Inclui a solicita��o de compras.
          
      set @iidSolicitacao = next value for seqiIDSolicitacao

	   insert into tMOVSolicitacaoCompra
	   (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	   Values 
	   (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)


   End -- if @@ROWCOUNT = 0

End 

/*
Fim do c�lculo de Consumo M�dio 
*/

select * from tMOVSolicitacaoCompra


  

