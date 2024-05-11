CREATE OR ALTER PROCEDURE [dbo].[SP_InserirTransferencia]
	@IdContaCredito INT, 
	@IdContaDebito INT, 
	@Valor DECIMAL(10,2), 
	@NomeHistorico VARCHAR(200)
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Cliente.sql
		Objetivo..............:	Procedure para inserir uma nova transferência
								IdTipo em lançamento = 1 (Transferência)
		Autor.................:	João Victor Maia
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirTransferencia] 1, 2, 100, 'Teste'

									SELECT	Id,
											IdContaCredito,
											IdContaDebito,
											Valor,
											NomeHistorico,
											DataTransferencia
										FROM [dbo].[Transferencia] WITH(NOLOCK)
										WHERE Id = IDENT_CURRENT('Transferencia')

									SELECT	Id,
											IdConta,
											IdTipo,
											IdTransferencia,
											TipoOperacao,
											Valor,
											NomeHistorico,
											DataLancamento
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										WHERE IdTransferencia = IDENT_CURRENT('Transferencia')

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
	*/
	BEGIN

		--Declarar variável
		DECLARE @IdTransferencia TINYINT

		--Inserir transferência
		INSERT INTO [dbo].[Transferencia](IdContaCredito, IdContaDebito, Valor, NomeHistorico, DataTransferencia)
								   VALUES(@IdContaCredito, @IdContaDebito, @Valor, @NomeHistorico, GETDATE())
		
		--Atribuir valor à variável
		SET @IdTransferencia = SCOPE_IDENTITY()

		--Inserir lançamentos
		INSERT INTO [dbo].[Lancamento](IdConta, IdTipo, IdTransferencia, TipoOperacao, Valor, NomeHistorico, DataLancamento)
								VALUES(@IdContaCredito, 1, @IdTransferencia, 'C', @Valor, @NomeHistorico, GETDATE()),
									  (@IdContaDebito, 1, @IdTransferencia, 'D', @Valor, @NomeHistorico, GETDATE())
	END
GO