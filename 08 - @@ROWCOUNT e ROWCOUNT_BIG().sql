/*

@@ROWCOUNT 

Contém o total de linhas processdas pela última instrução SELECT, UPDATE, DELETE e INSERT.

Utilização em testes de verificação se a tabela foi afetada conforme 
as condições do where.

*/
use eBook
go

Select * from tCADCliente where iidcliente >= 134
Select @@ROWCOUNT


/*
Instruções SELECT 'Texto' ou SET, o valor de @@rowcount é 1
*/

Select 'Teste de instrução @@rowcount'
Select @@ROWCOUNT


/*
Resultado de Updates 
*/

Update tCADLivro set nPaginas = nPaginas  +1    where iIDDestaque = 1
Select @@ROWCOUNT

/*
Utilizando a função ROWCOUNT_BIG() 
*/


Update tCADLivro set nPaginas = nPaginas  +1    where iIDDestaque = 1
Select @@ROWCOUNT, ROWCOUNT_BIG()


/*
Dicas

- utilize @@rowcount para validar se uma operação afetou linhas após a execução.
- O @@rowcount retornar um valor INT. Então ele armazena quantidade de linhas até pouco mais
  de 2 bilhões.
- ROWCOUNT_BIG() e um função que retorna um valor BIGINT e pode armazenar quantidade de linhas 
  processada até o valor de 9,2 quintilhões.
*/





