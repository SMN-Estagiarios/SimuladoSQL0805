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
		Autor.................:	Turma de Est�gio
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirVenda] 1, 4, 100, 60
									
									SELECT	*
										FROM [dbo].[Venda] WITH(NOLOCK)
										WHERE Id = IDENT_CURRENT('Venda')

									SELECT	*
										FROM [dbo].[Parcela] WITH(NOLOCK)
										WHERE Id = IDENT_CURRENT('Parcela')

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
								1 - Erro: O apartamento j� est� vendido
								2 - Erro: N�o foi poss�vel realizar a venda
								2 - Erro: N�o foi possivel gerar as parcelas
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
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 2
			
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
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 3

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
		Autor.................:	Grupo de Estagiarios SMN
		Data..................:	10/05/2024
		Ex....................:	DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

								DECLARE @DataInicio DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarVendas]
									
								SELECT	DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
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