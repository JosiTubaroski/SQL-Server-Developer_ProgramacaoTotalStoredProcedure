/*

Os eventos de erros ou exce��es gerados pelo engine do SQL Server geram
um conjunto de informa��es sobre o erro. 

Existe duas formas de voc� ter um erro no SQL Server. 

 - As que s�o geradas pelo pr�prio engine do SQL Server
 - As geradas por programa��o pela fun��o RAISERROR() 

Dessas duas formas, o erro gerando pode conter informa��es 
que v�o al�m do c�digo de erro que vimos na fun��o @@ERROR:

- N�mero do erro. Os que s�o gerados pelo engine do SQL SERVER 
  v�o at� o valor 49.999. Voce pode criar suas mensagem de erros com 
  n�meros acima de 50.000.
  
- Mensagem de erro. Mensagem com informa��es sobre o erro e em alguns caso
  cont�m informa��es sobre objetos, colunas, valores entre outros.

- Severidade. Indica a gravidade do erro. Alguns casos s�o informa��es,
  aviso ou erros 

- Estado. Como uma mensagem de erro pode ser tratada de v�rias formas, o 
          estado pode indicar, por exemplo, como o erro pode ser corrigido

- Procedimento - Nome do objetos de programa��o onde o erro ocorreu. Pode
                 ser uma procedure ou trigger.

- Linha -  Indica a linha dentro do procedimento onde ocorreu o erro. Em caso
           de execu��o em lote, a linha dentro do lote. 

Exemplos:            
*/

use eBook
go

Sele�t * fron Tabela

/*
Msg 102, Level 15, State 1, Line 39
Incorrect syntax near '*'.
*/


select 1/0 

/*
Msg 8134, Level 16, State 1, Line 39
Divide by zero error encountered.
*/

select * from NaoSeiONome

/*
Msg 208, Level 16, State 1, Line 46
Invalid object name 'NaoSeiONome'.
*/

Declare @iIDCodigo int 
Set @iIDCodigo = 344234234234324


/*
Msg 8115, Level 16, State 2, Line 54
Arithmetic overflow error converting expression to data type int.
*/

update tCADCliente set mCredito = 0 where iIDCliente = 1

/*
Msg 547, Level 16, State 0, Line 62
The UPDATE statement conflicted with the CHECK 
constraint "CK__tCADClien__mCred__3D5E1FD2". 
The conflict occurred in database "eBook", 
table "dbo.tCADCliente", column 'mCredito'.
The statement has been terminated.
*/

Update tMOVPedidoItem set IDLivro = 0 where iidpedido = 3443

/*
Msg 547, Level 16, State 0, Line 74
The UPDATE statement conflicted with the FOREIGN KEY constraint "FKLivro1". 
The conflict occurred in database "eBook", table "dbo.tCADLivro", column 'iIDLivro'.
The statement has been terminated.


*/

/*
Onde as mensagem ficam armazenadas 
*/


SELECT m.message_id , 
       m.language_id , 
       l.alias , 
       m.severity , 
       m.is_event_logged , 
       m.text
  FROM sys.messages m
  Join sys.syslanguages l 
    on m.language_id = l.lcid
    WHERE message_id = 18456

 

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/errors-and-events-reference-database-engine?view=sql-server-2017
https://docs.microsoft.com/PT-BR/previous-versions/sql/sql-server-2008-r2/ms179465(v=sql.105)