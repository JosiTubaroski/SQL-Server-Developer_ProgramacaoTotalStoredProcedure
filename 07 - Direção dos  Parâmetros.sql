/*
Os parâmetros são as melhores formas
de controlar o envio de dados para a procedure capturar
e realizar o processamento dentro do código.

Quando usamos os parâmetros na aula anterior, realizamos a
passagem dos dados do programa que executa para dentro da 
procedure.

Essa passagem podemos chamar de direção do parâmetro e ele 
pode assumir dois sentidos:

1. Entrada, quando passamos os dados para a procedure.
2. Saida, quando a procedure retorno os dados para o programa que
   a executou.

Todo o parâmetro por padrão será de entrada de dados, como vimos
na aula passada.

Se voce deseja criar um parâmetro de saída, voce deverá colocar
a palavra chave OUTPUT e dois lugar:

1. No final da definição do parâmetro, na fase de design da procedure.
2. No final do parâmetro no momento da execução da procedure. 

Posso utilizar quantos parâmetros de saída forem necessários para
atender as regras de negócios. 

Exemplo:

Vamos criar uma procedure para efetuar a inclusão do cliente
e do resultado da inclusão, teremos que ter o ID do cliente que será criado 
pelo código da procedure.

Para isso, vamos usar um parâmetro de saída para obter
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
      Set @cTipoPessoa = 'Pessoa Física'
   Else 
      Set @cTipoPessoa = 'Pessoa Jurídica'
  
   Set @iIDCliente = Next Value For seqIDCliente --<< Criando o ID do Cliente.

   Begin Try    
      
	  Insert into tCADCliente (iIDCliente, cNome, nTipoPessoa, cDocumento, dAniversario, mCredito, cTipoPessoa)
	  values (@iIDCliente , @cnome, @nTipoPessoa , @cDocumento , @dAniversario, @mCredito,@cTipoPessoa)
	   
      If @@rowcount = 0
         Raiserror('O Cliente %s não foi incluído.',16,1,@cNome)

   End Try

   Begin Catch 

      If @@TRANCOUNT > 0 -- tem transação aberta? 
         Rollback 

      -- Capturou as informações de erro 
      Declare @niIDEvento int = 0 ,
              @cMensagem varchar(512) ,
              @nErrorNumber int = ERROR_NUMBER(),
              @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
              @nErrorSeverity tinyint = ERROR_SEVERITY(), 
              @nErrorState tinyint = ERROR_STATE(), 
              @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
              @nErrorLine int = ERROR_LINE()

      -- Fez o tratamento, gerando uma única mensagem.
      Set @cMensagem = FormatMessage('MsgID %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@cErrorMessage,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
      Set @niIDEvento = next value for seqIIDEvento

      --- Realiza a gravação no Event Viewer.
      --- Execute xp_logevent @niIDEvento, @cMensagem , INFORMATIONAL 

      -- Realiza a gravação em uma tabela.
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

Declare @iIDCliente_Novo int = NULL  -- Variável que receberá o valor do ID do Cliente 

execute stp_IncluirCliente  @iidCliente = @iIDCliente_Novo,
                            @cNome = 'Jose da Silva' , 
                            @nTipoPessoa = 1, 
                            @cDocumento = '12345678901234' ,  
                            @dAniversario = '2000-01-01' 

raiserror('Código do cliente %d ',10,1,@iIDCliente_Novo)

Select top 1 * from tCADCliente order by iidcliente desc 
go

/*
?????????
*/

/*
Na execução voce deve também especificar a palavra chave
OUTPUT. 
*/

Declare @iIDCliente_Novo int 

execute stp_IncluirCliente  @iidCliente = @iIDCliente_Novo OUTPUT, --<< Para retorno, OUTPUT é obrigatório 
                             @cNome = 'Jose da Silva' , 
                             @nTipoPessoa = 1, 
                             @cDocumento = '12345678901234' ,  
                             @dAniversario = '2000-01-01' 

raiserror('Codigo do cliente %d ',10,1,@iIDCliente_Novo)

select top 1 * from tCADCliente order by iidcliente desc 





/*
Agora vamos melhorar a procedure  stp_IncluirPedido.
Na aula passada, colocamos todos o código de incluir pedidos dentro
da procedure.

Mas se voce reparou, somente podemos incluir um livro em um 
pedido. 

Ela não tem a opção de você informar o ID do Pedido para que
o próximo livro seja incluído neste pedido. 

Então vamos ajustar a procedure para:

1. Receber o ID do Pedido como parâmetro. Na primeira execução, não temos 
   o código do Pedido. Mas devemos receber de volta esse ID, então esse
   parâmetro será de saída.

2. No momento de gerar um novo ID, temos que testar se o que foi informado
   no parâmetro é NULL. Se sim, gerar um novo ID do Pedido. 

3. Se gerou um novo ID, efetuar o INSERT. Caso contrário, o ID foi passado como
   parâmetro, não gera o novo pedido. 



*/




/*
Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
*/

use eBook
go
/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_IncluirPedido
Objetivo   : Realiza a inclusão de pedido
------------------------------------------------------------*/
Create or Alter Procedure stp_IncluirPedido
@iidPedido int OUTPUT, -- ID do Pedido 
@iidCliente int , -- Código do Cliente que comprará o livro
@iidLivro int,    -- Código do Livro que será comprado
@iidLoja int,     -- Código da loja onde a compra foi feita 
@nQuantidade int  -- Quantidade de livros. 
as 
Begin 

   Set nocount on 

   Declare @niIDEvento int = 0   
   Declare @mValor smallmoney		   -- Valor do Livro

   Declare @lIncluirPedido bit = 0  -- Para testar se o pedido ser incluído 
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
           Raiserror('Estoque do livro %d não foi encontrado na filial %d',16,1,@iidLivro,@iidLoja )
         End 

         -- Se o valor do parâmetro iIDPedido for NULL, gera um novo valor 
         If @iIDPedido is null Begin 
            Select @iIDPedido = next value for seqIDPedido; -- Recupera o próximo número de pedido.
            set @lIncluirPedido = 1  -- Mudo o valor para indicar que deve incluir o pedido 
         End 

         Begin Transaction 

         if @lIncluirPedido = 1 Begin 

            if @nDebug = 1
               Raiserror('Incluindo Pedido...',10,1) with nowait 

            -- Inseri o cabeçalho do Pedido.
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
            Raiserror('Atualizando Crédito de Cliente...',10,1) with nowait 

         -- Atualiza o crédito do cliente. 
         Update tCADCliente 
            Set mCredito = mCredito - (@mValor * @nQuantidade)
          Where iIDCliente = @iidCliente

	      Commit -- 

      End Try 

      Begin Catch 

         If @@TRANCOUNT > 0 -- tem transação aberta? 
            Rollback 

         -- Capturou as informações de erro 
         Declare @cMensagem varchar(512) ,
                 @nErrorNumber int = ERROR_NUMBER(),
                 @cErrorMessage varchar(200) = ERROR_MESSAGE(), 
                 @nErrorSeverity tinyint = ERROR_SEVERITY(), 
                 @nErrorState tinyint = ERROR_STATE(), 
                 @cErrorProcedure varchar(128) = ERROR_PROCEDURE(),
                 @nErrorLine int = ERROR_LINE()

         -- Fez o tratamento, gerando uma única mensagem.
         Set @cMensagem = FormatMessage('MsgID %d. '+@cErrorMessage+' Severidade %d. Status %d. Procedure %s. Linha %d.',@nErrorNumber,@nErrorSeverity ,@nErrorState,@cErrorProcedure ,@nErrorLine)
      
         Set @niIDEvento = next value for seqIIDEvento

         -- Realiza a gravação em uma tabela.
         Insert into tLOGEventos (iIDEvento, cMensagem) values (@niIDEvento,@cMensagem) 

		   Raiserror(@cMensagem , 10,1) -- Somente para mostrar que houve um erro. 

         set @nRetorno = @niIDEvento -- Vamos usar em outas aulas. 

      End Catch 

   End 

End 
/*
Finaliza a Operacação.
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

Declare @iIDPedido int = NULL -- Veja que está com NULL 
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
