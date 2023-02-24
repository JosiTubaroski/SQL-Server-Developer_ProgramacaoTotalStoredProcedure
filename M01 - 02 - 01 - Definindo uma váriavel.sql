/*
Variável - Local temporário na memória para alocar dados escalar ou tabela

- A variável é criada com a instrução DECLARE 
- Começa com @.
- Define o tipo de dado que será armazenado.
- Opcional, define um valor.
- Se não definir valor, será assumido NULL.
- Ela existirá somente no contexto de execução do código ou do lote
- Variável do tipo Table veremos nas próximas aulas. 

*/

-- Define um única variável  
Declare @cNome varchar(200) 

-- Define várias variáveis com um DECLARE 
Declare @nSaldo int, @nValor Numeric(10)

Declare @nSalario smallmoney ,
        @mAumento smallmoney,
		@mFGTS smallmoney 
		
Declare @xPedidoExportar xml -- Recebe um estrutura no formato XML

/*
Definindo variável com valor default 
*/
use eBook
go


Declare @cNome varchar(200) = 'Jose da Silva' 

-- Define várias variáveis com um DECLARE 
Declare @nSaldo int = 100 , @nValor Numeric(10) = 1500.00 

Declare @nSalario smallmoney = 7500.00 ,
        @mAumento smallmoney = 580.00,
		@mFGTS smallmoney = 650.00
		
Declare @xPedidoExportar xml = '<tcadlivro iIDLivro="1" cTitulo="Underground"/>'









