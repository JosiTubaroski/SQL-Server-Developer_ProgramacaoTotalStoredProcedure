/*
At� agora, vimos que a execu��o das procedures foram realizadas
pelo SSMS usando o comando EXECUTE.

Mas podemos executar as procedure de diversas formas como um
aplicativo web, servi�o, pacote do SSIS, relat�rio via SSRS, 
agente do windows, agente do SQL Server. 

Mas aqui, utilizaremos uma forma de executar a procedure que 
ser� feito sempre na inicializa��o do servi�o do SQL Server. 

Essa abordagem � interessante quando voce precisa capturar dados
no momento quando o SQL Server incializa, criar objetos nos bancos
de dados ou realizar manuten��es no banco de dados.

Outra fun��o interessante � executar uma procedure que fica em execu��o 
continuamente quando o servi�o � inicializado, fazendo capturas de dados
e armazenando.

Ou mesmo criar tabelas tempor�rias global, existindo continuamente
no banco de dados tempdb.
*/


/*
Criar uma procedure de inicializa��o para criar uma tabela tempor�ria global
no banco de dados TEMPDB.

*/

use master
go
Create or Alter Procedure stp_InicializacaoSQLServer
as
Begin

    Create table ##tTMPTransferenciaCliente
    (
       iIDCliente int not null,
       jDados varchar(max) not null,
       dOcorrencia datetime not null default getdate()
    )

End 
/*
*/
go

select * from  ##tTMPTransferenciaCliente


/*
Incluindo a procedure como inicializa��o do SQL SERVER 
*/


execute sp_procoption @procname = 'stp_InicializacaoSQLServer', 
                      @OptionName = 'STARTUP',
                      @OptionValue = 'ON'
go


Select * 
  From sys.procedures
 Where is_auto_executed = 1




/*
Agora vamos parar o servi�o do SQL SERVER e depois reiniciar. 
*/

/*
Validando a exist�ncia da tabela 
*/

SELECT * FROM  ##tTMPTransferenciaCliente


/*
Voc� pode determinar quantas procedures forem necess�rias
no processo de inicializa��o e cada procedure ser� executada 
utilizando um thread do processador. 

Tamb�m n�o existe um ordem de execu��o da procedures. O SQL 
Server determinar� qual delas ser� executada primeiro.

Uma t�cnica que podemos utilizar � criar uma procedure mestre ou 
principal, colocar somente elas como inicializa��o e dentro dela
efetuar as chamadas para as procedures na ordem que voc� deseja.
*/


Create or Alter Procedure stp_InicializacaoCriarTabelaTemp
as
Begin
   
   Set nocount on 

   Create table ##tTMPTransferenciaCliente
   (
       iIDCliente int not null,
       jDados varchar(max) not null,
       dOcorrencia datetime not null default getdate()
   )

   Create Table ##tTMPMonitoraMemoria 
   (
      dData Datetime default getdate() not null,
      nTamanhoMB int  not null
   )


End 
go

Create or Alter Procedure stp_InicializacaoColetaDMemoria
as
Begin

   While 1=1 Begin

      Insert into ##tTMPMonitoraMemoria (nTamanhoMB)
      Select physical_memory_in_use_kb/1024 from sys.dm_os_process_memory

      Waitfor Delay '00:00:10'

   End 

End 
/*
*/
go



use master
go
Create or Alter Procedure stp_InicializacaoSQLServer
as
Begin

    Execute stp_InicializacaoCriarTabelaTemp

    Execute stp_InicializacaoColetaDMemoria

End 
/*
*/
go

select * from ##tTMPMonitoraMemoria




/*
Tirando a procedure como inicializa��o do SQL SERVER 
*/

execute sp_procoption @procname = 'stp_InicializacaoSQLServer', 
                      @OptionName = 'STARTUP',
                      @OptionValue = 'OFF'



Select * from sys.procedures
where is_auto_executed = 1
