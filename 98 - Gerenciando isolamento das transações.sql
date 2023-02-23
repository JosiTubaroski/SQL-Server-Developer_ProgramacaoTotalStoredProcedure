/*

Livro SQL SERVER 2005 Técnicas aplicadas - Pagina 235


Bloqueio e Recursos. 

O engine do SQL Server decide a melhor forma de realizar um "bloqueio"
em um "recurso". Isso para garantir a eficiência da transação versus a sobrecarga
de recursos de hardware e o do SQL Server.

Um bloqueio pode ser feito de várias formas que chamamos de "Modo de Bloqueio".

- Quando ele realiza um bloqueio de um recurso qualquer, esse bloqueio é chamado de 
  bloqueio exclusivo e é representado pela letra X. A sessão que realiza o bloqueio
  detêm o bloqueio do recurso e outra sessão não pode solicitar o bloqueio do mesmo 
  recurso.
*/

use eBook
go

Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente = 1 -- A coluna é um chave primária, o recurso será KEY.
 
 Select resource_type as type , 
	     request_mode as mode,
	     request_type as request,
        request_status as status,
	     request_session_id as session,
	     Case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	     End as object,
        resource_description
   From sys.dm_tran_locks 
  Where request_session_id = @@SPID
  Order by request_session_id , resource_type


Rollback 
go

/*
- Quando um operação de leitura é realizada, a sessão tenta obter um 
  bloqueio compartilhado representado pela letra S. A sessão que realiza o bloqueio
  detêm o bloqueio do recurso e outra sessão pode solicitar somente bloqueio compartilhados
  ou com intenção de bloqueio
  
*/

-- Executar esse SELECT em outra sessão. Pegar o SPID 
-- da outra sessão para colocar no SELECT abaixo.
Select * From tMOVPedidoItem

Select resource_type as type , 
       request_mode as mode,
	    request_type as request,
       request_status as status,
	    request_session_id as session,
	    case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	    end as object,
       resource_description
  From sys.dm_tran_locks 
 Where request_session_id = 54
 Order by type


/*

Os recursos.

Podemos dizer que os recursos são as unidades de alocação do dados que podem
sofrer algum tipo de bloqueio. 

Abaixo temos a hierarquia do recursos do menor até o maior 

Link : https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2014#lock-granularity-and-hierarchies

Recurso	         Descrição
------------------------------------------------------------------------------
RID	            Um identificador de linha usado para bloquear uma única 
                  linha dentro de um heap.
KEY	            Um bloqueio de linha dentro de um índice usado para 
                  proteger um intervalo de chaves em transações.
PAGE	            Uma página de 8 quilobytes (KB) em um banco de dados, 
                  como dados ou páginas de índice.
EXTENT	         Um grupo contíguo de oito páginas, como dados ou 
                  páginas de índice.
HoBT	            Um heap ou árvore-B. Um bloqueio protegendo uma 
                  árvore-B (índice) ou o heap de páginas de dados 
                  que não tem um índice clusterizado.
TABLE	            A tabela inteira, inclusive todos os dados e índices.
FILE	            Um arquivo do banco de dados.
APPLICATION	      Um recurso de aplicativo especificado.
METADATA	         Bloqueios de metadados.
ALLOCATION_UNIT	Uma unidade de alocação.
DATABASE	         O banco de dados inteiro.
*/


-- Bloqueando uma chave (KEY)
Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente = 1 


 Select resource_type as type , 
	     request_mode as mode,
	     request_type as request,
        request_status as status,
	     request_session_id as session,
	     case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	     end as object,
        resource_description
   From sys.dm_tran_locks 
where request_session_id = @@SPID 
order by request_session_id

ROLLBACK


-- Bloqueando a tabela TCADCliente  (OBJECT) 
Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where dCadastro > '2018-01-01'


 Select resource_type as type , 
	     request_mode as mode,
	     request_type as request,
        request_status as status,
	     request_session_id as session,
	     case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	     end as object,
        resource_description
   From sys.dm_tran_locks 
where request_session_id = @@SPID 
order by request_session_id

ROLLBACK

/*
Um bloqueio de granularidade menor é quando o SQL SERVER realiza o bloqueio
da linha (RID) ou da chave (KEY) onde temos o menor recurso 
que uma linha de dados.

Entretando, ele pode solicitar o que chamados de intenção de bloqueio
que pode ser exclusivo (IX) ou compartilhado (IS).

Para executar uma instrução onde requer um bloqueio, o engine do SQL Server
solicita a intenção de bloqueios nos níveis mais alto
do recurso que será bloqueado.

Por exemplo, se o engine decide bloquear uma KEY, ele tenta obter a intenção 
de bloqueio de recursos maiores como PAGE ou TABLE.

Exemplo: 

*/
use eBook
go

Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente = 1 


 Select resource_type as type , 
	     request_mode as mode,
	     request_type as request,
	     request_session_id as session,
        request_status as status,
	     case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	     end as object,
        resource_description
   From sys.dm_tran_locks 
where request_session_id = 53
order by request_session_id



-- Bloqueando várias chaves 


Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente <= 10 

 Rollback


Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente <= 5000

Rollback


Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente <= 11000

Rollback


 Select resource_type as type , 
	     request_mode as mode,
	     request_type as request,
        request_status as status,
	     request_session_id as session,
	     case when resource_type = 'OBJECT' 
	          then object_name(resource_associated_entity_id)
	     end as object,
        resource_description
   From sys.dm_tran_locks 
  Where request_session_id = @@SPID


Select COUNT(1) from tCADCliente
