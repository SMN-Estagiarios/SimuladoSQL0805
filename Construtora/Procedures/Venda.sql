CREATE OR ALTER PROCEDURE [dbo].[SP_InserirVenda]
	@IdCliente INT,
	@IdApartamento INT,
	@Valor DECIMAL(10,2),
	@TotalParcela SMALLINT
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Venda.sql
		Objetivo..............:	Procedure para inserir uma nova venda
								IdIndice 1 = INCC e 2 = IGPM
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirVenda] 0, 4, 1000000, 60
									
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
		Retornos..............: 0 - Sucesso
								1 - Erro: O apartamento j� est� vendido
								2 - Erro: N�o foi poss�vel realizar a venda
	*/
	BEGIN
		--Declarar vari�veis
		DECLARE @IdIndice TINYINT,
				@Entregue BIT,
				@Financiado BIT,
				@IdVenda INT,
				@IdJuros TINYINT

		--Atribuir valor �s vari�veis
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

		--Checar se o apartamento j� est� vendido
		IF EXISTS (SELECT TOP 1 1
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
			
		--Atribuir valor � IdVenda
		SET @IdVenda = IDENT_CURRENT('Venda')
		
		--Inserir primeira parcela
		INSERT INTO [dbo].[Parcela](IdVenda, 
									IdJuros, 
									Valor, 
									DataVencimento
									)
							VALUES (@IdVenda, 
									@IdJuros, 
									[dbo].[FNC_CalcularValorParcela](@Valor, @Financiado, @TotalParcela, @IdIndice),
									DATEADD(MONTH, 1, GETDATE())
									)

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarVendas]
	@IdCliente INT = NULL
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Venda.sql
		Objetivo..............:	Procedure para listar todas as vendas gerais ou de um cliente espec�fico
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:		DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListarVendas]
									
									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
		Retornos..............: 0 - Sucesso
	*/
	BEGIN
		--Listar as vendas
		SELECT	IdCliente,
				IdApartamento,
				IdIndice,
				Valor,
				DataVenda,
				Financiado,
				TotalParcela
			FROM [dbo].[Venda] WITH(NOLOCK)
			WHERE IdCliente = ISNULL(@IdCliente, IdCliente)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarAptNaoVendidos]
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Venda.sql
		Objetivo..............:	Procedure para listar os apartamentos ainda n�o vendidos
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:		DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListarAptNaoVendidos]
									
									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
		Retornos..............: 0 - Sucesso
	*/
	BEGIN

		--Listar apartamentos n�o vendidos
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