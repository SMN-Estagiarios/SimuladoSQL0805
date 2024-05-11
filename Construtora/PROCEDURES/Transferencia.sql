CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarTransferencia]
	@IdContaDebito INT,
	@IdContaCredito INT,
	@ValorTransferencia DECIMAL(15,2),
	@NomeReferencia VARCHAR(200)
	AS
	/* 
		Documentação
		Arquivo Fonte.....: Transferencia.sql
		Objetivo..........: Realizar uma transferencia entre contas
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE('ALL')

								DECLARE @Retorno INT, 
										@DATA_INI DATETIME = GETDATE()

								SELECT *
									FROM [dbo].[Conta] WITH(NOLOCK)
	
								SELECT TOP 20 *
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										ORDER BY DataLancamento DESC

								EXEC @Retorno = [dbo].[SP_RealizarTransferencia] 1, 2, 1500, 'Pagamento do alugel'

								SELECT	@Retorno AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao
								
								SELECT  *
									FROM [dbo].[Conta] WITH(NOLOCK)

								SELECT TOP 20 *
									FROM [dbo].[Lancamento] WITH(NOLOCK)
									ORDER BY DataLancamento DESC
							ROLLBACK TRAN

							--- Retornos ---
							00: Sucesso  
							01: Erro, uma das contas não existe 
							02: Erro, o valor da transferência é maior do que o disponível em conta 
							03: Erro, nao e possivel realizar transferencia para a mesma conta
							04: Erro, nao foi possivel realizar a transferencia

	*/
	BEGIN
		--Declaração de Variáveis
		DECLARE @DataAtual DATETIME = GETDATE()

		--Verifica se as contas existem
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id  = @IdContaCredito
									OR Id = @IdContaDebito
						)
			RETURN 1;

		--Verifica se o valor da transferencia é inferior ao valor de saldo
		IF	(@ValorTransferencia >	(
										SELECT [dbo].[FNC_CalcularSaldoAtualConta](@IdContaDebito, ValorSaldoInicial, ValorCredito, ValorDebito)
											FROM [dbo].[Conta] c WITH (NOLOCK)
											WHERE c.Id = @IdContaDebito 
									)
			)
			RETURN 2;

		--Validar se a transferencia e feita para a mesma conta
		IF @IdContaDebito = @IdContaCredito
			RETURN 3;
		ELSE
			BEGIN
				INSERT INTO [dbo].[Transferencia]	(IdContaCredito,IdContaDebito, Valor, NomeHistorico, DataTransferencia)
					VALUES							(@IdContaCredito, @IdContaDebito,@ValorTransferencia, @Nomereferencia, @DataAtual)

				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					RETURN 4;

				RETURN 0
			END
	END
GO
