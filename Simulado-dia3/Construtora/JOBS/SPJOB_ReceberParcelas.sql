USE DB_ConstrutoraLMNC;

GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ReceberParcelas]
	
AS
	/*
	Documentacao
	Arquivo fonte............:	SPJOB_ReceberParcelas.sql
	Objetivo.................:	Atualizar ao receber o pagamento de uma parcela.
	Autor....................:	Pedro Avelino
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@DataInicio DATETIME = GETDATE()

								

								SELECT	DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

								ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando as variaveis
		DECLARE	@ValorPagamento DECIMAL (10,2),
				@IdTipoLancamento INT,
				@DataAtual DATETIME = GETDATE()

		-- Verificar as parcelas que vencem no dia e se as contas das parcelas possuem saldo
		INSERT INTO [dbo].[Lancamento] (	IdConta,
											IdTipo,
											TipoOperacao,
											Valor,
											NomeHistorico,
											DataLancamento	
			
									   ) 
		SELECT	ct.Id,
				4,
				'D',
				p.valor,
				CONCAT('Pagamento de fatura ', p.Id),
				@DataAtual
			FROM [dbo].[Parcela] p WITH (NOLOCK)
				INNER JOIN [dbo].[Venda] v WITH (NOLOCK)
					ON v.Id = p.IdVenda
				INNER JOIN [dbo].[Cliente] c WITH (NOLOCK)
					ON c.Id = v.IdCliente
				INNER JOIN [dbo].[Conta] ct WITH (NOLOCK)
					ON ct.IdCliente = c.Id
			WHERE DATEDIFF(DAY, @DataAtual, p.DataVencimento) 
				AND [dbo].[FNC_CalcularSaldoAtualConta] (NULL, ct.SaldoInicial, ct.ValorCredito, ct.ValorDebito) >= p.Valor

				-- Data de vencimento 
		
		-- Setando os valores nas variaveis
		SELECT	@IdTipoLancamento = i.IdTipo,
				@ValorPagamento = i.Valor
			FROM inserted i
			WHERE Id IS NOT NULL;

		-- Atualizando a parcelas pagas
		UPDATE [dbo].[Parcela]
			SET IdVenda = 


			/*
			Se tiver, debitar parcela: pegar o id da parcela, gerar um lançamento com o valor da parcela
			(incluindo juros e multas por atraso)
			Com SCOPE_IDENTITY pegar o id do lançamento que foi inserido para parcela, e atualizar o registro o id da parcela
			com o id do lançamento

			*/
	END;

GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ReceberParcelas]
	AS
	/*
	Documentacao
	Arquivo fonte............:	SPJOB_ReceberParcelas.sql
	Objetivo.................:	Atualizar ao receber o pagamento de uma parcela.
	Autor....................:	Danyel Targino
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE	@DataInicio DATETIME = GETDATE()

									EXEC [dbo].[SPJOB_ReceberParcelas]

									SELECT	DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando as variaveis
		
		DECLARE @DataAtual DATE = GETDATE(),
				@TaxaAtrasadoAtual DECIMAL(6,5),
				@Id_Parcela INT,
				@Valor_Lancamento DECIMAL(15,2),
				@Id_Lancamento INT;

		-- Criar tabela temporaria
		CREATE TABLE #Tabela	(
									IdParcela INT,
									IdConta INT,
									IdVenda INT,
									IdLancamento INT,
									Id_Status TINYINT,
									Valor DECIMAL(15,2),
									Juros DECIMAL(15,2),
									Data_Cadastro DATE,
									SaldoDisponivel DECIMAL(15,2)
								);

		-- Inserir valores nela
		INSERT INTO #Tabela (	
								IdParcela,
								IdConta,
								IdVenda,
								IdLancamento,
								Valor,
								Juros,
								Data_Cadastro,
								SaldoDisponivel
							);
			SELECT	p.Id,
					ct.id,
					v.id,
					p.IdLancamento,
					p.Valor,
					((p.valor * 0.02)) + (DATEDIFF(DAY, p.DataVencimento, GETDATE()) * j.Aliquota) Juros,
					p.DataVencimento,
					[dbo].[FNC_CalcularSaldoAtualConta] (NULL, ct.ValorSaldoInicial, ct.ValorCredito, ct.ValorDebito) SaldoDisponivel
				FROM [dbo].[Parcela] p WITH (NOLOCK)
					INNER JOIN [dbo].[Venda] v WITH (NOLOCK)
						ON v.Id = p.IdVenda
					INNER  JOIN [dbo].[Cliente] c WITH (NOLOCK)
						ON c.Id = v.IdCliente
					INNER  JOIN [dbo].[Conta] ct WITH (NOLOCK)
						ON ct.IdCliente = c.Id
					INNER  JOIN [dbo].[Juros] j WITH(NOLOCK)
						ON j.DataInicio <= GETDATE()
				WHERE	p.DataVencimento <= GETDATE() AND
						p.IdLancamento IS NULL


			SELECT * FROM #Tabela;
			DROP TABLE #Tabela;
		-- Verificar se existe algum registro onde o valor da parcela é maior que o disponivel
		/* IF EXISTS (SELECT TOP 1 1
							FROM #Tabela
							WHERE (Valor + Juros) > SaldoDisponivel)
			BEGIN
				-- Gerar juros para a parcela
				UPDATE [dbo].[Parcela]
					SET Juros = [dbo].[FNC_CalcularJurosAtrasoParcela](Id_Emprestimo, Valor,  DAY(DATEDIFF(DAY, Data_Vencimento, @DataAtual)))
				WHERE	Data_Vencimento <= @DataAtual AND
						Id_Lancamento IS NULL

				RETURN 1
			END */





			/*

			SELECT	ct.Id,
					4,
				'D',
				p.valor,
				CONCAT('Pagamento de fatura ', p.Id),
				@DataAtual
			FROM [dbo].[Parcela] p WITH (NOLOCK)
				INNER JOIN [dbo].[Venda] v WITH (NOLOCK)
					ON v.Id = p.IdVenda
				INNER JOIN [dbo].[Cliente] c WITH (NOLOCK)
					ON c.Id = v.IdCliente
				INNER JOIN [dbo].[Conta] ct WITH (NOLOCK)
					ON ct.IdCliente = c.Id
			WHERE DATEDIFF(DAY, @DataAtual, p.DataVencimento) 
				AND [dbo].[FNC_CalcularSaldoAtualConta] (NULL, ct.SaldoInicial, ct.ValorCredito, ct.ValorDebito) >= p.Valor

				*/
	END;