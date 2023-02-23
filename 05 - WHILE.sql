/*
While 

Executa um bloco de comandos diversas vezes.

- Precisa de uma express�o l�gica para repetir o bloco de comandos.


While <Express�o L�gica>
   <Bloco de Comandos>

*/
use eBook
go


/*
Processar um intervalo de Itens.
*/
Set nocount on 

Declare @nContaLivro int = 1 -- @nContaLivro � igual a 1

While @nContaLivro < 4 Begin -- Fa�a enquanto @nContaLivro menor 4

      Select * 
        From tCADLivro 
       where iIDLivro = @nContaLivro

	   Set @nContalivro += 1 -- Soma 1 na vari�vel @nContaLivro
End 

Print @nContalivro
go


---
/*
Processar um intervalo de datas 
*/

Declare @dInicio date = '2018-12-01'  -- Come�o do M�s
Declare @dFinal date  = '2018-12-31'  -- Final do M�s

While @dInicio <= @dFinal begin

	   Print 'Calculo de consumo de ' + CAST(@dInicio as varchar(20))+' '+ datename(dw,@dInicio)
	   Set @dInicio = dateadd(Day,1,@dInicio)  -- Adiciona um dia a data @dInicio
end 



/*
Executar enquanto houver linhas para serem 
processadas

*/
use eBook
go

Begin 

   Declare @nQtdLivros tinyint  = 0

   update tRELEstoque 
      set dUltimoConsumo = '1900-01-01' 
    where iidlivro = 108 
   --- Retorno 8 linhas!!!

   Set @nQtdLivros = @@ROWCOUNT

   While @nQtdLivros > 0  Begin

         update top(1) tRELEstoque -- Retorna 1 linha, para WHERE Verdadeiro 
		      set dUltimoConsumo = getdate()
          where iidlivro = 108 
	         and dUltimoConsumo = '1900-01-01'
			
         set @nQtdLivros = @@ROWCOUNT

		   print @nQtdLivros
  
   End
		
End
/*
Fim do script 
*/


/*
Deletando um grande quantidade de linhas !!!
*/


-- Para relizar a simula��o 
drop table if exists tTMPPedidoItem

Select * into tTMPPedidoItem
  From tMOVPedidoItem


--- Solu��o 1
Delete from tTMPPedidoItem where iIDPedidoItem <= 1000000

/*
Problemas. 
- Voce teria uma transa��o aberta e talvez bloqueando a tabela inteira
- Isso causaria uma sequ�ncia de bloqueios em outras conex�es.
- O seu Log de Transa��o ficaria grande... 
*/

-- Solu��o 2. Fa�a DELETE menores. 
select count(1) from tTMPPedidoItem where iIDPedidoItem <= 1000000

/*
S�o 1.000.000 de linhas e vamos fazer dele��es a cada 49.000
--------------
*/

Declare @nDeletando bit = 1

while @nDeletando = 1 Begin 

      Raiserror('Deletando....', 10,1) with nowait 

      Delete top (49000) 
	     From tTMPPedidoItem 
	    Where iIDPedidoItem <= 1000000

	   if @@ROWCOUNT < 49000 
	      Set @nDeletando = 0

end 
go



/*
Script para aguardar a mudan�a de uma coluna da tabela 
*/
--Outra Sess�o 
update tRELEstoque set nQuantidade = 0 where nQuantidade = 1

use eBook
go
raiserror('Aguardando libera��o do estoque...',10,1) with nowait

while (select top 1 1 from tRELEstoque where nQuantidade = 0) is null
      waitfor delay '00:00:10'

raiserror('Estoque liberado...',10,1) with nowait
update tRELEstoque set nQuantidade = 1 where nQuantidade = 0


-- Voce criar um Job por exemplo, que fique aguardando com o status de algum
-- dados mudou e voce inicia um processo ou tarefa.

truncate table tMOVSolicitacaoCompra

/*
Fazendo o c�lculo para v�rios livros.
*/

Begin

   Set nocount on 
    
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

	Declare @dReferencia datetime        -- Data de Refer�ncia para o consumo. 

	Set @iIDLivro = 8513 -- Identifica o livro que ser� utilizado para o c�lculo 
	Set @dReferencia = '2018-09-15'
   
   -- Tabela para dados tempor�rios do livro. (iIDLivro int )
   Truncate table tTMPLivro
   
   -- Insere na table, 10 ID de livros que tem o estoque abaixo
   -- do estoque m�nimo
   Insert into tTMPLivro
   Select top 10 Livro.iidlivro 
     From tCADLivro as Livro 
     Join tRELEstoque as Estoque
       on Livro.iIDLivro = Estoque.iIDLivro
     Where Estoque.nQuantidadeMinima > Estoque.nQuantidade
   
   If @@ROWCOUNT = 0 Begin
	   Raiserror('N�o existem livros para serem processados.',10,1) with nowait
      Return 
	End

   -- Processa um livro por vez.
   While (Select top 1 iIDLivro from tTMPLivro) > 0 Begin 

         Set @iIDLivro = (Select top 1 iIDLivro from tTMPLivro)

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
	         and dPedido <= dateadd(month,-6,@dReferencia /*getdate()*/ )

	      -- Calcula a quantidade que deve ser solicitada.
	      Set @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

         If @nQtdSolicitada > 0 Begin
         
	         -- Calcula o valor estimado da quantidade solicitada.
	         Set @mValorEstimado = @mValorEstimado * @nQtdSolicitada

            -- Calcula o peso estimado
            Set @mPesoEstimado = @nQtdSolicitada * @nPeso

	         -- Inclui a solicita��o de compras.
          
            Set @iidSolicitacao = next value for seqiIDSolicitacao

	         insert into tMOVSolicitacaoCompra
	         (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	         Values 
	         (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)
   
         End -- If @nQtdSolicitada >= 0 

         -- Ao fim do processo, apaga o livro da tabela
         Delete tTMPLivro where iidlivro = @iIDLivro 
    
   End  -- While    

End 
/*
Fim do c�lculo de Consumo M�dio 
*/

Select * from tMOVSolicitacaoCompra


/*
Segundo Teste - Preparando 1 livro para ser processando.

update tRElEstoque set nQuantidadeMinima = 0


Update tRelEstoque 
   Set nQuantidadeMinima  = 10 ,
       nQuantidade = 5
 Where iidlivro = 111

Select top 1 * from tRelEstoque 
 Where iidlivro = 111

      Select AVG(nQuantidade)
	         From tMOVPedido as Pedido 
	         Join tMOVPedidoItem as Item
		         on Pedido.iIDPedido = Item.iIDPedido
	         Where Item.IDLivro = 111
	         and dPedido <= dateadd(month,-6,@dReferencia /*getdate()*/ )


*/



/*

Terceiro  - Preparando 10 livro para ser processando.

Update tRelEstoque 
   Set nQuantidadeMinima  = 10 ,
       nQuantidade = 5
 Where iidlivro in (Select top 10 iidlivro  from tRelEstoque 
                     group by iidlivro
                    having count(*)  =1
                    )

Select * from tRelEstoque 
 Where iidlivro in (Select top 10 iidlivro  from tRelEstoque 
                     group by iidlivro
                    having count(*)  =1
                    )

      Select AVG(nQuantidade)
	         From tMOVPedido as Pedido 
	         Join tMOVPedidoItem as Item
		         on Pedido.iIDPedido = Item.iIDPedido
	         Where Item.IDLivro = 111
	         and dPedido <= dateadd(month,-6,@dReferencia /*getdate()*/ )

*/

