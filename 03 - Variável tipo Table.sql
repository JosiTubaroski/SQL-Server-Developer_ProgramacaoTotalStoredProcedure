/*
https://docs.microsoft.com/pt-br/sql/t-sql/data-types/table-transact-sql?view=sql-server-2017

- Vari�vel que � definida como uma estrtura de uma tabela e 
  existente enquanto o c�digo referenciado estiver em 
  execu��o.

- Referenciada pela instru��es Select pelo alias.

- Basicamente aceitam as implementa��es de uma tabela
  permanente, com algunas restri��es como defini��o de 
  Chave Estrangeira.

- Toda tabela tempor�ria s�o criadas no banco de dados 
  TempDB. 

- Aceita �ndices e s�o afetadas pelo comando ALTER TABLE. 

- Tem que ter o prefixo @ no nome. 

*/

Use eBook
go

Declare @tTMPPedidos2018 Table (iIDPedido int not null Primary Key,
                                dPedido datetime not null ,
                                mValor smallmoney not null check (mValor >= 0),
                                nQtdItem smallint 
                                )
Insert into @tTMPPedidos2018 values (1,GETDATE(),100.00,2)
select * from @tTMPPedidos2018

go
select * from @tTMPPedidos2018
go


/*
Verificando no banco de dados TEMPDB 
*/


Declare @tTMPPedidos2018 Table (iIDPedido int not null Primary Key,
                                dPedido datetime not null ,
                                mValor smallmoney not null check (mValor >- 0),
                                nQtdItem smallint 
                                )
Insert into @tTMPPedidos2018 values (1,GETDATE(),100.00,2)
Select * from @tTMPPedidos2018
waitfor delay '00:01:00' 

-- Outra Conex�o
use tempdb
go
select * from sys.tables

/*
Outra conex�o n�o acessa essa tabelas. S�o vari�veis.  
*/


/*
Exemplos de utiliza��o de Vari�vel Table em comandos DML
*/
use eBook
go

Declare @tTMPPedidos2018 Table (iIDPedido int not null Primary Key,
                                dPedido datetime not null ,
                                mValor smallmoney not null check (mValor >= 0),
                                nQtdItem smallint 
                               )
-- Com o comando INSERT 
insert into @tTMPPedidos2018 (iIDPedido,dPedido,mValor,nQtdItem)
   Select Pedido.iidPedido,dPedido, isnull(mValor,0), nQtdItem
     From tMOVPedido Pedido
     Join (Select iIDPedido ,
                  Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                  Count(*) as nQtdItem  
             From tMOVPedidoItem 
            Group by iIDPedido
          ) as Item 
          on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dPedido >= '2018-01-01' 
      and Pedido.dPedido <= '2018-01-03'

-- Com o SELECT 
Select COUNT(1) 
  From @tTMPPedidos2018

-- Com o SELECT usando o WHERE 
Select COUNT(1) 
  From @tTMPPedidos2018
 Where dPedido <= '2018-01-02'

/*
Com o SELECT usando comm Join 
*/

/*
Select * 
  From @tTMPPedidos2018
   Join tMOVPedido 
     on @tTMPPedidos2018.iIDPedido = Pedido.iidPedido.
  Where @tTMPPedidos2018.dPedido <= '2018-02-01'
  */

-- Corrigindo
Select * 
  From @tTMPPedidos2018 as TMP2018 
  join tMOVPedido 
    on TMP2018.iIDPedido = tMOVPedido.iidPedido
 Where TMP2018.dPedido <= '2018-02-01'

-- Update 
update @tTMPPedidos2018
   set mValor *= 1.05

-- Delete 
Delete @tTMPPedidos2018
    
-- Truncate table n�o funciona
Truncate table @tTMPPedidos2018 
go


/*
Elas n�o s�o afetadas pela processo de transa��o 
*/

use eBook
go

Declare @tTMPPedidos2018 Table (iIDPedido int not null Primary Key,
                                dPedido datetime not null ,
                                mValor smallmoney not null check (mValor >= 0),
                                nQtdItem smallint 
                                )
Begin transaction 
   insert into @tTMPPedidos2018 (iIDPedido,dPedido,mValor,nQtdItem)
   Select Pedido.iidPedido,dPedido, isnull(mValor,0), nQtdItem
     From tMOVPedido Pedido
     Join (Select iIDPedido ,
                  Sum((nQuantidade * mValorUnitario)-mDesconto) as mValor,
                  Count(*) as nQtdItem  
             From tMOVPedidoItem 
            Group by iIDPedido
          ) as Item 
          on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dPedido >= '2018-01-01' 
      and Pedido.dPedido <= '2018-01-03'

    Select COUNT(*) from @tTMPPedidos2018

Rollback 

Select COUNT(*) from @tTMPPedidos2018

-- Drop Table n�o funciona 
Drop Table @tTMPPedidos2018


/*
Quando usar ?

Na minha opni�o, quando voc� realmente :

- Primeiro, n�o conseguir resolver algo somente com os comandos DML.
- Quando voc� tem dados simples para manipular onde somente utiliza INSERT e SELECT.
- A quantidade de linha � pequena.
- N�o precisar preservar e garantir a consist�ncia com transa��o. 

*/






