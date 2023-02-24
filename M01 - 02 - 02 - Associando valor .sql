/*

A utilização de variável começa como a associação de 
um valor que será atribuido a varíavel.

SET
SELECT, declarando direto valor na variável.
SELECT, carregando os dados do resultado de uma consulta.

*/

use eBook
go
set nocount on 


-- Atribuindo Valor Escalar 
Declare @cNome varchar(200)  = 'Jose da Silva' 
go

Declare @cNome varchar(200)  
Set @cNome = 'Jose da Silva' 
go

Declare @cNome varchar(200)  
Select  @cNome = 'Jose da Silva' 
Select  @cNome
go


/*
Atribuindo valor a partir de funções do SQL Server 
*/

Declare @dDiaHoje datetime = getdate()
print @dDiaHoje 
go

Declare @dDiaHoje datetime 
set @dDiaHoje = getdate()  -- Capturando a data e hora do momento. 
print @dDiaHoje


Declare @cNomeBanco sysname  
set @cNomeBanco = db_name() -- Retorna o nome do banco de dados 
print @cNomeBanco
go

Declare @nQtdLinhasProcessadas int 
Select * from tCADLivro where iIDDestaque = 6
set @nQtdLinhasProcessadas = @@ROWCOUNT
print @nQtdLinhasProcessadas
go


Declare @cNome varchar(200)  
Declare @cSobreNome varchar(200), @cNomeCompleto varchar(200) 
Set @cNome = 'Jose' 
Set @cSobreNome  = 'da Silva' 
Select @cNomeCompleto = @cNome + ' ' +@cSobreNome -- Função de atribuir
Raiserror(@cNomeCompleto, 10,1)
go


/*
Definindo variaveis e atribuindo valor em lote separados 
*/


Declare @cNome varchar(200)  
set @cNome = 'Jose' 
raiserror(@cNome , 10,1)
go

Declare @cSobreNome varchar(200), @cNomeCompleto varchar(200) 
Set @cSobreNome  = 'da Silva' 
Select @cNomeCompleto = @cNome + ' ' +@cSobreNome 
raiserror(@cNomeCompleto, 10,1)

go

/*
Carregando os dados a partir de consultas 
*/


-- Utilizando SET 

Declare @cNome varchar(200)  
Declare @mCredito smallmoney 

set @cNome =    (select cNome    from tCADCliente where iidcliente = 1)
set @mCredito = (select mCredito from tCADCliente where iidcliente = 1)

print @cNome 
print @mCredito 
go

-- Utilizando SELECT 
Declare @cNome varchar(200)  
Declare @dAniversario date
Declare @mCredito smallmoney 

Select @cNome = cNome, @dAniversario = dAniversario, @mCredito = mCredito from tCADCliente where iidcliente = 1 

print @cNome 
print @dAniversario
print @mCredito 
go

Declare @cNome varchar(200)  
Declare @dAniversario date
Declare @mCredito smallmoney 

Select @cNome = cNome, 
       @dAniversario = dAniversario, 
	   @mCredito = mCredito 
  From tCADCliente 
 Where iidcliente = 1 

print @cNome 
print @dAniversario
print @mCredito 
go


/*
Associando dado XML 
*/
use eBook
go

Declare @xEnviarPedido xml
set @xEnviarPedido = (Select * 
                        From tMOVPedido
                        Join tMOVPedidoItem 
						  on tMOVPedido.iIDPedido = tMOVPedidoItem.iIDPedido
					   Where dPedido between '2011-06-28' and '2011-06-29' 
					     For xml auto, elements 
					 )
Select @xEnviarPedido

/*
Atribuição de Operação 
*/

Declare @mValor int = 50
Set @mValor += 100 
Select @mValor
go

-- Equivalente 

Declare @mValor int = 50
Set @mValor = @mValor + 100 
Select @mValor

/*
 +=   Adição
 -=   Subtração
 *=   Multiplicação
 /=   Divisão
 %=   Módulo 

*/


