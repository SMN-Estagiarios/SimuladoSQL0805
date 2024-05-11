CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelaVendas]
	@IdVenda INT = NULL
	AS
	/*
	Documentacao
	Arquivo fonte............:	Parcela.sql
	Objetivo.................:	Listar as parcelas da venda.
	Autor....................:	Grupo Estagiários SMN
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE	@Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_ListarParcelaVendas] 3

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								
								ROLLBACK TRAN

								SELECT	Id,
										IdVenda,
										IdCompra,
										IdJuros,
										IdLancamento,
										Valor,
										DataVencimento
									FROM [dbo].[Parcela] WITH (NOLOCK)
									WHERE IdVenda = 3
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
	Autor....................:	Grupo Estagiários SMN
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE	@Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_ListarParcelaCompras] 1

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								
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
