/*
Severidade ou N�vel de Severidade.

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/database-engine-error-severities?view=sql-server-2017

Uma das informa��es de retorno de um erro � o nivel de severidade da mensagem,
indicando que ela pode ser um simples mensagem como um erro cr�tico. 

- Severidade entre 0 e 18 indicam informa��es, avisos, erros de transa��o,
  seguran�a e comandos T-SQL s�o alguns exemplo. 

- Podemos considerar que erros entre 0 e 9, s�o avisos de inform��es
  ou alertas. N�o vejo eles como erros do SQL Server. 
  
- Erros com n�vel acima de 10 s�o capturados pelo bloco CATCH.

- Severidade 11 at� 16 indicam erros que deve ser corrigidos pelo desenvolvedor.

- Entre 17 e 19 s�o erros que somente o adminstrador do sistema pode corrigir.

- Severidade entre 20 e 25 s�o erros cr�ticos. Os erros fatais encerram a 
  conex�o com o cliente. Esses erros n�o s�o capturados pelo bloco CATCH.

- 
  
*/

raiserror('Mensagem de Informa��o',10,1)

raiserror('Mensagem de Erro ',16,1)



Declare @iIDCodigo int 
Set @iIDCodigo = 344234234234324
/*
Msg 8115, Level 16, State 2, Line 54
Arithmetic overflow error converting expression to data type int.
*/