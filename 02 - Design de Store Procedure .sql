https://www.red-gate.com/simple-talk/sql/t-sql-programming/using-stored-procedures-to-provide-an-applications-business-logic-layer/
/*
Como todo o código de programação, o design de Procedure (SP)
deve seguir um padrão de desenvolvimento definido
pelo time de desenvolvimento, aprovado e acompanhado. 

O padrão tem por objetivo definir a estrutura para:

1. Nomear Stored Procedure.
2. Comentar o seu código. Ajude a você e os outros. 
3. Estrturar e identar corretamente os comandos para melhor leitura.
4. Definir variáveis e objetos temporários com nomes padronizados.
5. Identificar dentro do código, os locais das variaveis, teste
   captura de dados, processamento transacional, tratamento de erro e 
   finalização com o retorno dos dados. 

*/


/*
1. A definição da SP, observando o comando, é simples :

Create Procedure <NomeProcedure>
as 
<Código> 

Nome da Procedure  - Qualquer nome quem com até 128 caracters que 
                     começa com uma letra, _ , # ou ##.
                     Padronize:
                     - Começa com stp, stp_, usp, usp_,
                     - Utilize o padrão. Sugestão: CamelCase
                     - Primeira palavra informa o procedimento.
                     - E a segunda o grupo de dados.
                     Evite:
                     - Nomes longos.
                     - Nomes curtos e abreviados.
                     - Nomes sem sentido.
                     - Nomes em outras línguas. 
                     - Começa com sp_

Código             - Código t-SQL. Alguns comandos Create e Set não 
                     são aceitos. 

*/

/*
2. Inclusão de cabeçalho para identificação da procedure. 
*/

use eBook
go


/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Store Procedure
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabeçalho do Pedido.
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 02/01/2019
Execução   : Via SQL Server Management Studio, para demonstração        
Palavras-chave: Pedido
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               01/01/2019 Criação da Procedure 
*/
Create Procedure stp_AtualizaPedido
-- Área de parâmetros 
as
--<Código>
/*
Fim da Procedure stp_AtualizaPedido
*/
go


/*
3. Estruturação e identação do Código 

- É opcional, mas todo o código da procedure deve ficar
  dentro de um BEGIN / END.
  Por um simples motivo. Não existe comando que define o 
  fim da SP. Usando BEGIN/END, você consegue identificar.  

*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabeçalho do Pedido.
------------------------------------------------------------*/
Create Procedure stp_AtualizaPedido
AS
Begin
   -- <Codigo>
End 
go
/*
Fim da Procedure stp_AtualizaPedido
*/

/*
- Para blocos de Controle de Fluxo, deixe um 3 espaços
  na próximo linha antes de começar o  próximo comando.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabeçalho do Pedido.
------------------------------------------------------------*/
Create Procedure stp_AtualizaPedido
as
Begin
   Set Nocount on
   Declare @nRetorno int = 1
   Declare @iIDPedido int = 0
   Set @iIDPedido = (Select iidPedido from tMOVPedido) 
   If @iIDPedido is null 
      Raiserror('Não existe pedido para atulizar.',10,1) 
End 
go

/*
Mostrar como configurar o SSMS para colocar espaço no lugar
do TAB.
*/


/*
- Comandos DMLs devem ser estruturados para que cada cláusula 
  fique em um linha, permitindo uma melhor leitura do código. 

- Quando definir os alias para colunas e tabela, evite nomes 
  curtos e abreviados. 

*/

-- leia o código, entenda o que ele faz e veja quantas tabelas tem?
Select t2.cNome as cCliente,
t1.nNumero as nNumeroPedido,Cast(t1.dPedido as date) as dDataPedido , 
Sum((t3.nQuantidade*t3.mValorUnitario)-t3.mDesconto)-MAX(t1.mDesconto) as mValorPedido ,
Count(*) as nQtdItem From dbo.tMOVPedido t1
Join dbo.tCADCliente t2
on t1.iIDCliente = t2.iIDCliente
Join dbo.tMOVPedidoItem as t3 
on t1.iIDPedido = t3.iidPedido Where t1.dCancelado is null
Group by t2.cNome,       
t1.nNumero,
t1.dPedido 

/*
Versus  
*/
-- E Agora ?
Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
       Count(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
  Join dbo.tCADCliente Cliente 
    on Pedido.iIDCliente = Cliente.iIDCliente
  Join dbo.tMOVPedidoItem as Item 
    on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
 Group by Cliente.cNome,       
          Pedido.nNumero,
          Pedido.dPedido 


/*

*/

Select Cliente.cNome as cCliente,
       Pedido.nNumero as nNumeroPedido,
       Cast(Pedido.dPedido as date) as dDataPedido , 
       Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,
       Count(*) as nQtdItem 
  From dbo.tMOVPedido Pedido
       Join dbo.tCADCliente Cliente 
         on Pedido.iIDCliente = Cliente.iIDCliente
       Join dbo.tMOVPedidoItem as Item 
         on Pedido.iIDPedido = Item.iidPedido 
 Where Pedido.dCancelado is null
   and Item.iIDLoja = 12 
   and Cliente.dExclusao is null  
 Group by Cliente.cNome,       
          Pedido.nNumero,
          Pedido.dPedido 


/*
4. Definir variáveis e objetos temporários com nomes padronizados.

- Como as variáveis devem ter um nome no momento de sua declaração,
  voce deve também seguir um padrão na sua nomeação. 

  Utilizando a mesma regras para definição de colunas, 
  utilizaremos o prefixo que reflete o tipo do dado armazenado. 

   i - Inteiro 
   n - decimal ou numérico
   m - Money ou smallmoney
   d - Datas
   t - Time
   c - Caracteres
   x - XML
   l - Bit (lógico) 

*/

Declare @dAniversario datetime 
Declare @iQuantidade int 
Declare @mSalario smallmoney

/*
- A mesma regras na definição no nomes das views valem para 
  as tabelas temporárias
*/

Create  Table #tTMPMovimentoDoDia 
(
   iIDPedido int not null ,
   iIDLivro int not null ,
   iIDLoje int not null ,
   nQuantidade  tinyint not null ,
   mValorUnitario smallmoney not null ,
   mDesconto smallmoney not null 
)





/*
5. Definição de área dentro da procedure.

Neste item, o objetivo é você definir os locais
onde cada objeto é criado, utilizado, processado.
Onde configuramos o ambientes e definimos os valores
iniciais para variáveis.

Evitar.

- Definir variáveis em qualquer parte do código.
- Criar tabelas temporárias com SELECT..INTO.
- Duas ou mais áreas de retorno da procedure. 

*/
Create Procedure stp_IncluirPedido
/*
Área para parâmetros 
*/
AS
Begin

   /*
   Área para configuração da sessão 
   */
   Set NoCount on 

   /* 
   Area de Declaração das variáveis
   */
   Declare @nRetorno smallint = 0

   /*
   Área de consistência e validação dos parâmetros.
   */ 
   if 

   /*
   Área para cálculo e processamento que não 
   precisam de tratamento de erro ou transação.
   */

   Begin Transaction

   Begin Try
      
      /*
      Área de processamento 
      */ 


      Commit
      set @nRetorno = 0
   End Try

   Begin Catch
      /*
      Área de tratamento de erro
      */
      Rollback
      set @nRetorno = -1
   End Catch

   /*
   Area de finalização e retorno dos dados 
   */

   Return @nRetorno 

End 
/*
Fim da Procedure stp_IncluirPedido
*/