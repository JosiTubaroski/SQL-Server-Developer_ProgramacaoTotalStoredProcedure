# SQL Server Developer. Programação total com Stored Procedure

Como criar e gerar um script a partir do objetos do banco;

Conceitos de elementos básicos como comentários, apresentar mensagem e execução em lote;

Como trabalhar com variáveis, definir os tipos de dados e como operar elas com as instruções DML;

Vamos conhecer os comandos de controle de fluxo como:

IF/ELSE,

WHILE,

BEGIN/END,

TRY/CATCH,

BREAK,

CONTINUE,

RETURN;

Conhecer transações, conceitos e propriedades;

Os principais comandos de controle de transação como:

BEGIN  TRANSACTION,

COMMIT,

ROLLBACK;

Como montar transações aninhadas e realizar seu controle;

Identificar e resolver o bloqueios e deadlocks;

Como montar códigos com tratamento de erro, forçar uma exceção, capturar o erro e realizar o seu tratamento e armazenamento;

Conhecer as tabelas temporárias e variáveis tabelas para armazenar dados temporários durante execução do código;

Isso tudo que vimos até agora para começarmos a aprender a montar:

Stored Procedures

Motivos para usar Stored Procedure;

Como realizar o design e execução de uma Stored Procedure;

Retornando um DataSet;

Retornando um status de execução;

Definindo e utilizando os parâmetros de Entrada e Saída;

Incluindo controle de fluxo de dados;

Detectando erros de execução, fazendo a captura e realizando o tratamento como retorno de código o armazenando e uma tabela de Log;

Incluindo a transação de dados, realizando o controle e confirmando o processo em caso de sucesso. Em caso de erro, desfazer a transação dentro do tratamento de erro;

Demonstração da segurança de dados promovida pelo uso de Procedure;

Como montar o aninhamento de procedures (executar uma procedure dentro de outra procedure) e realizar o controle de execução, capturando o retorno de status de cada uma delas;

Implementando criptografia de uma procedure e demostrar se vale ou não a usar esse técnica;

View

Motivos para utilizar View;

Definindo o design da View e sua utilização;

Utilizando opções SCHEMABINDING  e CHECK OPTION;

Como criar views que podem ser atualizadas com comandos INSERT, UPDATE e DELETE;

Utilizando views indexadas para melhor o desempenho do acesso ao dados;

Apresentar as restrições e erros comuns na utilização de views;

Desde que Frank Cood definiu os conceitos dos bancos de dados relacionais em 1970 e com o surgindo poucos anos depois da linguagem SQL, ela se tornou o padrão para todos os bancos de dados relacionais. Por um simples motivo: ela é uma linguagem estável e muito aderante as demais linguagem de programação.

O Desenvolvedor que trabalha com um linguagem de programação em um ambiente comercial para lojas, instituições financeira, empresa entre outras, sempre terá a necessidade de tratar com um quantidade de dados e de alguma forma manipular em um banco de dados. Atualmente o mercado de gerenciadores de banco de dados possui diversos sistemas, entre os quais, os banco de dados relacionais são os mais utilizados.

Com a evolução da linguagem SQL, a sua padronização foi gerenciada pela ANSI e é aplicada de forma idêntica em todos os gerenciadores de banco de dados relacionais como SQL Server, Oracle, Mysql, DB2, PostgreSQL e outros.   Mas cada fornecedor desses gerenciadores de banco de dados colocaram as chamadas extensões da linguagem, dado a ela um característica ou nova funcionalidade exclusiva.

Entre as extensões, foi implementado comandos de linguagem de programação como controle de fluxos de dados, variáveis, objetos de programação e outros componentes que permite desenvolver códigos e executar estruturados.

No caso do SQL Server, ele possui o dialeto da linguagem SQL com o nome de de Transact-SQL ou simplesmente T-SQL que segue o padrão ANSI, mas com as exclusividades do banco de dados da Microsoft.

O que você aprenderá
Escolher a melhor forma de usar os comandos de fluxos de dados como IF, WHILE, BEGIN END e TRY CATCH.
A construir objetos de programação dos mais simples ao mais complexo com Stored Procedures.
Os conceitos de transação e a montar programas com controle transacional.
A identificar bloqueios e "deadlock" em transações, prever seus acontecimentos e tratar os erros corretamente.
Montar uma completa estrutura de detecção de erros e tratamentos.
A registrar os eventos de erros nos fluxos de dados em uma tabela de log para registro e posterior consulta.
Criar variáveis e tabelas temporárias para armazenar dados temporários durante a execução do programas.
A documentar, padronizar a simplificar a codificação dos objetos de programação.
Há algum requisito ou pré-requisito para o curso?
Conhecimentos de comando SELECT, INSERT, UPDATE e DELETE e criar tabelas.
Instalação do SQL Server 2017 Express Edition.
Noções de lógica de programação.
