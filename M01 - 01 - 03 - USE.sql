
/*
Troca de contexto do banco de dados da conexão atual.

Utilizado quando voce está trabalhando com scripts e precisar 
rodar o mesmo em vários bancos. 

*/

use master

select db_name()

use eBook

select db_name()


