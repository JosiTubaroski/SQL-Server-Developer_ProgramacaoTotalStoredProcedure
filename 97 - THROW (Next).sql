/*

THROW 

- Gera um exce��o semelhante a fun��o RAISERROR().
- N�o gera mensagem de aviso ou informa��o.
- Assume automaticamente a severidade 16
- N�o registro o evento no Log do SQL Server.


*/


THROW 66001,'Mensagem de erro',55
select @@ERROR

begin try

    print 'teste 01';
    throw 60000,'Erro de divis�o por zero',1 
    print 'teste 02'

end try

begin catch
   
   throw 

end catch 
