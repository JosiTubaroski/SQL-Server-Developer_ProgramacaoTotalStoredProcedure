/*
Bloco TRY e CATCH 

Controla as exce��es e tratamento de erros.

O bloco TRY controlas as exce��es, detectando os erros gerados por comandos
ou pela instru��o raiserror() e envia para bloco CATCH.

O bloco CACTH recebe do bloco TRY o erro, identifica os valores retornados 
usando fun��es de tratamento de erro exclusivas desse bloco. Neste bloco
voc� tem a op��o de devolver o erro para que fez a chamado ou tratar o erro para 
gerar um log em tabela ou no SQL Server Logs. 

-------------------
<Blocos de comandos> 

Begin Try

   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>
   <Comandos...>   

End Try



Begin Catch

   <Comandos...>
   <Comandos...>
   <Comandos...>

End Catch 

<Blocos de comandos> 
------------------------------------------------------------------


- Blocos TRY e CATCH deve ficar juntos.
- N�o pode existir comandos entre os blocos.
- Somente erros com severidade acima de 10 s�o detectados.
- Se n�o houver erro no bloco TRY, o fluxo � desviado para a pr�ximo instru��o
  abaixo do End Catch
- Voce pode decidir continuar a execu��o ou interromper no tratamento do erro 
*/


/*
Exemplo com erro de divis�o por zero 

- Simular sem o erro - SELECT 1/1
- Simular com o erro - SELECT 1/0 

*/

Begin

   set nocount on 

   raiserror('01. Teste de simula��o de erro',10,1) with nowait 

   Begin Try

      Raiserror('02. Inicio Teste de simula��o de erro',10,1) with nowait 
	   Select 1/0
	   Raiserror('03. Final Teste de simula��o de erro',10,1) with nowait 

   End Try

   Begin Catch

       Raiserror('99. Identifica��o do erro.',10,1) with nowait 

   End Catch 

   raiserror('04. Teste de simula��o de erro',10,1) with nowait 

End 
/*
Fim do exemplo
*/
go


/*
Simulando entre uma faixa de datas.

*/
Begin 

   Declare @dData datetime = '2018-11-15'
   Declare @dReferencia datetime = '2018-11-30'
   declare @nResultado int 

   While @dData <= @dReferencia begin

      Begin Try

         If datepart(dw,@dData) in (1,7)
	         Set @nResultado = 1/0 

	      Raiserror('Lan�amentos de contabilizado',10,1)  

      End Try 

      Begin Catch

         print '--- Houve um erro no dia ' 
	      print @dData 

      End Catch 

      Set @dData = dateadd(d,1,@dData)

   End -- While @dData <= @dReferencia

End 
go
/*
*/


/*
Identificando o erro no block CATCH 
Como vimos a fun��o @@ERROR, vamos usar junto com o bloco TRY e CATCH 
*/

-- Exemplo 
Begin 

   Begin Try

       Select 1/0 
       
   End Try

   Begin Catch 

      If @@ERROR = 8134
         Raiserror('Ocorreu um erro de divis�o por zero.',10,1)

   End Catch 

End 
/*
Fim do exemplo 
*/

-- Exemplo de atualiza��o de dados com erro.
use eBook
go

Begin 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que ser� alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 
   Declare @nCodigoErro int      -- Armazena o c�digo do erro  

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome ,-- +  ' Industrias.' , 
              @mCredito = mCredito
         From tCADCliente
        Where iIDCliente = @iIDCliente 
       
       If @mCredito < 20 

          Update tCADCliente 
             Set cNome = @cNome, -- Primeiro erro, dados truncados 
                 mCredito = 0    -- Segundo erro, viola��o da restri��o CHECK  
           Where iIDCliente = 33612
       
   End Try

   Begin Catch 

      Set @nCodigoErro = @@ERROR
   
      -- Os dados de cadeia ou bin�rios ficariam truncados.
      If @nCodigoErro = 8152
         Raiserror('Erro 8152. Os dados de cadeia ou bin�rios ficariam truncados.',10,1)
      
      -- Conflito entre a instru��o UPDATE e a restri��o CHECK 
      -- "CK__tCADClien__mCred__3D5E1FD2". O conflito ocorreu na base de 
      -- dados "eBook", tabela "dbo.tCADCliente", column 'mCredito'.
      If @nCodigoErro = 547
         Raiserror('Erro 547. Conflito entre a instru��o UPDATE e a restri��o CHECK.' ,10,1)
      Else 
         Print 'Codigo de error ' + cast(@nCodigoErro as varchar(10))

   End Catch 

End 
/*
Fim do Exemplo 
*/


/*
Alguns erros n�o s�o capturados. 
*/

Begin  try
   select * from TabelaNaoExiste
end Try

begin catch
    select 'Houve um erro'
end catch 
go


use eBook
go
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
   
   Insert into tTMPLivro
   Select top 10 Livro.iidlivro 
     From tCADLivro as Livro 
     Join tRELEstoque as Estoque
       on Livro.iIDLivro = Estoque.iIDLivro
     Where Estoque.nQuantidadeMinima > Estoque.nQuantidade
   
   If @@ROWCOUNT = 0 Begin
	   Raiserror('N�o existem livros para serem processados.',10,1)
      Return 
	End

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

            Begin Try 

	            insert into tMOVSolicitacaoCompra
	            (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	            Values 
	            (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)

            End Try 

            Begin Catch

               Raiserror('Houve um erro na inclus�o da Solicita��o de Compras',10,1)

            End Catch 
   
         End -- If @nQtdSolicitada >= 0 

         Delete tTMPLivro where iidlivro = @iIDLivro 
    
   End  -- While    

End 
/*
Fim do c�lculo de Consumo M�dio 
*/

Select * from tMOVSolicitacaoCompra
