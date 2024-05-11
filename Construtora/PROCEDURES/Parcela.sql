CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelaVendas]
	@IdVenda INT = NULL
	AS
	/*
	Documentacao
	Arquivo fonte............:	Parcela.sql
	Objetivo.................:	Listar as parcelas da venda.
	Autor....................:	Grupo
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
	Autor....................:	Grupo
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

	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContasReceber]
	AS
	/*
	Documentacao
	Arquivo fonte............:	Parcela.sql
	Objetivo.................:	Procedure para listar todas as parcelas ainda não pagas pelo cliente
	Autor....................:	João Victor Maia
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE	@Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC [dbo].[SP_ListarContasReceber]

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								
								ROLLBACK TRAN
	Retornos.................:	0 - Sucesso
	*/
	BEGIN

		--Listar as parcelas não pagas
		SELECT	Id,
				IdVenda,
				IdCompra,
				IdJuros,
				IdLancamento,
				Valor,
				DataVencimento
			FROM [dbo].[Parcela] WITH(NOLOCK)
			WHERE IdLancamento IS NULL

		RETURN 0
	END
GO