/*
Transações Aninhadas.

- Quando temos uma transação dentro de outra transação.
- Voce deve controlar a execução do begin transaction ,
  commit ou rollback pela função @@TRANCOUNT.

*/


/*
Exemplo 01 - Usando Begin Transaction e Commit 
*/
use eBook
go

Select @@TRANCOUNT
Begin 
   Begin Transaction 
      --Comando C1 
      Begin Transaction 
        -- Comando C2 
	     Begin Transaction 
	        -- Comando C3 
		     -- Comando C4 
		     -- Comando C5
	     Commit 
	     -- Comando C6
      Commit 
      -- Comando C7
   Commit 
End
if @@TRANCOUNT > 0
   commit 

Select @@TRANCOUNT
 
/*
Exemplo 02 - Usando de Begin Transaction e Rollback 
*/
Select @@TRANCOUNT
Begin 
   Begin Transaction
      --Comando C1
      Begin Transaction
        -- Comando C2 
	     Begin Transaction 
   	    -- Comando C3 
		    -- Comando C4 
		    -- Comando C5 
	     Rollback 
	     -- Comando C6
      Rollback 
      -- Comando C7 
   Rollback 
End
Select @@TRANCOUNT


-- Fazendo o controle do Rollback 
Select @@TRANCOUNT
Begin 
   Begin Transaction
      --Comando C1
      Begin Transaction
        -- Comando C2 
	     Begin Transaction 
   	     -- Comando C3 
		     -- Comando C4 
		     -- Comando C5 
	     if @@TRANCOUNT > 0 Rollback 
	     -- Comando C6
      if @@TRANCOUNT > 0 Rollback 
      -- Comando C7 
   if @@TRANCOUNT > 0 Rollback 
End
Select @@TRANCOUNT




/*
Exemplo 03 - Usand Begin Transaction, Commit e  Rollback 
Não ocorre o erro.
*/
Select @@TRANCOUNT
Begin 
   Begin Transaction
      --Comando C1
      Begin Transaction
        -- Comando C2 
	     Begin Transaction 
	        -- Comando C3
		     -- Comando C4
		     -- Comando C5
	     Commit 
	     -- Comando C6
      Commit 
      -- Comando C7
   Rollback 
End 
Select @@TRANCOUNT


/*
Exemplo de Begin Transaction, Commit e  Rollback 
-- Ocorre o erro.
*/
Select @@TRANCOUNT
Begin 
   Begin Transaction
      --Comando C1
      Begin Transaction
         -- Comando C2 
	     Begin Transaction 
	        -- Comando C3
		    -- Comando C4
		    -- Comando C5
	     Commit 
	     -- Comando C6
      Rollback  
      -- Comando C7
   Commit 
End 
Select @@TRANCOUNT


/*
*/
use eBook
go

Update tMOVNotaFiscal 
   Set mValorICMS = 10  
 Where iIDNotaFiscal = 1

Select mValorICMS 
  From tMOVNotaFiscal 
 Where iIDNotaFiscal = 1
 
Begin Transaction 
   Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1
   Begin Transaction
      Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1
 	   Begin Transaction 
	      Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1
		   Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1
		   Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1
	   Commit 
	   Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1

   if @@trancount > 0
      Rollback 

   Update tMOVNotaFiscal set mValorICMS += 1  where iIDNotaFiscal = 1

if @@trancount > 0
   Commit 

Select mValorICMS 
  From tMOVNotaFiscal 
 Where iIDNotaFiscal = 1

