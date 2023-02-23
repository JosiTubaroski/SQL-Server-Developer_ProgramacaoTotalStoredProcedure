/*
TRANSA��O -

Uma transa��o pode ser definida como uma unidade L�gica de Trabalho.

Se tudo que est� dentro dessa unidade l�gica de trabalho for feita com sucesso, 
os dados ser�o persistidos no banco de dados de forma permanente.

Se algo ocorrer de errado e a unidade l�gica de trabalho � inv�lida, todas 
as modifica��o feitas desde o in�cio do trabalho ser�o desfeitas e os 
dados ficam persistidos igualmente antes do in�cio do trabalho. 

*/












/*
- Toda a transa��o deve ter as quatro propriedade conhecidas como  ACID

Atomicidade  - A transa��o � indivis�vel.
Consist�ncia - A transa��o deve manter consist�ncia do dados.
Isolamento   - O que ocorre em uma trans��o n�o interfere em outra transa��o.
Durabilidade - Uma vez a transa��o confirmada, o dados s�o persistidos e o 
               armazenamento � permanente. 
*/














/*
Log de transa��o. 

- Um dos arquivos de banco de dados que registra tudo que ocorrer dentro de 
  uma transa��o.
- As instru��es s�o gravadas sequencialmente para cada transa��o.
- Se precisar realizar algum procedimento de recupera��o como desfazer 
  uma transa��o ou recuperar o banco no processo de Restore, o Log de transa��o 
  � utilizado. 
*/
use eBook
go
Select file_id, 
       type_desc, 
       name, 
       physical_name , 
       size*8/1024.0 as sizeMB 
  From sys.master_files 
  Where database_id = DB_ID()













