CREATE OR ALTER TRIGGER [dbo].[TRG_GerarLancamentosTransferenciaEntreContas]
	ON [dbo].[Transferencia]
	FOR INSERT
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte.....:	TRG_GerarLancamentosTransferenciaEntreContas.sql
		Objetivo............:	gera inserts na tabela de lancamentos mediante transferencias cadastradas 
									travado código para idTipo para transferencias = 1 
		Autor................:	Todos
		Data.................:	10/05/2024
		Ex....................:	
								BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT  *
										FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamento] WITH(NOLOCK)

									INSERT INTO Transferencia VALUES( 1, 2, 50, 'EXEMPLO', GETDATE())
									
									SELECT DATEDIFF(MILLISECOND,@DATA_INI,GETDATE()) AS Execução
									
									SELECT  *
										FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamento] WITH(NOLOCK)
								ROLLBACK TRAN
	
		*/
	BEGIN
			--Declaracao de Variáveis 
			DECLARE	@IdTransferencia INT,
							@IdContaCredito INT,
							@IdContaDebito INT,
							@VlrTransferencia DECIMAL(15,2),
							@NomeReferencia VARCHAR(200), 
							@DataTransferencia DATETIME,
							@TipoLancamento INT = 1, --id_tipolancamento travado em transferencia 
							@IdLancamentoInserido INT

	   		-- atribui��o de valores para casos de Insert
			SELECT @IdTransferencia = Id,
						@IdContaCredito = IdContaCredito,
						@IdContaDebito = IdContaDebito, 
						@VlrTransferencia = Valor,
						@NomeReferencia = NomeHistorico,
						@DataTransferencia = DataTransferencia   
				FROM inserted 		

			IF @IdTransferencia IS NOT NULL
				BEGIN	
					--inserção do lancamento para a conta que esta transferindo 
					INSERT INTO Lancamento(	
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
											@VlrTransferencia,
											@IdTransferencia,
											@DataTransferencia, 
											@NomeReferencia
										)
					--Verifica se houve erro ao inserir dados em Lancamentos 	
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de Débito', 16,1)
						END

					INSERT INTO Lancamento(	
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
											@VlrTransferencia,
											@IdTransferencia,
											@DataTransferencia, 
											@NomeReferencia 
										)

					--Verifica se houve erro ao inserir dados em Lancamentos 	
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de Crédito', 16,1)
						END
				END

	END
GO
