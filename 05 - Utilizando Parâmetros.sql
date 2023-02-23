/*
Utilização de parâmetros 

Um dos recursos mais interessantes de um procedure é a capacidade
de receber valores dos programas de chamada e utilizar durante
a execução do código, tornando a sua execução muito flexível.

https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/specify-parameters?view=sql-server-2017

Esses valores que são passados para as procedures são chamados de 
parâmetros da procedure.

Podemos dizer que os parâmetros de uma procedure são idênticas as 
variáveis. Começa com @, deve ter um nome, um tipo e tamanho.

Na definição do parâmetros não utilizamos o DECLARE 

Os parâmetros são definidos no momento de design da procedure. 

*/

use eBook
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaCredito 
Objetivo   : Atualiza on valor de credito do Cliente
------------------------------------------------------------*/
Create or Alter Procedure stp_AtualizaCredito
as
Begin

   Set nocount on 

   Declare @iIDCliente int -- Identificação do Clientes
   Declare @mCredito money -- Valor do novo crédito 

   Set @iIDCliente = 150
   Set @mCredito = $150.00
      
   Declare @nRetorno int = 0 -- Controla o retorno da procedure 

   Begin Try 

      If @mCredito < 0
         raiserror('O valor do crédito não pode ser negativo.',16,1)

      Update tCADCliente 
         Set mCredito = @mCredito
       Where iidcliente = @iIDCliente
      
      If @@rowcount = 0
         raiserror('O Cliente %d não foi encontrado.',16,1,@iIDCliente)

   End Try 

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transação aberta? 
         Rollback 

      -- Capturou as informações de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma única mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      -- Realiza a gravação no Event Viewer.
      Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a gravação em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 
      
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 

End 
/*
Fim da Procedure 
*/

Select mCredito , cNome from tCADCliente where iidcliente = 150
go

execute stp_AtualizaCredito
go

Select mCredito from tCADCliente where iidcliente = 150
go

/*
E para o Cliente ID = 151 ??

Vamos ajustar a procedure para receber então dois parâmetros.
 - Id do cliente que é um INT
 - Valor do crédito que é do tipo MONEY

- Utilize nome de parâmetros que de algum sentido para seu 
  conteúdo. Evite por exemplo @p1 int , @p2 money

Exemplo:
@id int 
@valor money 

Aqui vou usar uma coerência que é usar o mesmo nome do parâmetro
igual as colunas da tabela onde será usando. 

@iIDCliente int ,
@mCredito money 

*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaEstoque
Objetivo   : Atualiza o Saldo de Estoque do Livro. 
------------------------------------------------------------*/
Create or Alter Procedure stp_AtualizaCredito
@iIDCliente int ,
@mCredito money 
as
Begin

   Set nocount on 
   
   Declare @nRetorno int = 0 

   Begin Try 

      If @mCredito < 0
         raiserror('O valor do crédito não pode ser negativo.',16,1)

      Update tCADCliente 
         Set mCredito = @mCredito
       Where iidcliente = @iIDCliente
      
      If @@rowcount = 0
         raiserror('O Cliente %d não foi encontrado.',16,1,@iIDCliente)

   End Try 

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transação aberta? 
         Rollback 

      -- Capturou as informações de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma única mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      -- Realiza a gravação no Event Viewer.
      Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a gravação em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 
      
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 
   
End 
/*
Fim da Procedure 
*/
go


/*
Vimos na aula de Operações com Store Procedure que devemos 
usar o comando EXECUTE.
Agora veremos como utilizar o EXECUTE e passando parametros para a procedure .
*/


/*
Primeiro Exemplo. Esse é como você devem usar. Fica a Dica !!!
*/

Execute stp_AtualizaCredito @iidCliente = 151, @mCredito = $21.00
go
Select mCredito , cNome from tCADCliente where iidcliente = 151
go


Execute stp_AtualizaCredito @iidCliente = 151,  -- Código do Cliente 
                            @mCredito = $252.00 -- Valor de Credito 

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Declare @iIDClienteNovo int = 151      -- Código do Cliente 
Declare @mCreditoNovo money = $253.00  -- Valor de Crédito 

Execute stp_AtualizaCredito @iidCliente = @iIDClienteNovo,  
                            @mCredito   = @mCreditoNovo 

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

-- Voce pode inverter a ordem da passagem de parâmetro?

Execute stp_AtualizaCredito @mCredito = $254.00 , 
                            @iidCliente = 151

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

go



/*
Segundo Exemplo. Funciona, mas não é auto documentado. 
Não aconselho sua utilização.
*/

Execute stp_AtualizaCredito 151, $250.00
go
Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Execute stp_AtualizaCredito 151,  -- Código do Cliente 
                            $250.00 -- Valor de Credito 
go

Declare @iIDClienteNovo int = 151      -- Código do Cliente 
Declare @mCreditoNovo money = $250.00  -- Valor de Crédito 

Execute stp_AtualizaCredito @iIDClienteNovo,  
                            @mCreditoNovo 
go

-- Voce pode inverter a ordem da passagem de parâmetro?

Execute stp_AtualizaCredito $250.00 , 150
go

Select mCredito , cNome from tCADCliente where iidcliente = 150
go

Select iIDCliente,cNome, mCredito  
  From tCADCliente 
 Where iidcliente = 250 
go




/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 

Vamos usar o script 

*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirPedido
Objetivo   : Realiza a inclusão de pedido
------------------------------------------------------------*/
Create or Alter Procedure stp_IncluirPedido
@iidCliente int , -- Código do Cliente que comprará o livro
@iidLivro int,    -- Código do Livro que será comprado
@iidLoja int,     -- Código da loja onde a compra foi feita 
@nQuantidade int  -- Quantidade de livros. 
as 
Begin 

   Set nocount on 

   Declare @niIDEvento int = 0   
   Declare @iIDPedido int			   -- Código do Pedido 
   Declare @mValor smallmoney		   -- Valor do Livro

   Declare @nRetorno int = 0 
   Declare @nDebug bit = 0

   Begin 

      Begin Try 

         -- Recupera qual o valor do livro de uma determinada loja.
         Select @mValor = mValor 
	        From tRELEstoque 
	       Where iIDLivro = @iidLivro 
	         and iIDLoja = @iidLoja 

         If @@rowcount = 0 begin
           Raiserror('Estoque do livro %d não foi encontrado na filial %d',16,1,@iidLivro,@iidLoja )
         End 

         Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.

         Begin Transaction 

         if @nDebug = 1
            Raiserror('Incluindo Pedido...',10,1) with nowait 

         -- Inseri o cabeçalho do Pedido.
         Insert Into dbo.tMOVPedido           
         (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
         Values
         (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)
   
         if @nDebug = 1
            Raiserror('Incluindo Item de Pedido...',10,1) with nowait 
   
         -- Inseri o Item do Pedido
         Insert Into tMOVPedidoItem
         (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
         Values
         (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

         if @nDebug = 1
            Raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
      
         -- Atualiza o saldo do estoque do livro para a loja
         Update tRELEstoque 
            Set nQuantidade = nQuantidade - @nQuantidade 
          Where iIDLivro = @iidLivro 
            and iIDLoja = @iidLoja 

         if @nDebug = 1
            Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 

         -- Atualiza o crédito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - (@mValor * @nQuantidade)
          Where iIDCliente = @iidCliente

	      Commit -- 

      End Try 

      Begin Catch 

         If @@TRANCOUNT > 0 -- tem transação aberta? 
            Rollback 

         -- Capturou as informações de erro 
         Declare @cMensagem varchar(512) ,
                 @nErrorNumber int = ERROR_NUMBER(),
                 @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
                 @nErrorSeverity tinyint = ERROR_SEVERITY(), 
                 @nErrorState tinyint = ERROR_STATE(), 
                 @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
                 @nErrorLine int = ERROR_LINE()

         -- Fez o tratamento, gerando uma única mensagem.
         Set @cMensagem = FormatMessage('MsgID %d. '+@cErrorMessage+' Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a gravação em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

		   Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 

         set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

      End Catch 

   End 

End 
/*
Finaliza a Operacação.
*/
go

execute stp_IncluirPedido @iidCliente = 151,
                          @iidLivro = 106,
                          @iidLoja = 9,
                          @nQuantidade = 1 


