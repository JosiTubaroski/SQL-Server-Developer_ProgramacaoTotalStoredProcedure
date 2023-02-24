/*  
Return 

Finaliza a execução de um conjunto de instruções em lote ou de uma
stored procedure.

*/
use eBook
go

Begin

   Select max(iidcliente) from tMOVPedido

   Return 

   Select top 1 * from tCADLivro 

End 




/*
Inicio do script 
*/
set nocount on 

Begin
   
   If (Select iidcliente From tCADcliente where iidcliente = 3)  > 0
      Begin 
         update tCADCliente 
            set dExclusao = getdate() 
          where iidcliente = 1
         raiserror('Cliente foi cancelado.',10,1)
      End 
   Else
      Begin 
         raiserror('Cliente não cadastrado.',10,1)
		   Return 
	   End
	   
   Raiserror('Script processado  com sucesso.',10,1)

End 
/*
Fim do script 
*/




Begin

   Set nocount on 
    
	/*
	Procedimento para calcular o consumo médio
	de um livro nos último 6 meses, calcular a previsão
	de consumo para os próximos 12 meses e 
	gerar uma solicitacao de compras de livro. 
	*/
	
   Declare @iidSolicitacao int         -- Identificação da solicitação de compras
	Declare @iIDLivro int				   -- Identificação do Livro
	Declare @nPeso numeric(13,1)		   -- Peso atual do Livro 
	Declare @nQtdMesesConsumo int		   -- Quantos meses previsto de consumo
	Declare @nQtdEstoque int			   -- Quantidade de livro no estoque
	Declare @nQtdMediaConsumida int		-- Quantidade média consumida de livros
	Declare @nQtdSolicitada int			-- Quantidade que será solicitada para compra
	Declare @mValorEstimado smallmoney  -- Valor estimado da solicitação de compra. 
   Declare @mPesoEstimado numeric(13,1) -- Peso estimado dos livros.

	Declare @dReferencia datetime  -- Data de Referência para o consumo. 

	Set @iIDLivro = 8513 -- Identifica o livro que será utilizado para o cálculo 
	Set @dReferencia = '2018-09-15'

	/*
	Recupera o Peso atual do livro e a 
	quantidade de meses prevista para consumo 
	*/
	Select @nPeso = nPeso , 
		    @nQtdMesesConsumo = nMesesConsumo  
	  From tCADLivro 
	 Where iIDLivro = @iIDLivro

	if @@ROWCOUNT = 0 Begin
	   raiserror('O ID do livro não foi encontrado',10,1)
      Return 
	End
 
   /*
	Calcula o estoque atual do livro
	e o valor médio para estimativa da compra. 
	*/
	Select @nQtdEstoque =  SUM(nQuantidade),
		      @mValorEstimado = AVG(mValor) 
	   From tRELEstoque 
	   Where iIDLivro = @iIDLivro

	/*
	Calcula a quantidade média consumida 
	nos últimos seis meses. 
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

	-- Inclui a solicitação de compras.
          
   set @iidSolicitacao = next value for seqiIDSolicitacao

	insert into tMOVSolicitacaoCompra
	(iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	Values 
	(@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)
   
End 
/*
Fim do cálculo de Consumo Médio 
*/

select * from tMOVSolicitacaoCompra

