CREATE OR ALTER PROCEDURE [dbo].[SP_InserirCliente] 
	@Nome VARCHAR(500),
	@Email VARCHAR(500),
	@Senha VARCHAR(64),
	@Cpf BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
	AS 
	/*
	Documentacao
	Arquivo fonte...:	Cliente.sql
	Objetivo........:	Cria registro de cliente
	Autor...........:	Olívio Freitas
	Data............:	10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
									@Dat_ini DATETIME = GETDATE()

							SELECT	* FROM [dbo].[Cliente] 

							EXEC @RET = [dbo].[SP_InserirCliente] 'Steven Tyler','steven@gmail.com','steven321',74923472389,839911413450,'1992-12-13'

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS TempoExecucao

							SELECT	* FROM [dbo].[Cliente] 
						ROLLBACK TRAN

	RETORNO.........:	0 - Sucesso
						1 - ERRO - Cliente já cadastrado no sistema
						2 - ERRO - Não foi possível criar novo registro de cliente
	*/
	BEGIN
		IF EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE CPF = @Cpf)
			BEGIN
				RETURN 1
			END
		-- Criação de novo cliente
		INSERT INTO [dbo].[Cliente]	(
										Nome,
										Email,
										Senha,
										Cpf,
										Telefone,
										DataNascimento,
										Ativo
									)
							VALUES	(
										@Nome,
										@Email,
										@Senha,
										@Cpf,
										@Telefone,
										@DataNascimento,
										1
									)

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 2
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirCliente]
	@Id_Cliente INT
	AS
	/*
	Documentacao
	Arquivo fonte...:	Cliente.sql
	Objetivo........:	Atualiza o status de 'Ativo' do cliente para FALSE
	Autor...........:	Olívio Freitas
	Data............:	10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE	@RET INT, 
									@Dat_init DATETIME = GETDATE()

							SELECT	* FROM [dbo].[Cliente] 

							EXEC @RET = [SP_ExcluirCliente] 1

							SELECT	* FROM [dbo].[Cliente] 

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 

						ROLLBACK TRAN

	RETORNO.........:	0 - Sucesso
						1 - ERRO - O cliente não existe
						2 - ERRO - Não foi possível excluir o cliente
	*/
	BEGIN
		-- Verificação se existe registro do cliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @Id_Cliente)
			BEGIN
				RETURN 1
			END

		-- Atualiza status do cliente
		UPDATE [dbo].[Cliente]
			SET Ativo = 0
			WHERE Id = @Id_Cliente

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 2
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarSenhaCliente]
	@Id_Cliente INT,
	@Senha VARCHAR(64) 
	AS
    /*
	Documentacao
	Arquivo fonte...:	Cliente.sql
	Objetivo........:	Atualiza a senha do cliente
	Autor...........:	Olívio Freitas
	Data............:	10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE	@RET INT, 
									@Dat_init DATETIME = GETDATE()

							SELECT * FROM [dbo].[Cliente] 

							EXEC @RET = [SP_AtualizarSenhaCliente] 1, '1234560'

							SELECT * FROM [dbo].[Cliente] 

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 
						ROLLBACK TRAN

	RETORNO.........:	0 - Sucesso
						1 - ERRO - O cliente não existe
						2 - ERRO - Não foi possível excluir o cliente
	*/
	BEGIN
		-- Verificação se existe registro do cliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @Id_Cliente)
			BEGIN
				RETURN 1
			END

		-- Atualiza senha do cliente passado por parâmetro
		UPDATE [dbo].[Cliente]
			SET Senha = @Senha
			WHERE Id = @Id_Cliente

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 2
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarTelefoneCliente]
	@Id_Cliente INT,
	@Telefone BIGINT
	AS
    /*
	Documentacao
	Arquivo fonte...:	Cliente.sql
	Objetivo........:	Atualiza o telefone do cliente
	Autor...........:	Olívio Freitas
	Data............:	10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE	@RET INT, 
									@Dat_init DATETIME = GETDATE()

							SELECT * FROM [dbo].[Cliente] 

							EXEC @RET = [SP_AtualizarTelefoneCliente] 1, 83988991664

							SELECT * FROM [dbo].[Cliente] 

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 
						ROLLBACK TRAN

	RETORNO.........:	0 - Sucesso
						1 - ERRO - O cliente não existe
						2 - ERRO - Não foi possível atualizar o telefone do cliente
	*/
	BEGIN
		-- Verificação se existe registro do cliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @Id_Cliente)
			BEGIN
				RETURN 1
			END
		-- Atualiza telefone do cliente
		UPDATE [dbo].[Cliente]  SET Telefone = @Telefone
			WHERE Id = @Id_Cliente

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 2

	END
GO