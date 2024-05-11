CREATE OR ALTER TRIGGER [dbo].[TRG_GerarLancamentosTransferenciaEntreContas]
	ON [dbo].[Transferencia]
	FOR INSERT
	AS
	/*
	Documentacao
	Arquivo Fonte............:	TRG_GerarLancamentosTransferenciaEntreContas.sql
	Objetivo.................:	Gera inserts na tabela de lancamentos mediante transferencias cadastradas 
								travado código idTipo para transferencias = 1
	Autor....................:	Danyel Targino
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DataInicio DATETIME = GETDATE();

									SELECT * FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * FROM [dbo].[Lancamento] WITH(NOLOCK)

									INSERT INTO Transferencia (IdContaCredito, IdContaDebito, Valor, NomeHistorico, DataTransferencia)
										VALUES	( 1, 2, 50, 'EXEMPLO', GETDATE())
									
									SELECT DATEDIFF(MILLISECOND, @DataInicio,GETDATE()) AS TempoExecucao
									
									SELECT * FROM [dbo].[Transferencia] WITH(NOLOCK)
									SELECT * FROM [dbo].[Lancamento] WITH(NOLOCK)
								
								ROLLBACK TRAN
	
	*/
	BEGIN
		--Declarando as variaveis 
		DECLARE @IdTransferencia INT,
				@IdContaCredito INT,
				@IdContaDebito INT,
				@VlrTransferencia DECIMAL(15,2),
				@NomeReferencia VARCHAR(200), 
				@DataTransferencia DATETIME,
				@TipoLancamento INT = 1, --id_tipolancamento travado em transferencia 
				@IdLancamentoInserido INT

		-- Setando de valores para casos de Insert
		SELECT  @IdTransferencia = i.Id,
				@IdContaCredito = i.IdContaCredito,
				@IdContaDebito = i.IdContaDebito, 
				@VlrTransferencia = i.Valor,
				@NomeReferencia = i.NomeHistorico,
				@DataTransferencia = i.DataTransferencia
			FROM inserted i

		-- Verificando se existe transferencia
		IF @IdTransferencia IS NOT NULL
			BEGIN	
				-- Inserindo lancamento na conta que esta transferindo 
				INSERT INTO Lancamento	(	
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
					RAISERROR('Erro na inclusão do lancamento de Débito', 16,1)

				INSERT INTO Lancamento	(
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
					RAISERROR('Erro na inclusão do lancamento de Crédito', 16,1)
					
			END

	END
GO