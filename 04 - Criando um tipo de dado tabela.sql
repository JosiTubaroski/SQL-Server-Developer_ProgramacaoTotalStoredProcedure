/*
O SQL Server tem um recurso para os desenvolvedores que
permitem criarem os seus próprios tipos de dados com base
nos tipos já existentes no SQL SERVER.

Conhecidos como User Data Types, são tipos de dados
utilizados na definição de estrutura de tabelas,
declaração de variáveis e nos parâmetros de procedure
e funções. 

Create Type <Nome do tipo de dados> from <DataType> 

Os tipos de dados do SQL Server podem ser os Inteiros,
decimais, data, time, string , string variável. etc... 

Você também pode usar o tipo TABLE para criar o seu
tipo de dado.

go
*/
use eBook
go

Create Type dtCNPJ From varchar(14) 
go

/*
Esse tipo de dados fica armazenado no banco de dados 
e pode ser utiliza para qualquer referência de tipo de dados. 
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
Essa introdução é para voce conhecer os tipos de dados definidos
pelo usuário.  

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
Criar uma variável do tipo Tabela de Pedido
*/

Declare @tTMPPedido as dtTabelaPedido  

insert into @tTMPPedido values (1,getdate(),12000, 33)

Select * from @tTMPPedido
go 

/*
Vamos usar esse recurso quando utilizarmos procedure e precisamos
passar um dataset como parâmetro. 
*/

