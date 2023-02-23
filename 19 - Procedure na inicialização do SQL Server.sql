/*
Até agora, vimos que a execução das procedures foram realizadas
pelo SSMS usando o comando EXECUTE.

Mas podemos executar as procedure de diversas formas como um
aplicativo web, serviço, pacote do SSIS, relatório via SSRS, 
agente do windows, agente do SQL Server. 

Mas aqui, utilizaremos uma forma de executar a procedure que 
será feito sempre na inicialização do serviço do SQL Server. 

Essa abordagem é interessante quando voce precisa capturar dados
no momento quando o SQL Server incializa, criar objetos nos bancos
de dados ou realizar manutenções no banco de dados.

Outra função interessante é executar uma procedure que fica em execução 
continuamente quando o serviço é inicializado, fazendo capturas de dados
e armazenando.

Ou mesmo criar tabelas temporárias global, existindo continuamente
no banco de dados tempdb.
*/


/*
Criar uma procedure de inicialização para criar uma tabela temporária global
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
Incluindo a procedure como inicialização do SQL SERVER 
*/


execute sp_procoption @procname = 'stp_InicializacaoSQLServer', 
                      @OptionName = 'STARTUP',
                      @OptionValue = 'ON'
go


Select * 
  From sys.procedures
 Where is_auto_executed = 1




/*
Agora vamos parar o serviço do SQL SERVER e depois reiniciar. 
*/

/*
Validando a existência da tabela 
*/

SELECT * FROM  ##tTMPTransferenciaCliente


/*
Você pode determinar quantas procedures forem necessárias
no processo de inicialização e cada procedure será executada 
utilizando um thread do processador. 

Também não existe um ordem de execução da procedures. O SQL 
Server determinará qual delas será executada primeiro.

Uma técnica que podemos utilizar é criar uma procedure mestre ou 
principal, colocar somente elas como inicialização e dentro dela
efetuar as chamadas para as procedures na ordem que você deseja.
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
Tirando a procedure como inicialização do SQL SERVER 
*/

execute sp_procoption @procname = 'stp_InicializacaoSQLServer', 
                      @OptionName = 'STARTUP',
                      @OptionValue = 'OFF'



Select * from sys.procedures
where is_auto_executed = 1
