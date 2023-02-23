/*
Receber valores separado por vírgula em um parâmetro varchar e 
utiliza a função STRING_SPLIT() para separar os dados;
*/

use eBook
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaEstoque 
Objetivo   : Consulta o estoque atual dos livros.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Wolney M. Maia               01/01/2019 Criação da Procedure 
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaEstoque 
@iidLivro int ,
@iidLoja int 
as
Begin 

   Select Loja.iIDLoja,
          Loja.cDescricao , Loja.cLogradouro,
          Livro.cTitulo, Livro.nPaginas ,
          Estoque.nQuantidade , Estoque.mValor
     From tRELEstoque as Estoque
     Join tCADLivro as Livro
       on Estoque.iIDLivro = Livro.iIDLivro
     Join tCADLoja as Loja
       on Estoque.iIDLoja = Loja.iIDLoja
    Where Livro.iidLivro = @iidLivro and Loja.iIDLoja = @iidLoja 

End 
/*
*/
go



execute stp_ConsultaEstoque @iidLivro = 106 , @iidLoja = 9
go


/*
Mas as vezes precisamos fazer uma consulta de um livro em diversas lojas
por exemplo. 

No caso do SQL Server, ele não tem uma váriável para receber uma matriz de valores,
comunus em linguagem de programação.

No caso do SQL Server, podemos usar alguns recursos nativos, como um string com vários 
valores, uma estrutura XML/JSON ou até mesmo uma tabela. 

Vamos ver nesta aula como passar vários valores através de uma string .
*/


/*
Função STRING_SPLIT

- Recebe dois parâmetros.
- Uma que são os dados separados por um caracter separador.
- E o outro que é o próprio caracater separados.
- A função retorna um dataset com um unica coluna VALUE e as linhas contendo cada elemento do
  primeiro parâmetro

*/

Select value as Cidade from string_split('São Paulo,Belo Horizonte,Rio de Janeiro,Curitiba', ',')


/*
Aplicando essa função na procedure 
*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaEstoque 
Objetivo   : Consulta o estoque atual dos livros.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Wolney M. Maia               01/01/2019 Criação da Procedure 
Wolney M. Maia               05/04/2019 Alteração para aceitar várias lojas
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaEstoque 
@iidLivro int ,
@cLojas varchar(50) 
as
Begin 

   Select Loja.iIDLoja,
          Loja.cDescricao , Loja.cLogradouro,
          Livro.cTitulo, Livro.nPaginas ,
          Estoque.nQuantidade , Estoque.mValor
     From tRELEstoque as Estoque
     Join tCADLivro as Livro
       on Estoque.iIDLivro = Livro.iIDLivro
     Join tCADLoja as Loja
       on Estoque.iIDLoja = Loja.iIDLoja
    Where Livro.iidLivro = @iidLivro 
      and Loja.iIDLoja in (Select cast(Value as int) 
                             From string_split(@cLojas,',')
                          ) 

End 
/*
*/
go

execute stp_ConsultaEstoque @iidLivro = 106 , @cLojas= '9,20,101'
go


use eBook
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaEstoque 
Objetivo   : Consulta o estoque atual dos livros.

Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- --------------------
Wolney M. Maia               01/01/2019 Criação da Procedure 
Wolney M. Maia               05/04/2019 Alteração para aceitar várias lojas
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaEstoque 
@iidLivro int ,
@cLojas varchar(50) 
as
Begin 
  ;
  With cteLojas as (
      Select cast(Value as int) as iIDLoja 
        From string_split(@cLojas,',')
  )
  Select Loja.cDescricao , Loja.cLogradouro,
          Livro.cTitulo, Livro.nPaginas ,
          Estoque.nQuantidade , Estoque.mValor
     From tRELEstoque as Estoque
     Join tCADLivro as Livro
       on Estoque.iIDLivro = Livro.iIDLivro
     Join tCADLoja as Loja
       on Estoque.iIDLoja = Loja.iIDLoja
     Join cteLojas as Lojas 
       on Loja.iIDLoja = Lojas.iIDLoja 
    Where Livro.iidLivro = @iidLivro  

End 
/*
*/
go