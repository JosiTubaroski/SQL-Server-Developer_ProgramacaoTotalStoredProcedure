/*
Uma tabela temporária local criada em um procedimento armazenado será 
descartada automaticamente quando o procedimento armazenado for encerrado. 

A tabela pode ser referenciada por qualquer procedimento armazenado aninhado 
executado pelo procedimento armazenado que criou a tabela. 

A tabela não pode ser referenciada pelo processo que chamou o procedimento armazenado 
que criou a tabela.

*/

/*
Se uma variável de tabela é declarada em um procedimento armazenado, ela é 
local para o procedimento armazenado e não pode ser referenciada em 
um procedimento aninhado.
*/


/*
Vamos entender nesta aula o comportamento de tabelas temporárias  com store procedures. 
*/

use eBook
go

/*
Simulando um cenário 
*/


/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaCliente 
Objetivo   : Consulta clientes pelo ID, Nome ou documento 
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaCliente 
@iIDCliente int = null,
@cNome varchar(50) = null,
@cDocumento varchar(14) = null 
as
Begin 
  
   Set Nocount on 

   Declare @nRetorno int = 0 

   /*
   Tabela para coletar os resultados das consultas 
   */
   Create Table #tRetornoConsulta (cNome varchar(50), 
                                   nTipoPessoa tinyint , 
                                   cDocumento varchar(14) ,
                                   dAniversario date , 
                                   mCredito smallmoney )
   
   Set @cNome = trim(@cNome)
   Set @cDocumento = trim(@cDocumento)

   Begin Try 

      If @iIDCliente >= 1 
         Execute @nRetorno = stp_ConsultaClienteID @iidCliente = @iidcliente

      If @cNome like replicate('[ A-Z]',len(@cNome) )
         Execute @nRetorno = stp_ConsultaClienteNome @cNome = @cNome 

      IF @cDocumento like replicate('[0-9]',len(@cDocumento) )
         Execute @nRetorno = stp_ConsultaClienteDocumento @cDocumento = @cDocumento

      Select * 
        From #tRetornoConsulta
 
   
    End Try 

    Begin Catch 

       Execute @nRetorno = stp_ManipulaErro

    End Catch 

    Return  @nRetorno 
End 
/*
Fim da Procedure 
*/
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaClienteID
Objetivo   : Consulta clientes pelo ID
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaClienteID
@iIDCliente int 
With Encryption
As
Begin

   Insert into #tRetornoConsulta
   Select cNome, nTipoPessoa , cDocumento , dAniversario , mCredito
     From tCADCliente 
    Where iidcliente = @iIDCliente 
    
    Return 0 

End 
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaClienteNome
Objetivo   : Consulta clientes pelo Nome 
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaClienteNome
@cNome varchar(50)
As
Begin

   Insert into #tRetornoConsulta
   Select cNome, nTipoPessoa , cDocumento , dAniversario , mCredito
     From tCADCliente 
    Where cNome like '%'+@cNome+'%'

   Return 0 


End 
go

/*------------------------------------------------------------
Autor      : Wolney M. Maia
Objeto     : stp_ConsultaClienteDocumento
Objetivo   : Consulta clientes pelo Documento 
------------------------------------------------------------*/
Create or Alter Procedure stp_ConsultaClienteDocumento
@cDocumento varchar(14)
As
Begin

   Insert into #tRetornoConsulta
   Select cNome, nTipoPessoa , cDocumento , dAniversario , mCredito
     From tCADCliente 
    Where cDocumento = @cDocumento

   Return  0

End 
/*
*/
go


Declare @nRetorno int = 0 
Execute @nRetorno = stp_ConsultaCliente @cNome = 'Joelle' , 
                    @iidcliente = 4533 , 
                    @cDocumento = 77670220910



                   select * from #tRetornoConsulta


execute stp_ConsultaClienteID @iidcliente = 4433





















