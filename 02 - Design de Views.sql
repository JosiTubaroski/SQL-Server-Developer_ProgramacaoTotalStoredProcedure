/*
O design para criar de uma view se baseia em:

1. Conhecer os comandos para realizar sua criação e manutenção.
2. Ter um padrão de nomenclatura de objetos.
3. Construir o código documentado e organizado.

Não. Neste caso não utilizaremos a interface. 

Nesta aula, não será somente como criar um view !!!

*/


/*
1. Comandos :

Create View <NomeVisao> as <Código>

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

Alter View <NomeVisao> as <Código>

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

Use CREATE OR ALTER. Se não existe, cria. Se existir, altera. 
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

Se dropar e criar, as permissões são perdidas. 

Drop View <NomeVisao> 

Create View <NomeVisao> 
*/


/*
Procedures de sistemas 
*/

-- Mostra a definição da view. 
execute sp_help vCADEstoqueLivro
go
-- Mostra o código associado a view 
execute sp_helptext vCADEstoqueLivro
go


/*
Todas as views são criadas no banco de dados da conexão atual e 
armazenadas nas visões de catálogos:

sys.views
sys.columns
sys.sql_expression_dependencies 

A instrução de consulta associada a view está na visão de catálogo:

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

-- Mostra o código associado a view 
Select * 
  From sys.sql_modules
 Where object_id = object_id('vCADEstoqueLivro')
go 


/*
2. Padrão de Nomenclatura e Código 

- Padrão de Nomenclature é criar um processo
  para definir os nomes dos objetos do banco de dados
  que permite sua a identificação e tipo de objeto, por exemplo. 
  O padrão também permite que o time de desenvolvedores
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
No nome vCADEstoqueLivro, eu assumo um padrão que trabalho
a alguns anos e tenho, de algum forma, influenciado os Dev:

Nesse nome, adoto o seguinte padrão:

           vCADEstoqueLivro

          v CAD EstoqueLivro

v            - Prefixo no nome do objeto que indica que é uma view.

               Alguns outro prefixo:

               t   - Tabela
               stp - Procedure
               fn  - Função
               seq - Sequência 
               trg - Trigger 
               usr - Usuário de banco
               lgn - Login da instância
               pk  - Chave Primária
               fk  - Chave Estrangeira 
               chk - Restrição de verificação
               dfl - Restrição de valor padrão
               un  - Restrição de valor único 
               idc - Índice cluster
               idx - Índice não cluster 
			      dt  - Tipo de dados definido pelo usuário

CAD          - Indica que os dados serão extraidos de tabela de cadastros.

               Outros exemplos de classificação de views e tabelas.

               COM - Tabela de complementação de dados (1:1)
               MOV - Tabela de Movimentação
               LOG - Registro de log de eventos, como erros ou auditoria
               REL - Tabela de Relacionamento entre Tabelas CAD (n:n)
               TIP - Tabela de Tipificação 
               TMP - Tabela com dados temporários 
               
EstoqueLivro - Nome do objeto no estilo CamelCase (https://pt.wikipedia.org/wiki/CamelCase)
               
               Estoque_livro
               Estoque_Livro
               estoque_livro
               ESTOQUE_LIVRO

Para colunas, utilizo o prefixo que reflete o tipo
do dado armazenado. 

               i - Inteiro 
               n - decimal ou numérico
               m - Money ou smallmoney
               d - Datas
               t - Time
               c - Caracteres
               x - XML
               l - Bit (lógico) 

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
3. Construir o código documentado e organizado.

- Documente o seu código não somente para o integrantes do
  time de desenvolvimento, mas principalmente para você.

  Escreve o que o código realiza e quando for realizar uma 
  manutenção anos depois, você terá uma ajuda para relembrar
  a objetivo do objeto. 

- Tenha registrado o nome do autor, uma descrição do que faz o 
  objeto e, de preferência, mantenha um histórico das atualizações. 

Um código bem escrito permite uma fácil leitura, um rápido entendimento como
também a agilidade na identificação e correção de erros.

- Idente as cláusulas da instrução SELECT.
- Coloque cada cláusula em uma linha.
- Separe cada coluna por vírgula, deixando um espaço depois.
- Se tiver muitas colunas ou colunas com montagem complexas, 
  quebre as colunas em cada linha.
*/




/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vMOVPedidoTotalMes2018
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 02/01/2019
Execução   : Via SQL Server Management Studio, para demonstração        
Palavras-chave: Pedido
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               01/01/2019 Criação da Views
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

Quando a instrução SELECT de uma view faz chamada 
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
