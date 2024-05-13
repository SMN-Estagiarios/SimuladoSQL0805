CREATE OR ALTER PROCEDURE [dbo].[SP_ListaExtratoContas]
	@DiasParaSeremProcessados INT = NULL,
	@IdConta INT = NULL
AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista os extratos de contas passada por id bem como os dias posteriores em relação a data de hoje para fazer o processamento
		Autor.............: Adriel Alexander de Sousa
		Data..............: 10/05/2024
		Ex................: 
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListaExtratoContas]20, 1

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

	*/
	BEGIN
		
		--Declarando Variavel 
		DECLARE @DataAtual DATE = GETDATE(),
				@DataProcessamento DATE;

		IF @DiasParaSeremProcessados IS NOT NULL
			BEGIN
			   --setando a variável de data para processamento de acordo com o valor passado nos paramentros 
				SET @DataProcessamento = DATEADD(DAY, -@DiasParaSeremProcessados, @DataAtual)

				-- consulta o extrato com base em uma conta e os dias de processamentos passado por parametro 
				SELECT	la.IdConta,
						la.Valor,
						la.NomeHistorico,
						la.DataLancamento
					FROM [dbo].[Lancamento]la WITH(NOLOCK)
					WHERE la.IdConta = ISNULL(@IdConta,IdConta)
						  AND la.DataLancamento >= @DataProcessamento
						  AND la.DataLancamento <= @DataAtual
			END
		ELSE
			BEGIN
				--Consulta todo o histórico de extrato de uma conta passada por id ou de todas caso o id seja nulo
				SELECT	la.IdConta,
						la.Valor,
						la.NomeHistorico,
						la.DataLancamento
					FROM [dbo].[Lancamento]la WITH(NOLOCK)
					WHERE la.IdConta = ISNULL(@IdConta,IdConta)
			END
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContasAReceber]
	@IdConta INT = NULL
AS 
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista as parcelas que ainda serão pagas futuramente pelo cliente passando o id da conta, ou de todas deixando null
		Autor.............: Adriel Alexander de Sousa
		Data..............: 10/05/2024
		Ex................: 
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarContasAReceber]null

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

	*/
	BEGIN
		--consulta todas as vendas realizadas que geraram parcelas e essas parcelas encontram-se como n pagas ainda
		SELECT p.Id,
			   p.IdVenda,
			   p.Valor,
			   p.IdLancamento,
			   p.DataVencimento
			FROM [dbo].[Parcela] p WITH(NOLOCK)
				LEFT JOIN [dbo].[Lancamento] la WITH(NOLOCK)
					ON p.IdLancamento = la.Id
			WHERE p.IdLancamento IS NULL
					AND la.IdConta = ISNULL(@IdConta, IdConta)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContasAPagar]
AS 
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista contas que ainda não foram pagas pela empresa
		Autor.............: Adriel Alexander de Sousa
		Data..............: 10/05/2024
		Ex................: 
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarContasAPagar]

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

	*/
	BEGIN
		-- Consulta de contas a serem pagas pela construtura
		SELECT p.Id,
			   p.IdCompra,
			   p.Valor,
			   p.IdLancamento,
			   p.DataVencimento
			FROM [dbo].[Parcela] p WITH(NOLOCK)
				LEFT JOIN [dbo].[Lancamento] la WITH(NOLOCK)
					ON p.IdLancamento = la.Id
			WHERE p.IdLancamento IS NULL
					AND la.IdConta = 0
	END
GO


