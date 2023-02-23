/*
- Tabelas tempor�rias Global s�o criadas pela instru��es Create Table e 
  existem enquanto a conex�o que a criou est� ativa e quando n�o existir 
  mais refer�ncia de outras conex�es. 
  
- Voce pode usar DROP TABLE.

- Todas as sess�es tem acesso a tabela.

- Basicamente aceitam as implementa��es de uma tabela permanente, com algunas 
  restri��es como defini��o de Chave Estrangeira.

- Toda tabela tempor�ria s�o criadas no banco de dados 
  TempDB. 

- Aceita �ndices e s�o afetadas pelo comando ALTER TABLE. 

- Tem que ter o prefixo ## no nome. 
*/

Use eBook
go


Create Table ##tTMPPedidos2018
( 
   iIDPedido int not null Primary Key,
   dPedido datetime not null ,
   mValor smallmoney not null check (mValor >= 0),
   nQtdItem smallint 
)
go
Select * from ##tTMPPedidos2018

/*
Verificando no banco de dados TEMPDB 
*/

use tempdb
go
Select * from sys.tables

/*
Outra conex�o n�o acessa essa tabelas 
*/

-- Outra Conex�o 
use eBook
go
Select * from ##tTMPPedidos2018


/*
Verificando se a tabela tempor�rias j� existe
*/

select OBJECT_ID('tempdb..##tTMPPedidos2018')

if OBJECT_ID('tempdb..##tTMPPedidos2018') is not null
   raiserror('Tabela j� existe',10,1)
else 
   raiserror('Tabela n�o existe',10,1)



/*
Como a tabela � apagada? 

A sess�o que criou � que apaga!!!
Se outra sess�o est� referenciando, a tabela fica marcada
para apagar at� que todas as conex�es finalizem a refer�ncia.
*/


/*
Elas s�o afetadas pela processo de transa��o 

- Existe o tempo de processamento para preencher, confirmar 
  e registrar/revers�o no log de transa��o, iguais as tabelas convencionais. 

*/

Begin transaction 
   insert into ##tTMPPedidos2018 (iIDPedido,dPedido,mValor,nQtdItem)
   Select Pedido.iidPedido,dPedido, isnull(mValor,0), nQtdItem
     From tMOVPedido Pedido
    Cross Apply (Select sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                        COUNT(*) as nQtdItem  
                   From tMOVPedidoItem 
                  Where iIDPedido = Pedido.iIDPedido
                ) as Item 
    Where Pedido.dPedido >= '2018-01-01'

    Select COUNT(*) from ##tTMPPedidos2018

Rollback 

Select COUNT(*) from ##tTMPPedidos2018


/*
Quando usar ?

As mesmas regras da tabela tempor�ria Local 

- Compartilhar dados entre outras sess�es ou entre execu��es 
  de Stored Procedures aninhadas.

*/

