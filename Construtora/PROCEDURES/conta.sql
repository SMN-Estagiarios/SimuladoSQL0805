CREATE OR ALTER PROCEDURE [dbo].[SP_ListarFluxoDeCaixa]
	@DataInicio DATE = NULL,
	@DataTermino DATE = NULL
	AS
	/*
		Documenta��o
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista o fluxo de caixa di�rio da Construtora id da conta travado como 0 (Conta da construtora)
		Autor.............: Grupo Estagi�rios SMN
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								EXEC @RET = [dbo].[SP_ListarFluxoDeCaixa]NULL, NULL
							
							ROLLBACK TRAN

	*/
	 BEGIN

		-- Vari�veis de tempo
		DECLARE @DataAtual DATE = GETDATE(),
				@MesPassado DATE

		-- Data do m�s passado
		SET @MesPassado = DATEADD(MONTH, -1, @DataAtual)

		-- Se data in�cio for nulo, usar o dia 1 do m�s passado
		IF @DataInicio IS NULL	
			BEGIN
				SET @DataInicio = DATEFROMPARTS(YEAR(@MesPassado), MONTH(@MesPassado), 1);
			END

		-- Se data t�rmino for nulo, usar a data da chamada da procedure
		IF @DataTermino IS NULL
			BEGIN 
				SET @DataTermino = @DataAtual	
			END

		-- Tabela tempor�ria com as datas do per�odo
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
		-- Excluindo tabela tempor�ria
		DROP TABLE #TabelaData
	END		
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirConta]
	@IdCliente INT,
	@ValorSaldoInicial DECIMAL(10,2), 
	@ValorDebito DECIMAL(10,2),
	@ValorCredito DECIMAL(10,2)
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Conta.sql
		Objetivo..............:	Procedure para inserir uma nova conta
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirConta] 1, 0, 0, 0

									SELECT	Id,
											IdCliente,
											ValorSaldoInicial,
											ValorDebito,
											ValorCredito,
											DataAbertura,
											DataEncerramento,
											Ativo
										FROM [dbo].[Conta]
										Where Id = IDENT_CURRENT('Conta')
										
									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso	
								1 - Erro: O IdCliente n�o existe
								2 - Erro: Nenhum registro foi criado
	*/
	BEGIN
		--Checar se existe o IdCliente
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Cliente]
						WHERE Id = @IdCliente)
			BEGIN
				RETURN 1
			END

		--Inserir conta
		INSERT INTO [dbo].[Conta](IdCliente, ValorSaldoInicial, ValorDebito, ValorCredito, DataSaldo, DataAbertura, Ativo)
						   VALUES(@IdCliente, @ValorSaldoInicial, @ValorDebito, @ValorCredito, GETDATE(), GETDATE(), 1)
		
		--Checar se houve inser��o
		IF @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarConta]
	@IdConta INT
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Conta.sql
		Objetivo..............:	Procedure para desativar uma conta
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_DesativarConta] 1

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso	
								1 - Erro: O IdConta n�o existe
	*/
	BEGIN
		
		--Checar se o Id da conta existe
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Conta]
						WHERE Id = @IdConta)
			BEGIN
				RETURN 1
			END

		--Desativar conta
		UPDATE [dbo].[Conta]
			SET Ativo = 0
			WHERE Id = @IdConta

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContas]
	@IdCliente INT
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Conta.sql
		Objetivo..............:	Procedure para listar uma ou todas as contas
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:	DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListarContas]

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
		Retornos..............: 0 - Sucesso
	*/
	BEGIN
		SELECT	Id,
				IdCliente,
				ValorSaldoInicial,
				ValorCredito,
				ValorDebito,
				DataAbertura,
				DataAbertura,
				DataEncerramento,
				Ativo
			FROM [dbo].[Conta] WITH(NOLOCK)
			WHERE Id = ISNULL(@IdCliente, IdCliente)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarMovimentacaoConta]
	@IdConta INT = NULL,
	@PeriodoDia SMALLINT
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Conta.sql
		Objetivo..............:	Procedure para listar a movimenta��o de uma ou mais contas
		Autor.................:	Jo�o Victor Maia
		Data..................:	10/05/2024
		Ex....................:	DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListarMovimentacaoConta] NULL, 1
									select * from Lancamento
									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
		Retornos..............: 0 - Sucesso
	*/
	BEGIN
		SELECT	Id,
				IdConta,
				IdTipo,
				IdTransferencia,
				IdDespesa,
				TipoOperacao,
				Valor,
				NomeHistorico,
				DataLancamento
			FROM [dbo].[Lancamento] WITH(NOLOCK)
			WHERE	IdConta = ISNULL(@IdConta, IdConta)
					AND DATEDIFF(DAY, DataLancamento, GETDATE()) <= @PeriodoDia
	END
GO