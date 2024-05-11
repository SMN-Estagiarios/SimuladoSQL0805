CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta]
	@IdCliente INT
	AS 
	/*
		Documentacao
		Arquivo Fonte...: Conta.sql
		Objetivo........: Cria um novo Registro de Conta para um cliente ja existente
		Autor...........: Adriel Alexander de Sousa
		Data............: 10/05/2024
		Ex..............: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;
								DBCC FREESYSTEMCACHE('ALL');

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								
								SELECT Id,
								       IdCliente,
									   ValorSaldoInicial,
									   ValorCredito,
									   ValorDebito,
									   DataSaldo,
									   DataAbertura,
									   DataEncerramento
									   FROM [dbo].[Conta] WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_InserirNovaConta] 0

								
								SELECT Id,
								       IdCliente,
									   ValorSaldoInicial,
									   ValorCredito,
									   ValorDebito,
									   DataSaldo,
									   DataAbertura,
									   DataEncerramento
									   FROM [dbo].[Conta] WITH(NOLOCK)

								SELECT	@RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

		Retorno.........: 0 - Sucesso
						  1 - Erro ao cadastrar nova conta: Cliente não existe,
						  2 - Erro ao cadastrar nova conta: Erro de procesamento no insert
																
	*/
	BEGIN
		--Declaração de variável
		DECLARE @DataAtual DATE = GETDATE()
		
		--verifica se o id de cliente existe no banco de dados 
		IF NOT EXISTS (
						SELECT TOP 1 1
								FROM [dbo].[Cliente] c WITH(NOLOCK)
								WHERE Id = @IdCliente
					  ) 
			BEGIN 
				RETURN 1
			END
		-- Criação de um novo registro de Conta para cliente existente
		INSERT INTO [dbo].[Conta]	(IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo,
										DataAbertura,  Ativo) 
			VALUES
									(@IdCliente, 0, 0, 0, @DataAtual,
										@DataAtual, 1);

		-- Verifica se houve erro durante o insert de dados
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					RETURN 2
				END
			ELSE
				RETURN 0
	END
GO


CREATE OR ALTER PROCEDURE [dbo].[SP_DesativarConta]
	@IdConta INT
	AS 
	/*
		Documentacao
		Arquivo Fonte...: Conta.sql
		Objetivo........: Desativa uma conta que não possua saldo Negativo ou Disponível 
		Autor...........: Adriel Alexander de Sousa
		Data............: 10/05/2024
		Ex..............: 
							BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

									SELECT Id,
										   IdCliente,
										   ValorSaldoInicial,
										   ValorCredito,
										   ValorDebito,
										   DataSaldo,
										   DataAbertura,
										   DataEncerramento
										   FROM [dbo].[Conta] WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_DesativarConta] 1

									SELECT Id,
										   IdCliente,
										   ValorSaldoInicial,
										   ValorCredito,
										   ValorDebito,
										   DataSaldo,
										   DataAbertura,
										   DataEncerramento
										   FROM [dbo].[Conta] WITH(NOLOCK)

								SELECT	@RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

		Retorno.........:
							0 - Sucesso
							1 - Erro ao desativar a conta: Cliente não existe
							2 - Erro ao desativar a conta: - Nao foi possivel desativar a conta
	*/
	BEGIN
		DECLARE @SaldoAtual DECIMAL(10,2)

		SELECT @SaldoAtual = [dbo].[FNC_CalcularSaldoAtualConta](@idConta, NULL, NULL,NULL)

		-- Verificacao se a conta  existe
		IF NOT EXISTS(	
						SELECT TOP 1 1
							FROM [dbo].[Conta] WITH(NOLOCK)
							WHERE Id = @IdConta
					 )
			BEGIN
				RETURN 1
			END
		--Verifica se o saldo atual se existe saldo devedor ou disponível
		IF @SaldoAtual <> 0
			BEGIN
				RETURN 2
			END

		-- Atualizacao do atributo 'Ativo' para FALSE
		UPDATE [dbo].[Conta]
			SET Ativo = 0,
				DataEncerramento = GETDATE()
			WHERE Id = @IdConta

		-- Verifica se houve ao atualizar o registro
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END
		ELSE
			RETURN 0
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSaldoAtual]
	@Id_Conta INT = NULL
	AS 
	/*
	Documentacao
	Arquivo Fonte...: Conta.sql
	Objetivo........: Lista o saldo atual da conta passada ou retorna o saldo de todas as contas se o id for null
	Autor...........: Adriel Alexander
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
		
		--Consulta no banco referente ao saldo de todas as contas 
		SELECT  Id AS IdConta,
				[dbo].[FNC_CalcularSaldoAtual](@Id_Conta, ValorSaldoInicial, ValorCredito,ValorDebito) AS Saldo
		FROM [dbo].[Conta]
		WHERE Id = ISNULL(@Id_Conta, Id)
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

