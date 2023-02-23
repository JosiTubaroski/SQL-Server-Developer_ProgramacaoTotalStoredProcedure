/*
Armazenando uma mensagem de erro.

O que você precisa ter em mente quando está desenvolvendo uma
rotina tanto na camada da aplicação ou na camada de banco de
dados, é que em algum momento do seu código irá gerar um error.

Como desenvolvedor, você deve conhecer as boas práticas no 
tratamento do eventos de erros. 

E muitos não tem a conciência de:

- Captura o erro corretamente.
- Dar o devido tratamento.
- Gravar o erro em tabela, arquivo ou log para posterior análise.
- Agregar informações além das contidas na mensagem de erro. 
- Importante!! Jamais expôr a mensagem de erro original para a 
  aplicação. 

Uma boa prática é você adotar no nomento do 
desenvolvimento os 5 pontos acima. 

Nós já fizemos uma parte desse itens. 

- Já sabemos como capturar o erro. Estamos usando o bloco
  TRY e CATCH. 

- E como tratar o errro. No bloco CATCH, capturamos as 
  informações do erro e fizemos um tratamento, criando um 
  única mensagem com todas as informações. 

Agora temos que armazenar essa mensagem em algum lugar 
para que possamos consultar e analisar posteriormente. 

Nesta demonstração, colocaremos os dados em uma tabela.

*/


/*
Usando uma Tabela 
---------------------
*/

-- Vamos criar uma tabela para armazenar os erros. 
use eBook
go

Drop Table if exists tLOGEventos
go

Drop Sequence if exists seqIIDEvento 
go

Create Sequence seqIIDEvento as int start with 1 increment by 1
go

Drop Table if exists tLOGEventos

Create Table tLOGEventos
(
   iIDEvento int not null default (next value for seqIIDEvento),
   dDataHora datetime not null default getdate(),
   cMensagem varchar(512) not null check(cMensagem <> ''),
   Constraint PKEvento Primary Key (iIDEvento)
)

/*
No exemplo, utilizei apenas um coluna (cMensagem) para armazenar 
toda a mensagem. É uma estrategia.

Você pode colocar as informações em colunas separadas. 
Vamos fazer isso mais adiante quando falar em Procedures.

*/

use eBook
go

Begin 

   set nocount on 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que será alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 

   Declare @nRetorno int = 0 

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome ,-- +  ' Industrias.' , 
              @mCredito = mCredito
         From tCADCliente
        Where iIDCliente = @iIDCliente 
       
       If @mCredito < 20 

          Update tCADCliente 
             Set cNome = @cNome, -- Primeiro erro, dados truncados 
                 mCredito = 0    -- Segundo erro, violação da restrição CHECK  
           Where iIDCliente = 33612
       
   End Try

   Begin Catch 
      
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

      set @niIDEvento = Next Value For seqIIDEvento
      -- Realiza a gravação em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

      Raiserror(@cMensagem,10,1)

      Set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

   End Catch 
   
End 

/*
Fim do Exemplo 
*/

-- Analisando os erros 
Select * from tLOGEventos

/*
Agregando informações adicionais

São informações que não estão relacionadas diretamente ao erro,
mas ajudam no processo de análise. 

A mensagem de erro ocorreu em qual banco de dados?
Qual a conta de logon no momento do erro?
Qual a data e hora de logon ?
O nome da aplicação?
O IP e o nome do computador do Cliente?

*/

Select connect_time, 
       client_net_address, 
       host_name, program_name , 
       login_name 
  From sys.dm_exec_connections as conn 
  Join sys.dm_exec_sessions as session 
    On conn.session_id = session.session_id 
 Where conn.session_id = @@spid
go

/*
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-connections-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql?view=sql-server-2017
*/

Declare @cMensagemComplemento varchar(512) 

Select @cMensagemComplemento = 'Banco de Dados :'+DB_name()+char(13)+
      'Login :'+ session.login_name +char(13)+
      'Tempo de Conexão :'+ convert(varchar(20),conn.connect_time, 120)+char(13)+
      'IP : '+conn.client_net_address+char(13)+
      'Computador : '+ session.host_name+char(13)+
      'Aplicação : '+ session.program_name 
 From sys.dm_exec_connections as conn 
 Join sys.dm_exec_sessions as session 
   On conn.session_id = session.session_id 
Where conn.session_id = @@spid

Select @cMensagemComplemento



/*
Adicionando mais informações ao erro. 
*/
use eBook
go

Begin 

   set nocount on 

   Declare @cNome varchar(100)   -- Recebe o nome do Cliente
   Declare @iIDCliente int       -- Recebe o ID do cleinte que será alterado 
   Declare @mCredito smallmoney  -- Recebe o valor de credito concedido para o Cliente 

   Declare @nRetorno int = 0 

   Set @iIDCliente = 33612

   Begin Try
      
       Select @cNome = cNome ,-- +  ' Industrias.' , 
              @mCredito = mCredito
         From tCADCliente
        Where iIDCliente = @iIDCliente 
       
       If @mCredito < 20 

          Update tCADCliente 
             Set cNome = @cNome, -- Primeiro erro, dados truncados 
                 mCredito = 0    -- Segundo erro, violação da restrição CHECK  
           Where iIDCliente = 33612
       
   End Try

   Begin Catch 
      
      -- Capturou as informações de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @cMsgCompl varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma única mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)

      -- Agregar mais informações. 
      Select @cMsgCompl = 'Banco de Dados: '+DB_name()+char(13)+
                          'Login: '+ login_name +char(13)+
                          'Tempo de Conexão: '+ convert(varchar(20),connect_time, 120)+char(13)+
                          'IP: '+client_net_address+char(13)+
                          'Computador: '+ host_name+char(13)+
                          'Aplicação: '+ program_name 
                      From sys.dm_exec_connections as conn 
                      Join sys.dm_exec_sessions as session 
                        On conn.session_id = session.session_id 
                     Where conn.session_id = @@spid

      Set @cMensagem = @cMensagem + char(13)+@cMsgCompl

      Set @niIDEvento = Next Value For seqIIDEvento

      -- Realiza a gravação em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

      Raiserror(@cMensagem,10,1)

      set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

   End Catch 
   
End 

/*
Fim do Exemplo 
*/
