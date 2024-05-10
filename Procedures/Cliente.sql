CREATE OR ALTER PROCEDURE [dbo].[SP_InserirCliente]
	@Nome VARCHAR(100),
	@Email VARCHAR(120),
	@Senha VARCHAR(64),
	@CPF BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Cliente.sql
		Objetivo..............:	Procedure para inserir um novo cliente
		Autor.................:	João Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirCliente] 'Orcíno Neto', 'orcinoneto@gmail.com', 'amoaph', '96532279408', '83975112995', '06/07/1991'

									SELECT	Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Id = IDENT_CURRENT('Cliente')

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
								1 - Erro: Esse email já está cadastrado
								2 - Erro: Esse CPF já está cadastrado
								3 - Erro: Esse telefone já está cadastrado
								4 - Erro: Não foi possível criar o cliente
	*/
	BEGIN
		
		--Checar se o Email já existe
		IF EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente]
						WHERE Email = @Email
				  )
			BEGIN
				RETURN 1
			END

		--Checar se o CPF já existe
		IF EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente]
						WHERE CPF = @CPF
				  )
			BEGIN
				RETURN 2
			END
		--Checar se o telefone já existe
		IF EXISTS (SELECT TOP 1 1
					FROM [dbo].[Cliente]
					WHERE Telefone = @Telefone
				  )
		BEGIN
			RETURN 3
		END

		--Inserir cliente
		INSERT INTO [dbo].[Cliente](Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
							 VALUES(@Nome, @Email, HASHBYTES('SHA2_256', @Senha), @CPF, @Telefone, @DataNascimento, 1)

		--Checar se houve um registro feito
		IF @@ROWCOUNT = 0
			BEGIN
				RETURN 4
			END

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarCliente]
	@Id INT
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Cliente.sql
		Objetivo..............:	Procedure para desativar um cliente
								Ativo fixado em 0 (inativo)
		Autor.................:	João Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_DesativarCliente] 1

									SELECT	Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Id = 1

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
	*/
	BEGIN
		--Colocar o cliente como inativo
		UPDATE [dbo].[Cliente]
			SET Ativo = 0
			WHERE Id =  @Id

		--Checar se mais de um cliente foi afetado
		IF @@ROWCOUNT <> 1
			BEGIN
				RETURN 1
			END

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarCliente]
	@Id INT,
	@Nome VARCHAR(100) = NULL,
	@Email VARCHAR(120) = NULL,
	@Senha VARCHAR(64) = NULL,
	@CPF BIGINT = NULL,
	@Telefone BIGINT = NULL,
	@DataNascimento DATE = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Cliente.sql
		Objetivo..............:	Procedure para atualizar o registro de um cliente
		Autor.................:	João Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									SELECT	Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Id = 1

									EXEC @Ret = [dbo].[SP_AtualizarCliente] 1, 'Rafael Valência'

									SELECT	Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Id = 1

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
								1 - Erro: Mais de um ou nenhum cliente foi alterado
	*/
	BEGIN
		--Atualizar um cliente
		UPDATE [dbo].[Cliente]
			SET Nome = ISNULL(@Nome, Nome),
				Email = ISNULL(@Email, Email),
				Senha = ISNULL(HASHBYTES('SHA2_256', @Senha), HASHBYTES('SHA2_256', Senha)),
				CPF = ISNULL(@CPF, CPF),
				@Telefone = ISNULL(@Telefone, Telefone),
				@DataNascimento = ISNULL(@DataNascimento, DataNascimento)
			WHERE Id = @Id

		--Checar se um e apenas um cliente foi alterado
		IF @@ROWCOUNT <> 1
			BEGIN
				RETURN 1
			END

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarCliente]
	@Id INT
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Cliente.sql
		Objetivo..............:	Procedure para atualizar o registro de um cliente
		Autor.................:	João Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListarCliente] NULL

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
	*/
	BEGIN

		--Listar Clientes
		SELECT	Id,
				Nome,
				Email,
				Senha,
				CPF,
				Telefone,
				DataNascimento,
				Ativo
			FROM [dbo].[Cliente] WITH(NOLOCK)
			WHERE Id = ISNULL(@Id, Id)

		RETURN 0
	END
GO