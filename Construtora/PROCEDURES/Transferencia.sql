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

								SELECT Id,
								       IdCliente,
									   ValorSaldoInicial,
									   ValorCredito,
									   ValorDebito,
									   DataSaldo,
									   DataAbertura,
									   DataEncerramento
									   FROM [dbo].[Conta] WITH(NOLOCK)
	
								SELECT TOP 20 Id,
											  IdConta,
											  IdTipo,
											  IdTransferencia,
											  IdDespesa,
											  TipoOperacao,
											  Valor,
											  NomeHistorico,
										      DataLancamento
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										ORDER BY DataLancamento DESC

								EXEC @RET = [dbo].[SP_RealizarTransferencia] 1, 2, 2000, 'Teste'

								SELECT @RET AS RETORNO,
									   DATEDIFF(MILLISECOND,@Dat_init, GETDATE()) AS EXECUÇÂO


								SELECT Id,
								       IdCliente,
									   ValorSaldoInicial,
									   ValorCredito,
									   ValorDebito,
									   DataSaldo,
									   DataAbertura,
									   DataEncerramento
									   FROM [dbo].[Conta] WITH(NOLOCK)
	
								SELECT TOP 20 Id,
											  IdConta,
											  IdTipo,
											  IdTransferencia,
											  IdDespesa,
											  TipoOperacao,
											  Valor,
											  NomeHistorico,
										      DataLancamento
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										ORDER BY DataLancamento DESC

							ROLLBACK TRAN

		Retornos........: 0 - Sucesso  
						  1 - Erro ao Transferir: Uma das contas não existe 
						  2 - Erro ao Transferir: O Valor da Transferência é maior do que o disponível em conta 
						  3 - Erro ao Transferir: Impossivel fazer trasnferência para a mesma conta,
						  4 - Erro ao Transferir: Erro no processamento do insert

	*/
	BEGIN
		--declaração de Variáveis
		DECLARE @Data_Atual DATETIME = GETDATE()
		--Verifica se as contas Existem
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id  = @IdContaCredito
									OR Id = @IdContaDebito
						)
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
			   --Erro ao processar o insert de transferencia
			   IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						RETURN 4
					END
				RETURN 0
			END
	END
GO
