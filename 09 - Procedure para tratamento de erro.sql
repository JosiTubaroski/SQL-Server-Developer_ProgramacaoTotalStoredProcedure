/*
Neste aula vamos aprender a criar uma procedure para um fim específico.
Será uma procedure genérica e de apoio para outras procedures.

Antes de começar, vamos entender um caso para criar essa procedure.

Vamos analisar os comandos utilizados na área do BEGIN CATCH vistos nas aulas
de transação e da análise da procedure stp_IncluirPedido da aula passada.

Feito a análise e o entendimento, vamos criar uma procedure
para conter todo esse tratamento de erro.

Mas antes, devemos definir:

1. Nome da Procedure?
2. Quais serão os parâmetros de entrada?
3. Quais serão os parâmetros de saída, se existir?
4. Como tratar o retorno do status?
5. Ela retorna um dataset?


1. Nome da procedure : stp_ManipularErros

2. Quais serão os parâmetros de Entrada.  Não há necessidade de parâmetros 
  

*/

use eBook
go

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
     


/*
3. Parâmetros de saida. Neste caso não haverá.

4. Como tratar o retorno.
   
   O código acima tem a atribuição da variável @nRetorno para retornar o status. 
   Ela tem que existir para as procedures que usarem essa, tenha o tratamento retorno
   e o status.

5. Retorna um DataSet. Neste caso, como o tratamento de erro é para 
   gravar em uma tabela, não precisamos retornar um DataSet


Então, vamos construindo a procedure.
*/

go

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Store Procedure
Objeto     : stp_ManipulaErro
Objetivo   : Utilizada na area CATCH para capturas os erros no Event Viewer do Windows
             e para gravar na tabela tLOGEventos.
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 11/01/2019
Execução   : A procedure deve se executada na area de CATCH         
Palavras-chave: Erro, tratamento, catch, avisos
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               11/01/2019 Criação da Procedure 
*/

Create Or Alter Procedure stp_ManipulaErro
as
Begin
   /*
   Área para configuração da sessão 
   */
   Set NoCount on 

   /* 
   Area de Declaração das variáveis
   */
   Declare @nRetorno smallint = 0

   /*
   Área de consistência e validação dos parâmetros.
   */ 
    

   /*
   Área para cálculo e processamento que não 
   precisam de tratamento de erro ou transação.
   */
   
   /*
   Area de finalização e retorno dos dados 
   */

   Return @nRetorno

End
/*
Fim da Procedure stp_ManipulaErro
*/
go


/*
No construção acima, utilizaremos todos os conceitos que aprendemos até agora. 

Na área de configuração da sessão, já definimos o SET NOCOUNT

Em Declaração de variáveis, vamos colocar a definação das variáveis dos erros.

Na área de consistência e validação, não colocaremos nada, por enquanto.

E na área de cálculo e processamento, as etapdas de gravar na tabela.

Por fim, em finalização o retorno do status.


*/
go

use eBook
go

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Store Procedure
Objeto     : stp_ManipulaErro
Objetivo   : Utilizada na area CATCH para capturas os erros no Event Viewer do Windows
             e para gravar na tabela tLOGEventos.
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 11/01/2019
Execução   : A procedure deve se executada na area de CATCH         
Palavras-chave: Erro, tratamento, catch, avisos
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               11/01/2019 Criação da Procedure 
*/

Create Or Alter Procedure stp_ManipulaErro
as
Begin
   /*
   Área para configuração da sessão 
   */
   Set NoCount on 

   /* 
   Area de Declaração das variáveis
   */
   Declare @nRetorno int = 0
   Declare @niIDEvento int = 0 ,
           @cMensagem varchar(512) ,
           @nErrorNumber int = ERROR_NUMBER(),
           @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
           @nErrorSeverity tinyint = ERROR_SEVERITY(), 
           @nErrorState tinyint = ERROR_STATE(), 
           @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
           @nErrorLine int = ERROR_LINE()

   /*
   Área de consistência e validação dos parâmetros.
   */ 

   /*
   Área para cálculo e processamento que não 
   precisam de tratamento de erro ou transação.
   */
   Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
   Set @niIDEvento = next value for seqIIDEvento

   -- Realiza a gravação em uma tabela.
   Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

   /*
   Area de finalização e retorno dos dados 
   */

   Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   Return @nRetorno

End
/*
Fim da Procedure stp_ManipulaErro
*/
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

         Execute @nRetorno = stp_ManipulaErro

      End Catch 

   End 

   Return @nRetorno

End 
/*
Finaliza a Operacação.
*/
go 

use eBook
go

Declare @nStatus int = 0
execute @nStatus = stp_IncluirPedido @iidpedido = null ,
                                     @iidCliente = 8834,
                                     @iidLivro = 106,
                                     @iidLoja = 9,
                                     @nQuantidade = 10000000
Select @nStatus

Select * 
  From tLOGEventos 
 Where iIDEvento = @nStatus


/*
No cenário atual, a conta que você está fazendo os teste tem o 
acesso a tabela tLOGEventos.  

Mas pode ser que outras conta precisarão de acesso neste tabela. 
Para um maior controle, vamos transformar o acesso dos dados 
dessa tabela utilizando views a vamos adicionar algumas colunas 
para melhorar o controle. 

*/

Alter Table tLOGEventos add cUsuario varchar(50) default original_login()
go

use eBook
go


/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vLOGEventos
Objetivo   : Visualizar os eventos de erro 
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 11/01/2019
Execução   : 
Palavras-chave: Erro, tratamento, catch, avisos
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               11/01/2019 Criação da View
*/

Create Or Alter View vLOGEventos
as
Select iIDEvento, dDataHora, cMensagem  
  From tLOGEventos 
 Where cUsuario = original_login()








Declare @nStatus int = 0
execute @nStatus = stp_IncluirPedido @iidpedido = null ,
                                     @iidCliente = 8834,
                                     @iidLivro = 106,
                                     @iidLoja = 9,
                                     @nQuantidade = 10000000
Select @nStatus

Select * 
  From vLOGEventos
 Where iIDEvento = @nStatus



