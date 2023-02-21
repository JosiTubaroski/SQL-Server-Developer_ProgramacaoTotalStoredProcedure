/*

@@ROWCOUNT 

Cont�m o total de linhas processdas pela �ltima instru��o SELECT, UPDATE, DELETE e INSERT.

Utiliza��o em testes de verifica��o se a tabela foi afetada conforme 
as condi��es do where.

*/
use eBook
go

Select * from tCADCliente where iidcliente >= 134
Select @@ROWCOUNT


/*
Instru��es SELECT 'Texto' ou SET, o valor de @@rowcount � 1
*/

Select 'Teste de instru��o @@rowcount'
Select @@ROWCOUNT


/*
Resultado de Updates 
*/

Update tCADLivro set nPaginas = nPaginas  +1    where iIDDestaque = 1
Select @@ROWCOUNT

/*
Utilizando a fun��o ROWCOUNT_BIG() 
*/


Update tCADLivro set nPaginas = nPaginas  +1    where iIDDestaque = 1
Select @@ROWCOUNT, ROWCOUNT_BIG()


/*
Dicas

- utilize @@rowcount para validar se uma opera��o afetou linhas ap�s a execu��o.
- O @@rowcount retornar um valor INT. Ent�o ele armazena quantidade de linhas at� pouco mais
  de 2 bilh�es.
- ROWCOUNT_BIG() e um fun��o que retorna um valor BIGINT e pode armazenar quantidade de linhas 
  processada at� o valor de 9,2 quintilh�es.
*/





