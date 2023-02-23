/*
Utiliza��o de par�metros 

Um dos recursos mais interessantes de um procedure � a capacidade
de receber valores dos programas de chamada e utilizar durante
a execu��o do c�digo, tornando a sua execu��o muito flex�vel.

https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/specify-parameters?view=sql-server-2017

Esses valores que s�o passados para as procedures s�o chamados de 
par�metros da procedure.

Podemos dizer que os par�metros de uma procedure s�o id�nticas as 
vari�veis. Come�a com @, deve ter um nome, um tipo e tamanho.

Na defini��o do par�metros n�o utilizamos o DECLARE 

Os par�metros s�o definidos no momento de design da procedure. 

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

   Declare @iIDCliente int -- Identifica��o do Clientes
   Declare @mCredito money -- Valor do novo cr�dito 

   Set @iIDCliente = 150
   Set @mCredito = $150.00
      
   Declare @nRetorno int = 0 -- Controla o retorno da procedure 

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

Select mCredito , cNome from tCADCliente where iidcliente = 150
go

execute stp_AtualizaCredito
go

Select mCredito from tCADCliente where iidcliente = 150
go

/*
E para o Cliente ID = 151 ??

Vamos ajustar a procedure para receber ent�o dois par�metros.
 - Id do cliente que � um INT
 - Valor do cr�dito que � do tipo MONEY

- Utilize nome de par�metros que de algum sentido para seu 
  conte�do. Evite por exemplo @p1 int , @p2 money

Exemplo:
@id int 
@valor money 

Aqui vou usar uma coer�ncia que � usar o mesmo nome do par�metro
igual as colunas da tabela onde ser� usando. 

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
Vimos na aula de Opera��es com Store Procedure que devemos 
usar o comando EXECUTE.
Agora veremos como utilizar o EXECUTE e passando parametros para a procedure .
*/


/*
Primeiro Exemplo. Esse � como voc� devem usar. Fica a Dica !!!
*/

Execute stp_AtualizaCredito @iidCliente = 151, @mCredito = $21.00
go
Select mCredito , cNome from tCADCliente where iidcliente = 151
go


Execute stp_AtualizaCredito @iidCliente = 151,  -- C�digo do Cliente 
                            @mCredito = $252.00 -- Valor de Credito 

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Declare @iIDClienteNovo int = 151      -- C�digo do Cliente 
Declare @mCreditoNovo money = $253.00  -- Valor de Cr�dito 

Execute stp_AtualizaCredito @iidCliente = @iIDClienteNovo,  
                            @mCredito   = @mCreditoNovo 

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

-- Voce pode inverter a ordem da passagem de par�metro?

Execute stp_AtualizaCredito @mCredito = $254.00 , 
                            @iidCliente = 151

Select mCredito , cNome from tCADCliente where iidcliente = 151
go

go



/*
Segundo Exemplo. Funciona, mas n�o � auto documentado. 
N�o aconselho sua utiliza��o.
*/

Execute stp_AtualizaCredito 151, $250.00
go
Select mCredito , cNome from tCADCliente where iidcliente = 151
go

Execute stp_AtualizaCredito 151,  -- C�digo do Cliente 
                            $250.00 -- Valor de Credito 
go

Declare @iIDClienteNovo int = 151      -- C�digo do Cliente 
Declare @mCreditoNovo money = $250.00  -- Valor de Cr�dito 

Execute stp_AtualizaCredito @iIDClienteNovo,  
                            @mCreditoNovo 
go

-- Voce pode inverter a ordem da passagem de par�metro?

Execute stp_AtualizaCredito $250.00 , 150
go

Select mCredito , cNome from tCADCliente where iidcliente = 150
go

Select iIDCliente,cNome, mCredito  
  From tCADCliente 
 Where iidcliente = 250 
go




/*
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 

Vamos usar o script 

*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirPedido
Objetivo   : Realiza a inclus�o de pedido
------------------------------------------------------------*/
Create or Alter Procedure stp_IncluirPedido
@iidCliente int , -- C�digo do Cliente que comprar� o livro
@iidLivro int,    -- C�digo do Livro que ser� comprado
@iidLoja int,     -- C�digo da loja onde a compra foi feita 
@nQuantidade int  -- Quantidade de livros. 
as 
Begin 

   Set nocount on 

   Declare @niIDEvento int = 0   
   Declare @iIDPedido int			   -- C�digo do Pedido 
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
           Raiserror('Estoque do livro %d n�o foi encontrado na filial %d',16,1,@iidLivro,@iidLoja )
         End 

         Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.

         Begin Transaction 

         if @nDebug = 1
            Raiserror('Incluindo Pedido...',10,1) with nowait 

         -- Inseri o cabe�alho do Pedido.
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
            Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 

         -- Atualiza o cr�dito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - (@mValor * @nQuantidade)
          Where iIDCliente = @iidCliente

	      Commit -- 

      End Try 

      Begin Catch 

         If @@TRANCOUNT > 0 -- tem transa��o aberta? 
            Rollback 

         -- Capturou as informa��es de erro 
         Declare @cMensagem varchar(512) ,
                 @nErrorNumber int = ERROR_NUMBER(),
                 @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
                 @nErrorSeverity tinyint = ERROR_SEVERITY(), 
                 @nErrorState tinyint = ERROR_STATE(), 
                 @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
                 @nErrorLine int = ERROR_LINE()

         -- Fez o tratamento, gerando uma �nica mensagem.
         Set @cMensagem = FormatMessage('MsgID %d. '+@cErrorMessage+' Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a grava��o em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

		   Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 

         set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

      End Catch 

   End 

End 
/*
Finaliza a Operaca��o.
*/
go

execute stp_IncluirPedido @iidCliente = 151,
                          @iidLivro = 106,
                          @iidLoja = 9,
                          @nQuantidade = 1 


