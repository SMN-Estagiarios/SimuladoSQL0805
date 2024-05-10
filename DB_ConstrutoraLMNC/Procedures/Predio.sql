USE DB_ConstrutoraLMNC;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirPredio]
	@Nome VARCHAR(40),
	@CEP CHAR(8),
	@UF CHAR(2),
	@Cidade VARCHAR(60),
	@Bairro VARCHAR(60),
	@Logradouro VARCHAR(80),
	@Numero VARCHAR(4),
	@TotalPavimento TINYINT,
	@AptosPorAndar TINYINT
	AS
	/*
	Documentacao
	Arquivo fonte...:	Predio.sql
	Objetivo........:	Cria registro de predio e ao mesmo tempo cria todos os apartamentos
	Autor...........:	Grupo Estagiarios
	Data............:	10/05/2024
	Exemplo.........:	BEGIN TRANSACTION
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT,
									@Dat_ini DATETIME = GETDATE()

							SELECT * FROM Predio
							SELECT * FROM Apartamento

							EXEC @RET = [dbo].[SP_InserirPredio] 'SoBalanca', '58025147', 'PB', 'Jampa', 'Cuia', 'Rua das Flores', '420', 3, 3

							SELECT * FROM Apartamento
							SELECT * FROM Predio

							SELECT	@RET AS RETORNO,
									DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
						ROLLBACK TRANSACTION

	RETORNO.........:	0 - Sucesso
						1 - ERRO - Falha ao criar registro de predio
						2 - ERRO - Falha ao criar registro de apartamento

	*/
	BEGIN
		-- Declaro as variaveis necessárias
		DECLARE	@IdPredio SMALLINT;

		BEGIN TRANSACTION
			BEGIN TRY
				-- Faço INSERT em predio
				INSERT INTO [dbo].[Predio]	(
																Nome,
																CEP,
																UF,
																Cidade,
																Bairro,
																Logradouro,
																Numero,
																TotalPavimento,
																QuantidadeApartamentoPorPavimento,
																Entregue
															)
									VALUES	(
													@Nome,
													@CEP,
													@UF,
													@Cidade,
													@Bairro,
													@Logradouro,
													@Numero,
													@TotalPavimento,
													@AptosPorAndar,
													0
												)
					-- Capturo IdPredio que acabou de ser gerado
					SET @IdPredio = SCOPE_IDENTITY()
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 1
			END CATCH
		COMMIT TRANSACTION
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_EntregarPredio]
	@IdPredio INT
	AS
	/*
	Documentacao
	Arquivo fonte...:	Predio.sql
	Objetivo........:	Atualiza atributo 'Entregue' do predio para TRUE
	Autor...........:	Grupo Estagiarios
	Data............:	10/05/2024
	Exemplo.........:	BEGIN TRANSACTION
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT,
									@Dat_ini DATETIME = GETDATE()

							SELECT * FROM Predio

							EXEC @RET = [dbo].[SP_EntregarPredio] 12

							SELECT * FROM Predio

							SELECT	@RET AS RETORNO,
									DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
						ROLLBACK TRANSACTION

	RETORNO.........:	0 - Sucesso
						1 - ERRO - Predio nao existe em nossos registros

	*/
	BEGIN
		-- Verificacao se o predio passado por parametro existe no banco de dados
		IF NOT EXISTS	(SELECT TOP 1 1
							FROM [dbo].[Predio] WITH(NOLOCK)
							WHERE Id = @IdPredio)
			BEGIN
				RETURN 1
			END

		-- Atualiza atributo de 'Entregue' do Predio passado por parametro
		UPDATE [dbo].[Predio]
			SET Entregue = 1
			WHERE Id = @IdPredio
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarPredio]
	@IdPredio INT = NULL
	AS
	/*
	Documentacao
	Arquivo fonte...:	Predio.sql
	Objetivo........:	Atualiza atributo 'Entregue' do predio para TRUE
	Autor...........:	Grupo Estagiarios
	Data............:	10/05/2024
	Ex..............:	DBCC DROPCLEANBUFFERS;
						DBCC FREEPROCCACHE;

						DECLARE @Dat_ini DATETIME = GETDATE()

						EXEC [dbo].[SP_ListarPredio]

						SELECT	DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		-- Listar predio(s)
		SELECT	Id,
					Nome,
					CEP,
					UF,
					Cidade,
					Bairro,
					Logradouro,
					Numero,
					TotalPavimento,
					QuantidadeApartamentoPorPavimento,
					Entregue
			FROM [dbo].[Predio] WITH(NOLOCK)
			WHERE Id = COALESCE(@IdPredio, Id)
	END
GO