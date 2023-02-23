/*

Livro SQL SERVER 2005 T�cnicas aplicadas - Pagina 235


Bloqueio e Recursos. 

O engine do SQL Server decide a melhor forma de realizar um "bloqueio"
em um "recurso". Isso para garantir a efici�ncia da transa��o versus a sobrecarga
de recursos de hardware e o do SQL Server.

Um bloqueio pode ser feito de v�rias formas que chamamos de "Modo de Bloqueio".

- Quando ele realiza um bloqueio de um recurso qualquer, esse bloqueio � chamado de 
  bloqueio exclusivo e � representado pela letra X. A sess�o que realiza o bloqueio
  det�m o bloqueio do recurso e outra sess�o n�o pode solicitar o bloqueio do mesmo 
  recurso.
*/

use eBook
go

Begin Transaction

Update tCADCliente 
   set mCredito = 100
 Where iIDCliente = 1 -- A coluna � um chave prim�ria, o recurso ser� KEY.
 
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
- Quando um opera��o de leitura � realizada, a sess�o tenta obter um 
  bloqueio compartilhado representado pela letra S. A sess�o que realiza o bloqueio
  det�m o bloqueio do recurso e outra sess�o pode solicitar somente bloqueio compartilhados
  ou com inten��o de bloqueio
  
*/

-- Executar esse SELECT em outra sess�o. Pegar o SPID 
-- da outra sess�o para colocar no SELECT abaixo.
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

Podemos dizer que os recursos s�o as unidades de aloca��o do dados que podem
sofrer algum tipo de bloqueio. 

Abaixo temos a hierarquia do recursos do menor at� o maior 

Link : https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2014#lock-granularity-and-hierarchies

Recurso	         Descri��o
------------------------------------------------------------------------------
RID	            Um identificador de linha usado para bloquear uma �nica 
                  linha dentro de um heap.
KEY	            Um bloqueio de linha dentro de um �ndice usado para 
                  proteger um intervalo de chaves em transa��es.
PAGE	            Uma p�gina de 8 quilobytes (KB) em um banco de dados, 
                  como dados ou p�ginas de �ndice.
EXTENT	         Um grupo cont�guo de oito p�ginas, como dados ou 
                  p�ginas de �ndice.
HoBT	            Um heap ou �rvore-B. Um bloqueio protegendo uma 
                  �rvore-B (�ndice) ou o heap de p�ginas de dados 
                  que n�o tem um �ndice clusterizado.
TABLE	            A tabela inteira, inclusive todos os dados e �ndices.
FILE	            Um arquivo do banco de dados.
APPLICATION	      Um recurso de aplicativo especificado.
METADATA	         Bloqueios de metadados.
ALLOCATION_UNIT	Uma unidade de aloca��o.
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
Um bloqueio de granularidade menor � quando o SQL SERVER realiza o bloqueio
da linha (RID) ou da chave (KEY) onde temos o menor recurso 
que uma linha de dados.

Entretando, ele pode solicitar o que chamados de inten��o de bloqueio
que pode ser exclusivo (IX) ou compartilhado (IS).

Para executar uma instru��o onde requer um bloqueio, o engine do SQL Server
solicita a inten��o de bloqueios nos n�veis mais alto
do recurso que ser� bloqueado.

Por exemplo, se o engine decide bloquear uma KEY, ele tenta obter a inten��o 
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



-- Bloqueando v�rias chaves 


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
