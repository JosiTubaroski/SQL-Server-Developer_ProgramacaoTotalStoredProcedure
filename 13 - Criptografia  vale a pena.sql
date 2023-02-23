/*
Criptografia da procedure.

Quando você informar para o SQL Server criptografar o código associado 
a procedure.

O SQL Server consegue executar a procedure criptografada, mas voce não consegue
acessar mais o contéudo da procedure armazenado no banco de dados. 

*/

use eBook
go

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
   
   Set @cNome = trim(@cNome)
   Set @cDocumento = trim(@cDocumento)

   Begin Try 

      If @iIDCliente >= 1 
         Execute @nRetorno = stp_ConsultaClienteID @iidCliente = @iidcliente

      If @cNome like replicate('[ A-Z]',len(@cNome) )
         Execute @nRetorno = stp_ConsultaClienteNome @cNome = @cNome 

      IF @cDocumento like replicate('[0-9]',len(@cDocumento) )
         Execute @nRetorno = stp_ConsultaClienteDocumento @cDocumento = @cDocumento
   
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
With Encryption
As
Begin

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
With Encryption
As
Begin

   Select cNome, nTipoPessoa , cDocumento , dAniversario , mCredito
     From tCADCliente 
    Where cDocumento = @cDocumento

   Return  0

End 
/*
*/
go



/*
Agora vamos testar com outro usuário que tem permissão de executar
procedure e ele tem a permissão de visualiar conteúdo. 
*/
Create Login usrMaria
  With Password = '@123456', 
  Default_Database = ebook, 
  Check_Expiration = off,     -- Conta não expira
  Check_Policy = off          -- Não aplicar as políticas de senha do Windows 
go

Create User usrMaria
   For Login usrMaria
   With Default_Schema = dbo
go

Grant Execute on schema::dbo to usrMaria
Grant View Definition on schema::dbo to usrMaria
go

sp_helptext 'dbo.stp_ConsultaClienteDocumento'
go

Declare @iIDObject int = object_id('dbo.stp_ConsultaClienteDocumento')
Select Definition 
  From sys.sql_modules 
 Where object_id = @iIDObject
go

Declare @iIDObject int = object_id('dbo.stp_ConsultaClienteDocumento')
Select OBJECT_DEFINITION(@iIDObject) 
go


/*
Mas vale a pena criptografar uma procedure ?

1. Se o seu ambiente não tem um controle de acesso rígido, as contas de login
   tem acesso a visualizar o conteúdo de procedures e os códigos delas são
   sensíveis e não podem ser visto, vale a pena então ter as procedures
   criptografadas.
   
2. Ter um local seguro, fora do banco para guardar o original. 
   Usa login e senha para isso.

3. Uma vez no banco e com contas com perfil de administrador, 
   pode-se descriptograr de duas forma:

   Com acesso via DAC e com a conta de sysadmin, é possível executar 
   scripts que permiter quebrar a criptgrafica 

   Utilizando ferramentas de terceiros, que acessam a base e tenha permissão
   de visualizar o código da procedures. 

*/


/*
Formas segura.

1. Restringir o acesso. 
2. Gerar backups criptografados e com senha 
*/


