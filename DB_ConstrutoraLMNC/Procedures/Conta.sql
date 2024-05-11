CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta]
	@IdCliente INT
	AS 
	/*
	Documentacao
	Arquivo Fonte..: Contas.sql
	Objetivo.......: Cria uma conta na tabela [dbo].[Contas]
	Autor..........: OrcinoNeto
	Data...........: 10/05/2024
	Ex.............: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

								SELECT	Id,
											IdCliente,
											ValorSaldoInicial,
											ValorCredito,
											ValorDebito,
											DataSaldo,
											DataAbertura,
											DataEncerramento,
											Ativo
									FROM [dbo].[Conta]

							EXEC @RET = [dbo].[SP_InserirNovaConta] 1

									SELECT	Id,
												IdCliente,
												ValorSaldoInicial,
												ValorCredito,
												ValorDebito,
												DataSaldo,
												DataAbertura,
												DataEncerramento,
												Ativo
										FROM [dbo].[Conta]

								SELECT @RET AS RETORNO,
											DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN

		--	RETORNO   --
			0 - Sucesso
			1 - Erro ao Inserir Conta 
																
	*/
	BEGIN
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
			VALUES	(	
						@IdCliente,
						0,
						0,
						0,
						GETDATE(),
						GETDATE(),
						NULL,
						1
					);

		IF @@ROWCOUNT <> 0
			RETURN 1
		ELSE
			RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioExtratoConta]
    @IdConta INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: Conta.sql
	Objetivo..........: Mostra o relatorio do extrato da conta.
	Autor.............: OrcinoNeto
	Data..............: 10/05/2024
	Ex................: 
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()                            
                        
							EXEC @RET =[dbo].[SP_RelatorioExtratoConta] 1

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN
	RETORNO...........: 
		0 - Sucesso
		1 - Erro
	*/
BEGIN   

    SELECT	l.Id,
			l.IdConta,
			cl.Nome,
			l.DataLancamento,                
			l.TipoOperacao,
			l.NomeHistorico,
			SUM(CASE WHEN l.TipoOperacao = 'C' THEN l.Valor ELSE 0 END) AS Entradas,
			SUM(CASE WHEN l.TipoOperacao = 'D' THEN l.Valor ELSE 0 END) AS Saidas			
		FROM [dbo].[Lancamento] l WITH(NOLOCK)
			INNER JOIN [dbo].[Conta] ct WITH(NOLOCK) 
				ON l.IdConta = ct.Id
			INNER JOIN [dbo].[Cliente] cl WITH(NOLOCK) 
				ON cl.Id = ct.IdCliente
		WHERE 
			l.IdConta = @IdConta
		GROUP BY l.Id,
				 l.IdConta,
				 cl.Nome,
				 l.DataLancamento,                
				 l.TipoOperacao,
				 l.NomeHistorico
		ORDER BY l.DataLancamento DESC

	IF @@ROWCOUNT <> 0
		RETURN 0
	RETURN 1
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
		Autor.............: Grupo Estagiarios SMN
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

		-- Variaveis de tempo
		DECLARE @DataAtual DATE = GETDATE(),
				@MesPassado DATE

		-- Data do mes passado
		SET @MesPassado = DATEADD(MONTH, -1, @DataAtual)

		-- Se data in�cio for nulo, usar o dia 1 do mes passado
		IF @DataInicio IS NULL	
			BEGIN
				SET @DataInicio = DATEFROMPARTS(YEAR(@MesPassado), MONTH(@MesPassado), 1);
			END

		-- Se data termino for nulo, usar a data da chamada da procedure
		IF @DataTermino IS NULL
			BEGIN 
				SET @DataTermino = @DataAtual	
			END

		-- Tabela temporaria com as datas do per�odo
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
		-- Excluindo tabela tempororia
		DROP TABLE #TabelaData
END