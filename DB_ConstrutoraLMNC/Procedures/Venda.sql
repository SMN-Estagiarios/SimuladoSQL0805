CREATE OR ALTER PROCEDURE [dbo].[SP_InserirVenda]
	@IdCliente INT,
	@IdApartamento INT,
	@Valor DECIMAL(10,2),
	@TotalParcela SMALLINT
	AS
	/*
		Documentação
		Arquivo Fonte.....:	Venda.sql
		Objetivo..........:	Procedure para inserir uma nova venda
							IdIndice 1 = INCC e 2 = IGPM
		Autor.............:	Todos
		Data..............:	10/05/2024
		Ex................:	
							BEGIN TRAN
								DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

								DECLARE @Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_InserirVenda] 0, 1, 1500000, 60

								SELECT	IdCliente,
											IdApartamento,
											IdIndice,
											Valor,
											DataVenda,
											Financiado,
											TotalParcela
									FROM [dbo].[Venda] WITH(NOLOCK)
									WHERE Id = IDENT_CURRENT('Venda')

								SELECT	IdVenda,
											IdCompra,
											IdJuros,
											IdLancamento,
											Valor,
											DataVencimento
									FROM [dbo].[Parcela] WITH(NOLOCK)
									WHERE Id = IDENT_CURRENT('Parcela')

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
		Retornos..............: 
			0 - Sucesso
			1 - Erro: O apartamento já está vendido
			2 - Erro: Não foi possível realizar a venda
	*/
	BEGIN
		--Declarar variáveis
		DECLARE	@IdIndice TINYINT,
				@Entregue BIT,
				@Financiado BIT,
				@IdVenda INT,
				@IdJuros TINYINT

		--Atribuir valor às variáveis
		SELECT @Entregue = Entregue
			FROM [dbo].[Predio] p
				INNER JOIN [dbo].[Apartamento] a
					ON p.Id = a.IdPredio
			WHERE a.Id = @IdApartamento

		SET @IdIndice = CASE	WHEN @Entregue = 0 THEN 1
								ELSE 2
						END

		SET @Financiado = CASE	WHEN @TotalParcela > 1 THEN 1
								ELSE 0
						  END
						  
		SET @IdJuros = CASE		WHEN @TotalParcela > 1 THEN 1
								ELSE NULL
					   END

		--Checar se o apartamento já está vendido
		IF EXISTS	(
						SELECT TOP 1 1
							FROM [dbo].[Venda]
							WHERE IdApartamento = @IdApartamento
					)
			BEGIN
				RETURN 1
			END
		
		--Inserir uma venda
		INSERT INTO [dbo].[Venda](IdCliente, IdApartamento, IdIndice, Valor, DataVenda, Financiado, TotalParcela)
						   VALUES(@IdCliente, @IdApartamento, @IdIndice, @Valor, GETDATE(), @Financiado, @TotalParcela)

		--Checar se uma venda foi realizada
		IF @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END
			
		--Atribuir valor à IdVenda
		SET @IdVenda = IDENT_CURRENT('Venda')
		
		--Inserir primeira parcela
		INSERT INTO [dbo].[Parcela]	(
										IdVenda, 
										IdJuros, 
										Valor, 
										DataVencimento
									)
							VALUES (
										@IdVenda, 
										@IdJuros, 
										(@Valor/ @TotalParcela + (CASE	WHEN @Financiado = 1 THEN(@Valor * (SELECT MAX(vi.Aliquota)
																										FROM [dbo].[ValorIndice] vi WITH(NOLOCK)
																									WHERE vi.IdIndice = @IdIndice
																								)
																						)
															ELSE 0
														END
														)
										),
										DATEADD(MONTH, 1, GETDATE())
									)

		RETURN 0
	END
GO

CREATE OR ALTER PROC [dbo].[SP_RelatorioAptoVendidos]
	@IdVenda INT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte...: Venda.sql
		Objetivo........: Listar todos os apartamentos com as informacoes de parcelas pagas, vencidas e vincendas
		Autor...........: Grupo de estagiarios SMN
		Data............: 10/05/2024
		Ex..............:	
							DBCC FREEPROCCACHE
							DBCC DROPCLEANBUFFERS
							DBCC FREESYSTEMCACHE('ALL')

							DECLARE @DATA_INI DATETIME = GETDATE();

							EXEC [dbo].[SP_RelatorioAptoVendidos]

							SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		-- Declarando variavel da data atual
		DECLARE @DataAtual DATE = GETDATE();
		
		-- Recuperando dados da subquery e calculando tambem a quantidade de parcelas restantes
		SELECT	v.Id AS IdVenda,
				v.TotalParcela AS TotalParcela,
				x.QuantidadeParcelaPaga AS QuantidadeParcelaPaga,
				x.QuantidadeParcelaVencida AS QuantidadeParcelaVencida,
				(v.TotalParcela - x.QuantidadeParcelaPaga - x.QuantidadeParcelaVencida) AS ParcelasRestantes
			FROM	(
						-- Recuperando dados do id da venda, contagem de parcelas pagas e contagem de parcelas vencidas
						SELECT	p.IdVenda AS IdVenda,
								(
									SELECT	COUNT(Id)
										FROM [dbo].[Parcela] WITH(NOLOCK)
										WHERE IdLancamento IS NOT NULL
											AND IdVenda = p.IdVenda
								) AS QuantidadeParcelaPaga,
								(
									SELECT	COUNT(Id)
										FROM [dbo].[Parcela] WITH(NOLOCK)
										WHERE IdLancamento IS NULL
											AND DataVencimento < @DataAtual
											AND IdVenda = p.IdVenda
								) AS QuantidadeParcelaVencida
							FROM [dbo].[Parcela] p WITH(NOLOCK)
							WHERE IdVenda = ISNULL(@IdVenda, p.IdVenda)
					) AS x
				INNER JOIN [dbo].[Venda] v WITH(NOLOCK)
					ON x.IdVenda = v.Id;
	END
GO

CREATE OR ALTER PROC [dbo].[SP_RelatorioAptoNaoVendidos]
	@IdVenda INT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte...: Venda.sql
		Objetivo........: Listar todos os apartamentos com as informacoes de parcelas pagas, vencidas e vincendas
		Autor...........: OrcinoNeto
		Data............: 10/05/2024
		Ex..............:	
							DBCC FREEPROCCACHE
							DBCC DROPCLEANBUFFERS
							DBCC FREESYSTEMCACHE('ALL')

							DECLARE @DATA_INI DATETIME = GETDATE();

							EXEC [dbo].[SP_RelatorioAptoNaoVendidos]

							SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		SELECT	a.Id,
				a.IdPredio,
				a.Numero,
				a.Pavimento
			FROM [dbo].[Apartamento] a WITH(NOLOCK)
				LEFT JOIN [dbo].[Venda] v WITH(NOLOCK)
					ON a.Id = v.IdApartamento
			WHERE v.IdApartamento IS NULL
	END
GO

CREATE OR ALTER PROC [dbo].[SP_RelatorioContasReceber]
	@IdVenda INT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte...: Venda.sql
		Objetivo........: Relatorio de contas a receber.
		Autor...........: OrcinoNeto
		Data............: 10/05/2024
		Ex..............:	
							DBCC FREEPROCCACHE
							DBCC DROPCLEANBUFFERS
							DBCC FREESYSTEMCACHE('ALL')

							DECLARE @DATA_INI DATETIME = GETDATE();

							EXEC [dbo].[SP_RelatorioContasReceber]

							SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		SELECT	v.Id,
				v.Valor,
				v.DataVenda,
				v.TotalParcela,
				p.DataVencimento,
				p.IdLancamento,
				p.Valor
			FROM [dbo].[Venda]v WITH(NOLOCK)
				LEFT JOIN [dbo].[Parcela] p WITH(NOLOCK)
					ON v.Id = p.IdVenda
			WHERE p.IdLancamento IS NULL
	
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1
	END
GO