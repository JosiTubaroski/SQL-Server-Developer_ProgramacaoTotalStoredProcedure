
/*
Troca de contexto do banco de dados da conex�o atual.

Utilizado quando voce est� trabalhando com scripts e precisar 
rodar o mesmo em v�rios bancos. 

*/

use master

select db_name()

use eBook

select db_name()


