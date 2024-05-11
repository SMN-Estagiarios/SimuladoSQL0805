USE DB_ConstrutoraLMNC;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirConta]
	@IdCliente INT
	AS 
	/*
	Documentacao
	Arquivo Fonte...: Conta.sql
	Objetivo........: Cria uma conta no banco de dados
	Autor...........: Olivio Freitas
	Data............: 10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
							DBCC FREESYSTEMCACHE('ALL');

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT	* FROM [dbo].[Conta]

							EXEC @RET = [dbo].[SP_InserirConta] 0

							SELECT	* FROM [dbo].[Conta]

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN

	RETORNO.........:
					00 - Sucesso
					01 - Erro ao criar conta
	*/
	BEGIN
		-- Cria��o de um novo registro de Conta
		INSERT INTO [dbo].[Conta]	(
										IdCliente,
										ValorSaldoInicial,
										ValorCredito,
										ValorDebito,
										DataSaldo,
										DataAbertura,
										DataEncerramento,
										Ativo
									) 
						VALUES
									(
										@IdCliente,
										0,
										0,
										0,
										GETDATE(),
										GETDATE(),
										NULL,
										1
									);

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarConta]
	@IdConta INT
	AS 
	/*
	Documentacao
	Arquivo Fonte...: Conta.sql
	Objetivo........: Desativa uma conta do banco de dados
	Autor...........: Olivio Freitas
	Data............: 10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
							DBCC FREESYSTEMCACHE('ALL');

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT	* FROM [dbo].[Conta]

							EXEC @RET = [dbo].[SP_DesativarConta] 1

							SELECT	* FROM [dbo].[Conta]

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN

	RETORNO.........:
						0 - Sucesso
						1 - A conta nao existe
						2 - ERRO - Nao foi possivel desativar a conta
	*/
	BEGIN
		-- Verificacao se a conta passada por parametro existe
		IF NOT EXISTS(	SELECT TOP 1 1
							FROM [dbo].[Conta] WITH(NOLOCK)
							WHERE Id = @IdConta)
			BEGIN
				RETURN 1
			END

		-- Atualizacao do atributo 'Ativo' para FALSE
		UPDATE [dbo].[Conta]
			SET Ativo = 0,
				DataEncerramento = GETDATE()
			WHERE Id = @IdConta

		-- Tratamento de erros
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 2
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSaldoAtual]
	@Id_Conta INT = NULL
	AS 
	/*
	Documentacao
	Arquivo Fonte...: Conta.sql
	Objetivo........: Lista o saldo atual da conta passada por parametro
	Autor...........: Olivio Freitas
	Data............: 10/05/2024
	Ex..............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
							DBCC FREESYSTEMCACHE('ALL');

							DECLARE	@RET INT, 
									@Dat_init DATETIME = GETDATE()

							EXEC @RET = [dbo].[SP_ListarSaldoAtual] 1

							SELECT	@RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN
	*/
	
	BEGIN
		SELECT  Id AS IdConta,
				[dbo].[FNC_CalcularSaldoAtual](@Id_Conta, ValorSaldoInicial, ValorCredito,ValorDebito)
		FROM [dbo].[Conta]
		WHERE Id = COALESCE(@Id_Conta, Id)
	END
GO 


CREATE OR ALTER PROCEDURE [dbo].[SP_ListarFluxoDeCaixa]
	@DataInicio DATE = NULL,
	@DataTermino DATE = NULL
AS
	/*
		Documentacao
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Lista o fluxo de caixa diario da Construtora. O id da conta está setado como 0 (Conta da construtora)
		Autor.............: Olivio Freitas
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
		-- Variaveis de tempo
		DECLARE @DataAtual DATE = GETDATE(),
				@MesPassado DATE

		-- Data do mes passado
		SET @MesPassado = DATEADD(MONTH, -1, @DataAtual)

		-- Se data inicio for nulo, usar o dia 1 do mes passado
		IF @DataInicio IS NULL	
			BEGIN
				SET @DataInicio = DATEFROMPARTS(YEAR(@MesPassado), MONTH(@MesPassado), 1);
			END

		-- Se data termino for nulo, usar a data da chamada da procedure
		IF @DataTermino IS NULL
			BEGIN 
				SET @DataTermino = @DataAtual	
			END

		-- Tabela temporaria com as datas do periodo
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
		-- Excluindo tabela temporaria
		DROP TABLE #TabelaData
	END
GO