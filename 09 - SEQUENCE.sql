/*
Sequence 

Objeto do banco de dados para criar sequenciador num�ricos independente 
de qualquer tabela. 

A defini��o do sequenciador � feita para instru��o CREATE SEQUENCE

E o retorno de um valor num�rico com a pr�xima sequ�ncia da numera��o � 
feita pelo comando NEXT VALUE.

*/
use eBook
go

-- Criar o Sequenciador 
Create Sequence NotaFiscal 
       as int 
	   start with 1 
	   increment by 1

-- Obtem o pr�ximo valor da Sequencia
Select Next Value for Notafiscal

-- Reinicia a Sequencia
Alter Sequence NotaFiscal 
      restart

Select Next Value for Notafiscal


/*
Usando SEQUENCE na cria��o de tabelas.
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

Declare @iidPessoa int -- Define uma vari�vel do tipo INT.
Set @iidPessoa = Next Value for seqIDPessoa 

Insert into tTMPPessoas (iIDPessoa, cNome) 
values (@iidPessoa, 'Joaquim Gomes')
go


Select * from tTMPPessoas 


/*
Consultando as informa��es do sequenciador. 
*/

select * from sys.sequences
where name = 'seqIDPessoa'


/*
Comparando o IDENTITY() x SEQUENCE 
*/


/*
SEQUENCE	- Independente de tabela e coluna.
IDENTITY	- Associado a uma tabela e coluna. S� pode exisitr uma coluna IDENTITY()

SEQUENCE	- Deve ser chamado pela comando NEXT VALUE para obter o pr�ximo valor 
IDENTITY	- O pr�ximo valor � gerado automaticamente. 

SEQUENCE	- A sequencia de n�meros pode ser reiniciada. 
IDENTITY	- Ap�s atingir o valor m�ximo do tipo da coluna, n�o pode mais inserir linhas.

SEQUENCE	- Como ele � independente da tabela, pode se usado no comando UPDATE.
IDENTITY	- O valor pode se mudado, mas requer utilizar a instru��o 
              SET IDENTITY_INSERT antes e depois da atualiza��o

SEQUENCE	- Com certas configura��es, ela mant�m os dados em cache o que garante melhor desempenho.
IDENTITY	- Mante os dados persistidos em disco.
*/


-- Na minha vis�o, ele deve ser utilizado no lugar do IDENTITY()


