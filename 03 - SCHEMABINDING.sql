/*
SCHEMABINDING é uma opção que você declara no design 
da view para realizar uma associação entre a visão e
as tabelas utilizadas na consulta.

Com isso, as modificações nas estruturas das tabelas
que afetam as definições da view não poderá ser realizadas.

Para usar essa opção, as tabelas deve ser declaradas com o 
esquema (nome de duas partes, schema.table) 

Exemplo.

*/

use eBook
go 
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
  From tCADCliente 
 Where mCredito < 10
go
/*
Fim da View vCADClientesSemCredito
*/

Select * from vCADClientesSemCredito 


/*
Um integrante do time de DEV recebe a tarefa de colocar neste 
view a descrição do tipo do cliente se é uma Pessoa Física ou Jurídica,
que será utilizado somente atender uma planilha Excel de um setor.
E ele decidiu realizar os seguintes procedimentos: 
*/

-- Altera a tabela, incluíndo a coluna cTipoPessoa
Alter Table tCADCliente add cTipoPessoa char(15)
go

-- Atualiza a coluna com base no valor de nTipoPessoa.
Update tCADCliente 
   Set cTipoPessoa = Case nTipoPessoa 
                          When 1 
                          Then 'Pessoa Física' 
                          Else 'Pessoa Jurídica'
                     End 
go
-- Atualiza a estrutura da visão 

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vCADClientesSemCredito
Objetivo   : Apresenta os clientes com credito menor que R$ 10,00
------------------------------------------------------------*/
Create or Alter View vCADClientesSemCredito 
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito,
       cTipoPessoa -- Inclusão da nova coluna.
  From tCADCliente 
 Where mCredito < 10
go
/*
Fim da View vCADClientesSemCredito
*/
go

Select * From vCADClientesSemCredito

Select * From tCADCliente

/*
Depois de um tempo, foi necessário uma manutenção na tabela 
tCADCliente e decidiram tirar a coluna cTipoPessoa, pois já tinha
a coluna nTipoPessoa. Entretanto não consideram a view na análise e
tiraram a coluna 
*/



Alter Table tCADCliente drop column cTipoPessoa 

/*
Passando um tempo,  quando foram executar a view.
*/

Select * From vCADClientesSemCredito

/*
Msg 207, Level 16, State 1, Procedure vCADClientesSemCredito, Line 11 [Batch Start Line 93]
Invalid column name 'cTipoPessoa'.
Msg 4413, Level 16, State 1, Line 94
Could not use view or function 'vCADClientesSemCredito'
because of binding errors.
*/


/*
Resolvendo. Incluindo no design da view a opção SCHEMABINDING.
*/

-- Altera a tabela, incluíndo a coluna cTipoPessoa
Alter Table tCADCliente add cTipoPessoa char(15)
go

-- Atualiza a coluna com base no valor de nTipoPessoa.
Update tCADCliente 
   Set cTipoPessoa = Case nTipoPessoa 
                          When 1 
                          Then 'Pessoa Física' 
                          Else 'Pessoa Jurídica'
                     End 
go



/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vCADClientesSemCredito
Objetivo   : Apresenta os clientes com credito menor que R$ 10,00
------------------------------------------------------------*/
Create or Alter View vCADClientesSemCredito 
With SchemaBinding
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito,
       cTipoPessoa 
  From tCADCliente 
 Where mCredito < 10
go
/*
Fim da View vCADClientesSemCredito
*/
go

/*
Msg 4512, Level 16, State 3, Procedure vCADClientesSemCredito, Line 9 [Batch Start Line 122]
Cannot schema bind view 'vCADClientesSemCredito' because name 'tCADCliente' 
is invalid for schema binding. Names must be in two-part format and an 
object cannot reference itself.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vCADClientesSemCredito
Objetivo   : Apresenta os clientes com credito menor que R$ 10,00
------------------------------------------------------------*/
Create or Alter View vCADClientesSemCredito 
with schemabinding
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito,
       cTipoPessoa 
  From dbo.tCADCliente -- Declarando o SCHEMA.TABLE
 Where mCredito < 10
go
/*
Fim da View vCADClientesSemCredito
*/
go

/*
Testando... 
*/

Select * From vCADClientesSemCredito

/*
Agora vamos tentar excluir a coluna da tabela. 
*/

Alter Table tCADCliente drop column cTipoPessoa 

/*
Msg 5074, Level 16, State 1, Line 180
The object 'vCADClientesSemCredito' is dependent on column 'cTipoPessoa'.
Msg 4922, Level 16, State 9, Line 180
ALTER TABLE DROP COLUMN cTipoPessoa failed because one or 
more objects access this column.
*/
