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

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarRelatorioContasAReceber]
	@IdVenda INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Parcela.sql
		Objetivo..........: Visualizar as contas a receber
		Autor.............: Danyel Targino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								EXEC @RET = [dbo].[SP_GerarRelatorioContasAReceber]
							
							ROLLBACK TRAN

	*/
	BEGIN
		-- Analisar quais parcelas a receber a empresa tem
		SELECT	c.Nome,
				v.Valor,
				v.DataVenda,
				p.Valor,
				p.DataVencimento
			FROM [dbo].[Parcela] p WITH (NOLOCK)
				INNER JOIN Venda v WITH (NOLOCK)
					ON v.IdCliente = p.Id
				INNER JOIN Cliente c WITH (NOLOCK)
					ON c.Id = v.IdCliente
			WHERE p.IdLancamento IS NULL
				
		
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarRelatorioContasAPagar]
	@IdCompra INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Parcela.sql
		Objetivo..........: Visualizar as contas a receber
		Autor.............: Danyel Targino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								EXEC @RET = [dbo].[SP_GerarRelatorioContasAPagar]
							
							ROLLBACK TRAN

	*/
	BEGIN
		-- Analisar quais parcelas a pagar a empresa tem
		SELECT	c.Id,
				c.Valor,
				c.DataCompra,
				p.Valor,
				p.DataVencimento
			FROM [dbo].[Parcela] p WITH (NOLOCK)
				INNER JOIN Compra c WITH (NOLOCK)
					ON c.Id = p.IdCompra
			WHERE p.IdLancamento IS NULL
				
		
	END
GO