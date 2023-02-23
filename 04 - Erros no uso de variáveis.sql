/*
Erros comuns na utiliza��o de vari�vel

S�o tr�s dicas para voc� n�o errar quando desenvolver
com vari�veis.

*/

use eBook
go

/*
Dica 1 

Quando o SELECT n�o retorna linhas e n�o h� dados para
carregar para a vari�vel.
*/

Select * 
  From tRELEstoque
 Where iIDEstoque = 26140 
    or iIDEstoque = 74823


/*
Quando saldo abaixo de 50, fa�a uma solicitacao de compra 
*/

Declare @nSaldoEstoque int 

Select @nSaldoEstoque = nQuantidade 
  From tRelEstoque
 Where iIDEstoque = 26140 

Print @nSaldoEstoque

Select @nSaldoEstoque = nQuantidade 
  From tRelEstoque
 Where iIDEstoque = 748230 -- Ops. Coloque um zero a mais!!!

Print @nSaldoEstoque
go 

/*
Como Corrigir ??
*/


Declare @nSaldoEstoque int 

Select @nSaldoEstoque = nQuantidade 
  From tRelEstoque
 Where iIDEstoque = 26140 

Print @nSaldoEstoque
Set @nSaldoEstoque = -1 -- Assim que usou a vari�vel, colocar NULL.

Select @nSaldoEstoque = nQuantidade 
  From tRelEstoque
 Where iIDEstoque = 748230

Print @nSaldoEstoque
go

/*
OU 
*/


Declare @nSaldoEstoque int 

Set @nSaldoEstoque  = (Select nQuantidade 
                         From tRelEstoque
                        Where iIDEstoque = 26140 )

Print @nSaldoEstoque

set @nSaldoEstoque = (Select nQuantidade 
                        From tRelEstoque
                       where iIDEstoque = 748230)

Print @nSaldoEstoque
go

/*
Dica 2 
Quando o SELECT retorna mais de uma linha 
Qual � o estoque do livro 106 ? 

*/

Declare @nSaldoEstoque int 

Select @nSaldoEstoque = nQuantidade  
  From tRelEstoque 
 Where iIDLivro = 106 

Print @nSaldoEstoque
go

/*
Analisando.... 
*/
Select *
  From tRelEstoque 
 where iIDLivro = 106 

/*
*/
Declare @nSaldoEstoque int = 0

Select @nSaldoEstoque += nQuantidade  
  From tRelEstoque 
 Where iIDLivro = 106 

Print @nSaldoEstoque
go 

/*
Ou
*/

Declare @nSaldoEstoque int = 0

Select @nSaldoEstoque = SUM(nQuantidade) 
  From tRelEstoque 
 Where iIDLivro = 106 

Print @nSaldoEstoque
go 

/*
Dica 3 
Utilizando o SET e recuperando mais de uma linha pelo SELECT 
*/


Declare @nSaldoEstoque int 

set @nSaldoEstoque = (Select sum(nQuantidade)
                        From tRelEstoque 
                       Where iIDLivro = 106 
					  )

Print @nSaldoEstoque
go

/*
Msg 512, Level 16, State 1, Line 121
Subquery returned more than 1 value. 
This is not permitted when the subquery follows =, !=, <, <= , >, >= or 
when the subquery is used as an expression.
*/


