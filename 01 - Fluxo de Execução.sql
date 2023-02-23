/*
Fluxo de execução 

- Execução sequêncial de um conjunto de instruções. 

<Ponto de Início>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de Término>

- Execução sequêncial com desvio no fluxo de instruções. 

<Ponto de Início>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   if <Condição>
      <Comandos...>
   else 
      <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de Término>

- Execução sequêncial com repetição de instruções. 

<Ponto de Início>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   While <Condição>
      <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de Término>

- Execução sequêncial com chamada de Stored Procedure 

<Ponto de Início>    
   <Comandos...>
   <Comandos...>
   <Comandos...>
   Execute <Procedure01>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de Término>

<Procedure01>
<Ponto de Início>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
<Ponto de Término>



*/



use eBook
go

Alter Sequence seqiIDSolicitacao restart
Truncate table tMOVSolicitacaoCompra


/*
Início do calculo de Consumo Médio 
*/

/*
Procedimento para calcular o consumo médio
de um livro nos último 6 meses, calcular a previsão
de consumo para os próximos 12 meses e 
gerar uma solicitacao de compras de livro. 
*/

Declare @iidSolicitacao int          -- Identificação da solicitação de compras
Declare @iIDLivro int				    -- Identificação do Livro
Declare @nPeso numeric(13,1)		    -- Peso atual do Livro 
Declare @nQtdMesesConsumo int		    -- Quantos meses previsto de consumo
Declare @nQtdEstoque int			    -- Quantidade de livro no estoque
Declare @nQtdMediaConsumida int		 -- Quantidade média consumida de livros
Declare @nQtdSolicitada int			 -- Quantidade que será solicitada para compra
Declare @mValorEstimado smallmoney   -- Valor estimado da solicitação de compra. 
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

/*
Calcula o estoque atual do livro
e o valor médio para estimativa da compra. 
*/
Select @nQtdEstoque = SUM(nQuantidade),
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
 Where Item.IDLivro = 8513
   and Pedido.dPedido >= dateadd(month,-6,@dReferencia /*getdate()*/ )

-- Calcula a quantidade que de ser solicitada.
set @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

-- Calcula o valor estimado da quantidad solicitada.
set @mValorEstimado = @mValorEstimado * @nQtdSolicitada

-- Calcula o peso estimado
set @mPesoEstimado = @nQtdSolicitada * @nPeso

-- Inclui a solicitação de compras.
insert into tMOVSolicitacaoCompra
(iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
Values 
(@iIDLivro,@nQtdSolicitada , @mValorEstimado,@mPesoEstimado) 

/*
Fim do cálculo de Consumo Médio 
*/

select * from tMOVSolicitacaoCompra




