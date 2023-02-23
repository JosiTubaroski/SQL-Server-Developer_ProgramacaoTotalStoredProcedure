/*
Severidade ou Nível de Severidade.

https://docs.microsoft.com/pt-br/sql/relational-databases/errors-events/database-engine-error-severities?view=sql-server-2017

Uma das informações de retorno de um erro é o nivel de severidade da mensagem,
indicando que ela pode ser um simples mensagem como um erro crítico. 

- Severidade entre 0 e 18 indicam informações, avisos, erros de transação,
  segurança e comandos T-SQL são alguns exemplo. 

- Podemos considerar que erros entre 0 e 9, são avisos de informções
  ou alertas. Não vejo eles como erros do SQL Server. 
  
- Erros com nível acima de 10 são capturados pelo bloco CATCH.

- Severidade 11 até 16 indicam erros que deve ser corrigidos pelo desenvolvedor.

- Entre 17 e 19 são erros que somente o adminstrador do sistema pode corrigir.

- Severidade entre 20 e 25 são erros críticos. Os erros fatais encerram a 
  conexão com o cliente. Esses erros não são capturados pelo bloco CATCH.

- 
  
*/

raiserror('Mensagem de Informação',10,1)

raiserror('Mensagem de Erro ',16,1)



Declare @iIDCodigo int 
Set @iIDCodigo = 344234234234324
/*
Msg 8115, Level 16, State 2, Line 54
Arithmetic overflow error converting expression to data type int.
*/