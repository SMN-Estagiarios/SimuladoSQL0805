CREATE OR ALTER PROCEDURE [dbo].[InserirCliente]	@Nome VARCHAR(100),
													@Email VARCHAR(120),
													@Senha VARCHAR(64),
													@CPF BIGINT,
													@Telefone BIGINT,
													@DataNascimento DATE

	AS
	/*
		Documentacao
		Arquivo Fonte.....: cliente.sql
		Objetivo..........: Inserir registro em [dbo].[Cliente]
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								SELECT	Id,
										Nome,
										Email,
										Senha,
										CPF,
										Telefone,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[InserirCliente]	'Arigato gozaimassu',
																	'arigatogozaimassu@gmail.com',
																	'FalaFiote',
																	12345678912,
																	88912341234,
																	'20-10-2002'
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

								SELECT	Id,
										Nome,
										Email,
										Senha,
										CPF,
										Telefone,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		INSERT INTO [dbo].[Cliente] (Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
			VALUES (@Nome, @Email, @Senha, @CPF, @Telefone, @DataNascimento, 1)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[MudarAtividadeCliente]	@Id INT,
														@Nome VARCHAR(100)

	AS
	/*
		Documentacao
		Arquivo Fonte.....: cliente.sql
		Objetivo..........: Muda bit de ativo em deterimnado registro em [dbo].[Cliente]
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								SELECT	Id,
										Nome,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[MudarAtividadeCliente]	1, NULL
																	
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

								SELECT	Id,
										Nome,
										Ativo
									FROM [dbo].[Cliente] WITH(NOLOCK)

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		--CASO O ID NAO SEJA NULO, A ALTERACAO SERA FEITA COM BASE NELE, CASO CONTRÁRIO, SERÁ NO NOME
		UPDATE Cliente
			SET ativo =	CASE	WHEN Ativo = 0
									THEN  1
								ELSE  0
						END
			WHERE id = @Id OR Nome = @Nome
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[MudarDadosCliente]	@Id INT,
													@Email VARCHAR(120),
													@Senha VARCHAR(64),
													@Telefone BIGINT
	
	AS
	/*
		Documentacao
		Arquivo Fonte.....: cliente.sql
		Objetivo..........: Muda dados em deterimnado registro em [dbo].[Cliente]
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								SELECT	Id,
										Email,
										Senha,
										Telefone
									FROM [dbo].[Cliente] WITH(NOLOCK)

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[MudarDadosCliente]	1, 'meodeos@gmail.com', NULL, NULL
																	
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

								SELECT	Id,
										Email,
										Senha,
										Telefone
									FROM [dbo].[Cliente] WITH(NOLOCK)

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		--FAZ O UPDATE DOS CAMPOS VALIDOS PARA MUDANCA
		UPDATE Cliente
			SET	Email = ISNULL(@Email, Email),
				Senha = ISNULL(@Senha, Senha),
				Telefone = ISNULL(@Telefone, Telefone)
			WHERE Id = @Id
	END