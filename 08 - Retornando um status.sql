https://docs.microsoft.com/pt-br/sql/relational-databases/stored-procedures/return-data-from-a-stored-procedure?view=sql-server-2017

/*
Uma outra forma de retornar valor da procedure é pelo Status 
de operação da procedure, utilizando a instrução RETURN com um 
valor INT para representar um status. 

Return <int> 


*/
use eBook
go

Create or Alter Procedure stp_AtualizaCredito
@iIDCliente int ,
@mCredito money 
as
Begin

   Set nocount on 
   
   Declare @nRetorno int = 0 -- Status de Retorno, assume como 0 - Status OK.

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

      --- Realiza a gravação no Event Viewer.
      --- Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a gravação em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 
      
      -- Como houve uma exceção e gerou um código de evento,
      -- vamos usar esse código como retorno da procedure. 
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 

   Return @nRetorno -- Aqui temos o retorno da procedure.  

End 
/*
Fim da Procedure 
*/
go

use eBook
go


/*
Exemplo 01 
*/
Declare @nStatus int 
Execute @nStatus = stp_AtualizaCredito 54545487, 40
Select @nStatus 

if @nStatus <> 0 
   Select * From tLOGEventos where iIDEvento = @nStatus

go

/*
Exemplo 02 
*/
Begin Try
   declare @nStatus int 
   execute @nStatus = stp_AtualizaCredito 54545487, 40
   if @nStatus > 0
      raiserror('Erro na atualização do crédito',16,1)
End Try 
Begin Catch 
    Raiserror('Ocorreu um erro na atualização. Favor entrar em contato com o suporte e informa o codigo de erro %d',16,1,@nStatus)   
End Catch 
go






/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirPedido
Objetivo   : Realiza a inclusão de pedido
------------------------------------------------------------*/
Create or Alter Procedure stp_IncluirPedido
@iidPedido int OUTPUT, -- ID do Pedido 
@iidCliente int , -- Código do Cliente que comprará o livro
@iidLivro int,    -- Código do Livro que será comprado
@iidLoja int,     -- Código da loja onde a compra foi feita 
@nQuantidade int  -- Quantidade de livros. 
as 
Begin 

   Set nocount on 
      
   Declare @niIDEvento int = 0   
   Declare @mValor smallmoney		   -- Valor do Livro

   Declare @lIncluirPedido bit = 0  -- Para testar se o pedido ser incluído 
   Declare @nRetorno int = 0 
   Declare @nDebug bit = 0

   Begin 

      Begin Try 

         -- Recupera qual o valor do livro de uma determinada loja.
         Select @mValor = (mValor * @nQuantidade)
	        From tRELEstoque 
	       Where iIDLivro = @iidLivro 
	         and iIDLoja = @iidLoja 

         If @@rowcount = 0 begin
           Raiserror('Estoque do livro %d não foi encontrado na filial %d',16,1,@iidLivro,@iidLoja )
         End 

         -- Se o valor do parâmetro iIDPedido for NULL, gera um novo valor 
         If @iIDPedido is null Begin 
            Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.
            set @lIncluirPedido = 1  -- Mudo o valor para indicar que deve incluir o pedido 
         End 

         Begin Transaction 

         if @lIncluirPedido = 1 Begin 

            if @nDebug = 1
               Raiserror('Incluindo Pedido...',10,1) with nowait 

            -- Inseri o cabeçalho do Pedido.
            Insert Into dbo.tMOVPedido           
            (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
            Values
            (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)

         End -- @lIncluirPedido = 1 Begin 
   
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
            
         set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

      End Catch 

   End 

   Return @nRetorno

End 
/*
Finaliza a Operacação.
*/
go 

/*
Ambiente
*/
Select * From tRelEstoque 
where iidloja = 9 
  and iidlivro in (108,113,121)
/*
iIDEstoque  iIDLivro    iIDLoja     nQuantidade mValor                dAlteracao              dUltimoConsumo nQuantidadeMinima
----------- ----------- ----------- ----------- --------------------- ----------------------- -------------- -----------------
53499       108         9           17          49,8844               NULL                    2019-01-17     0
22218       113         9           15          13,2211               NULL                    NULL           0
30126       121         9           146         96,053                NULL                    NULL           0

*/

Select mCredito  from tCADCliente where iidcliente = 8834
go
Select sum(mvalor) From tRelEstoque 
where iidloja = 9 
  and iidlivro in (108,113,121)
go

execute stp_AtualizaCredito @iidcliente = 8834, @mCredito = 50

/*
mCredito
---------------------
9654,8092

Novo
9476.6401


*/

set nocount on 

Declare @nStatus int = 0 

Declare @iIDPedido int = NULL -- Veja que está com NULL 
Declare @iidCliente int = 8834
Declare @iidLivro int = 108
Declare @iidLoja int = 9 
Declare @nQuantidade int = 1


execute @nStatus = stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                                     @iidCliente = @iidCliente,
                                     @iidLivro = @iidLivro,
                                     @iidLoja = @iidLoja,
                                     @nQuantidade = @nQuantidade 

if @nStatus = 0 Begin 
   Set @iidLivro = 113
   execute @nStatus = stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                                        @iidCliente = @iidCliente,
                                        @iidLivro = @iidLivro,
                                        @iidLoja = @iidLoja,
                                        @nQuantidade = @nQuantidade

End

if @nStatus = 0 Begin 
   Set @iidLivro = 121
   execute @nStatus = stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                                        @iidCliente = @iidCliente,
                                        @iidLivro = @iidLivro,
                                        @iidLoja = @iidLoja,
                                        @nQuantidade = @nQuantidade

End 

Raiserror('Pedido gerado %d ', 10,1,@iIDPedido)
if @nStatus <> 0
   Raiserror('Status de erro %d', 10,1,@nStatus)

Select * From tLOGEventos Where iIDEvento = 500038
go

Select * From tRelEstoque 
where iidloja = 9 
  and iidlivro in (108,113,121)

                          
select  * from tMOVPedido where iidPedido = 1664975

select * from tMOVPedidoItem where iidPedido = 1664975
