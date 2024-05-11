CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelaVendas]
	@IdVenda INT = NULL
	AS
	/*
		Documentacao
		Arquivo fonte............:	Parcela.sql
		Objetivo.................:	Listar as parcelas da venda.
		Autor....................:	Grupo de Estagiarios SMN
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
		Autor....................:	Grupo de Estagiarios SMN
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

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarRelatorioContasAReceber]	
	AS
	/*
		Documentação
		Arquivo Fonte.....: Parcela.sql
		Objetivo..........: Gerar o relatorio de todas as contas que a empresa tem a receber
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT

								EXEC [dbo].[SP_GerarRelatorioContasAReceber]

								SELECT	DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
	*/
	BEGIN
		-- Recuperar parcelas que a empresa tem a receber
		SELECT	Id,
				IdVenda,
				Valor,
				DataVencimento
			FROM [dbo].[Parcela] WITH(NOLOCK)
			WHERE IdCompra IS NULL
				AND IdLancamento IS NULL
			ORDER BY IdVenda, DataVencimento;
	END
