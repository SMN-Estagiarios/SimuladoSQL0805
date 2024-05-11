CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtualConta]	(
																	@IdConta INT = NULL, 
																	@ValorSldInicial DECIMAL(10,2) = NULL, 
																	@ValorCredito DECIMAL(10,2) = NULL, 
																	@ValorDebito DECIMAL(10,2) = NULL
																)
	 RETURNS  DECIMAL(10,2)
	 AS 
	 /*
		Documentação
		Arquivo Fonte.....: FNC_CalcularSaldoAtualConta.sql
		Objetivo..........: Calcular o saldo atual com base no identificar de uma conta ou pelos valores passados
		Autor.............: Odlavir Florentino 
 		Data..............: 10/05/2024
		Ex................: DBCC DROPCLEANBUFFERS
							DBCC FREEPROCCACHE
							DBCC FREESYSTEMCACHE('ALL')
								
							DECLARE @DATA_INI DATETIME = GETDATE()

							SELECT	[dbo].[FNC_CalcularSaldoAtualConta](NULL,200,500,100) AS Resultado

							SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		  --Verificar ID nulo
		IF(@IdConta IS NOT NULL)
			--Recuperar Valores 
			BEGIN
				SELECT @ValorSldInicial = ValorSaldoInicial,
					   @ValorCredito = ValorCredito,
					   @ValorDebito = ValorDebito
					FROM [dbo].[Conta] WITH(NOLOCK)
					WHERE Id = @IdConta
			END
			--Caso do Id nulo, vai usar os demais valores passados como parâmetros
		RETURN @ValorSldInicial + @ValorCredito - @ValorDebito
	END
GO