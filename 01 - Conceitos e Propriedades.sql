/*
TRANSAÇÃO -

Uma transação pode ser definida como uma unidade Lógica de Trabalho.

Se tudo que está dentro dessa unidade lógica de trabalho for feita com sucesso, 
os dados serão persistidos no banco de dados de forma permanente.

Se algo ocorrer de errado e a unidade lógica de trabalho é inválida, todas 
as modificação feitas desde o início do trabalho serão desfeitas e os 
dados ficam persistidos igualmente antes do início do trabalho. 

*/












/*
- Toda a transação deve ter as quatro propriedade conhecidas como  ACID

Atomicidade  - A transação é indivisível.
Consistência - A transação deve manter consistência do dados.
Isolamento   - O que ocorre em uma transção não interfere em outra transação.
Durabilidade - Uma vez a transação confirmada, o dados são persistidos e o 
               armazenamento é permanente. 
*/














/*
Log de transação. 

- Um dos arquivos de banco de dados que registra tudo que ocorrer dentro de 
  uma transação.
- As instruções são gravadas sequencialmente para cada transação.
- Se precisar realizar algum procedimento de recuperação como desfazer 
  uma transação ou recuperar o banco no processo de Restore, o Log de transação 
  é utilizado. 
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













