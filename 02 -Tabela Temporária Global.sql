/*
- Tabelas temporárias Global são criadas pela instruções Create Table e 
  existem enquanto a conexão que a criou está ativa e quando não existir 
  mais referência de outras conexões. 
  
- Voce pode usar DROP TABLE.

- Todas as sessões tem acesso a tabela.

- Basicamente aceitam as implementações de uma tabela permanente, com algunas 
  restrições como definição de Chave Estrangeira.

- Toda tabela temporária são criadas no banco de dados 
  TempDB. 

- Aceita índices e são afetadas pelo comando ALTER TABLE. 

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
Outra conexão não acessa essa tabelas 
*/

-- Outra Conexão 
use eBook
go
Select * from ##tTMPPedidos2018


/*
Verificando se a tabela temporárias já existe
*/

select OBJECT_ID('tempdb..##tTMPPedidos2018')

if OBJECT_ID('tempdb..##tTMPPedidos2018') is not null
   raiserror('Tabela já existe',10,1)
else 
   raiserror('Tabela não existe',10,1)



/*
Como a tabela é apagada? 

A sessão que criou é que apaga!!!
Se outra sessão está referenciando, a tabela fica marcada
para apagar até que todas as conexões finalizem a referência.
*/


/*
Elas são afetadas pela processo de transação 

- Existe o tempo de processamento para preencher, confirmar 
  e registrar/reversão no log de transação, iguais as tabelas convencionais. 

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

As mesmas regras da tabela temporária Local 

- Compartilhar dados entre outras sessões ou entre execuções 
  de Stored Procedures aninhadas.

*/

