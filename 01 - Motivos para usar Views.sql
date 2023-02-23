/*
View ou Vis�o, s�o objetos de programa��o que 
encapsulam uma instru��o SELECT.
*/

use eBook
go

Create or Alter View vCADClientesSemCredito 
as 
Select iIDCliente as ID, 
       cNome as Nome, 
       mCredito as ValorCredito   
  From tCADCliente 
 Where mCredito < 10
go


/*
Quando a instru��o abaixo � executada, a view executa
o c�digo que est� associado. 
*/

Select * 
  From vCADClientesSemCredito


/*
N�o � verdade que, neste caso, os dados j� est�o armazenados 
na view. N�o � isso.
Existe sim a execu��o do c�digo SELECT associado a view.
*/

/*
Por que usar as views ??
*/

/*
01. Simplificar uma instru��o SELECT complexa para facilitar a sua utiliza��o 
    e reaproveitar o c�digo 

02. Acess�vel por qualquer instru��o DML e me certos cen�rios 
    at� mesmo pela instru��es INSERT, UPDATE E DELETE para atualizar 
	dados.

03. Reduz o tr�nsito de dados pela rede interna. 

04. Encapsular regras de neg�cios, escondendo os objetos de banco de dados 

05. Permitir emular tabelas que foram alteradas  
    com vers�es antigas de sistemas. 

	Imagine um sistema que tinha uma tabela de nome tCADPessoaFisica que 
	contemplava os dados de clientes e endere�o.

	O sistema foi atualizado a foi necess�rio uma nova normaliza��o da
	tabela de Pessoa Fisica para tabela de TCADCliente e os dados de endere�o
	foram para uma nova tabela tCADEndereco.

	Mas um sistema legado � que n�o era poss�vel de realizar manutena��o,
	precisa acessar a tabela tCADPessoaFisica que n�o existe mais.

	Solu��o. Criar uma vis�o. 

*/

Create or Alter View tCADPessoFisica 
as
Select Cliente.* , 
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
Obs. Como nesse exemplo, a justificativa de view ter o nome tCADPessoaFisica �
para ela substituir o nome de uma tabela que existia com esse nome. 


06. Maior seguran�a ao acesso ao dados. Voce pode conceder permiss�o 
    de acesso a vis�o sem a necessidade de conceder permiss�es 
    nas tabelas. 

*/