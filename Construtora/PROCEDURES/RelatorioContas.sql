CREATE OR ALTER PROCEDURE [dbo].[SP_ListaExtratoContas]
	@DiasParaSeremProcessados INT = NULL,
	@IdConta INT = NULL
AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista o fluxo de caixa diário da Construtora id da conta travado como 0 (Conta da construtora)
		Autor.............: Adriel Alexander de Sousa
		Data..............: 10/05/2024
		Ex................: 
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListaExtratoContas]20, 3

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							SELECT MONTH(DataLancamento)
								FROM Lancamento

	*/
	BEGIN
		
		--Declarando Variavel 
		DECLARE @DataAtual DATE = GETDATE(),
				@DataProcessamento DATE;

		IF @DiasParaSeremProcessados <> NULL 
			BEGIN
			--setando a variável de data para processamento de acordo com o valor passado nos paramentros 
				SET @DataProcessamento =DATEADD(DAY, -ABS(@DiasParaSeremProcessados), @DataAtual)
				
					SELECT	la.IdConta,
							la.Valor,
							la.Valor,
							la.NomeHistorico,
							la.DataLancamento,
							tl.Nome
						FROM [dbo].[Lancamento]la WITH(NOLOCK)
							INNER JOIN [dbo].[TipoLancamento] tl
								ON tl.Id = la.IdTipo
						WHERE la.IdConta = ISNULL(@IdConta,IdConta)
							  AND DataLancamento BETWEEN @DataProcessamento AND @DataAtual
			END
		ELSE
			BEGIN
				SELECT	la.IdConta,
							la.Valor,
							la.Valor,
							la.NomeHistorico,
							la.DataLancamento,
							tl.Nome
						FROM [dbo].[Lancamento]la WITH(NOLOCK)
							INNER JOIN [dbo].[TipoLancamento] tl
								ON tl.Id = la.IdTipo
						WHERE la.IdConta = ISNULL(@IdConta,IdConta)
			END
	END


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
		
		SELECT p.Id,
			   p.IdVenda,
			   p.Valor,
			   p.IdLancamento,
			   p.DataVencimento
			FROM [dbo].[Parcela] p WITH(NOLOCK)
				LEFT JOIN [dbo].[Lancamento] la
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
