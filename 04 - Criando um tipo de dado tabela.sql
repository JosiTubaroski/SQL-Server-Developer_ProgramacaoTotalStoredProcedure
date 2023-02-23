/*
O SQL Server tem um recurso para os desenvolvedores que
permitem criarem os seus pr�prios tipos de dados com base
nos tipos j� existentes no SQL SERVER.

Conhecidos como User Data Types, s�o tipos de dados
utilizados na defini��o de estrutura de tabelas,
declara��o de vari�veis e nos par�metros de procedure
e fun��es. 

Create Type <Nome do tipo de dados> from <DataType> 

Os tipos de dados do SQL Server podem ser os Inteiros,
decimais, data, time, string , string vari�vel. etc... 

Voc� tamb�m pode usar o tipo TABLE para criar o seu
tipo de dado.

go
*/
use eBook
go

Create Type dtCNPJ From varchar(14) 
go

/*
Esse tipo de dados fica armazenado no banco de dados 
e pode ser utiliza para qualquer refer�ncia de tipo de dados. 
*/

Create Table tCADEmpresa
(
   iIDEmpresa int not null,
   cRazaoSocial varchar(100) not null,
   cCNPJ dtCNPJ
)
go

Insert Into tCADEmpresa Values (1,'Empresa XPTO', '99999999999999')
go

Select * From tCADEmpresa
go

sp_help tCADEmpresa


/*
Essa introdu��o � para voce conhecer os tipos de dados definidos
pelo usu�rio.  

E para explicar que podemos criar um tipo de dados tabela. 

*/

use eBook
go

drop type if exists dtTabelaPedido
go


Create Type dtTabelaPedido
As Table 
(   
   iIDPedido int not null Primary Key,
   dPedido datetime not null ,
   mValor smallmoney not null check (mValor >= 0),
   nQtdItem smallint 
)
go


/*
Criar uma vari�vel do tipo Tabela de Pedido
*/

Declare @tTMPPedido as dtTabelaPedido  

insert into @tTMPPedido values (1,getdate(),12000, 33)

Select * from @tTMPPedido
go 

/*
Vamos usar esse recurso quando utilizarmos procedure e precisamos
passar um dataset como par�metro. 
*/

