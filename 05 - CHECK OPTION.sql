/*
CHECK OPTION é uma opção que você declara no design 
da view que garante os dados 
continue visível depois de qualquer alteração.

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
With SchemaBinding
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito,
       cTipoPessoa 
  From dbo.tCADCliente 
 Where mCredito < 10
  With Check Option 
go
/*
Fim da View vCADClientesSemCredito
*/
go

use eBook
go
Select top 10 *
  From vCADClientesSemCredito 
go

Update vCADClientesSemCredito  
   Set ValorCredito = 15
 Where ID = 20


/*
Msg 550, Level 16, State 1, Line 38
The attempted insert or update failed because the target view either 
specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION 
and one or more rows resulting from the operation did not 
qualify under the CHECK OPTION constraint.
The statement has been terminated.
*/


/*
Entretanto, se você realizar o ajuste direto na tabela...
*/
update tCADCliente 
   set  mCredito = 20.00
where iIDCliente = 20
go

Select top 10 *
  From vCADClientesSemCredito 
  Where id = 20


/*
*/


/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vClienteAtivo
Objetivo   : Apresenta os clientes ativos
------------------------------------------------------------*/

Create Or Alter View vClienteAtivo
With SchemaBinding
as
Select iIDCliente, cNome, mCredito ,cTipoPessoa ,dExclusao
  From dbo.tCADCliente 
 Where dExclusao is null 
  With Check Option 
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
With SchemaBinding
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito,
       cTipoPessoa,
	   dExclusao
  From dbo.vClienteAtivo
 Where mCredito < 10
  With Check Option 
go
/*
Fim da View vCADClientesSemCredito
*/


Select * from vCADClientesSemCredito 
go

Update vCADClientesSemCredito  
   Set dExclusao = getdate() 
 Where id = 35





