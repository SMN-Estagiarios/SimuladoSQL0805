CREATE OR ALTER PROCEDURE [dbo].[SP_InserirVenda]
	@IdCliente INT,
	@IdApartamento INT,
	@Valor DECIMAL(10,2),
	@TotalParcela SMALLINT
	AS
	/*
		Documentação
		Arquivo Fonte.....:	Venda.sql
		Objetivo.............:	Procedure para inserir uma nova venda
									IdIndice 1 = INCC e 2 = IGPM
		Autor.................:	Todos
		Data..................:	10/05/2024
		Ex.....................:	
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
		IF EXISTS (
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