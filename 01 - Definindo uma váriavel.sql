/*
Vari�vel - Local tempor�rio na mem�ria para alocar dados escalar ou tabela

- A vari�vel � criada com a instru��o DECLARE 
- Come�a com @.
- Define o tipo de dado que ser� armazenado.
- Opcional, define um valor.
- Se n�o definir valor, ser� assumido NULL.
- Ela existir� somente no contexto de execu��o do c�digo ou do lote
- Vari�vel do tipo Table veremos nas pr�ximas aulas. 

*/

-- Define um �nica vari�vel  
Declare @cNome varchar(200) 

-- Define v�rias vari�veis com um DECLARE 
Declare @nSaldo int, @nValor Numeric(10)

Declare @nSalario smallmoney ,
        @mAumento smallmoney,
		@mFGTS smallmoney 
		
Declare @xPedidoExportar xml -- Recebe um estrutura no formato XML

/*
Definindo vari�vel com valor default 
*/
use eBook
go


Declare @cNome varchar(200) = 'Jose da Silva' 

-- Define v�rias vari�veis com um DECLARE 
Declare @nSaldo int = 100 , @nValor Numeric(10) = 1500.00 

Declare @nSalario smallmoney = 7500.00 ,
        @mAumento smallmoney = 580.00,
		@mFGTS smallmoney = 650.00
		
Declare @xPedidoExportar xml = '<tcadlivro iIDLivro="1" cTitulo="Underground"/>'









