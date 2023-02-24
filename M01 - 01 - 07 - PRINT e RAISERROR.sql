/*

Como emitir uma mensagem no meio da execução de um script para 
apresentar informações para quem executou a instruções.

Select 
Print 
Raiserror()

Motivos:

- Debugar
- Gerar um erro ou exceção
- Emitir avisos ou informações


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

-- Impressão com valor null não são apresentados.
Print 'Teste de impressao 01'

Print 'Teste de impressao 02 com NULL '  + null


-- Print enviado os dados para um buffer. Isso faz com que a mensagem
-- não é enviada para o console de execução imediatamente. 


print 'Comando executado'
waitfor delay '00:00:05'
go 2


/*
Função RAISERROR()

Utilizada para gerar uma exceção no fluxo de execução 
de um script ou objeto de programação. 

No nosso caso, utilizaremos somente para gerar uma mensagem. 

*/

raiserror('Comando executado com sucesso !!!', 10,1)

/*
O parâmetro 10 indica para o RAISSERROR() tratar a mensagem como
uma informação .
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

Boa prática. 
Utilize RAISSERROR() WITH NOWAIT 
para apresentar mensagens de aviso ou uma informação direto
para quem está executando, sem passar pelo buffer. 

*/
