/*
Separação de execução em blocos ou lote 

GO 

Não é uma instrução SQL Server. 
É um comando da SQL Server Management Studio.
Torna o script legíveis e facilita execuções em lote.

GO indica o fim de execução de um bloco de comandos.

-- Exemplos 
*/
use eBook
go

Select count(1) from tCADCliente -- Total de cadatros tabela Cliente 
Select max(iidPedido) from tMOVPedido -- Ultimo ID da tabela Pedidos
go 
select * from tTabelaNaoExiste
go
Select sum(mValor) from tMOVNotaFiscal
Select top 1 * from tCADLivro
go

/*
Separar execuções de objetos de programação 
*/

Create Or Alter Procedure stp_UltimoPedido
as
Select top 1 * from tMOVPedido order by iIDPedido desc 

execute stp_UltimoPedido

go


-- Forma correta 
Create Or Alter Procedure stp_UltimoPedido
as
Select top 1 * from tMOVPedido order by iIDPedido desc 
go

execute stp_UltimoPedido

go



/*
Exemplo de script que precisa utilizar GO
*/

Drop table if exists tCADRevista

Create Table tCADRevista (iid int, cNome varchar(50))

insert into tCADRevista (iid, cNome) values (1,'Revista Olha')

Create or Alter View vRevista as
Select cNome from tCADRevista

Alter Table tCADRevista add nEdicao int  not null default 0

/*
Msg 111, Level 15, State 1, Line 34
'CREATE VIEW' must be the first statement in a query batch.

A view deve ser a primeira instrução em um lote 
Mas como colocar a view antes de criar a tabela???

*/


Drop table if exists tCADRevista

Create Table tCADRevista (iid int, cNome varchar(50))

Create or Alter View vRevista as
Select cNome from tCADRevista

insert into tCADRevista (iid, cNome) values (1,'Revista Olha')

Alter Table tCADRevista add nEdicao int  not null default 0


/*
Separando por lote 
*/

Drop table if exists tCADRevista
Create Table tCADRevista (iid int, cNome varchar(50))
go

Create or Alter View vRevista as
Select cNome from tCADRevista

insert into tCADRevista (iid, cNome) values (1,'Revista Olha')

Alter Table tCADRevista add nEdicao int  not null default 0


/*

*/


Drop table if exists tCADRevista
Create Table tCADRevista (iid int, cNome varchar(50))
go

Create or Alter View vRevista as
Select cNome from tCADRevista
go

insert into tCADRevista (iid, cNome) values (1,'Revista Olha')

Alter Table tCADRevista add nEdicao int  not null default 0


/*
Utilizando GO com o parâmetro de quantidade de execuções 
*/

Select getdate()
go 2 


Select top 1 * from tCADCliente
go
Select count(1) from tCADLivro
go 2


/*
Exemplo Prático 
*/

Drop table if exists tCADRevista
Create Table tCADRevista (iid int, cNome varchar(50))
go

insert into tCADRevista (iid, cNome) values (rand()*1000,newid() )
go 2000

select * from tCADRevista


/*
Script para monitorar o uso da memória 
*/

Drop table if exists tTMPMonitorMemoria
Create Table tTMPMonitorMemoria (
   dData datetime default getdate(),
   nTamanho decimal(10,6)
)
go

insert into tTMPMonitorMemoria (nTamanho)
select count(1)*8096/1024.0/1024.0 from sys.dm_os_buffer_descriptors
waitfor delay '00:00:10'
go 10

Select * from tTMPMonitorMemoria





