CREATE OR ALTER PROCEDURE [dbo].[SP_ListarExtratoContas]
	@DiasASeremProcessados INT = NULL,
	@IdConta INT = NULL
AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Listar o fluxo de caixa diário da Construtora, como o id da conta travado como 0(id Conta Construtora)
		Autor.............: Rafael Mauricio
		Data..............: 10/05/2024
		Ex................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarExtratoContas]20, 3

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							SELECT MONTH(DataLancamento)
								FROM Lancamento
							ROLLBACK TRAN
	*/
	BEGIN
		
		--Declarando Variavel 
		DECLARE @DataAtual DATE = GETDATE(),
				@DataProcessamento DATE;

		IF @DiasASeremProcessados <> NULL 
			BEGIN
			--setando a variável de data para processamento de acordo com o valor passado nos paramentros 
				SET @DataProcessamento =DATEADD(DAY, -ABS(@DiasASeremProcessados), @DataAtual)
				
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
						WHERE la.IdConta = ISNULL(@IdConta, IdConta)
			END
	END

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContasAReceber]
	@IdConta INT = NULL
AS 
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Listar parcelas que serão pagas pelo cliente passando o id da conta, ou de todas deixando null
		Autor.............: Rafael de Souza Mauricio
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarContasAReceber]null

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN
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
		Objetivo..........: Listar contas em aberto da empresa
		Autor.............: Rafael Mauricio
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarContasAPagar]

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN
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
