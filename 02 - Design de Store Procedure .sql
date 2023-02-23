https://www.red-gate.com/simple-talk/sql/t-sql-programming/using-stored-procedures-to-provide-an-applications-business-logic-layer/
/*
Como todo o c�digo de programa��o, o design de Procedure (SP)
deve seguir um padr�o de desenvolvimento definido
pelo time de desenvolvimento, aprovado e acompanhado. 

O padr�o tem por objetivo definir a estrutura para:

1. Nomear Stored Procedure.
2. Comentar o seu c�digo. Ajude a voc� e os outros. 
3. Estrturar e identar corretamente os comandos para melhor leitura.
4. Definir vari�veis e objetos tempor�rios com nomes padronizados.
5. Identificar dentro do c�digo, os locais das variaveis, teste
   captura de dados, processamento transacional, tratamento de erro e 
   finaliza��o com o retorno dos dados. 

*/


/*
1. A defini��o da SP, observando o comando, � simples :

Create Procedure <NomeProcedure>
as 
<C�digo> 

Nome da Procedure  - Qualquer nome quem com at� 128 caracters que 
                     come�a com uma letra, _ , # ou ##.
                     Padronize:
                     - Come�a com stp, stp_, usp, usp_,
                     - Utilize o padr�o. Sugest�o: CamelCase
                     - Primeira palavra informa o procedimento.
                     - E a segunda o grupo de dados.
                     Evite:
                     - Nomes longos.
                     - Nomes curtos e abreviados.
                     - Nomes sem sentido.
                     - Nomes em outras l�nguas. 
                     - Come�a com sp_

C�digo             - C�digo t-SQL. Alguns comandos Create e Set n�o 
                     s�o aceitos. 

*/

/*
2. Inclus�o de cabe�alho para identifica��o da procedure. 
*/

use eBook
go


/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Store Procedure
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabe�alho do Pedido.
Projeto    : Treinamento          
Empresa Respons�vel: ForceDB Treinamentos
Criado em  : 02/01/2019
Execu��o   : Via SQL Server Management Studio, para demonstra��o        
Palavras-chave: Pedido
----------------------------------------------------------------------------------------------        
Observa��es :        

----------------------------------------------------------------------------------------------        
Hist�rico:        
Autor                  IDBug Data       Descri��o        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               01/01/2019 Cria��o da Procedure 
*/
Create Procedure stp_AtualizaPedido
-- �rea de par�metros 
as
--<C�digo>
/*
Fim da Procedure stp_AtualizaPedido
*/
go


/*
3. Estrutura��o e identa��o do C�digo 

- � opcional, mas todo o c�digo da procedure deve ficar
  dentro de um BEGIN / END.
  Por um simples motivo. N�o existe comando que define o 
  fim da SP. Usando BEGIN/END, voc� consegue identificar.  

*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabe�alho do Pedido.
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
- Para blocos de Controle de Fluxo, deixe um 3 espa�os
  na pr�ximo linha antes de come�ar o  pr�ximo comando.
*/

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_AtualizaPedido
Objetivo   : Atuliza os dados do cabe�alho do Pedido.
------------------------------------------------------------*/
Create Procedure stp_AtualizaPedido
as
Begin
   Set Nocount on
   Declare @nRetorno int = 1
   Declare @iIDPedido int = 0
   Set @iIDPedido = (Select iidPedido from tMOVPedido) 
   If @iIDPedido is null 
      Raiserror('N�o existe pedido para atulizar.',10,1) 
End 
go

/*
Mostrar como configurar o SSMS para colocar espa�o no lugar
do TAB.
*/


/*
- Comandos DMLs devem ser estruturados para que cada cl�usula 
  fique em um linha, permitindo uma melhor leitura do c�digo. 

- Quando definir os alias para colunas e tabela, evite nomes 
  curtos e abreviados. 

*/

-- leia o c�digo, entenda o que ele faz e veja quantas tabelas tem?
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
4. Definir vari�veis e objetos tempor�rios com nomes padronizados.

- Como as vari�veis devem ter um nome no momento de sua declara��o,
  voce deve tamb�m seguir um padr�o na sua nomea��o. 

  Utilizando a mesma regras para defini��o de colunas, 
  utilizaremos o prefixo que reflete o tipo do dado armazenado. 

   i - Inteiro 
   n - decimal ou num�rico
   m - Money ou smallmoney
   d - Datas
   t - Time
   c - Caracteres
   x - XML
   l - Bit (l�gico) 

*/

Declare @dAniversario datetime 
Declare @iQuantidade int 
Declare @mSalario smallmoney

/*
- A mesma regras na defini��o no nomes das views valem para 
  as tabelas tempor�rias
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
5. Defini��o de �rea dentro da procedure.

Neste item, o objetivo � voc� definir os locais
onde cada objeto � criado, utilizado, processado.
Onde configuramos o ambientes e definimos os valores
iniciais para vari�veis.

Evitar.

- Definir vari�veis em qualquer parte do c�digo.
- Criar tabelas tempor�rias com SELECT..INTO.
- Duas ou mais �reas de retorno da procedure. 

*/
Create Procedure stp_IncluirPedido
/*
�rea para par�metros 
*/
AS
Begin

   /*
   �rea para configura��o da sess�o 
   */
   Set NoCount on 

   /* 
   Area de Declara��o das vari�veis
   */
   Declare @nRetorno smallint = 0

   /*
   �rea de consist�ncia e valida��o dos par�metros.
   */ 
   if 

   /*
   �rea para c�lculo e processamento que n�o 
   precisam de tratamento de erro ou transa��o.
   */

   Begin Transaction

   Begin Try
      
      /*
      �rea de processamento 
      */ 


      Commit
      set @nRetorno = 0
   End Try

   Begin Catch
      /*
      �rea de tratamento de erro
      */
      Rollback
      set @nRetorno = -1
   End Catch

   /*
   Area de finaliza��o e retorno dos dados 
   */

   Return @nRetorno 

End 
/*
Fim da Procedure stp_IncluirPedido
*/