/*

Como emitir uma mensagem no meio da execu��o de um script para 
apresentar informa��es para quem executou a instru��es.

Select 
Print 
Raiserror()

Motivos:

- Debugar
- Gerar um erro ou exce��o
- Emitir avisos ou informa��es


*/
use eBook
go


Select  'Comando executado com sucesso !!!'


Select top 1 * from tCADCliente
Select  'Comando executado com sucesso !!!'

/*
Print.
Print uma mensagem !!!
*/
print 'Comando executado com sucesso !!!'


Select top 1 * from tCADCliente
print 'Comando executado com sucesso !!!'


set nocount on
select  top( cast(rand()*100 as int)) * from tCADCliente
print 'O comando executou '+ cast(@@rowcount as varchar(10))+ ' linhas.'


/*
Problemas com o print 
*/

-- Impress�o com valor null n�o s�o apresentados.
Print 'Teste de impressao 01'

Print 'Teste de impressao 02 com NULL '  + null


-- Print enviado os dados para um buffer. Isso faz com que a mensagem
-- n�o � enviada para o console de execu��o imediatamente. 


print 'Comando executado'
waitfor delay '00:00:05'
go 2


/*
Fun��o RAISERROR()

Utilizada para gerar uma exce��o no fluxo de execu��o 
de um script ou objeto de programa��o. 

No nosso caso, utilizaremos somente para gerar uma mensagem. 

*/

raiserror('Comando executado com sucesso !!!', 10,1)

/*
O par�metro 10 indica para o RAISSERROR() tratar a mensagem como
uma informa��o .
*/

/*
Comparando PRINT com RAISERROR() 
*/

print 'Comando executado'
waitfor delay '00:00:10'
go 2


raiserror( 'Comando executado', 10,1) with nowait
waitfor delay '00:00:10'
go 2


/*

Boa pr�tica. 
Utilize RAISSERROR() WITH NOWAIT 
para apresentar mensagens de aviso ou uma informa��o direto
para quem est� executando, sem passar pelo buffer. 

*/
