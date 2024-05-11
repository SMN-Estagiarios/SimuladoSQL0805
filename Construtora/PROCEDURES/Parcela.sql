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

CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioContasAPagar]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: cliente.sql
		Objetivo..........: Extrai todas as despesas ainda nao pagas
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_RelatorioContasAPagar]
																	
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo


							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		SELECT	d.Id,
				d.IdTipo,
				d.Descricao,
				d.Valor,
				d.DataVencimento
			FROM [dbo].[Despesa] d WITH(NOLOCK)
				LEFT JOIN [dbo].[Lancamento] l WITH(NOLOCK)
					ON d.Id = d.Id
				WHERE l.IdDespesa IS NULL

		 RETURN 0
	END
GO