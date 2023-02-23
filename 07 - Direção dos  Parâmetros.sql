/*
Os par�metros s�o as melhores formas
de controlar o envio de dados para a procedure capturar
e realizar o processamento dentro do c�digo.

Quando usamos os par�metros na aula anterior, realizamos a
passagem dos dados do programa que executa para dentro da 
procedure.

Essa passagem podemos chamar de dire��o do par�metro e ele 
pode assumir dois sentidos:

1. Entrada, quando passamos os dados para a procedure.
2. Saida, quando a procedure retorno os dados para o programa que
   a executou.

Todo o par�metro por padr�o ser� de entrada de dados, como vimos
na aula passada.

Se voce deseja criar um par�metro de sa�da, voce dever� colocar
a palavra chave OUTPUT e dois lugar:

1. No final da defini��o do par�metro, na fase de design da procedure.
2. No final do par�metro no momento da execu��o da procedure. 

Posso utilizar quantos par�metros de sa�da forem necess�rios para
atender as regras de neg�cios. 

Exemplo:

Vamos criar uma procedure para efetuar a inclus�o do cliente
e do resultado da inclus�o, teremos que ter o ID do cliente que ser� criado 
pelo c�digo da procedure.

Para isso, vamos usar um par�metro de sa�da para obter
o retorno desse dados. 

*/

use eBook
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirCliente
Objetivo   : Incluir um novo Cliente 
------------------------------------------------------------*/

Create or Alter Procedure stp_IncluirCliente
@iIDCliente int OUTPUT, --<< Obtendo o retorno do ID do Cliente 
@cNome varchar(50) , 
@nTipoPessoa tinyint , 
@cDocumento varchar(14) ,  
@dAniversario date , 
@mCredito smallmoney = $20.00
as
Begin

   Set nocount on 
   
   Declare @nRetorno int = 0 
   Declare @cTipoPessoa varchar(20)

   If @nTipoPessoa = 1
      Set @cTipoPessoa = 'Pessoa F�sica'
   Else 
      Set @cTipoPessoa = 'Pessoa Jur�dica'
  
   Set @iIDCliente = Next Value For seqIDCliente --<< Criando o ID do Cliente.

   Begin Try    
      
	  Insert into tCADCliente (iIDCliente, cNome, nTipoPessoa, cDocumento, dAniversario, mCredito, cTipoPessoa)
	  values (@iIDCliente , @cnome, @nTipoPessoa , @cDocumento , @dAniversario, @mCredito,@cTipoPessoa)
	   
      If @@rowcount = 0
         Raiserror('O Cliente %s n�o foi inclu�do.',16,1,@cNome)

   End Try

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transa��o aberta? 
         Rollback 

      -- Capturou as informa��es de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma �nica mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      --- Realiza a grava��o no Event Viewer.
      --- Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a grava��o em uma tabela.
      Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

	   Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 
      
      Set @nRetorno = @niIDEvento  -- Vamos usar em outas aulas. 

   End Catch

End 
/*
Fim da Procedure stp_IncluirCliente
*/
go 


/*
Agora, vamos executar a procedure para obter o valor do ID do Cliente 
*/
use eBook
go

Declare @iIDCliente_Novo int = NULL  -- Vari�vel que receber� o valor do ID do Cliente 

execute stp_IncluirCliente  @iidCliente = @iIDCliente_Novo,
                            @cNome = 'Jose da Silva' , 
                            @nTipoPessoa = 1, 
                            @cDocumento = '12345678901234' ,  
                            @dAniversario = '2000-01-01' 

raiserror('C�digo do cliente %d ',10,1,@iIDCliente_Novo)

Select top 1 * from tCADCliente order by iidcliente desc 
go

/*
?????????
*/

/*
Na execu��o voce deve tamb�m especificar a palavra chave
OUTPUT. 
*/

Declare @iIDCliente_Novo int 

execute stp_IncluirCliente  @iidCliente = @iIDCliente_Novo OUTPUT, --<< Para retorno, OUTPUT � obrigat�rio 
                             @cNome = 'Jose da Silva' , 
                             @nTipoPessoa = 1, 
                             @cDocumento = '12345678901234' ,  
                             @dAniversario = '2000-01-01' 

raiserror('Codigo do cliente %d ',10,1,@iIDCliente_Novo)

select top 1 * from tCADCliente order by iidcliente desc 





/*
Agora vamos melhorar a procedure  stp_IncluirPedido.
Na aula passada, colocamos todos o c�digo de incluir pedidos dentro
da procedure.

Mas se voce reparou, somente podemos incluir um livro em um 
pedido. 

Ela n�o tem a op��o de voc� informar o ID do Pedido para que
o pr�ximo livro seja inclu�do neste pedido. 

Ent�o vamos ajustar a procedure para:

1. Receber o ID do Pedido como par�metro. Na primeira execu��o, n�o temos 
   o c�digo do Pedido. Mas devemos receber de volta esse ID, ent�o esse
   par�metro ser� de sa�da.

2. No momento de gerar um novo ID, temos que testar se o que foi informado
   no par�metro � NULL. Se sim, gerar um novo ID do Pedido. 

3. Se gerou um novo ID, efetuar o INSERT. Caso contr�rio, o ID foi passado como
   par�metro, n�o gera o novo pedido. 



*/




/*
Rotina que faz um pedido, atualiza o estoque e o cr�dito do Cliente. 
*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirPedido
Objetivo   : Realiza a inclus�o de pedido
------------------------------------------------------------*/
Create or Alter Procedure stp_IncluirPedido
@iidPedido int OUTPUT, -- ID do Pedido 
@iidCliente int , -- C�digo do Cliente que comprar� o livro
@iidLivro int,    -- C�digo do Livro que ser� comprado
@iidLoja int,     -- C�digo da loja onde a compra foi feita 
@nQuantidade int  -- Quantidade de livros. 
as 
Begin 

   Set nocount on 

   Declare @niIDEvento int = 0   
   Declare @mValor smallmoney		   -- Valor do Livro

   Declare @lIncluirPedido bit = 0  -- Para testar se o pedido ser inclu�do 
   Declare @nRetorno int = 0 
   Declare @nDebug bit = 0

   Begin 

      Begin Try 

         -- Recupera qual o valor do livro de uma determinada loja.
         Select @mValor = (mValor * @nQuantidade)
	        From tRELEstoque 
	       Where iIDLivro = @iidLivro 
	         and iIDLoja = @iidLoja 

         If @@rowcount = 0 begin
           Raiserror('Estoque do livro %d n�o foi encontrado na filial %d',16,1,@iidLivro,@iidLoja )
         End 

         -- Se o valor do par�metro iIDPedido for NULL, gera um novo valor 
         If @iIDPedido is null Begin 
            Select @iIDPedido = next value for seqIDPedido; -- Recupera o pr�ximo n�mero de pedido.
            set @lIncluirPedido = 1  -- Mudo o valor para indicar que deve incluir o pedido 
         End 

         Begin Transaction 

         if @lIncluirPedido = 1 Begin 

            if @nDebug = 1
               Raiserror('Incluindo Pedido...',10,1) with nowait 

            -- Inseri o cabe�alho do Pedido.
            Insert Into dbo.tMOVPedido           
            (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDesconto)
            Values
            (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,getdate()),DATEADD(d,10,getdate()),null,587885,5)

         End -- @lIncluirPedido = 1 Begin 
   
         if @nDebug = 1
            Raiserror('Incluindo Item de Pedido...',10,1) with nowait 
   
         -- Inseri o Item do Pedido
         Insert Into tMOVPedidoItem
         (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDesconto)
         Values
         (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

         if @nDebug = 1
            Raiserror('Atualizando Estoque do Livro...',10,1) with nowait 
      
         -- Atualiza o saldo do estoque do livro para a loja
         Update tRELEstoque 
            Set nQuantidade = nQuantidade - @nQuantidade 
          Where iIDLivro = @iidLivro 
            and iIDLoja = @iidLoja 

         if @nDebug = 1
            Raiserror('Atualizando Cr�dito de Cliente...',10,1) with nowait 

         -- Atualiza o cr�dito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - (@mValor * @nQuantidade)
          Where iIDCliente = @iidCliente

	      Commit -- 

      End Try 

      Begin Catch 

         If @@TRANCOUNT > 0 -- tem transa��o aberta? 
            Rollback 

         -- Capturou as informa��es de erro 
         Declare @cMensagem varchar(512) ,
                 @nErrorNumber int = ERROR_NUMBER(),
                 @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
                 @nErrorSeverity tinyint = ERROR_SEVERITY(), 
                 @nErrorState tinyint = ERROR_STATE(), 
                 @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
                 @nErrorLine int = ERROR_LINE()

         -- Fez o tratamento, gerando uma �nica mensagem.
         Set @cMensagem = FormatMessage('MsgID %d. '+@cErrorMessage+' Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a grava��o em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

		   Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 

         set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

      End Catch 

   End 

End 
/*
Finaliza a Operaca��o.
*/
go 

/*
Ambiente
*/
Select * From tRelEstoque 
where iidloja = 9 
  and iidlivro in (108,113,121)
/*
iIDEstoque  iIDLivro    iIDLoja     nQuantidade mValor                dAlteracao              dUltimoConsumo nQuantidadeMinima
----------- ----------- ----------- ----------- --------------------- ----------------------- -------------- -----------------
53499       108         9           18          49,8844               NULL                    2019-01-17     0
22218       113         9           16          13,2211               NULL                    NULL           0
30126       121         9           147         96,053                NULL                    NULL           0
*/

Select mCredito  from tCADCliente where iidcliente = 8834

execute stp_AtualizaCredito @iidcliente = 8834, @mCredito = 200

/*
mCredito
---------------------
200,00

Novo


*/

set nocount on 

Declare @iIDPedido int = NULL -- Veja que est� com NULL 
Declare @iidCliente int = 8834
Declare @iidLivro int = 108
Declare @iidLoja int = 9 
Declare @nQuantidade int = 1


execute stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                          @iidCliente = @iidCliente,
                          @iidLivro = @iidLivro,
                          @iidLoja = @iidLoja,
                          @nQuantidade = @nQuantidade 

Set @iidLivro = 113 
execute stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                          @iidCliente = @iidCliente,
                          @iidLivro = @iidLivro,
                          @iidLoja = @iidLoja,
                          @nQuantidade = @nQuantidade

Set @iidLivro = 121
execute stp_IncluirPedido @iIDPedido = @iIDPedido OUTPUT ,
                          @iidCliente = @iidCliente,
                          @iidLivro = @iidLivro,
                          @iidLoja = @iidLoja,
                          @nQuantidade = @nQuantidade

Raiserror('Pedido gerado %d ', 10,1,@iIDPedido)
go


Select * From tRelEstoque 
where iidloja = 9 
  and iidlivro in (108,113,121)

                          
select * from tMOVPedido where iidPedido = 1664974 

select  * from tMOVPedidoItem where iidPedido = 1664974
