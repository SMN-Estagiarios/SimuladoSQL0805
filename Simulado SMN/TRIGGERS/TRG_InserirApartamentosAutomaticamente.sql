CREATE OR ALTER TRIGGER [dbo].[TRG_InserirApartamentosAutomaticamente]
	ON [dbo].[Predio]
	AFTER INSERT
	AS
	/*
	Documentacao
	Arquivo fonte............:	TRG_InserirApartamentosAutomaticamente.sql
	Objetivo.................:	Cria os registros de apartamentos assim que um predio e inserido
	Autor....................:	Grupo de estagiarios SMN
	Data.....................:	10/05/2024
	Exemplo..................:	BEGIN TRAN
								
									DBCC FREEPROCCACHE
									DBCC FREESYSTEMCACHE('ALL')
									DBCC DROPCLEANBUFFERS

									SELECT * FROM [dbo].[Predio] WITH(NOLOCK)

									SELECT * FROM [dbo].[Apartamento] WITH(NOLOCK)

									DECLARE @DataInicio DATETIME = GETDATE();

									EXEC [dbo].[SP_InserirPredio] 'SoBalanca', '58025147', 'PB', 'Jampa', 'Cuia', 'Rua das Flores', '420', 3, 2

									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao;

									SELECT * FROM [dbo].[Predio] WITH(NOLOCK)

									SELECT * FROM [dbo].[Apartamento] WITH(NOLOCK)
								
								ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando as variaveis
		DECLARE @Id INT,
				@TotalPavimento INT,
				@ApartamentoPorPavimento INT,
				@ContagemPavimento INT = 1,
				@ContagemApartamento INT = 1;

		-- Setando as variaveis do inserted
		SELECT	@Id = i.Id,
				@TotalPavimento = i.TotalPavimento,
				@ApartamentoPorPavimento = i.QuantidadeApartamentoPorPavimento
			FROM inserted i;

		-- Loop para Criacao de apartamentos
		WHILE @ContagemPavimento <= @TotalPavimento
			BEGIN
				WHILE @ContagemApartamento <= @ApartamentoPorPavimento
					BEGIN
						-- Fazendo INSERT dos apartamentos
						INSERT INTO [dbo].[Apartamento]	(IdPredio, Numero, Pavimento)
							VALUES	(@Id, @ContagemApartamento, @ContagemPavimento)
						
						IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
							BEGIN
								ROLLBACK TRAN;
								RAISERROR('Erro ao inserir apartamento', 16, 1);
								RETURN;
							END
						
						-- Incremento na variavel de contagem de apartamentos
						SET @ContagemApartamento += 1;
					END

				SET @ContagemApartamento = 1;
				
				-- Incremento na variavel de contagem de pavimentos
				SET @ContagemPavimento += 1;
			END
	END