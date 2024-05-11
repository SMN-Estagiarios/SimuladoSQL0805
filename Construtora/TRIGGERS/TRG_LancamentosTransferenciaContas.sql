CREATE OR ALTER TRIGGER [dbo].[TRG_LancamentoTransferenciaContas]
		ON [dbo].[Transferencia]
		FOR INSERT
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_LancamentoTransferenciaContas.sql
		Objetivo.............:	Lançamento de débito na conta débito e lançamento de crédito na conta crédito da transferência 
		Autor................:	Gustavo Targino
		Data.................:	10/05/2024
		Ex...................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DataInicio DATETIME = GETDATE();

									SELECT * FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * FROM [dbo].[Lancamento] WITH(NOLOCK)

									EXEC [dbo].[SP_RealizarTransferencia] 1, 2, 5000, 'Pagamento'
									
									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo
									
									SELECT  * FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * FROM [dbo].[Lancamento] WITH(NOLOCK)
								ROLLBACK TRAN
	
		*/
	BEGIN
			
			DECLARE @IdTransferencia INT,
					@IdContaCredito INT,
					@IdContaDebito INT,
					@Valor DECIMAL(15,2),
					@NomeReferencia VARCHAR(200), 
					@Data DATETIME,
					@TipoLancamento INT = 1, -- Tipo de lançamento que corresponde transferência
					@IdLancamentoInserido INT

	   		-- Recuperando os dados inseridos em transferência
			SELECT  @IdTransferencia = Id,
					@IdContaCredito = IdContaCredito,
					@IdContaDebito = IdContaDebito, 
					@Valor = Valor,
					@NomeReferencia = NomeHistorico,
					@Data = DataTransferencia   
				FROM INSERTED 		

				
			-- Inserindo lançamento para a conta débito
			INSERT INTO Lancamento (	
										IdConta,
										IdTipo,
										TipoOperacao,
										Valor,
										IdTransferencia,
										Datalancamento,
										NomeHistorico
									)
						VALUES
									(
										@IdContaDebito, 
										@TipoLancamento,
										'D', 
										@Valor,
										@IdTransferencia,
										@Data, 
										@NomeReferencia
									)

			-- Checagem de erro
			IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				RAISERROR('Erro ao inserir lançamento para a conta de débito', 16, 1)

			-- Inserindo lançamento para a conta crédito
			INSERT INTO Lancamento (	
									 IdConta,
									 IdTipo,
									 TipoOperacao,
									 Valor,
									 IdTransferencia,
									 Datalancamento,
									 NomeHistorico
								   )
							VALUES
								   (
									 @IdContaCredito, 
									 @TipoLancamento,
									 'C', 
									 @Valor,
									 @IdTransferencia,
									 @Data, 
									 @NomeReferencia 
								   )

			-- Checagem de erro 	
			IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				RAISERROR('Erro ao inserir lançamento para a conta créditop', 16, 1)

	END
GO
