/*
O design para criar de uma view se baseia em:

1. Conhecer os comandos para realizar sua cria��o e manuten��o.
2. Ter um padr�o de nomenclatura de objetos.
3. Construir o c�digo documentado e organizado.

N�o. Neste caso n�o utilizaremos a interface. 

Nesta aula, n�o ser� somente como criar um view !!!

*/


/*
1. Comandos :

Create View <NomeVisao> as <C�digo>

*/
use eBook 
go 

drop view if exists vCADEstoqueLivro
go


Create View vCADEstoqueLivro as Select iIDLivro, iIDLoja,nQuantidade, mValor   From tRELEstoque 
go

Create View vCADEstoqueLivro
as 
Select iIDLivro, iIDLoja, nQuantidade, mValor From tRELEstoque 
go


/*
Comandos :

Alter View <NomeVisao> as <C�digo>

*/


Alter View vCADEstoqueLivro
as 
Select iIDLivro, 
       iIDLoja, 
       nQuantidade, 
       mValor 
  From tRELEstoque 
go

/*
Comandos :

Drop View <NomeVisao> 

*/

Drop View vCADEstoqueLivro
go

/*
Dica.

Use CREATE OR ALTER. Se n�o existe, cria. Se existir, altera. 
*/

Create or Alter View vCADEstoqueLivro
as 
Select iIDLivro, 
       iIDLoja, 
       nQuantidade, 
       mValor 
  From tRELEstoque 
go

/*
Evite o procedimento Drop e Criar.  Use o Create or Alter.

Se dropar e criar, as permiss�es s�o perdidas. 

Drop View <NomeVisao> 

Create View <NomeVisao> 
*/


/*
Procedures de sistemas 
*/

-- Mostra a defini��o da view. 
execute sp_help vCADEstoqueLivro
go
-- Mostra o c�digo associado a view 
execute sp_helptext vCADEstoqueLivro
go


/*
Todas as views s�o criadas no banco de dados da conex�o atual e 
armazenadas nas vis�es de cat�logos:

sys.views
sys.columns
sys.sql_expression_dependencies 

A instru��o de consulta associada a view est� na vis�o de cat�logo:

sys.sql_modules
*/

use eBook
go

-- Dados da view
Select * 
  From sys.views 
 Where name = 'vCADEstoqueLivro'
go

-- Colunas associadas a view 
Select * 
  From sys.columns
 Where object_id = object_id('vCADEstoqueLivro')
go


-- Tabelas referenciadas pela view 
Select * 
  From sys.sql_expression_dependencies 
 Where referencing_id = object_id('vCADEstoqueLivro')
go

-- Mostra o c�digo associado a view 
Select * 
  From sys.sql_modules
 Where object_id = object_id('vCADEstoqueLivro')
go 


/*
2. Padr�o de Nomenclatura e C�digo 

- Padr�o de Nomenclature � criar um processo
  para definir os nomes dos objetos do banco de dados
  que permite sua a identifica��o e tipo de objeto, por exemplo. 
  O padr�o tamb�m permite que o time de desenvolvedores
  possa criar os objetos que todos possam identificar.
*/

Create View vCADEstoqueLivro
as 
Select iIDLivro, 
       iIDLoja, 
       nQuantidade, 
       mValor 
  From tRELEstoque 
go

/*
No nome vCADEstoqueLivro, eu assumo um padr�o que trabalho
a alguns anos e tenho, de algum forma, influenciado os Dev:

Nesse nome, adoto o seguinte padr�o:

           vCADEstoqueLivro

          v CAD EstoqueLivro

v            - Prefixo no nome do objeto que indica que � uma view.

               Alguns outro prefixo:

               t   - Tabela
               stp - Procedure
               fn  - Fun��o
               seq - Sequ�ncia 
               trg - Trigger 
               usr - Usu�rio de banco
               lgn - Login da inst�ncia
               pk  - Chave Prim�ria
               fk  - Chave Estrangeira 
               chk - Restri��o de verifica��o
               dfl - Restri��o de valor padr�o
               un  - Restri��o de valor �nico 
               idc - �ndice cluster
               idx - �ndice n�o cluster 
			      dt  - Tipo de dados definido pelo usu�rio

CAD          - Indica que os dados ser�o extraidos de tabela de cadastros.

               Outros exemplos de classifica��o de views e tabelas.

               COM - Tabela de complementa��o de dados (1:1)
               MOV - Tabela de Movimenta��o
               LOG - Registro de log de eventos, como erros ou auditoria
               REL - Tabela de Relacionamento entre Tabelas CAD (n:n)
               TIP - Tabela de Tipifica��o 
               TMP - Tabela com dados tempor�rios 
               
EstoqueLivro - Nome do objeto no estilo CamelCase (https://pt.wikipedia.org/wiki/CamelCase)
               
               Estoque_livro
               Estoque_Livro
               estoque_livro
               ESTOQUE_LIVRO

Para colunas, utilizo o prefixo que reflete o tipo
do dado armazenado. 

               i - Inteiro 
               n - decimal ou num�rico
               m - Money ou smallmoney
               d - Datas
               t - Time
               c - Caracteres
               x - XML
               l - Bit (l�gico) 

*/
use eBook
go

Create view vMOVPedidoTotalMes2018
as
Select Datename(Month,dPedido) as nMes , 
       Count(1) as nQuantiade 
  From tMOVPedido
 where dPedido between '2018-01-01' and '2019-01-01'
 Group by Datename(Month,dPedido)
go

/*
3. Construir o c�digo documentado e organizado.

- Documente o seu c�digo n�o somente para o integrantes do
  time de desenvolvimento, mas principalmente para voc�.

  Escreve o que o c�digo realiza e quando for realizar uma 
  manuten��o anos depois, voc� ter� uma ajuda para relembrar
  a objetivo do objeto. 

- Tenha registrado o nome do autor, uma descri��o do que faz o 
  objeto e, de prefer�ncia, mantenha um hist�rico das atualiza��es. 

Um c�digo bem escrito permite uma f�cil leitura, um r�pido entendimento como
tamb�m a agilidade na identifica��o e corre��o de erros.

- Idente as cl�usulas da instru��o SELECT.
- Coloque cada cl�usula em uma linha.
- Separe cada coluna por v�rgula, deixando um espa�o depois.
- Se tiver muitas colunas ou colunas com montagem complexas, 
  quebre as colunas em cada linha.
*/




/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vMOVPedidoTotalMes2018
Objetivo   : Apresentar o total de pedidos agrupador por m�s
             para o ano de 2018 
Projeto    : Treinamento          
Empresa Respons�vel: ForceDB Treinamentos
Criado em  : 02/01/2019
Execu��o   : Via SQL Server Management Studio, para demonstra��o        
Palavras-chave: Pedido
----------------------------------------------------------------------------------------------        
Observa��es :        

----------------------------------------------------------------------------------------------        
Hist�rico:        
Autor                  IDBug Data       Descri��o        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               01/01/2019 Cria��o da Views
Wolney M. Maia               03/01/2019 Ajuste no WHERE, alterando para 
                                        o operador Between.
*/
Create or Alter view vMOVPedidoTotalMes2018
as
Select Datename(Month,dPedido) as cMes, 
       Count(*) as nQuantidade 
  From tMOVPedido
 Where dPedido between '2018-01-01' and '2019-01-01' 
 Group by Datename(Month,dPedido)

/*
Fim da View vMOVPedidoTotalMes2018
*/



/*
Views Aninhadas.

Quando a instru��o SELECT de uma view faz chamada 
para uma outra view 

*/
use eBook
go

Create Or Alter View vClienteAtivo
as
Select iIDCliente, cNome, nTipoPessoa, cDocumento, dAniversario, dCadastro, dExclusao, mCredito
  From tCADCliente 
where dExclusao is null 
go
/*
Fim da View vCADClientesSemCredito
*/



/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vCADClientesSemCredito
Objetivo   : Apresenta os clientes com credito menor que R$ 10,00
------------------------------------------------------------*/
Create or Alter View vCADClientesSemCredito 
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito
  From vClienteAtivo
 Where mCredito < 10
go
/*
Fim da View vCADClientesSemCredito
*/


select * from vCADClientesSemCredito
