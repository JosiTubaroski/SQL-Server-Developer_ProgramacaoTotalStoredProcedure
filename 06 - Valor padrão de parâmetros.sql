/*
Valor Padrão ou Default dos parâmetros. 

- Até aqui, todos os parâmetro de uma procedure devem ser utilizados. 
  Eles não são opcionais. 

*/
use eBook
go

Execute stp_AtualizaCredito @iidCliente = 151  -- Código do Cliente 
go

/*
Msg 201, Level 16, State 4, Procedure stp_AtualizaCredito, Line 0 [Batch Start Line 274]
Procedure or function 'stp_AtualizaCredito' expects parameter '@mCredito', which was not supplied.
*/

/*
Para tornar um parâmetro opcional ou incluir no código um controle
mais rígidos na passagem de dados, voce tem a opção de colocar um
valor padrão nos parâmetros. 
Exemplo 
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaEstoque
Objetivo   : Atualiza o Saldo de Estoque do Livro. 
------------------------------------------------------------*/
Create or Alter Procedure stp_AtualizaCredito
@iIDCliente int ,
@mCredito money = $20.00
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
Primeiro Exemplo. Esse é como você devem usar. Fica a Dica !!!
*/

Execute stp_AtualizaCredito @iidCliente = 151, @mCredito = $251.00

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Execute stp_AtualizaCredito @iidCliente = 151

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Execute stp_AtualizaCredito @iidCliente = 150 , @mCredito = DEFAULT

Select mCredito , cNome from tCADCliente where iidcliente = 150

go

/*
E se eu não sei qual deve ser o valor padrão que um parâmetro deve assumir?

No exemplo abaixo, temos a procedure que atualiza os dados de Cliente.
E um dos parâmetros é a Data de Exclusão do cliente.

Mas essa procedure pode se utilizada para atualizar outros dados,
e não necessáriamente realizar a exclusão,

Então qual valor passar para esse parâmetro ou se não sei, qual o
valor padrão para esse parâmetro? 

NULL !!!

*/
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaCliente
Objetivo   : Atualiza os dados de Cliente 
------------------------------------------------------------*/
Create or Alter Procedure stp_AtualizaCliente
@iIDCliente int, 
@cNome varchar(50) , 
@nTipoPessoa tinyint , 
@cDocumento varchar(14) ,  
@dAniversario date , 
@mCredito smallmoney = $20.00,
@dDataExclusao datetime = NULL -- Assume NULL quando não sabemos o valor.
as
Begin

   Set nocount on 
   
   Declare @nRetorno int = 0 

   Begin Try    
         
      Update tCADCliente 
	     Set cNome = @cNome ,
	         nTipoPessoa = @nTipoPessoa,
	         cDocumento = @cDocumento ,
	         dAniversario = @dAniversario ,
	         mCredito = @mCredito ,
	         dExclusao = @dDataExclusao 
	   Where iIDCliente = @iIDCliente 
	     and dExclusao is null
	   
      If @@rowcount = 0
         Raiserror('O Cliente %d não foi Atualizado. Verifique se o cliente existe ou se ele já foi excluído.',16,1,@iIDCliente)

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

	  Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 
      
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch

End 
/*
Fim da Procedure stp_AtualizaCliente 
*/
go 

Select * from tCADCliente where iIDCliente = 150
go


Execute stp_AtualizaCliente @iIDCliente = 150 , 
                            @cNome = 'Kirsten Grimes Silva', 
							@nTipoPessoa = 1 , 
							@cDocumento = '87091275985' , 
							@dAniversario = '1998-02-09' 
go
Select * from tCADCliente where iIDCliente = 150
go



