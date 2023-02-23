/*
View ou Visão, são objetos de programação que 
encapsulam uma instrução SELECT.
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
Quando a instrução abaixo é executada, a view executa
o código que está associado. 
*/

Select * 
  From vCADClientesSemCredito


/*
Não é verdade que, neste caso, os dados já estão armazenados 
na view. Não é isso.
Existe sim a execução do código SELECT associado a view.
*/

/*
Por que usar as views ??
*/

/*
01. Simplificar uma instrução SELECT complexa para facilitar a sua utilização 
    e reaproveitar o código 

02. Acessível por qualquer instrução DML e me certos cenários 
    até mesmo pela instruções INSERT, UPDATE E DELETE para atualizar 
	dados.

03. Reduz o trânsito de dados pela rede interna. 

04. Encapsular regras de negócios, escondendo os objetos de banco de dados 

05. Permitir emular tabelas que foram alteradas  
    com versões antigas de sistemas. 

	Imagine um sistema que tinha uma tabela de nome tCADPessoaFisica que 
	contemplava os dados de clientes e endereço.

	O sistema foi atualizado a foi necessário uma nova normalização da
	tabela de Pessoa Fisica para tabela de TCADCliente e os dados de endereço
	foram para uma nova tabela tCADEndereco.

	Mas um sistema legado é que não era possível de realizar manutenação,
	precisa acessar a tabela tCADPessoaFisica que não existe mais.

	Solução. Criar uma visão. 

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
Obs. Como nesse exemplo, a justificativa de view ter o nome tCADPessoaFisica é
para ela substituir o nome de uma tabela que existia com esse nome. 


06. Maior segurança ao acesso ao dados. Voce pode conceder permissão 
    de acesso a visão sem a necessidade de conceder permissões 
    nas tabelas. 

*/