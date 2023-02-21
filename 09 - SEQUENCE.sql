/*
Sequence 

Objeto do banco de dados para criar sequenciador numéricos independente 
de qualquer tabela. 

A definição do sequenciador é feita para instrução CREATE SEQUENCE

E o retorno de um valor numérico com a próxima sequência da numeração é 
feita pelo comando NEXT VALUE.

*/
use eBook
go

-- Criar o Sequenciador 
Create Sequence NotaFiscal 
       as int 
	   start with 1 
	   increment by 1

-- Obtem o próximo valor da Sequencia
Select Next Value for Notafiscal

-- Reinicia a Sequencia
Alter Sequence NotaFiscal 
      restart

Select Next Value for Notafiscal


/*
Usando SEQUENCE na criação de tabelas.
*/

use eBook
go

Create Sequence seqIDPessoa 
       as int 
	   start with 1 
	   increment by 1
go

drop  Table tTMPPessoas 
go

Create Table tTMPPessoas 
(
   iIDPessoa int not null Default (Next Value for seqIDPessoa) primary key,
   cNome varchar(100) not null
)
go

Insert into tTMPPessoas (cNome) values ('Jose da Silva')
go

Select * from tTMPPessoas



/*
Usando SEQUENCE direto no comando INSERT
*/

Insert into tTMPPessoas (iIDPessoa, cNome) 
values (Next Value for seqIDPessoa , 'Maria da Silva')
go

Select * from tTMPPessoas

/*
Usando o SEQUENCE ante de executar o INSERT 
*/

Declare @iidPessoa int -- Define uma variável do tipo INT.
Set @iidPessoa = Next Value for seqIDPessoa 

Insert into tTMPPessoas (iIDPessoa, cNome) 
values (@iidPessoa, 'Joaquim Gomes')
go


Select * from tTMPPessoas 


/*
Consultando as informações do sequenciador. 
*/

select * from sys.sequences
where name = 'seqIDPessoa'


/*
Comparando o IDENTITY() x SEQUENCE 
*/


/*
SEQUENCE	- Independente de tabela e coluna.
IDENTITY	- Associado a uma tabela e coluna. Só pode exisitr uma coluna IDENTITY()

SEQUENCE	- Deve ser chamado pela comando NEXT VALUE para obter o próximo valor 
IDENTITY	- O próximo valor é gerado automaticamente. 

SEQUENCE	- A sequencia de números pode ser reiniciada. 
IDENTITY	- Após atingir o valor máximo do tipo da coluna, não pode mais inserir linhas.

SEQUENCE	- Como ele é independente da tabela, pode se usado no comando UPDATE.
IDENTITY	- O valor pode se mudado, mas requer utilizar a instrução 
              SET IDENTITY_INSERT antes e depois da atualização

SEQUENCE	- Com certas configurações, ela mantém os dados em cache o que garante melhor desempenho.
IDENTITY	- Mante os dados persistidos em disco.
*/


-- Na minha visão, ele deve ser utilizado no lugar do IDENTITY()


