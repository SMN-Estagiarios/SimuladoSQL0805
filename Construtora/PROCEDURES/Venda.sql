USE DB_ConstrutoraLMNC;
GO

CREATE OR ALTER PROC [dbo].[SP_RelatorioAptoVendidos]
	@IdVenda INT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte.....: Venda.sql
		Objetivo..........: Listar todos os apartamentos com as informacoes de parcelas pagas, vencidas e vincendas
		Autor.............: Grupo de estagiarios SMN
		Data..............: 10/05/2024
		Ex................:	DBCC FREEPROCCACHE
							DBCC DROPCLEANBUFFERS
							DBCC FREESYSTEMCACHE('ALL')

							DECLARE @DATA_INI DATETIME = GETDATE();

							EXEC [dbo].[SP_RelatorioAptoVendidos]

							SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		-- Declarando variavel da data atual
		DECLARE @DataAtual DATE = GETDATE();
		
		-- Recuperando dados da subquery e calculando tambem a quantidade de parcelas restantes
		SELECT	v.Id AS IdVenda,
				v.TotalParcela AS TotalParcela,
				x.QuantidadeParcelaPaga AS QuantidadeParcelaPaga,
				x.QuantidadeParcelaVencida AS QuantidadeParcelaVencida,
				(v.TotalParcela - x.QuantidadeParcelaPaga - x.QuantidadeParcelaVencida) AS ParcelasRestantes
			FROM	(
						-- Recuperando dados do id da venda, contagem de parcelas pagas e contagem de parcelas vencidas
						SELECT	p.IdVenda AS IdVenda,
								(
									SELECT	COUNT(Id)
										FROM [dbo].[Parcela] WITH(NOLOCK)
										WHERE IdLancamento IS NOT NULL
											AND IdVenda = p.IdVenda
								) AS QuantidadeParcelaPaga,
								(
									SELECT	COUNT(Id)
										FROM [dbo].[Parcela] WITH(NOLOCK)
										WHERE IdLancamento IS NULL
											AND DataVencimento < @DataAtual
											AND IdVenda = p.IdVenda
								) AS QuantidadeParcelaVencida
							FROM [dbo].[Parcela] p WITH(NOLOCK)
							WHERE IdVenda = ISNULL(@IdVenda, p.IdVenda)
					) AS x
				INNER JOIN [dbo].[Venda] v WITH(NOLOCK)
					ON x.IdVenda = v.Id;
	END