/*
https://docs.microsoft.com/pt-br/sql/t-sql/data-types/table-transact-sql?view=sql-server-2017

- Variável que é definida como uma estrtura de uma tabela e 
  existente enquanto o código referenciado estiver em 
  execução.

- Referenciada pela instruções Select pelo alias.

- Basicamente aceitam as implementações de uma tabela
  permanente, com algunas restrições como definição de 
  Chave Estrangeira.

- Toda tabela temporária são criadas no banco de dados 
  TempDB. 

- Aceita índices e são afetadas pelo comando ALTER TABLE. 

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

-- Outra Conexão
use tempdb
go
select * from sys.tables

/*
Outra conexão não acessa essa tabelas. São variáveis.  
*/


/*
Exemplos de utilização de Variável Table em comandos DML
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
    
-- Truncate table não funciona
Truncate table @tTMPPedidos2018 
go


/*
Elas não são afetadas pela processo de transação 
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

-- Drop Table não funciona 
Drop Table @tTMPPedidos2018


/*
Quando usar ?

Na minha opnião, quando você realmente :

- Primeiro, não conseguir resolver algo somente com os comandos DML.
- Quando você tem dados simples para manipular onde somente utiliza INSERT e SELECT.
- A quantidade de linha é pequena.
- Não precisar preservar e garantir a consistência com transação. 

*/






