CREATE OR ALTER PROCEDURE [dbo].[SPJOB_GerarParcela]
	AS
	/*
		Documentação
		Arquivo Fonte.....:	SPJOB_GerarParcela.sql
		Objetivo.............:	Job diário para gerar uma parcela quando o dia da venda for igual ao dia do job e ainda houver parcelas em aberto
		Autor.................:	Todos
		Data..................:	10/05/2024
		Ex.....................:	
									BEGIN TRAN
										DBCC FREEPROCCACHE
										DBCC DROPCLEANBUFFERS

										DECLARE @DataInicio DATETIME = GETDATE()

										EXEC [dbo].[SPJOB_GerarParcela]

										SELECT	IdCliente,
												IdApartamento,
												IdIndice,
												Valor,
												DataVenda,
												Financiado,
												TotalParcela
											FROM [dbo].[Venda] WITH(NOLOCK)
											WHERE Id = IDENT_CURRENT('Venda')

										SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
									ROLLBACK TRAN
		Retornos..............: 
			0 - Sucesso			
	*/
	BEGIN
		
		--Declarar variáveis
		DECLARE @DataAtual DATETIME = GETDATE()
	
		--Inserir parcelas de vendas em aberto
		INSERT INTO [dbo].[Parcela](IdVenda, IdJuros, Valor, DataVencimento)
							SELECT	Id,
										1,
										Valor,
										DATEADD(MONTH, 1, @DataAtual)
								FROM [dbo].[Venda] WITH(NOLOCK)
								WHERE	DATEPART(DAY, DataVenda) = DATEPART(DAY, @DataAtual)
										AND DATEDIFF(MONTH, DataVenda, @DataAtual) <= TotalParcela
			
	END
GO