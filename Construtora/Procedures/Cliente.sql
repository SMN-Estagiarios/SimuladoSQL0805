CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovoCliente] 
	@Nome VARCHAR(100),
	@DataNasc DATE,
	@Email VARCHAR(120),
	@Senha VARCHAR(64),
	@CPF BIGINT,
	@Telefone BIGINT
	AS 
	/*
	Documentacao
	Arquivo fonte...:	Cliente.sql
	Objetivo........:	Insere novos registro de Clientes 
	Autor...........:	Adriel Alexander 
	Data............:	10/05/2024 
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
									@Dat_ini DATETIME = GETDATE()

							SELECT	Nome, 
									Email,
									CPF,
									DataNascimento
								FROM [dbo].[Cliente] WITH(NOLOCK)
								 
							EXEC @RET = [dbo].[SP_InserirNovoCliente] 'Adriel Alexs','1992-12-13','adriel.alexs@gmail.com','xablas4321',74923472389,839911413450

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS TempoExecucao

							SELECT	Nome, 
									Email,
									CPF,
									DataNascimento
								FROM [dbo].[Cliente] WITH(NOLOCK)
						ROLLBACK TRAN

	Retorno.........:	0 - Sucesso
						1 - Erro ao inserir Cliente: Cliente já se encontra cadastrado no Sistema
						2 - Erro ao inserir Cliente: Não foi possível criar novo registro de cliente
	*/
	BEGIN
		
		--Verifica se o Cliente Existe pelo CPF
		IF EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE CPF = @CPF)
			BEGIN
				RETURN 1
			END
		-- Insere Cliente Na tabela [dbo].[Cliente]
		INSERT INTO [dbo].[Cliente]	(Nome, Email, Senha, Cpf, Telefone,
										DataNascimento,Ativo)
		   VALUES					
									(@Nome,	@Email,	@Senha,	@CPF, @Telefone,
										@DataNasc, 1)

		-- Verifica se aconteceu algum erro ao inserir nove cliente 
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END
		ELSE
			RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarCliente]
	@IdCliente INT
	AS
	/*
		Documentacao
		Arquivo fonte...:	Cliente.sql
		Objetivo........:	Desativa cliente fazendo um update no bit de atividade
		Autor...........:	Adriel Alexander 
		Data............:	10/05/2024
		Ex..............:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@RET INT, 
										@Dat_init DATETIME = GETDATE()

								SELECT	Nome, 
										Email,
										CPF,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_DesativarCliente] 1
								SELECT	@RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 

								SELECT	Nome, 
										Email,
										CPF,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

							ROLLBACK TRAN

		Retorno.........:	0 - Sucesso
							1 - Erro ao Desativar Cliente: Cliente já se encontra cadastrado no Sistema
							2 - Erro ao Desativar Cliente: Falha no update de Cliente
	*/
	BEGIN
		
		-- Verificação se existe registro do cliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @IdCliente)
			BEGIN
				RETURN 1
			END

		-- Atualiza bit de atividade do Cliente
		UPDATE [dbo].[Cliente]
			SET Ativo = 0
			WHERE Id = @IdCliente

		-- Verifica se aconteceu algum erro ao atualiza registro de cliente
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					RETURN 2
				END
			ELSE
				RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarRegistroCliente]
	@IdCliente INT,
	@Senha VARCHAR(64) = NULL,
	@Nome VARCHAR(100) = NULL,
	@CPF BIGINT = NULL,
	@DataNascimento DATE = NULL,
	@Email VARCHAR(120) = NULL,
	@Telefone BIGINT = NULL
	AS
    /*
		Documentacao
		Arquivo fonte...:	Cliente.sql
		Objetivo........:	Atualiza dados do Cliente
		Autor...........:	Adriel Alexander De Sousa
		Data............:	10/05/2024
		Ex..............: 
							BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@RET INT, 
										@Dat_init DATETIME = GETDATE()

								SELECT	Id,
										Nome, 
										Email,
										CPF,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_AtualizarRegistroCliente]2, NULL, 'Luis Fernando', NULL, NULL, 'LuisFe@gmail.com'

								SELECT	Nome, 
										Email,
										CPF,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

								SELECT	@RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 
							ROLLBACK TRAN

		RETORNO.........:	0 - Sucesso
							1 - Erro ao atualizar o Cliente- O cliente não existe
							2 - ERRO - Não foi possível excluir o cliente
	*/
	BEGIN
		
		-- Verificação se existe registro do cliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @IdCliente)
			BEGIN
				RETURN 1
			END

		-- Atualiza Parametros de Clientes que foram passados na execução da procedure
		UPDATE [dbo].[Cliente]
			SET Senha = ISNULL(@Senha, Senha),
				Nome = ISNULL(@Nome, Nome),
				CPF = ISNULL(@CPF, CPF),
				DataNascimento = ISNULL(@DataNascimento, DataNascimento),
				Email = ISNULL(@Email, Email),
				Telefone = ISNULL(@Telefone, Telefone)
			WHERE Id = @IdCliente

	-- Verifica se aconteceu algum erro ao inserir nove cliente 
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END
		ELSE
			RETURN 0
	END
GO

