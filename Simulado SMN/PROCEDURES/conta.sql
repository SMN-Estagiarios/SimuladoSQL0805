CREATE OR ALTER PROCEDURE [dbo].[SP_InserirConta]
	@IdCliente INT
	AS
	/*
		Documenta��o
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Inserir uma nova conta.
		Autor.............: Grupo Estagi�rios SMN
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
										@DataInicio DATETIME = GETDATE()

								SELECT * 
									FROM [dbo].[Conta]
								SELECT * 
									FROM [dbo].[Cliente]

								EXEC @RET = [dbo].[SP_InserirConta] 5

								SELECT	@RET AS Retorno,
										DATEDIFF (MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

								SELECT * 
									FROM [dbo].[Conta]
								SELECT * 
									FROM [dbo].[Cliente]
							
							ROLLBACK TRAN
							Retorno..............: 
													0 - Sucesso
													1 - Erro cliente n�o cadastrado.
													2 - Erro conta n�o cadastrada.
													3 - Erro ao inserir uma nova conta.

	*/
	BEGIN
		-- Declarando as variaveis
		DECLARE @DataAtual DATETIME = GETDATE()
		
		-- Verificar se o cliente est� cadastrado
		IF NOT EXISTS	(SELECT TOP 1 1
							FROM [dbo].[Cliente] WITH (NOLOCK)
							WHERE Id = @IdCliente
						)
			BEGIN
				PRINT 'ERRO 1'
				RETURN 1
			END
		
		-- Verificando se a conta est� cadastrada
		IF NOT EXISTS	(SELECT TOP 1 1
							FROM [dbo].[Conta] WITH (NOLOCK)
							WHERE Id = @IdCliente
						)
		BEGIN
			PRINT 'ERRO 2'
			RETURN 2
		END
		
		INSERT INTO [dbo].[Conta]	(	IdCliente,
										ValorSaldoInicial,
										ValorCredito,
										ValorDebito,
										DataSaldo,
										DataAbertura,
										DataEncerramento,
										Ativo
									)
			VALUES (@IdCliente, 0, 0, 0, @DataAtual, @DataAtual, NULL, 1)
		IF @@ROWCOUNT <> 1
			RETURN 3
		
		RETURN 0
	END
GO


CREATE OR ALTER PROCEDURE [dbo].[SP_ListarContas]
	@IdCliente INT = NULL
	AS
	/*
	Documenta��o
	Arquivo Fonte............:	Conta.sql
	Objetivo.................:	Listar contas
	Autor....................:	Danyel Targino
	Data.....................:	10/05/2024
	Ex.......................:	DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

								DECLARE @Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_ListarContas]

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
							
							Retornos..............: 
													0 - Sucesso
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
	
	RETURN 0

GO


CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarConta]
	@IdConta INT
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Conta.sql
		Objetivo..............:	Desativar uma conta
		Autor.................:	Danyel Targino
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()
									SELECT * 
										FROM [dbo].[Conta]

									EXEC @Ret = [dbo].[SP_DesativarConta] 3

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

									SELECT * 
										FROM [dbo].[Conta]
								
								ROLLBACK TRAN

								Retorno...............: 0 - Sucesso	
														1 - Erro: Conta inexistente
	*/
	BEGIN
		
		-- Verificar se o Id da conta existe
		IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Conta]
						WHERE Id = @IdConta)
			BEGIN
				RETURN 1
			END

		-- Desativando uma conta
		UPDATE [dbo].[Conta]
			SET Ativo = 0
			WHERE Id = @IdConta

		RETURN 0
	END
GO



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

								EXEC @RET = [dbo].[SP_ListarFluxoDeCaixa] NULL, NULL
							
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