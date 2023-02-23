/*
Valor Padr�o ou Default dos par�metros. 

- At� aqui, todos os par�metro de uma procedure devem ser utilizados. 
  Eles n�o s�o opcionais. 

*/
use eBook
go

Execute stp_AtualizaCredito @iidCliente = 151  -- C�digo do Cliente 
go

/*
Msg 201, Level 16, State 4, Procedure stp_AtualizaCredito, Line 0 [Batch Start Line 274]
Procedure or function 'stp_AtualizaCredito' expects parameter '@mCredito', which was not supplied.
*/

/*
Para tornar um par�metro opcional ou incluir no c�digo um controle
mais r�gidos na passagem de dados, voce tem a op��o de colocar um
valor padr�o nos par�metros. 
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
         raiserror('O valor do cr�dito n�o pode ser negativo.',16,1)

      Update tCADCliente 
         Set mCredito = @mCredito
       Where iidcliente = @iIDCliente
      
      If @@rowcount = 0
         raiserror('O Cliente %d n�o foi encontrado.',16,1,@iIDCliente)

   End Try 

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transa��o aberta? 
         Rollback 

      -- Capturou as informa��es de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma �nica mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      -- Realiza a grava��o no Event Viewer.
      Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a grava��o em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 
      
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 
   
End 
/*
Fim da Procedure 
*/
go

/*
Primeiro Exemplo. Esse � como voc� devem usar. Fica a Dica !!!
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
E se eu n�o sei qual deve ser o valor padr�o que um par�metro deve assumir?

No exemplo abaixo, temos a procedure que atualiza os dados de Cliente.
E um dos par�metros � a Data de Exclus�o do cliente.

Mas essa procedure pode se utilizada para atualizar outros dados,
e n�o necess�riamente realizar a exclus�o,

Ent�o qual valor passar para esse par�metro ou se n�o sei, qual o
valor padr�o para esse par�metro? 

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
@dDataExclusao datetime = NULL -- Assume NULL quando n�o sabemos o valor.
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
         Raiserror('O Cliente %d n�o foi Atualizado. Verifique se o cliente existe ou se ele j� foi exclu�do.',16,1,@iIDCliente)

   End Try

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transa��o aberta? 
         Rollback 

      -- Capturou as informa��es de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma �nica mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      -- Realiza a grava��o no Event Viewer.
      Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a grava��o em uma tabela.
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



