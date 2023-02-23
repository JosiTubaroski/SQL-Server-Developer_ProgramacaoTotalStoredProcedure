/*
Fluxo de execu��o 

- Execu��o sequ�ncial de um conjunto de instru��es. 

<Ponto de In�cio>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de T�rmino>

- Execu��o sequ�ncial com desvio no fluxo de instru��es. 

<Ponto de In�cio>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   if <Condi��o>
      <Comandos...>
   else 
      <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de T�rmino>

- Execu��o sequ�ncial com repeti��o de instru��es. 

<Ponto de In�cio>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   While <Condi��o>
      <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de T�rmino>

- Execu��o sequ�ncial com chamada de Stored Procedure 

<Ponto de In�cio>    
   <Comandos...>
   <Comandos...>
   <Comandos...>
   Execute <Procedure01>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de T�rmino>

<Procedure01>
<Ponto de In�cio>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de T�rmino>



*/



use eBook
go

Alter Sequence seqiIDSolicitacao restart
Truncate table tMOVSolicitacaoCompra


/*
In�cio do calculo de Consumo M�dio 
*/

/*
Procedimento para calcular o consumo m�dio
de um livro nos �ltimo 6 meses, calcular a previs�o
de consumo para os pr�ximos 12 meses e 
gerar uma solicitacao de compras de livro. 
*/

Declare @iidSolicitacao int          -- Identifica��o da solicita��o de compras
Declare @iIDLivro int				    -- Identifica��o do Livro
Declare @nPeso numeric(13,1)		    -- Peso atual do Livro 
Declare @nQtdMesesConsumo int		    -- Quantos meses previsto de consumo
Declare @nQtdEstoque int			    -- Quantidade de livro no estoque
Declare @nQtdMediaConsumida int		 -- Quantidade m�dia consumida de livros
Declare @nQtdSolicitada int			 -- Quantidade que ser� solicitada para compra
Declare @mValorEstimado smallmoney   -- Valor estimado da solicita��o de compra. 
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
Select @nQtdEstoque = SUM(nQuantidade),
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
 Where Item.IDLivro = 8513
   and Pedido.dPedido >= dateadd(month,-6,@dReferencia /*getdate()*/ )

-- Calcula a quantidade que de ser solicitada.
set @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

-- Calcula o valor estimado da quantidad solicitada.
set @mValorEstimado = @mValorEstimado * @nQtdSolicitada

-- Calcula o peso estimado
set @mPesoEstimado = @nQtdSolicitada * @nPeso

-- Inclui a solicita��o de compras.
insert into tMOVSolicitacaoCompra
(iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
Values 
(@iIDLivro,@nQtdSolicitada , @mValorEstimado,@mPesoEstimado) 

/*
Fim do c�lculo de Consumo M�dio 
*/

select * from tMOVSolicitacaoCompra




