CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelaVendas]
	@IdVenda INT = NULL
	AS
	/*
	Documentacao
	Arquivo fonte............:	Parcela.sql
	Objetivo.................:	Listar as parcelas da venda.
	Autor....................:	Danyel Targino
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@DataInicio DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarParcelaVendas] 1

								SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								
								ROLLBACK TRAN
	*/
	BEGIN
		-- Listar as Parcelas
		SELECT	Id,
				IdVenda,
				IdCompra,
				IdJuros,
				IdLancamento,
				Valor,
				DataVencimento
			FROM [dbo].[Parcela] WITH (NOLOCK)
			WHERE IdVenda = ISNULL(@IdVenda, IdVenda)

	END;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelaCompras]
	@IdCompra INT = NULL
	AS
	/*
	Documentacao
	Arquivo fonte............:	Parcela.sql
	Objetivo.................:	Listar as parcelas da venda.
	Autor....................:	Danyel Targino
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@DataInicio DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarParcelaCompras] 1

								SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								
								ROLLBACK TRAN
	*/
	BEGIN
		-- Listar as Parcelas
		SELECT	Id,
				IdVenda,
				IdCompra,
				IdJuros,
				IdLancamento,
				Valor,
				DataVencimento
			FROM [dbo].[Parcela] WITH (NOLOCK)
			WHERE IdCompra = ISNULL(@IdCompra, IdCompra)

	END;
GO
