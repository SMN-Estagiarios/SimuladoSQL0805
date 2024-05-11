CREATE OR ALTER PROCEDURE [dbo].[SP_CriarLancamento]
	@IdConta INT,
	@IdTipoLanc INT,
	@IdTransf INT,
	@IdDespesa INT,
	@TipoOperacao CHAR(1),
	@Valor DECIMAL(10,2),
	@DataLancamento DATETIME,
	@NomeHistorico VARCHAR(200)
	AS
	/*
	Documenta��o
	Arquivo Fonte..: Lancamentos.sql
	Objetivo..........: Inserir Dados na Tabela Lancamentos, n�o permitir lancamentos futuros.
							Se @DataLancamento for NULL recebe GetDate().
	Autor..............: Ol�vio Freitas
	Data...............: 10/05/2024
	Ex..................:	
							BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT
								SELECT TOP 10 * FROM Lancamento
	
								EXEC @RET = [dbo].[SP_CriarLancamento]	1, 1, null, null,'D',200, null, 'Dinheiro de Pinga'
								
								SELECT TOP 10 * FROM Lancamento
	
								SELECT @RET AS RETORNO
	
								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

		Lista de retornos:
                1: Valor de Lan�amento tem que ser maior que 0.
                2: N�o permitido lan�amentos futuros.
                3: N�o permitido lan�amentos de meses diferentes.
                4: Erro ao inserir lan�amento.
	*/

	BEGIN
		DECLARE	@DataAtual DATETIME = GETDATE(),
						@IdLancamento INT;

		--Verifica��o se o lancamento � maior que 0.
		IF @Valor < 0
			BEGIN
				 RETURN 1
			END

		--Verificando se o lan�amento � com data futura.
		IF @DataLancamento > DATEADD(MINUTE, DATEDIFF(MINUTE, @DataLancamento, @DataAtual), @DataLancamento)
			BEGIN
				 RETURN 2
			END

		--Verificando se o lan�amento � do mes anterior.
		IF DATEDIFF(MONTH,@DataLancamento, @DataAtual) <> 0
			BEGIN
				RETURN 3
			END

		--Inserindo Lan�amento
		INSERT INTO [dbo].[Lancamento]	(
																IdConta,
																IdTipo,
																IdTransferencia,
																IdDespesa,
																TipoOperacao,
																Valor,
																DataLancamento,
																NomeHistorico
															)
			VALUES (
							@IdConta,
							@IdTipoLanc,
							@IdTransf,
							@IdDespesa,
							@TipoOperacao,
							@Valor,
							ISNULL(@DataLancamento,@DataAtual),
							@NomeHistorico
						)

			RETURN 0
	END
GO