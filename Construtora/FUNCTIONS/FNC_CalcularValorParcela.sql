CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularValorParcela](
															@ValorVenda DECIMAL(10,2),
															@Financiado BIT,
															@TotalParcela SMALLINT,
															@IdIndice TINYINT
														 )
	RETURNS DECIMAL(10,2)
	AS
	/*
		Documentação
		Arquivo Fonte.........:	FNC_CalcularValorParcela.sql
		Objetivo..............:	Function para calcular o valor total a ser pago na parcela
		Autor.................:	Grupo de Estagiarios SMN
		Data..................:	10/05/2024
		Ex....................:	DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

								DECLARE @DataInicio DATETIME = GETDATE()

								SELECT [dbo].[FNC_CalcularValorParcela](150000.00, 1, 60, 2)

								SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		--Declarar variável
		DECLARE @ValorTotal DECIMAL(10,2)

		--Calcular valor
		SET @ValorTotal = @ValorVenda / @TotalParcela + (CASE	WHEN @Financiado = 1 THEN(@ValorVenda * (SELECT MAX(vi.Aliquota)
																											FROM [dbo].[ValorIndice] vi WITH(NOLOCK)
																											WHERE vi.IdIndice = @IdIndice
																										 )
																						  )
																ELSE 0
														  END
														)
		RETURN @ValorTotal
	END
GO