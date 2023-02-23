/*

BEGIN / END

Agrupa v�rias instru��es em um bloco de comandos. 

BEGIN
   <Comandos>
   <Comandos>
	...
END


De um forma quase semelhante em C ou Java

int main (void)
{

}


public static void main(String arg[])
{

}

*/


use eBook
go


Begin
   /*
   Iniciando a consulta
   */
   Set nocount on 

   Select cTitulo 
     From tCADLivro 
	Where iIDLivro = 3443

   Raiserror('Consulta realizada com sucesso',10,1)

End 
go



/*
Blocos Aninhados 
*/

Begin
   Set nocount on 
   /*
   Iniciando a consulta
   */
   Begin 
      
      Select cTitulo 
  	     From tCADLivro 
	    Where iIDLivro = 3443

      Raiserror('Consulta realizada com sucesso',10,1)

   End 
   /*
   Confirma o pedido 
   */
   Begin 

      Update tMOVPedido 
	      Set dCancelado = getdate() 
	    Where iidpedido = 182965

      Raiserror('Pedido cancelado', 10,1) 

   End 
End 
go



/*
Se voce tirar todos os blocos, o script ser� igual ao exemplo abaixo. 
*/

/*
Iniciando a consulta
*/
Set nocount on 
Select cTitulo 
  From tCADLivro 
 Where iIDLivro = 3443
Raiserror('Consulta realizada com sucesso',10,1)
/*
Confirma o pedido 
*/
Update tMOVPedido 
   Set dCancelado = getdate() 
 Where iidpedido = 182965
Raiserror('Pedido cancelado', 10,1) 


/*
Exemplo de script com coment�rios, defini��o de vari�veis e bloco BEGIN/END
*/

use eBook
go


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
	   and dPedido <= dateadd(month,-6,   @dReferencia  /*getdate()*/  )

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

End 
/*
Fim do c�lculo de Consumo M�dio 
*/

select * from tMOVSolicitacaoCompra


