/*

Uma das atividades para quem desenvolve código é criar e
utilizar as variáveis. 

No caso do T-SQL, vamos demonstrar como usar variáveis com as
instruções DML para 

- Recuperar dados de instruções DML
- Utilizar elas em filtros de pesquisas no WHERE ou HAVING
- Opção de usar na cláusula TOP 
- Utilizar na cláusula SELECT na apresentação e operações de colunas

*/

/*
Utilizando no INSERT 
*/

use eBook

/*
-----------------------------------------------------------------------
Exemplo 01 - Inserir dados de um novo Autor 
*/

-- Variáveis para receber os dados 
Declare @cNome varchar(260)
Declare @dNascimento datetime

-- Variáveis de controle e dados padrão 
Declare @iIDAutor int = (select max(iidAutor) from tCADAutor) + 1
-- O ID desse Autor será o último iIDAutor da tabela tCADAutor acrescido de 1 

Declare @dCadastro datetime = getdate() 

-- Associa os Valores 
Set @cNome = 'Jose da Silva'
Set @dNascimento = '1980-02-03' 

Insert Into tCADAutor (iIDAutor, cNome, dNascimento ,dCadastro ) 
Values (@iIDAutor, @cNome, @dNascimento , @dCadastro)

/*
Validando 
*/
Select top 1 * from tCADAutor order by 1 desc 
go
-- Pegar o ID do Autor  17369


/*
Sobre a definição do conteúdo de @iidAutor 
6 formas diferentes de se obter o mesmo valor 
*/

Declare @iIDAutor int = (select max(iidAutor) from tCADAutor) + 1
print @iIDAutor
go

Declare @iIDAutor int 
set @iIDAutor = (select max(iidAutor) from tCADAutor) + 1
print @iIDAutor
go

Declare @iIDAutor int 
select @iIDAutor = max(iidAutor) + 1 from tCADAutor
print @iIDAutor
go
----- OU 

Declare @iIDAutor int = (select top 1 iidAutor from tCADAutor order by iidautor desc) + 1
print @iIDAutor
go

Declare @iIDAutor int 
set @iIDAutor = (select top 1 iidAutor from tCADAutor order by iidautor desc) + 1
print @iIDAutor
go

Declare @iIDAutor int 
select top 1 @iIDAutor  = iidAutor+1 from tCADAutor order by iidautor desc
print @iIDAutor
go 


/*
Utilizando no update 
*/
use eBook

/*
-----------------------------------------------------------------------
Exemplo 02 - Atualizando dados de Autor 

Atualização pelo ID do Autor, alterando o Nome e a Data de Nascimento.

*/

Select * from tCADAutor where iIDAutor = 17369

-- Variáveis para receber os dados 
Declare @cNome varchar(260) 
Declare @dNascimento datetime

-- Variáveis de controle e dados padrão 

Declare @iIDAutor int =  17369

Set @cNome = 'João da Silva'
Set @dNascimento = '1982-12-10'

update tCADAutor 
   set cNome = @cNome ,
       dNascimento = @dNascimento 
 where iIDAutor = @iIDAutor


/*
Dica !!! Voce pode utilizar o UPDATE para recuperar o dados que foi
atualizado e colocar em um variável. 

Cenário. Voce precisa atualizar o preco do livro "The Art of Dreaming"
da loja 32 em 7% e capturar esse novo valor.

*/
Select iIDLivro, cTitulo   
  From tCADLivro 
 Where cTitulo = 'The Art of Dreaming'
 
Select * From tRELEstoque where iIDLivro = 158 and iIDLoja = 32
-- 87,9056
-----------

Declare @mValorNovo smallmoney 

Update tRelEstoque 
   Set mValor  = mValor * 1.07
 Where iIDLivro = 158 
   and iIDLoja = 32

Select @mValorNovo = mValor  
  From tRELEstoque 
 where iIDLivro = 158 
   and iIDLoja = 32

print @mValorNovo
go

/*
Repetindo o processo, mas somente utilizando o Update. 
*/
--94.06


Declare @mValorNovo smallmoney 

Update tRelEstoque 
    Set @mValorNovo = mValor = mValor * 1.07
 Where iIDLivro = 158 
   and iIDLoja = 32

print @mValorNovo
go

Select * From tRELEstoque where iIDLivro = 158 and iIDLoja = 32


/*
Determinado o valor da clausula TOP
*/

Declare  @nQtdLinhas int = 5
Select Top (@nQtdLinhas) * from tCADLivro


/*
Na apresentação dos dados pela cláusula SELECT 
*/

-- Relatório para conceder aumento de R$ 100,00 no crédito dos clientes

Declare @mAumento smallmoney = 100.00
Select cNome, 
       mCredito, 
       mCredito + @mAumento as mNovoCredito 
  From tCADCliente 
go

-- Relatório de calculando o aumento dos livros
Declare @nPercentualAumento decimal(5,2) 
Set @nPercentualAumento = 12.50

Select Livro.cTitulo, 
       Livro.nPeso , 
       Loja.cDescricao,
       Estoque.mValor * Estoque.nQuantidade as mValorEstoque ,
       (Estoque.mValor * Estoque.nQuantidade) * (1+(@nPercentualAumento)/100) as mValorAumento
  From tRELEstoque as Estoque
  Join tCADLivro as Livro
    on Estoque.iIDLivro = Livro.iIDLivro
  Join tCADLoja as Loja 
    on Estoque.iIDLoja = Loja.iIDLoja
where Livro.iIDLivro = 2354
go

/*
Utilizando variável como contador 
*/

Declare @nContagem int = 0

Set @nContagem += 1
print @nContagem

Set @nContagem += 1
print @nContagem

Set @nContagem += 1
print @nContagem

Set @nContagem += 1
print @nContagem

/*
Dicas:

- Declare todas as variáveis dentro da mesma região do seu código.
- Se possível, comenta a função de cada variável.
- Evite nomes que não são legíveis. Exemplo:
*/
Declare @x int 
Declare @Valor money 
Declare @e1 int , @e2 int , @e3 int 
Declare @saidaA varchar(10), @saidaB varchar(20)
/*
- Utilize nomes que dão sentido ao propósito da variável.
*/

Declare @iDMovimento int 
Declare @nValorProduto money 
Declare @mEstoqueAtual int , @nEstoqueAnterior  int , @mEstoqueNovo int 
Declare @cRetornoNome varchar(10), @cRetornoSobreNome varchar(20)

/*
- Define corretamente os tipos de dados. Evite tipos que representam dados
  que não são aderente ao negócio.
*/
Declare @cNome nvarchar(1000)
Declare @nValorEstoque float 
Declare @nIdadeAluno bigint 
Declare @dDataPedido varchar(10)
Declare @nQuantidadeEstoque char(10)
go
/*
Corrigindo...
*/
Declare @cNome varchar(50)
Declare @nValorEstoque smallmoney
Declare @nIdadeAluno tinyint 
Declare @dDataPedido date
Declare @nQuantidadeEstoque smallint 
