CREATE OR ALTER PROCEDURE [dbo].[SP_CriarContaBancaria]	@IdCliente INT

	AS
	/*
		Documentacao
		Arquivo Fonte.....: conta.sql
		Objetivo..........: Inserir registro em [dbo].[conta] com base no id de algum cliente
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

							SELECT	Id AS IdConta
									IdCliente AS IdCliente,
									Ativo
								FROM [dbo].[Conta] WITH(NOLOCK)

							DBCC DROPCLEANBUFFERS
							DBCC FREEPROCCACHE

							DECLARE	@Ret INT,
									@DataInicio DATETIME = GETDATE()

							EXEC @Ret = [dbo].[SP_CriarContaBancaria] 1
							SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

							SELECT	Id,
									IdTipo,
									Descricao,
									Valor,
									DataVencimento
								FROM [dbo].[Conta] WITH(NOLOCK)

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
							1 - NAO E POSSIVEL INSERIR DESPESA COM DIFERENCA DE TEMPO MAIOR QUE 30 DIAS
	*/
	BEGIN
		--DECLARA VARIAVEL PARA RECECER GETDATE
		DECLARE @DataHoje DATE = GETDATE()

		--VERIFICA SE JA HA CONTA ATIVA DO CLIENTE NO BANCO
		IF EXISTS	(
						SELECT TOP 1 1
							FROM [dbo].[Conta] WITH(NOLOCK)
							WHERE Id = @IdCliente
								AND Ativo = 1
					)
			RETURN 1

		--INSERT EM CONTA COM O ID DO CLIENTE EM ESPECIFICO
		INSERT INTO [dbo].[Conta] (IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo,
									DataAbertura, DataEncerramento, Ativo)
			VALUES (@IdCliente, 0.00, 0.00, 0.00, @DataHoje, @DataHoje, NULL, 1)

		RETURN 0

	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_EncerramentoConta]	@IdConta INT

	AS
	/*
		Documentacao
		Arquivo Fonte.....: conta.sql
		Objetivo..........: Alterar sitacao de atividade para inativo em [dbo].[conta] com base no id de conta
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								SELECT	Id AS IdConta,
										Ativo
									FROM [dbo].[Conta] WITH(NOLOCK)

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_EncerramentoConta] 1, 'coisa', -19900.00, '01-20-2024'
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

								SELECT	Id AS IdConta,
										Ativo
									FROM [dbo].[Conta] WITH(NOLOCK)

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
							1 - NAO E POSSIVEL INSERIR DESPESA COM DIFERENCA DE TEMPO MAIOR QUE 30 DIAS
	*/
	BEGIN
		--SO E POSSIVEL ENCERRAR CONTA AO VERIFICAR QUE SALDO NAO E NEGATIVO
		IF	(SELECT	(	
						ValorSaldoInicial
						- ValorDebito
						+ ValorCredito
					)
				FROM [dbo].[Conta] WITH(NOLOCK)) < 0

			--CASO SEJA NEGATICO RETORNA ERRO
			RETURN 1

		--CASO SEJA DIFERENTE DE NEGATIVO SETA O ATIVO PARA 0 (INATIVO)
		UPDATE Conta
			SET Ativo = 0
			WHERE Id = @IdConta
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioExtratoContas]	@DataInicio DATE,
															@DataFim DATE

	AS
	/*
		Documentacao
		Arquivo Fonte.....: conta.sql
		Objetivo..........: Extrai relatorio de extrato de contas (entradas e saidas) em determinado periodo de tempo
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_RelatorioExtratoContas] '05-01-2024', '05-09-2024'
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		SELECT	l.IdConta,
				l.TipoOperacao,
				l.Valor,
				tl.Nome,
				l.DataLancamento
			FROM Lancamento l
				INNER JOIN TipoLancamento tl
					ON tl.Id = l.IdTipo
			WHERE l.DataLancamento BETWEEN @DataInicio AND @DataFim
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioContasAReceber]

	AS
	/*
		Documentacao
		Arquivo Fonte.....: conta.sql
		Objetivo..........: Listar todas os pagamentos não recebidos, incluindo os futuros ainda nao vencidos
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_RelatorioContasAReceber]
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

							ROLLBACK TRAN

		RETORNOS: ........: 0 - SUCESSO
	*/
	BEGIN
		--RETORNA TODAS AS PARELAS 
		SELECT	p.IdVenda,
				p.Valor,
				p.DataVencimento
			FROM Parcela p
				LEFT JOIN Lancamento l
					ON l.Id = p.IdLancamento
				WHERE p.IdLancamento IS NULL
					AND IdVenda IS NOT NULL
		RETURN 0

	END
GO
