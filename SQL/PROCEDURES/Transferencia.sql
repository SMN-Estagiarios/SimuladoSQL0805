CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarTransferencia]
	@IdContaDeb INT,
	@IdContaCred INT,
	@ValorTransf DECIMAL(15,2),
	@NomeReferencia VARCHAR(200)
	AS
	/* 
	Documenta��o
	Arquivo Fonte...: Transferencia.sql
	Objetivo........: Realiza transferencia entre contas
	Autor...........: Olivio Freitas
	Data............: 10/05/2024
	Ex..............: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT ValorSaldoInicial,
									ValorCredito,
									ValorDebito,
									DataSaldo,
									DataAbertura,
									DataEncerramento,
									Ativo
								FROM [dbo].[Conta] WITH(NOLOCK)
	
							SELECT TOP 20 Id,
											IdConta,
											IdTipo,
											IdTransferencia,
											Valor,
											TipoOperacao,
											DataLancamento,
											NomeHistorico
									FROM [dbo].[Lancamento]
									ORDER BY DataLancamento DESC

							EXEC @RET = [dbo].[SP_RealizarTransferencia] 1, 2, 2000, 'Teste'

							SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUcaO
								
							SELECT  ValorSaldoInicial,
									ValorCredito,
									ValorDebito,
									DataSaldo,
									DataAbertura,
									DataEncerramento,
									Ativo
								FROM [dbo].[Conta] WITH(NOLOCK)

							SELECT TOP 20 Id,
										IdConta,
										IdTipo,
										IdTransferencia,
										Valor,
										TipoOperacao,
										DataLancamento,
										NomeHistorico
								FROM [dbo].[Lancamento]
								ORDER BY DataLancamento DESC

						ROLLBACK TRAN

	Retornos........: 0 - Sucesso  
						1 - Erro ao Transferir: Uma das contas n�o existe 
						2 - Erro ao Transferir: O Valor da Transfer�ncia � maior do que o dispon�vel em conta 
						3 - Erro ao Transferir: Impossivel fazer trasnfer�ncia para a mesma conta

	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Data_Atual DATETIME = GETDATE()

		-- Verifica se as contas passadas por parametro existem
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Conta] WITH(NOLOCK)
							WHERE Id  = @IdContaCred
								OR Id = @IdContaDeb)
			BEGIN
				RETURN 1
			END

		-- Verifica se o valor da transferencia e maior do que valor de saldo
		IF(@ValorTransf > (SELECT [dbo].[FNC_CalcularSaldoAtual](@IdContaDeb, ValorSaldoInicial, ValorCredito,ValorDebito)
								FROM [dbo].[Conta] c WITH (NOLOCK)
								WHERE c.Id = @IdContaDeb )) 
			BEGIN
				RETURN 2
			END

		-- Validacao de uma transferencia entre contas feitas para uma mesma conta 
		IF(@IdContaDeb = @IdContaCred)
			BEGIN 
				RETURN 3
			END
		-- Gerar Inserts em transfer�ncia
		ELSE
			BEGIN
				INSERT INTO [dbo].[Transferencia]	(
														IdContaCredito,
														IdContaDebito,
														Valor, 
														NomeHistorico,
														DataTransferencia
													)
										VALUES
													(
														@IdContaCred,
														@IdContaDeb,
														@ValorTransf,
														@Nomereferencia,
														@Data_Atual
													)
				RETURN 0
			END
	END
GO