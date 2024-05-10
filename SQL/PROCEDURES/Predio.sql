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

							EXEC @RET = [dbo].[SP_InserirPredio] 'SoBalanca', '58025147', 'PB', 'Jampa', 'Cuia', 'Rua das Flores', '420', 15, 8

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
		DECLARE	@IdPredio SMALLINT,
				@PavimentoAtual INT = 1,
				@NumeroApto INT = 1

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
												0
											)
					-- Capturo IdPredio que acabou de ser gerado
					SET @IdPredio = SCOPE_IDENTITY()
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 1
			END CATCH

			BEGIN TRY
				-- Loop para Criacao de apartamentos
				WHILE @PavimentoAtual <= @TotalPavimento
					BEGIN
						DECLARE @AptosPavimento INT = 1

						WHILE @AptosPavimento <= @AptosPorAndar
							BEGIN
								-- Faço INSERT de apartamentos
								INSERT INTO [dbo].[Apartamento]	(
																	IdPredio,
																	Numero,
																	Pavimento,
																	Vendido
																)
														VALUES	(
																	@IdPredio,
																	@NumeroApto,
																	@PavimentoAtual,
																	0
																)
								SET @NumeroApto = @NumeroApto + 1;
								SET @AptosPavimento = @AptosPavimento + 1
							END
						SET @PavimentoAtual = @PavimentoAtual + 1
					END
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 2
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

							EXEC @RET = [dbo].[SP_EntregarPredio] 16

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

							EXEC @RET = [dbo].[SP_ListarPredio] 18

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

		-- Lista predio e seus apartamentos
		SELECT	p.Id,
				p.Nome,
				p.Entregue,
				a.Numero,
				a.Pavimento,
				a.Vendido
			FROM [dbo].[Predio] p WITH(NOLOCK)
				INNER JOIN [dbo].[Apartamento] a
					ON a.IdPredio = p.Id
			WHERE p.Id = @IdPredio
			ORDER BY a.Numero
	END
GO