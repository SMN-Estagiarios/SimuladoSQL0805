CREATE OR ALTER PROCEDURE [dbo].[SP_InserirConta]
	@IdCliente INT
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Inserir um registro de conta
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK);

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Retorno INT;

								EXEC @Retorno = [dbo].[SP_InserirConta] 4

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK);
							ROLLBACK TRAN

							--- Retornos ---
							00: Sucesso
							01: Erro, o cliente nao existe
							02: Erro, ja existe conta para esse cliente
							03: Erro, nao foi possivel inserir uma conta
	*/
	BEGIN
		-- Declarando variavel de data atual
		DECLARE @DataAtual DATE = GETDATE();

		-- Verificar se existe o cliente
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Cliente] WITH(NOLOCK)
								WHERE Id = @IdCliente
						)
			RETURN 1;

		-- Verificar se o cliente ja possui uma conta
		IF EXISTS	(
						SELECT TOP 1 1
							FROM [dbo].[Conta] WITH(NOLOCK)
							WHERE IdCliente = @IdCliente
					)
			RETURN 2;

		-- Inserir uma conta
		INSERT INTO [dbo].[Conta] (IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito,
										DataSaldo, DataAbertura, DataEncerramento, Ativo)
			VALUES					(@IdCliente, 0, 0, 0,
										@DataAtual, @DataAtual, NULL, 1);

		IF @@ERROR <> 0 OR @@ROWCOUNT<> 1
			RETURN 3;

		RETURN 0;
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarConta]
	@IdConta INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Listar uma ou todas as contas
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Retorno INT;

								EXEC @Retorno = [dbo].[SP_ListarConta] 4

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN

							--- Retornos ---
							00: Sucesso
							01: Erro, a conta nao existe
	*/
	BEGIN
		-- Verificar se a conta existe
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
						)
			RETURN 1

		--Recuperar a(s) conta(a)
		SELECT	Id,
				IdCliente,
				ValorSaldoInicial,
				ValorCredito,
				ValorDebito,
				DataSaldo,
				DataAbertura,
				DataEncerramento,
				Ativo
			FROM [dbo].[Conta] WITH(NOLOCK)
			WHERE Id = ISNULL(@IdConta, Id)

		RETURN 0;
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ReativarConta]
	@IdConta INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Reativar uma conta
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK)

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Retorno INT;

								EXEC @Retorno = [dbo].[SP_ReativarConta] 1

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK)
							ROLLBACK TRAN

							--- Retornos ---
							00: Sucesso
							01: Erro, a conta nao existe
							02: Erro, a conta nao foi atualizada
							03: Erro, nao e possivel atualizar a conta da contrutora
	*/
	BEGIN
		-- Verificar se a conta existe
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
						)
			RETURN 1

		-- Verificando se o id passado e diferente do da construtora
		IF @IdConta <> 0
			BEGIN
				--Atualizar o status da conta
				UPDATE [dbo].[Conta]
					SET Ativo = 1
					WHERE Id = @IdConta;
		
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					RETURN 2
			END
		ELSE
			RETURN 3;

		RETURN 0;
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarConta]
	@IdConta INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Desativar uma conta
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK)

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Retorno INT;

								EXEC @Retorno = [dbo].[SP_DesativarConta] 1

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;

								SELECT	*
									FROM [dbo].[Conta] WITH(NOLOCK)
							ROLLBACK TRAN

							--- Retornos ---
							00: Sucesso
							01: Erro, a conta nao existe
							02: Erro, a conta nao foi atualizada
							03: Erro, nao e possivel atualizar a conta da contrutora
	*/
	BEGIN
		-- Verificar se a conta existe
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
						)
			RETURN 1

		-- Verificando se o id passado e diferente do da construtora
		IF @IdConta <> 0
			BEGIN
				--Atualizar o status da conta
				UPDATE [dbo].[Conta]
					SET Ativo = 0
					WHERE Id = @IdConta;
		
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					RETURN 2
			END
		ELSE
			RETURN 3;

		RETURN 0;
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarFluxoDeCaixa]
	@DataInicio DATE = NULL,
	@DataTermino DATE = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista o fluxo de caixa diário da Construtora id da conta travado como 0 (Conta da construtora)
		Autor.............: Grupo Estagiários SMN
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ListarFluxoDeCaixa]NULL, NULL

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN
	*/
	 BEGIN

		-- Variáveis de tempo
		DECLARE @DataAtual DATE = GETDATE(),
				@MesPassado DATE

		-- Data do mês passado
		SET @MesPassado = DATEADD(MONTH, -1, @DataAtual)

		-- Se data início for nulo, usar o dia 1 do mês passado
		IF @DataInicio IS NULL	
			BEGIN
				SET @DataInicio = DATEFROMPARTS(YEAR(@MesPassado), MONTH(@MesPassado), 1);
			END

		-- Se data término for nulo, usar a data da chamada da procedure
		IF @DataTermino IS NULL
			BEGIN 
				SET @DataTermino = @DataAtual	
			END

		-- Tabela temporária com as datas do período
		CREATE TABLE #TabelaData (
									Dia DATE
								 ) 

		--Populando tabela de dias
		WHILE @DataInicio <= @DataTermino
			BEGIN
				INSERT INTO  #TabelaData(Dia) VALUES 
										(@DataInicio)
				SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
			END;
			
		-- Calculando fluxo de caixa
		WITH CalculoCreditoDebito AS (
										SELECT	ISNULL(SUM(CASE WHEN TipoOperacao = 'C' THEN Valor ELSE 0 END), 0) AS Valor_Credito,
												ISNULL(SUM(CASE WHEN TipoOperacao = 'D' THEN Valor ELSE 0 END), 0) AS Valor_Debito,
												td.Dia,
												C.Id AS IdConta
											FROM #TabelaData td
												CROSS JOIN [dbo].[Conta] C WITH(NOLOCK)
												LEFT JOIN [dbo].[Lancamento] la WITH(NOLOCK)
													ON DATEDIFF(DAY, td.Dia, la.DataLancamento) = 0 
														AND C.Id = la.IdConta
												WHERE td.Dia >= C.DataAbertura 
													AND C.Id = 0 
												GROUP BY td.Dia, c.Id
									 )
										SELECT  x.IdConta,
												x.Credito,
												x.Debito,
												x.SaldoFluxoAcumulativo,
												x.DataSaldo
											FROM (
													SELECT	Valor_Credito Credito,
															Valor_Debito Debito,
															Dia DataSaldo,
															IdConta,
															SUM(Valor_Credito - Valor_Debito) OVER (PARTITION BY IdConta ORDER BY Dia) AS SaldoFluxoAcumulativo
														FROM CalculoCreditoDebito
											     ) x		
		-- Excluindo tabela temporária
		DROP TABLE #TabelaData
END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarExtratoDeConta]
	@IdConta INT = NULL,
	@Dias INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Gerar extrato das contas, podendo ser de somente uma conta ou de todas as contas.
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Retorno INT;

								EXEC @Retorno = [dbo].[SP_GerarExtratoDeConta] NULL, 10

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN

							--- Retornos ---
							0: Sucesso
							1: Erro, cliente nao encontrado

	*/
	BEGIN
		-- Declarando variaveis
		DECLARE @DataInicial DATE,
				@DataFinal DATE = GETDATE();
		

		-- Verificando se existe conta com o id passado
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id = ISNULL(@IdConta, Id)
						)
			RETURN 1
		
		-- Verificando se foi passado a quantidade de dias, e caso seja, setar a variavel data inicial para uma diferenca da data atual menos os dias
		IF @Dias IS NULL
			BEGIN
				SELECT	@DataInicial = MIN(DataAbertura) 
					FROM [dbo].[Conta] WITH(NOLOCK)
			END
		ELSE
			-- Senao setar a variavel data inicial para a menor data de abertura de conta
			SET @DataInicial = DATEADD(DAY, -@Dias, @DataFinal);

		SELECT	IdConta,
				IdTipo,
				COALESCE(IdTransferencia, 0) AS IdTransferencia,
				TipoOperacao,
				Valor,
				NomeHistorico,
				DataLancamento
			FROM [dbo].[Lancamento] WITH(NOLOCK)
			WHERE DataLancamento BETWEEN @DataInicial AND @DataFinal 
				AND IdConta = ISNULL(@IdConta, IdConta)
			ORDER BY IdConta, DataLancamento;
				
		RETURN 0;
	END