CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarTransferencia]
	@IdContaDebito INT,
	@IdContaCredito INT,
	@VlrTransf DECIMAL(15,2),
	@NomeReferencia VARCHAR(200)
	AS
	/* 
		Documenta��o
		Arquivo Fonte.....: Transferencia.sql
		Objetivo..........: Instanciar uma nova trasnfer�ncia entre contas
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
								SELECT * FROM [dbo].[Transferencia]

								EXEC @RET = [dbo].[SP_RealizarTransferencia] 1, 2, 2000, 'Teste'

								SELECT @RET AS RETORNO,
									   DATEDIFF(MILLISECOND,@Dat_init, GETDATE()) AS EXECU��O


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
									SELECT * FROM [dbo].[Transferencia]

							ROLLBACK TRAN

		Retornos........: 0 - Sucesso  
						  1 - Erro ao Transferir: Conta destino n�o existe no sistema
						  2 - Erro ao Transferir: Conta origem n�o existe no sistema
						  3 - Erro ao Transferir: O Valor da Transfer�ncia � maior do que o dispon�vel em conta 
						  4 - Erro ao Transferir: Impossivel fazer trasnfer�ncia para a mesma conta,
						  5 - Erro ao Transferir: Erro no processamento do insert

	*/
	BEGIN
		--declara��o de Vari�veis
		DECLARE @Data_Atual DATETIME = GETDATE()
		--Verifica se a conta que ser� enviada a transferencia existe
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id  = @IdContaCredito
						)
			BEGIN
				RETURN 1
			END
		
		--Verifica se a conta que receber� a transferencia existe
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Conta] WITH(NOLOCK)
								WHERE Id  = @IdContaDebito
						)
			BEGIN
				RETURN 2
			END


		--Verifica se o valor da transferencia � inferior ao valor de saldo
		IF(@VlrTransf > (SELECT [dbo].[FNC_CalcularSaldoAtualConta](@IdContaDebito, ValorSaldoInicial, ValorCredito,ValorDebito)
										FROM [dbo].[Conta] c WITH (NOLOCK)
										WHERE c.Id = @IdContaDebito )) 
			BEGIN
				RETURN 3
			END 

		--validacao de uma transferencia entre contas feitas para uma mesma conta 
		IF(@IdContaDebito = @IdContaCredito)
			BEGIN 
				RETURN 4
			END
		--Gerar Inserts em transfer�ncia
		ELSE
			BEGIN
					INSERT INTO [dbo].[Transferencia](IdContaCredito,IdContaDebito, Valor, 
														NomeHistorico,DataTransferencia, Estorno)
						VALUES						
													 (@IdContaCredito, @IdContaDebito,@VlrTransf,
														@Nomereferencia, @Data_Atual, 0)
			   --Erro ao processar o insert de transferencia
			   IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						RETURN 5
					END
				RETURN 0
			END
	END
GO


CREATE OR ALTER PROCEDURE [dbo].[Sp_RealizarEstornoTransferencia]
	@IdTransferencia INT 
	AS 
	/*
		Documenta��o
		Arquivo Fonte.....: Transferencia.sql
		Objetivo..........: atualiza registro de transferencia para informar que houve o estorno da transa��o 
		Autor.............: Adriel Alexander
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

							
								SELECT * FROM [dbo].[Transferencia]
								select * from conta

								EXEC @RET = [dbo].[RealizarEstornoTransferencia]5

								SELECT @RET AS RETORNO,
									   DATEDIFF(MILLISECOND,@Dat_init, GETDATE()) AS EXECU��O

									SELECT * FROM [dbo].[Transferencia]
									select * from conta

							ROLLBACK TRAN

		Retornos........: 0 - Sucesso  
						  1 - Erro ao estornar transferencia: Registro de transferencia n�o existe no sistema 
						  2 - Erro ao estornar : Conta origem n�o existe no sistema
						 

	*/
	BEGIN 
		--
		DECLARE @DataAtual DATETIME = GETDATE()
			
		--VERIFICA SE A TRANSFERENCIA EXISTE NO BANCO DE DADOS e Se ela foi feita a mais de 7 dias
		IF NOT EXISTS  (
						 SELECT TOP 1 1
								FROM [dbo].[Transferencia] WITH(NOLOCK)
								WHERE Id = @IdTransferencia
									  AND DATEDIFF(DAY, DataTransferencia, GETDATE()) < 7
						)
			BEGIN
				RETURN 1
			END
        --realiza��o do update do registro de Transferencia 
		UPDATE [dbo].[Transferencia] 
			SET Estorno = 1 
			WHERE Id = @IdTransferencia
		
		--VERIFICA SE HOUVE ERRO NO PROCESSO DE UPDATE 
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1 
				BEGIN
					RETURN 2
				END
			RETURN 0
	END

