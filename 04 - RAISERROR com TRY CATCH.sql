/*
Função RAISERROR.

Ela tem duas funções quando executada.  

- Primeira e gerar um mensagem de aviso, devolvendo para o cliente a mensagem.
- Somente mensagem com severidade até 10 geram mensagem de avisos. 

*/
use eBook
go

Begin
   set nocount on 
   Begin Try 

      Select top 1 * from tCADCliente 
      raiserror('Processo completado com sucesso',10,1)

   End Try 
   Begin Catch 

      raiserror('Tratamento de erros ',10,1)

   End Catch 
End 

/*

- Segunda é gerar uma exceção (ou um erro) retornando um 
  mensagem de aviso, devolvendo para o cliente a mensagem de erro.

- Se o RAISERROR estiver dentro de um bloco TRY, o fluxo será desviado 
  automaticamente para o bloco CATCH. 

- Se o RAISERROR estiver dentro de um bloco CATCH, será gerando um 
  erro, apresentado a mensagem e retornado para o cliente. 

- Mensagens com severidade acima de 10 geram uma exceção.
*/

use eBook
go

Begin
   set nocount on 
   Begin Try 

      Select top 1 * from tCADCliente where iIDCliente = 344545345

      If @@ROWCOUNT = 0 
         Raiserror('Cliente não foi encontrado',11,1)

   End Try 
   Begin Catch 

      Raiserror('Tratamento de erros ',10,1)

   End Catch 
End 

/*
Existe duas formas de gerar uma exceção pela programação.

- Instruções T-SQL que apresentam erros.
- Execução da função RAISSEROR() 

*/


/*
Parâmetros do função RAISERROR()

A função aceita 3 parâmetros obrigatórios:

- Cadeia de caracters com a mensagem de erro ou número da mensagem de erro.
- Código da severidade 
- Códido do status entre 1 e 255. Fora desse valores o SQL Server converte
  para a faixa entre 1 e 255.

*/

Raiserror('Tratamento de erros ',10,0)
Raiserror('Tratamento de erros ',12,0)
Raiserror('Tratamento de erros ',16,0) -- Indica erros gerais que podem ser corrigidos pelo usuário.

/*
- Utilizar severidade acima de 19 são criados pelo administradores 
  e deve usar o parâmetro WITH LOG. Com isso, os eventos do RAISSERROR()
  serão gravados no arquivo de Log de erros do SQL Server. 
*/

Raiserror('Tratamento de erros sem usar o Log do SQL Server',16,0) 
Raiserror('Tratamento de erros usando o Log do SQL Server',16,0) WITH LOG 

Raiserror('Erro na gravação da tabela tCADCliente',19,0) 
Raiserror('Erro na gravação da tabela tCADCliente',19,0) WITH LOG


/*
Procedure para leitura do LOG de Eventos (erros) do SQL SERVER. 
*/
Execute sp_readerrorlog  0 , 1, 'tCADCliente'

/*
LogDate        - Data do Log
ProcessInfo    - Processo do SQL Server 
Text           - Mensagem do LOG 
*/


-- Demonstrar via SSMS !!!

/*
Montagem a mensagem em tempo de execução.

Você pode usar a montagem da mensagem em tempo de execução
antes de usar o RAISERROR() 

*/

Declare @cMensagemErro varchar(100)
Set @cMensagemErro = 'Erro na execução da instrução. '
Raiserror(@cMensagemErro,16,1)
go

Declare @cMensagemErro varchar(100)
Declare @iidCliente int = 100 
Set @cMensagemErro = 'Codigo do cliente '+ CAST(@iidCliente as varchar(10))+' não foi encontrado.'
Raiserror(@cMensagemErro,16,1)
go

Declare @cMensagemErro varchar(100)
Declare @iidCliente int = 100 
Declare @cTabela varchar(100) = 'tCADCliente' 
Set @cMensagemErro = 'Codigo do cliente '+ CAST(@iidCliente as varchar(10))+' não foi encontrado na tabela '+ @cTabela+'.'
Raiserror(@cMensagemErro,16,1)
go


/*
Montar em tempo de execução com a função RAISERROR() 

- A cadeia de caracteres deve conter conversões inseridas. 
- Essas conversões são semelhantes ao parâmetros de substituição
  utiliza na função PRINTF() da Linguagem C.

*/

-- Substituição %d substitui um INT
Declare @iidCliente int = 100 
Raiserror('Codigo do cliente %d não foi encontrado.',16,1,@iidCliente)
go

-- Substituição %s substitui uma STRING 
Declare @iidCliente int = 100 
Declare @cTabela varchar(100) = 'tCADCliente' 
Raiserror('Codigo do cliente %d não foi encontrado na tabela %s.',16,1,@iidCliente,@cTabela)
go

/*
Passando uma data como parâmetro 
*/
Declare @dDataPesquisa datetime 
set @dDataPesquisa = GETDATE()
Raiserror('Não existe linhas para a data %d',16,1,@dDataPesquisa)
go

Declare @cDataPesquisa varchar(20)
set @cDataPesquisa = convert(varchar(20), GETDATE(),120)

Raiserror('Não existe linhas para a data %s,',16,1,@cDataPesquisa)
go
