/*

THROW 

- Gera um exceção semelhante a função RAISERROR().
- Não gera mensagem de aviso ou informação.
- Assume automaticamente a severidade 16
- Não registro o evento no Log do SQL Server.


*/


THROW 66001,'Mensagem de erro',55
select @@ERROR

begin try

    print 'teste 01';
    throw 60000,'Erro de divisão por zero',1 
    print 'teste 02'

end try

begin catch
   
   throw 

end catch 
