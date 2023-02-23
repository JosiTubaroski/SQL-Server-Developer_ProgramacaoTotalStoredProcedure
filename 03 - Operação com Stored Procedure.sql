/*
Vamos aprender em como criar uma SP e realizar
todas as manutenções e consultas sobre as Procedures
*/

use eBook
go


/*
1. Para criar uma Procedure.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_MovimentoDoDia
Objetivo   : Apresenta a movimentação de pedidos
------------------------------------------------------------*/
Create Procedure stp_MovimentoDoDia
as
Begin
   
   Select Cliente.cNome as cCliente,
          Pedido.nNumero as nNumeroPedido,
          Cast(Pedido.dPedido as date) as dDataPedido , 
          Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
          Count(*) as nQtdItem 
     From dbo.tMOVPedido Pedido
          Join dbo.tCADCliente Cliente 
            on Pedido.iIDCliente = Cliente.iIDCliente
          Join dbo.tMOVPedidoItem as Item 
            on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dCancelado is null
      and Pedido.dPedido between '2010-07-05' and '2010-07-06'
    Group by Cliente.cNome,       
             Pedido.nNumero,
             Pedido.dPedido 

End 
/*
Fim da Procedure stp_MovimentoDoDia
*/
go


/*
2. Para Alterar o código associado a Procedure 
*/
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_MovimentoDoDia
Objetivo   : Apresenta a movimentação de pedidos
------------------------------------------------------------*/
Alter Procedure stp_MovimentoDoDia
as
Begin
   
   Select Cliente.cNome as cCliente,
          Pedido.nNumero as nNumeroPedido,
          Cast(Pedido.dPedido as date) as dDataPedido , 
          Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
          Count(*) as nQtdItem 
     From dbo.tMOVPedido Pedido
          Join dbo.tCADCliente Cliente 
            on Pedido.iIDCliente = Cliente.iIDCliente
          Join dbo.tMOVPedidoItem as Item 
            on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dCancelado is null
      and Pedido.dPedido between '2010-07-05' and '2010-07-06'
    Group by Cliente.cNome,       
             Pedido.nNumero,
             Pedido.dPedido 

End 
/*
Fim da Procedure stp_MovimentoDoDia
*/
go

/*
Dicas.
Utilize a instrução CREATE OR ALTER 
*/
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_MovimentoDoDia
Objetivo   : Apresenta a movimentação de pedidos
------------------------------------------------------------*/
Create or Alter Procedure stp_MovimentoDoDia
as
Begin
   
   Select Cliente.cNome as cCliente,
          Pedido.nNumero as nNumeroPedido,
          Cast(Pedido.dPedido as date) as dDataPedido , 
          Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
          Count(*) as nQtdItem 
     From dbo.tMOVPedido Pedido
          Join dbo.tCADCliente Cliente 
            on Pedido.iIDCliente = Cliente.iIDCliente
          Join dbo.tMOVPedidoItem as Item 
            on Pedido.iIDPedido = Item.iidPedido 
    Where Pedido.dCancelado is null
      and Pedido.dPedido between '2010-07-05' and '2010-07-06'
    Group by Cliente.cNome,       
             Pedido.nNumero,
             Pedido.dPedido 

End 
/*
Fim da Procedure stp_MovimentoDoDia
*/
go

/*
3. Para Excluir uma procedure do banco de dados 
*/

Drop Procedure stp_MovimentoDoDia
go


/*
4. Consultar se uma procedure existe
*/

Select object_id, name,create_date, modify_date 
  From sys.objects 
 Where name = 'stp_MovimentoDoDia'
go

Select * from sys.procedures
 Where name = 'stp_MovimentoDoDia'
go

select object_id('stp_MovimentoDoDia')
go
select object_id('stp_MovimentoDoDia_NaoExiste')
go



/*
5. Exibindo dependência de uma SP
*/

-- Exibe os objetos que depende da existência da Procedure 
SELECT referencing_schema_name, 
       referencing_entity_name, 
       referencing_id, 
       referencing_class_desc, 
       is_caller_dependent  
  FROM sys.dm_sql_referencing_entities ('dbo.stp_MovimentoDoDia', 'OBJECT');   

go

/*
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-sql-referencing-entities-transact-sql?view=sql-server-2017
*/

-- Quais os objetos utilizados pela Procedure 
SELECT distinct referenced_schema_name, 
       referenced_entity_name, 
       referenced_id 
  FROM sys.dm_sql_referenced_entities ('dbo.stp_MovimentoDoDia', 'OBJECT');   


SELECT referenced_schema_name, 
       referenced_entity_name, 
       referenced_id, 
       referenced_minor_name,
       referenced_minor_id 
  FROM sys.dm_sql_referenced_entities ('dbo.stp_MovimentoDoDia', 'OBJECT');   


/*
6. Exibindo o contéudo de uma Procedure 

- Utilizando a procedure sp_helptext 
- Utilizando a view de catalogo sys.sql_modules 
- Utilizando a função OBJECT_DEFINITION()

*/

sp_helptext 'dbo.stp_MovimentoDoDia'
go

Declare @iIDObject int = object_id('dbo.stp_MovimentoDoDia')
Select Definition 
  From sys.sql_modules 
 Where object_id = @iIDObject
go

Declare @iIDObject int = object_id('dbo.stp_MovimentoDoDia')
Select OBJECT_DEFINITION(@iIDObject) 
go

/*
7. Renomear uma procedure.
- Não perde as permissões 
- Verificar antes as dependências de outros obejtos com a procedure.
*/


sp_rename 'dbo.stp_MovimentoDoDia' , 'stp_PedidosDoDia'

/*
Caution: Changing any part of an object name could break 
         scripts and stored procedures.
*/



/*
8. Executando uma Procedures.
*/

Execute dbo.stp_MovimentoDoDia
go

Exec dbo.stp_MovimentoDoDia
go

Execute ('dbo.stp_MovimentoDoDia')
go


Declare @cNomeProcedure varchar(50)
Set @cNomeProcedure = 'dbo.stp_MovimentoDoDia'
Execute @cNomeProcedure


/*
9. Verificando o desempenho de execução. 
*/

Select * 
  From sys.dm_exec_procedure_stats

/*
https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-procedure-stats-transact-sql?view=sql-server-2017
*/
