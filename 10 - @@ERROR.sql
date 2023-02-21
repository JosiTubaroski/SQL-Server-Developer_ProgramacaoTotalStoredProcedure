/*

@@ERROR

Fun��o de sistema que retorna o n�mero do erro gerando na �ltima instru��o 
T-SQL que apresentou erro. O retorno ser� de um n�mero INT.

Todo o erro deve ser capturado, tratado e, preferencialmente armazenamento para 
posterior an�lise.

*/

Print @@ERROR

Select 2/2
Print @@ERROR

Select 2/0
Print @@ERROR

Select 1/2.0
Print @@ERROR

/*
O valor de @@ERROR � zero automaticamente antes de executar 
a pr�xima instru��o T-SQL.
*/


Declare @nNumeroError_A int 
Declare @nNumeroError_B int 

Select 2/0
Set @nNumeroError_A = @@ERROR  -- Captura o erro na vari�vel e zera o valor de @@ERROR
Set @nNumeroError_B = @@ERROR

print 'Erros....'
print @nNumeroError_A 
print @nNumeroError_B 

/*
Dica: Sempre utilizar vari�vel para armazenar o valor do erro 
      imediatamente ap�s a instru��o T-SQL.

O uso de @@ERROR pode ser aplicado para pequenos scripts e controle de
transa��es que n�o requer um tratamento de erro mais robusto. 

Para um controle mais robusto e eficiente, teremos uma se��o somente para tratar erros.

*/