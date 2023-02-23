/*
Tratamento de erros com Transa��o. 

Quanto implementamos o tratamento de erro em um 
solu��o ou regra de neg�cio, devemos tamb�m
sempre n�s ater ao processo de transa��o. 

- Se n�o ocorreu erro na transa��o, voce deve confirmar.
- Se ocorreu algum erro na transa��o, temos duas op��es. 

   1. - Voc� reverte a transa��o 
      - Registra o evento de erro e informa��es adicionais
        em uma tabela ou log do SQL SERVER 
      - Retorna o c�digo de registro do evento de erro.

   2. - Voc� reverte a transa��o 
      - Voc� avalia qual o tipo do erro 
      - Dependendo do tipo de erro, voc� reinicia o processo novamente. 
      - Controlar quantas vezes voce deve executar esse procedimento.
      - Por fim, registra o evento em tabela.
      - Retorna o c�digo do registro do evento. 
      
No caso do item 2, o erros como timeout de bloqueio e deadlocks 
s�o pass�veis de repeti��o do processo.

- Vamos utilizar TRY CATCH com COMMIT OU ROLLBACK 
  e como encaixar esses comandos. 


Exemplo : Reverte a transa��o e Retorna um c�digo.

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

   Return <C�digo de Registro>

End Catch 

<Blocos de comandos> 

/*
Exemplo : Voc� avalia qual o tipo do erro e 
          reinicia o processo novamente. 
*/
*/


-- <Blocos de comandos> 

Declare @nContagemErro tinyint = 3 -- N�mero de Tentativas de repetir o processo. 

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
         Return -- <C�digo de Registro>
   
   End Catch 

   -- <Blocos de comandos> 

End -- While nContagemErro > 0 

--<Blocos de comandos> 

*/

---------------------------------------------------------------------
-- Exemplos 

/*
Rotina que faz um pedido, atualiza o estoque e 
o cr�dito do Cliente. 
*/

use eBook
go

Set nocount on  

Declare @iidCliente int = 8834	-- C�digo do Cliente que comprar� o livro
Declare @iidLivro int = 106		-- C�digo do Livro que ser� comprado
Declare @iidLoja int = 9		   -- C�digo da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- C�digo do Pedido 
Declare @mValor smallmoney		   -- Valor do Livro

Declare @nRetorno int = 0 -- Retorna o c�digo do evento

Begin 

   -- Recupera qual o valor do livro de uma determinada loja.
   Select @mValor = mValor 
	  From tRELEstoque 
	 Where iIDLivro = @iidLivro 
	   and iIDLoja = @iidLoja 
   
   Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.

   Begin Try 

      Begin Transaction 

      Raiserror('Incluindo Pedido %d ...',10,1,@iIDPedido ) with nowait 
      -- Inseri o cabe�alho do Pedido.

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

      Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 
      -- Atualiza o cr�dito do cliente. 
      Update tCADCliente 
         Set mCredito = mCredito - @mValor 
       Where iIDCliente = @iidCliente

	   Commit -- 

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

      Raiserror(@cMensagem,10,1)

      set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch 
End 
/*
Finaliza a Operaca��o.
*/


/*
Analise 
*/

Select * from tLOGEventos


/*
---------------------------------------------------------------------
Tratamento de erro de TIMEOUT de bloqueio 

Caracter�sticas do c�digo.

- Se ocorrer timeout, o c�digo realizar� 3 tentativas de execu��o;
- Teremos a instru��o WHILE para controlar essa contagem;
- Se ocorrer o COMMIT, total de tentativas � zerado;
- Se ocorrer o erro 1222, registra o erro e aguarde 10 segundos 
  para um nova tentativa;
- Se o erro for diferente de 1222, registra o erro e finaliza o c�digo

*/


/*
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 
*/

use eBook
go

Declare @iidCliente int = 8834	-- C�digo do Cliente que comprar� o livro
Declare @iidLivro int = 106		-- C�digo do Livro que ser� comprado
Declare @iidLoja int = 9		   -- C�digo da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- C�digo do Pedido 
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
   
      Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.

      Begin Try 

         Begin Transaction 

         Raiserror('Incluindo Pedido...',10,1) with nowait 
         -- Inseri o cabe�alho do Pedido.
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

         Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 
         -- Atualiza o cr�dito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - @mValor 
          Where iIDCliente = @iidCliente

	      Commit  
         Set @nContagemErro = 0   

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

         If @nErrorNumber = 1222  Begin
            WaitFor Delay '00:00:10' 
            Set @nContagemErro -= 1
         End 
         Else 
            Set @nContagemErro = 0
         
         -- Fez o tratamento, gerando uma �nica mensagem.

         Set @cMensagem = 'MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d. Tentativa %d'
         Set @cMensagem = FormatMessage(@cMensagem,@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine,@nContagemErro)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a grava��o em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

         Raiserror(@cMensagem,10,1)-- Somente est� aqui para demonstrar a mensagem de erro. 

         If @nContagemErro = 0 
            Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

      End Catch 

   End -- While @nContagemErro > 0 

End 
/*
Finaliza a Operaca��o.
*/

Select * from tLOGEventos



/*
---------------------------------------------------------------------
Incluindo tratamento de erro por DeadLock 
*/


/*
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 
*/

use eBook
go

Declare @iidCliente int = 8834	-- C�digo do Cliente que comprar� o livro
Declare @iidLivro int = 106		-- C�digo do Livro que ser� comprado
Declare @iidLoja int = 9		   -- C�digo da loja onde a compra foi feita 
Declare @nQuantidade int = 1	   -- Quantidade de livros. 
Declare @iIDPedido int			   -- C�digo do Pedido 
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
   
      Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.

      Begin Try 

         Begin Transaction 

         -- Raiserror('Incluindo Pedido...',10,1) with nowait 
         -- Inseri o cabe�alho do Pedido.
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

         --Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 
         -- Atualiza o cr�dito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - @mValor 
          Where iIDCliente = @iidCliente

	      Commit  
         Set @nContagemErro = 0   

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

         If @nErrorNumber in (1222,1205)  Begin
            WaitFor Delay '00:00:10' 
            Set @nContagemErro -= 1
         End 
         Else 
            Set @nContagemErro = 0

         -- Fez o tratamento, gerando uma �nica mensagem.

         Set @cMensagem = 'MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d. Tentativa %d'
         Set @cMensagem = FormatMessage(@cMensagem,@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine,@nContagemErro)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a grava��o em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

         --Raiserror(@cMensagem,10,1)

         If @nContagemErro = 0 
            Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

      End Catch 

   End -- While 
End 
Select @nRetorno as 'Retorno'


/*
Finaliza a Operaca��o.
*/




