CREATE OR ALTER PROCEDURE [dbo].[SPJOB_GerarParcela]
	AS
	/*
		Documentação
		Arquivo Fonte.........:	SPJOB_GerarParcela.sql
		Objetivo..............:	Job diário para gerar uma parcela quando o dia da venda for igual ao dia do job e ainda houver parcelas em aberto
		Autor.................:	Grupo de Estagiarios SMN
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @DataInicio DATETIME = GETDATE()

									SELECT	*
										FROM [dbo].[Parcela] WITH(NOLOCK)
										ORDER BY IdVenda


									EXEC [dbo].[SPJOB_GerarParcela]

									SELECT	*
										FROM [dbo].[Parcela] WITH(NOLOCK)
										ORDER BY IdVenda

									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		
		--Declarar variáveis
		DECLARE @DataAtual DATETIME = GETDATE()

		--Criar tabela temporária
		CREATE TABLE #UltimasParcelas(
										IdVenda INT,
										DataVencimento DATE
									 )

		--Popular tabela temporária
		INSERT INTO #UltimasParcelas
			SELECT	IdVenda,
					MAX(DataVencimento)
				FROM [dbo].[Parcela]
				GROUP BY IdVenda

		--Inserir parcelas de vendas em aberto
		INSERT INTO [dbo].[Parcela](IdVenda, IdJuros, Valor, DataVencimento)
							SELECT	v.Id,
									1,
									[dbo].[FNC_CalcularValorParcela](v.Valor, v.Financiado, v.TotalParcela, v.IdIndice),
									DATEADD(MONTH, 1, @DataAtual)
								FROM [dbo].[Venda] v WITH(NOLOCK)
									INNER JOIN #UltimasParcelas up
										ON v.Id = up.IdVenda
								WHERE	DATEPART(DAY, v.DataVenda) = DATEPART(DAY, @DataAtual) --Checar se está no dia de vencimento
										AND DATEPART(MONTH, up.DataVencimento) = DATEPART(MONTH, @DataAtual) --Checar se está no mês do vencimento
										AND DATEDIFF(MONTH, DataVenda, @DataAtual) <= TotalParcela -- Checar se ainda há parcelas em aberto
	END
GO