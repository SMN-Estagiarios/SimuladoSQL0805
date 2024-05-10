CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarTransferencia]
	@IdContaDebito INT,
	@IdContaCredito INT,
	@VlrTransf DECIMAL(15,2),
	@NomeReferencia VARCHAR(200)
	AS
	/* 
		Documentação
		Arquivo Fonte.....: Transferencia.sql
		Objetivo..........: Instanciar uma nova trasnferência entre contas
		Autor.............: Adriel Alexander
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
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
						  1 - Erro ao Transferir: Uma das contas não existe 
						  2 - Erro ao Transferir: O Valor da Transferência é maior do que o disponível em conta 
						  3 - Erro ao Transferir: Impossivel fazer trasnferência para a mesma conta

	*/
	BEGIN
		--declaração de Variáveis
		DECLARE @Data_Atual DATE = GETDATE()
		--Verifica se as contas Existem
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id  = @IdContaCredito
									OR Id = @IdContaDebito)
			BEGIN
				RETURN 1
			END

		--Verifica se o valor da transferencia é inferior ao valor de saldo
		IF(@VlrTransf > (SELECT [dbo].[FNC_CalcularSaldoAtualConta](@IdContaDebito, ValorSaldoInicial, ValorCredito,ValorDebito)
										FROM [dbo].[Conta] c WITH (NOLOCK)
										WHERE c.Id = @IdContaDebito )) 
			BEGIN
				RETURN 2
			END

		--validacao de uma transferencia entre contas feitas para uma mesma conta 
		IF(@IdContaDebito = @IdContaCredito)
			BEGIN 
				RETURN 3
			END
		--Gerar Inserts em transferência
		ELSE
			BEGIN
					INSERT INTO [dbo].[Transferencia](IdContaCredito,IdContaDebito, Valor, 
														NomeHistorico,DataTransferencia)
						VALUES						
													 (@IdContaCredito, @IdContaDebito,@VlrTransf,
														@Nomereferencia, @Data_Atual)
				RETURN 0
			END
	END
GO
