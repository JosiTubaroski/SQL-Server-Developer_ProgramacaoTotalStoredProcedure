/*
Bloco TRY e CATCH 

Controla as exceções e tratamento de erros.

O bloco TRY controlas as exceções, detectando os erros gerados por comandos
ou pela instrução raiserror() e envia para bloco CATCH.

O bloco CACTH recebe do bloco TRY o erro, identifica os valores retornados 
usando funções de tratamento de erro exclusivas desse bloco. Neste bloco
você tem a opção de devolver o erro para que fez a chamado ou tratar o erro para 
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
- Não pode existir comandos entre os blocos.
- Somente erros com severidade acima de 10 são detectados.
- Se não houver erro no bloco TRY, o fluxo é desviado para a próximo instrução
  abaixo do End Catch
- Voce pode decidir continuar a execução ou interromper no tratamento do erro 
*/


/*
Exemplo com erro de divisão por zero 

- Simular sem o erro - SELECT 1/1
- Simular com o erro - SELECT 1/0 

*/

Begin

   set nocount on 

   raiserror('01. Teste de simulação de erro',10,1) with nowait 

   Begin Try

      Raiserror('02. Inicio Teste de simulação de erro',10,1) with nowait 
	   Select 1/0
	   Raiserror('03. Final Teste de simulação de erro',10,1) with nowait 

   End Try

   Begin Catch

       Raiserror('99. Identificação do erro.',10,1) with nowait 

   End Catch 

   raiserror('04. Teste de simulação de erro',10,1) with nowait 

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

	      Raiserror('Lançamentos de contabilizado',10,1)  

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
Como vimos a função @@ERROR, vamos usar junto com o bloco TRY e CATCH 
*/

-- Exemplo 
Begin 

   Begin Try

       Select 1/0 
       
   End Try

   Begin Catch 

      If @@ERROR = 8134
         Raiserror('Ocorreu um erro de divisão por zero.',10,1)

   End Catch 

End 
/*
Fim do exemplo 
*/

-- Exemplo de atualização de dados com erro.
use eBook
go

Begin 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que será alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 
   Declare @nCodigoErro int      -- Armazena o código do erro  

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome ,-- +  ' Industrias.' , 
              @mCredito = mCredito
         From tCADCliente
        Where iIDCliente = @iIDCliente 
       
       If @mCredito < 20 

          Update tCADCliente 
             Set cNome = @cNome, -- Primeiro erro, dados truncados 
                 mCredito = 0    -- Segundo erro, violação da restrição CHECK  
           Where iIDCliente = 33612
       
   End Try

   Begin Catch 

      Set @nCodigoErro = @@ERROR
   
      -- Os dados de cadeia ou binários ficariam truncados.
      If @nCodigoErro = 8152
         Raiserror('Erro 8152. Os dados de cadeia ou binários ficariam truncados.',10,1)
      
      -- Conflito entre a instrução UPDATE e a restrição CHECK 
      -- "CK__tCADClien__mCred__3D5E1FD2". O conflito ocorreu na base de 
      -- dados "eBook", tabela "dbo.tCADCliente", column 'mCredito'.
      If @nCodigoErro = 547
         Raiserror('Erro 547. Conflito entre a instrução UPDATE e a restrição CHECK.' ,10,1)
      Else 
         Print 'Codigo de error ' + cast(@nCodigoErro as varchar(10))

   End Catch 

End 
/*
Fim do Exemplo 
*/


/*
Alguns erros não são capturados. 
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
Fazendo o cálculo para vários livros.
*/

Begin

   Set nocount on 
    
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

	Declare @dReferencia datetime        -- Data de Referência para o consumo. 

	Set @iIDLivro = 8513 -- Identifica o livro que será utilizado para o cálculo 
	Set @dReferencia = '2018-09-15'
   
   -- Tabela para dados temporários do livro. (iIDLivro int )
   Truncate table tTMPLivro
   
   Insert into tTMPLivro
   Select top 10 Livro.iidlivro 
     From tCADLivro as Livro 
     Join tRELEstoque as Estoque
       on Livro.iIDLivro = Estoque.iIDLivro
     Where Estoque.nQuantidadeMinima > Estoque.nQuantidade
   
   If @@ROWCOUNT = 0 Begin
	   Raiserror('Não existem livros para serem processados.',10,1)
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
	      Set @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

         If @nQtdSolicitada > 0 Begin
         
	         -- Calcula o valor estimado da quantidade solicitada.
	         Set @mValorEstimado = @mValorEstimado * @nQtdSolicitada

            -- Calcula o peso estimado
            Set @mPesoEstimado = @nQtdSolicitada * @nPeso

	         -- Inclui a solicitação de compras.
          
            Set @iidSolicitacao = next value for seqiIDSolicitacao

            Begin Try 

	            insert into tMOVSolicitacaoCompra
	            (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	            Values 
	            (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)

            End Try 

            Begin Catch

               Raiserror('Houve um erro na inclusão da Solicitação de Compras',10,1)

            End Catch 
   
         End -- If @nQtdSolicitada >= 0 

         Delete tTMPLivro where iidlivro = @iIDLivro 
    
   End  -- While    

End 
/*
Fim do cálculo de Consumo Médio 
*/

Select * from tMOVSolicitacaoCompra
