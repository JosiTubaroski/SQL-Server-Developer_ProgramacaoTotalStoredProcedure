/*
Tratamento de erros com Transação. 

Quanto implementamos o tratamento de erro em um 
solução ou regra de negócio, devemos também
sempre nós ater ao processo de transação. 

- Se não ocorreu erro na transação, voce deve confirmar.
- Se ocorreu algum erro na transação, temos duas opções. 

   1. - Você reverte a transação 
      - Registra o evento de erro e informações adicionais
        em uma tabela ou log do SQL SERVER 
      - Retorna o código de registro do evento de erro.

   2. - Você reverte a transação 
      - Você avalia qual o tipo do erro 
      - Dependendo do tipo de erro, você reinicia o processo novamente. 
      - Controlar quantas vezes voce deve executar esse procedimento.
      - Por fim, registra o evento em tabela.
      - Retorna o código do registro do evento. 
      
No caso do item 2, o erros como timeout de bloqueio e deadlocks 
são passíveis de repetição do processo.

- Vamos utilizar TRY CATCH com COMMIT OU ROLLBACK 
  e como encaixar esses comandos. 


Exemplo : Reverte a transação e Retorna um código.

-------------------
<Blocos de comandos> 

Begin Try

   Begin Transaction 

   <Comandos...>
   <Comandos...>
   <Comandos...>   

   Commit 

End Try

Begin Catch

   if @@trancount > 0
      Rollback 

   <Comandos...>
   <Comandos...>
   <Comandos...>

   Return <Código de Registro>

End Catch 

<Blocos de comandos> 

/*
Exemplo : Você avalia qual o tipo do erro e 
          reinicia o processo novamente. 
*/
*/


-- <Blocos de comandos> 

Declare @nContagemErro tinyint = 3 -- Número de Tentativas de repetir o processo. 

While @nContagemErro > 0 Begin 

   Begin Try

      Begin Transaction 

      --<Comandos...>
      --<Comandos...>
      --<Comandos...>
      --<Comandos...>
      --<Comandos...>
      --<Comandos...>   

      Commit 
      Set @nContagemErro = 0 

   End Try

   Begin Catch

      Declare @nErrorNumber int = ERROR_NUMBER()

      if @@trancount > 0
         Rollback 
      
      if @nErrorNumber in ( /*<Lista de Error>*/ )  Begin
         WaitFor Delay '00:00:10' 
         Set @nContagemErro -= 1 -- Diminui a contagem 
      End 
      
      --<Comandos...>
      --<Comandos...>
      --<Comandos...>

      IF @nContagemErro = 0 
         Return -- <Código de Registro>
   
   End Catch 

   -- <Blocos de comandos> 

End -- While nContagemErro > 0 

--<Blocos de comandos> 

*/

---------------------------------------------------------------------
-- Exemplos 

/*
Rotina que faz um pedido, atualiza o estoque e 
o crédito do Cliente. 
*/

use eBook
go

Set nocount on  

Declare @iidCliente int = 8834	-- Código do Cliente que comprará o livro
Declare @iidLivro int = 106		-- Código do Livro que será comprado
Declare @iidLoja int = 9		   -- Código da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- Código do Pedido 
Declare @mValor smallmoney		   -- Valor do Livro

Declare @nRetorno int = 0 -- Retorna o código do evento

Begin 

   -- Recupera qual o valor do livro de uma determinada loja.
   Select @mValor = mValor 
	  From tRELEstoque 
	 Where iIDLivro = @iidLivro 
	   and iIDLoja = @iidLoja 
   
   Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.

   Begin Try 

      Begin Transaction 

      Raiserror('Incluindo Pedido %d ...',10,1,@iIDPedido ) with nowait 
      -- Inseri o cabeçalho do Pedido.

      Insert Into dbo.tMOVPedido           
      (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
      Values
      (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)
       
      Raiserror('Incluindo Item de Pedido...',10,1) with nowait 
      -- Inseri o Item do Pedido
      Insert Into tMOVPedidoItem
      (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
      Values
      (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

      Raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
      -- Atualiza o saldo do estoque do livro para a loja
      Update tRELEstoque 
         Set nQuantidade = nQuantidade - @nQuantidade 
       Where iIDLivro = @iidLivro 
         and iIDLoja = @iidLoja 

      Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 
      -- Atualiza o crédito do cliente. 
      Update tCADCliente 
         Set mCredito = mCredito - @mValor 
       Where iIDCliente = @iidCliente

	   Commit -- 

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

      Raiserror(@cMensagem,10,1)

      set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 
End 
/*
Finaliza a Operacação.
*/


/*
Analise 
*/

Select * from tLOGEventos


/*
---------------------------------------------------------------------
Tratamento de erro de TIMEOUT de bloqueio 

Características do código.

- Se ocorrer timeout, o código realizará 3 tentativas de execução;
- Teremos a instrução WHILE para controlar essa contagem;
- Se ocorrer o COMMIT, total de tentativas é zerado;
- Se ocorrer o erro 1222, registra o erro e aguarde 10 segundos 
  para um nova tentativa;
- Se o erro for diferente de 1222, registra o erro e finaliza o código

*/


/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go

Declare @iidCliente int = 8834	-- Código do Cliente que comprará o livro
Declare @iidLivro int = 106		-- Código do Livro que será comprado
Declare @iidLoja int = 9		   -- Código da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- Código do Pedido 
Declare @mValor smallmoney		   -- Valor do Livro

Declare @nRetorno int = 0 
Declare @nContagemErro tinyint = 3   -- Numero de Tentativas de repetir o processo. 

Begin 

   set lock_timeout 5000 -- Espera o bloqueio por 5 segundos. 

   While @nContagemErro > 0 Begin 

      -- Recupera qual o valor do livro de uma determinada loja.
      Select @mValor = mValor 
	     From tRELEstoque 
	    Where iIDLivro = @iidLivro 
	      and iIDLoja = @iidLoja 
   
      Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.

      Begin Try 

         Begin Transaction 

         Raiserror('Incluindo Pedido...',10,1) with nowait 
         -- Inseri o cabeçalho do Pedido.
         Insert Into dbo.tMOVPedido           
         (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
         Values
         (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)
   
         Raiserror('Incluindo Item de Pedido...',10,1) with nowait 
         -- Inseri o Item do Pedido
         Insert Into tMOVPedidoItem
         (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
         Values
         (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

         Raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
         -- Atualiza o saldo do estoque do livro para a loja
         Update tRELEstoque 
            Set nQuantidade = nQuantidade - @nQuantidade 
          Where iIDLivro = @iidLivro 
            and iIDLoja = @iidLoja 

         Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 
         -- Atualiza o crédito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - @mValor 
          Where iIDCliente = @iidCliente

	      Commit  
         Set @nContagemErro = 0   

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

         If @nErrorNumber = 1222  Begin
            WaitFor Delay '00:00:10' 
            Set @nContagemErro -= 1
         End 
         Else 
            Set @nContagemErro = 0
         
         -- Fez o tratamento, gerando uma única mensagem.

         Set @cMensagem = 'MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d. Tentativa %d'
         Set @cMensagem = FormatMessage(@cMensagem,@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine,@nContagemErro)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a gravação em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

         Raiserror(@cMensagem,10,1)-- Somente está aqui para demonstrar a mensagem de erro. 

         If @nContagemErro = 0 
            Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

      End Catch 

   End -- While @nContagemErro > 0 

End 
/*
Finaliza a Operacação.
*/

Select * from tLOGEventos



/*
---------------------------------------------------------------------
Incluindo tratamento de erro por DeadLock 
*/


/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go

Declare @iidCliente int = 8834	-- Código do Cliente que comprará o livro
Declare @iidLivro int = 106		-- Código do Livro que será comprado
Declare @iidLoja int = 9		   -- Código da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- Código do Pedido 
Declare @mValor smallmoney		   -- Valor do Livro

Declare @nRetorno int = 0 
Declare @nContagemErro tinyint = 3   -- Numero de Tentativas de repetir o processo. 

Begin 

   set lock_timeout 5000 -- Espera o bloqueio por 5 segundos. 

   While @nContagemErro > 0 Begin 

      -- Recupera qual o valor do livro de uma determinada loja.
      Select @mValor = mValor 
	     From tRELEstoque 
	    Where iIDLivro = @iidLivro 
	      and iIDLoja = @iidLoja 
   
      Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.

      Begin Try 

         Begin Transaction 

         -- Raiserror('Incluindo Pedido...',10,1) with nowait 
         -- Inseri o cabeçalho do Pedido.
         Insert Into dbo.tMOVPedido           
         (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
         Values
         (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)
   
         -- Raiserror('Incluindo Item de Pedido...',10,1) with nowait 
         -- Inseri o Item do Pedido
         Insert Into tMOVPedidoItem
         (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
         Values
         (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

         -- Raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
         -- Atualiza o saldo do estoque do livro para a loja
         Update tRELEstoque 
            Set nQuantidade = nQuantidade - @nQuantidade 
          Where iIDLivro = @iidLivro 
            and iIDLoja = @iidLoja 

         --Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 
         -- Atualiza o crédito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - @mValor 
          Where iIDCliente = @iidCliente

	      Commit  
         Set @nContagemErro = 0   

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

         If @nErrorNumber in (1222,1205)  Begin
            WaitFor Delay '00:00:10' 
            Set @nContagemErro -= 1
         End 
         Else 
            Set @nContagemErro = 0

         -- Fez o tratamento, gerando uma única mensagem.

         Set @cMensagem = 'MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d. Tentativa %d'
         Set @cMensagem = FormatMessage(@cMensagem,@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine,@nContagemErro)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a gravação em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

         --Raiserror(@cMensagem,10,1)

         If @nContagemErro = 0 
            Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

      End Catch 

   End -- While 
End 
Select @nRetorno as 'Retorno'


/*
Finaliza a Operacação.
*/




