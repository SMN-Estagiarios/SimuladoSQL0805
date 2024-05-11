USE DB_ConstrutoraLMNC;

GO

CREATE OR ALTER TRIGGER [dbo].[TRG_InserirApartamentosAutomaticamente]
	ON [dbo].[Predio]
	AFTER INSERT
AS
	/*
		Documentacao
		Arquivo fonte...: TRG_InserirApartamentosAutomaticamente.sql
		Objetivo........: Cria os registros de apartamentos assim que um predio e inserido
		Autor...........: Grupo Estagiarios
		Data............: 10/05/2024
		Exemplo.........:	BEGIN TRAN
								SELECT *
									FROM [dbo].[Predio] WITH(NOLOCK)

								SELECT *
									FROM [dbo].[Apartamento] WITH(NOLOCK)

								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')
								DBCC DROPCLEANBUFFERS

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_InserirPredio] 'SoBalanca', '58025147', 'PB', 'Jampa', 'Cuia', 'Rua das Flores', '420', 3, 2

								SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) TempoExecucao;

								SELECT *
									FROM [dbo].[Predio] WITH(NOLOCK)

								SELECT *
									FROM [dbo].[Apartamento] WITH(NOLOCK)
							ROLLBACK TRAN
	*/
	BEGIN
		-- Declaracao das variaveis necessarias
		DECLARE @Id INT,
				@TotalPavimento INT,
				@ApartamentoPorPavimento INT,
				@ContagemPavimento INT = 1,
				@ContagemApartamento INT = 1;

		-- Atribuicao das variaveis do inserted
		SELECT	@Id = Id,
				@TotalPavimento = TotalPavimento,
				@ApartamentoPorPavimento = QuantidadeApartamentoPorPavimento
			FROM inserted;

		-- Loop para Criacao de apartamentos
		WHILE @ContagemPavimento <= @TotalPavimento
			BEGIN
				WHILE @ContagemApartamento <= @ApartamentoPorPavimento
					BEGIN
						-- Faço INSERT de apartamentos
						INSERT INTO [dbo].[Apartamento]	(
															IdPredio,
															Numero,
															Pavimento
														)
												VALUES	(
															@Id,
															@ContagemApartamento,
															@ContagemPavimento
														)
						IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
							BEGIN
								ROLLBACK TRAN;
								RAISERROR('Erro ao inserir apartamento', 16, 1);
								RETURN;
							END;
						-- Incremento na variavel de contagem de apartamentos
						SET @ContagemApartamento += 1;
					END;

				SET @ContagemApartamento = 1;
				-- Incremento na variavel de contagem de pavimentos
				SET @ContagemPavimento += 1;
			END;
	END;