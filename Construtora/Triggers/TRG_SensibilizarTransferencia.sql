CREATE OR ALTER TRIGGER [dbo].[TRG_SensibilizarTransferencia]
	ON [dbo].[Transferencia]
	FOR INSERT
	AS 
	/*
		Documentação
		Arquivo Fonte.........:	TRG_SensibilizarTransferencia.sql
		Objetivo..............:	Sensibilizar a tabela conta após uma transferência
		Autor.................:	Rafael Mauricio
		Data..................:	10/05/2024
		Ex....................:	BEGIN TRAN
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS
									
									DECLARE @Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_RealizarTransferencia] 1, 2, 100, 'Teste'

									SELECT	Id,
											IdCliente,
											ValorSaldoInicial,
											ValorCredito,
											ValorDebito,
											DataSaldo
										FROM [dbo].[Conta] WITH(NOLOCK)
										WHERE Id IN (1, 2)

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
		Retornos..............: 0 - Sucesso
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @IdContaCredito INT,
				@IdContaDebito INT,
				@Valor DECIMAL(10,2)

		--Atribuir valor às variáveis
		SELECT	@IdContaCredito = IdContaCredito,
				@IdContaDebito = IdContaDebito,
				@Valor = Valor
			FROM Inserted

		--Sensibilizar conta crédito
		UPDATE [dbo].[Conta]
			SET ValorCredito += @Valor
			WHERE Id = @IdContaCredito
		
		--Sensibilizar conta débito
		UPDATE [dbo].[Conta]
			SET ValorDebito += @Valor
			WHERE Id = @IdContaDebito
	END
GO