USE DB_ConstrutoraLMNC
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtual]	(
															@IdConta INT = NULL, 
															@ValorSaldoInicial DECIMAL(10,2) = NULL, 
															@ValorCredito DECIMAL(10,2) = NULL, 
															@ValorDebito DECIMAL(10,2) = NULL
														)
	RETURNS  DECIMAL(10,2)
	AS 
	/*
	Documentacao
	Arquivo Fonte...: FNC_CalcularSaldoAtual.sql
	Objetivo........: Calcula o saldo atual da conta passada por parâmetro
	Autor...........: Olívio Neto
	Data............: 10/05/2024
	Ex..............: 
						DBCC DROPCLEANBUFFERS;
						DBCC FREEPROCCACHE;
								
						DECLARE @Dat_ini DATETIME = GETDATE()

						SELECT	[dbo].[FNC_CalcularSaldoAtual](1,NULL,NULL,NULL) AS Resultado,
								DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
	*/
	BEGIN
		--Verificar ID nulo
		IF(@IdConta IS NOT NULL)
			-- Recuperar Valores 
			BEGIN
				SELECT	@ValorSaldoInicial = ValorSaldoInicial,
						@ValorCredito = ValorCredito,
						@ValorDebito = ValorDebito
					FROM [dbo].[Conta] WITH(NOLOCK)
					WHERE Id = @IdConta
			END
		--Caso o IdConta seja nulo, usara os demais valores passados nos parametros
		RETURN @ValorSaldoInicial + @ValorCredito - @ValorDebito
	END
GO