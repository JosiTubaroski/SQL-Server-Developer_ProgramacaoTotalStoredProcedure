/*

BREAK - Interrompe a execu��o do bloco WHILE, devolve o controle do fluxo
        para a pr�ximo instru��o ap�s o WHILE.

CONTINUE - Interrompe a execu��o do Bloco WHILE e volta o controle para o WHILE, ignorando
           as instru��es abaixo do CONTINUE. 



<Comandos>

WHILE <Condi��o> BEGIN

   <Comandos>

   BREAK

   <Comandos>

   CONTINUE

   <Comandos>

END 

<Comandos>

*/



/*
Demonstra��o 
*/

raiserror('Inicio do fluxo' , 10,1)

Declare @iIDLivro int = 0  --- Come�a com 0 na vari�vel 

While @iIDLivro <= 15 begin  -- Executa o Loop 15 vezes 

   set @iIDLivro += 1

   if @iIDLivro in (1,2,3,4,5)  -- Se contator entre 1 e 5
      Continue                  -- Volta para inicio do While
   
   if @iIDLivro > 10 -- Se contador maior que 10, sai do Loop 
      break   --- Sair do la�o. 

   raiserror('Fluxo normal %d', 10,1,@iidlivro )

end 

raiserror('Final do fluxo' , 10,1)