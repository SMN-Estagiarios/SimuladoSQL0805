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

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								EXEC @RET = [dbo].[SP_ListarFluxoDeCaixa]NULL, NULL
							
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
CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioExtratoContas]
	@Ano INT,
	@Mes INT
AS
	/*
		Documentação
		Arquivo Fonte.....: Conta.sql
		Objetivo..........: Listar o extrato das contas com base no último mês
		Autor.............: Gustavo Targino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@DataInicio DATETIME = GETDATE()

								EXEC [dbo].[SP_RelatorioExtratoContas] 2024, 04
								
								SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo

							ROLLBACK TRAN
	*/
	 BEGIN
		DECLARE @DataInicio DATE,
				@DataFim DATE

		-- Usando o dia 1 do mês e ano solicitado até o último dia desse mês e desse ano
		SET @DataInicio = DATEFROMPARTS(@Ano, @Mes, 01)
		SET @DataFim = EOMONTH(@DataInicio) 

		-- Tabela de calendário
		CREATE TABLE #TabelaData(
									DataSaldo DATE
								)
				
		--Populando tabela de calendário
		WHILE @DataInicio <= @DataFim
			BEGIN
				INSERT INTO #TabelaData(DataSaldo) 
					VALUES	(@DataInicio)
				SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
			END;

		WITH CalculoCreditoDebito AS (
										SELECT  ISNULL(SUM(CASE WHEN TipoOperacao = 'C' THEN Valor ELSE 0 END), 0) AS Valor_Credito,
												ISNULL(SUM(CASE WHEN TipoOperacao = 'D' THEN Valor ELSE 0 END), 0) AS Valor_Debito,
												td.DataSaldo,
												C.Id AS Id_Conta
											FROM #TabelaData td
												CROSS JOIN [dbo].[Conta] C WITH(NOLOCK)
												LEFT JOIN [dbo].[Lancamento] la WITH(NOLOCK)
													ON DATEDIFF(DAY, td.DataSaldo, la.DataLancamento) = 0 
													AND C.Id = la.IdConta
											WHERE  td.DataSaldo >= C.DataAbertura
											GROUP BY td.DataSaldo, c.Id
								   	)	
											SELECT  Id_Conta,
													ISNULL(LAG(Saldo_Final, 1, 0) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo), 0) AS Saldo_Inicial,
													Credito,
													Debito,
													Saldo_Final,
													DataSaldo
												FROM (
														SELECT  Valor_Credito Credito,
																Valor_Debito Debito,
																DataSaldo DataSaldo,
																Id_Conta Id_Conta,
																SUM(Valor_Credito - Valor_Debito) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo) AS Saldo_Final
															FROM CalculoCreditoDebito
									)x				
END	