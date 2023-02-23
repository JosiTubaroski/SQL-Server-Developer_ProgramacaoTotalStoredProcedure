/*
Coletando informa��es sobre os erros. 

Na �rea do block CATCH, � poss�vel capturar as informa��es dos erros 
que foram explicados na aula 01-Entendendo os erros dessa se��o.

S�o eles. 

- N�mero do erro. Os que s�o gerados pelo engine do SQL SERVER 
  v�o at� o valor 49.999. Voce pode criar suas mensagem de erros com 
  n�meros acima de 50.000.
  
- Mensagem de erro. Mensagem com informa��es sobre o erro e em alguns caso
  cont�m informa��es sobre objetos, colunas, valores entre outros.

- Severidade. Indica a gravidade do erro. Alguns casos s�o informa��es,
  aviso ou erros 

- Estado. Com uma mensagem de erro pode ser tratada de v�rias formas, o 
          estado pode indicar, por exemplo, como o erro pode ser corrigido

- Procedimento - Nome do objetos de programa��o onde o erro ocorreu. Pode
                 ser uma procedure ou trigger.

- Linha -  Indica a linha dentro do procedimento onde ocorreu o erro. Em caso
           de execu��o em lote, a linha dentro do lote. 

Essas informa��es sobre os erros somente s�o acess�veis se :

1. A captura ocorrer no bloco CATCH e 
2. Utilizar as seguintes fun��es:

   ERROR_NUMBER() 
   ERROR_MESSAGE() 
   ERROR_SEVERITY() 
   ERROR_STATE() 
   ERROR_PROCEDURE() 
   ERROR_LINE() 


Exemplos 
*/
use eBook
go

Begin Try
     select 1/0
End Try

Begin Catch
   Print ERROR_NUMBER() 
   Print ERROR_MESSAGE() 
   Print ERROR_SEVERITY() 
   Print ERROR_STATE() 
   Print ERROR_PROCEDURE() 
   Print ERROR_LINE() 
End Catch

/*
Aten��o!! Essa fun��es somente retornam os valores do erro
quando utilizadas dentro o CATCH.
O uso delas fora da �rea do CATCH, sempre retornam o NULL !!
*/

/*
Diferen�a entre @@ERROR e o ERROR_NUMBER() 

- @@ERROR deve ser capturado logo ap�s a execu��o do comando.
  Quando o comando ap�s a ocorr�ncia do erro for executado,
  o valor de @@ERROR ser� 0.

- ERROR_NUMBER() mant�m o c�digo do erro durante toda a execu��o
  do bloco CATCH. 

*/

-- Exemplo de atualiza��o de dados com erro
-- � utilizado o @ERROR 

sp_help tCADCliente  


-- Vai ocorrer o erro 
Update tCADCliente 
   Set mCredito = 0    -- Terceiro erro, viola��o da restri��o CHECK  
Where iIDCliente = 33612
go


-- Simulando...
use eBook
go

Begin 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que ser� alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 
   Declare @nCodigoErro int = 0  -- Armazena o c�digo do erro  

   Set @iIDCliente = 33612

   Begin Try
      
       -- Simula o primeiro erro 
       Select @cNome = cNome ,--+  ' Industrias.' , 
              @mCredito = mCredito
         From tCADCliente
        Where iIDCliente = @iIDCliente 
       
       If @mCredito < 20 

          Update tCADCliente 
             Set cNome = @cNome, -- Segundo erro, dados truncados 
                 mCredito = 0    -- Terceiro erro, viola��o da restri��o CHECK  
           Where iIDCliente = 33612
       
   End Try

   Begin Catch 

      --Set @nCodigoErro = @@ERROR

      -- Os dados de cadeia ou bin�rios ficariam truncados.
      If @@ERROR = 8152
         Raiserror('Erro 8152. Os dados de cadeia ou bin�rios ficariam truncados.',10,1)
      
      -- Conflito entre a instru��o UPDATE e a restri��o CHECK 
      -- "CK__tCADClien__mCred__3D5E1FD2". O conflito ocorreu na base de 
      -- dados "eBook", tabela "dbo.tCADCliente", column 'mCredito'.

      If @@ERROR = 547
         Raiserror('Erro 547. Conflito entre a instru��o UPDATE e a restri��o CHECK.' ,10,1)
      Else 
         Print 'Codigo de error ' + cast(@nCodigoErro as varchar(10))

   End Catch 

End 
/*
Fim do Exemplo 
*/



-- Exemplo de atualiza��o de dados com erro
-- � utilizado o ERROR_NUMBER()
use eBook
go

Begin 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que ser� alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome ,--+  ' Industrias.' , 
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
      -- Os dados de cadeia ou bin�rios ficariam truncados.
      If ERROR_NUMBER()  = 8152
         Raiserror('Erro 8152. Os dados de cadeia ou bin�rios ficariam truncados.',10,1)
      
      -- Conflito entre a instru��o UPDATE e a restri��o CHECK 
      -- "CK__tCADClien__mCred__3D5E1FD2". O conflito ocorreu na base de 
      -- dados "eBook", tabela "dbo.tCADCliente", column 'mCredito'.
      If ERROR_NUMBER() = 547
         Raiserror('Erro 547. Conflito entre a instru��o UPDATE e a restri��o CHECK.' ,10,1)
      Else 
         Print 'Codigo de error ' + cast(ERROR_NUMBER()  as varchar(10))

   End Catch 

End 
/*
Fim do Exemplo 
*/





/*
Come�ando a montar um rotina completa de tratamento de erro.

Vamos come�ar com a captura do erro e o tratamento da mensagem.
Depois veremos como armazenar essa mensagem e complementar com outras
informa��es.

No tratamento, vamos usar a fun��o FORMATMESSAGE()

https://docs.microsoft.com/pt-br/sql/t-sql/functions/formatmessage-transact-sql?view=sql-server-2017



*/

Select FormatMessage('Ocorre um erro na execu��o da Procedure.')

Select FormatMessage('Ocorre um erro %d na execu��o da Procedure', 2500)

Select FormatMessage('Ocorre um erro %d na execu��o da Procedure %s', 2500 ,'stp_IncluirCliente')



/*
Catpura e tratamento da mensagem de erro.
*/
use eBook
go

Begin 

   set nocount on 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que ser� alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 

   Declare @nRetorno int = 0 

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome +  ' Industrias.' , 
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
      
      Declare @cMensagem varchar(200) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)

      Raiserror(@cMensagem,10,1)

      set @nRetorno = @nErrorNumber

   End Catch 
   
End 

/*
Fim do Exemplo 
*/

