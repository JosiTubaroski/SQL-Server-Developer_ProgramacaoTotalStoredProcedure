/*

@@ERROR

Função de sistema que retorna o número do erro gerando na última instrução 
T-SQL que apresentou erro. O retorno será de um número INT.

Todo o erro deve ser capturado, tratado e, preferencialmente armazenamento para 
posterior análise.

*/

Print @@ERROR

Select 2/2
Print @@ERROR

Select 2/0
Print @@ERROR

Select 1/2.0
Print @@ERROR

/*
O valor de @@ERROR é zero automaticamente antes de executar 
a próxima instrução T-SQL.
*/


Declare @nNumeroError_A int 
Declare @nNumeroError_B int 

Select 2/0
Set @nNumeroError_A = @@ERROR  -- Captura o erro na variável e zera o valor de @@ERROR
Set @nNumeroError_B = @@ERROR

print 'Erros....'
print @nNumeroError_A 
print @nNumeroError_B 

/*
Dica: Sempre utilizar variável para armazenar o valor do erro 
      imediatamente após a instrução T-SQL.

O uso de @@ERROR pode ser aplicado para pequenos scripts e controle de
transações que não requer um tratamento de erro mais robusto. 

Para um controle mais robusto e eficiente, teremos uma seção somente para tratar erros.

*/
