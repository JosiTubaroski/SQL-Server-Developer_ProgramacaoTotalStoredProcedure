/*
Views Atualizáveis. 

Os dados podem ser atualizados através de uma visão. Essas visões 
são chamadas de atualizáveis. 

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
go

Update vCADClientesSemCredito 
   Set ValorCredito = 20
 Where ID = 1
go

Select * from vCADClientesSemCredito 
go
select * from tcadcliente where iidcliente = 1


/*
Agora vamos ver algumas visões que não são atualizáveis e 
quais as mensagens de erros que retornam.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vMOVPedidoTotalMes2018
Objetivo   : Apresentar o total de pedidos agrupador por mês
             para o ano de 2018 
------------------------------------------------------------*/
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
go
select * from vMOVPedidoTotalMes2018
go


Update vMOVPedidoTotalMes2018 
   Set nQuantidade = 0 
 Where cMes = 'June'
go

/*
Msg 4406, Level 16, State 1, Line 59
Update or insert of view or function 'vMOVPedidoTotalMes2018' failed 
because it contains a derived or constant field.
*/


use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : vCADPessoFisica 
Objetivo   : Manter compatibilidade com o Sistema XPTO Versão 1.0 
------------------------------------------------------------*/
Create or Alter View vCADPessoFisica 
as
Select Cliente.iIDCliente,
       Cliente.cNome , 
       Cliente.cDocumento,
       Cliente.dAniversario,
       Endereco.cLogradouro,
       Endereco.nNumero,
       Endereco.cComplemento,
       Endereco.cBairro,
       Endereco.cCEP
  From tCADCliente Cliente 
  Join tCADEndereco Endereco 
    On Cliente.iIDCliente = Endereco.iIDCliente 
 Where Endereco.iIDTipoEndereco = 1
   and Cliente.nTipoPessoa = 1 
/*
Fim da view vCADPessoFisica 
*/
go

Select cNome, 
       dAniversario, 
       cLogradouro 
  From vCADPessoFisica 
 Where iIDCliente  =1 

/*
Alterar dados de duas colunas que pertence a tabelas diferentes em um 
única instrução UPDATE 
*/

go
Update vCADPessoFisica 
   Set dAniversario = '1973-07-26' ,
       cLogradouro = 'Avenida Nullam,1532'
 Where iIDCliente  =1 

/*
Msg 4405, Level 16, State 1, Line 102
View or function 'vCADPessoFisica' is not updatable because the 
modification affects multiple base tables.
*/

Update vCADPessoFisica 
   Set dAniversario = '1973-07-26' 
 Where iIDCliente  =1 
go

Update vCADPessoFisica 
   Set cLogradouro = 'Avenida Nullam,1532'
 Where iIDCliente  =1 
go

/*
*/



