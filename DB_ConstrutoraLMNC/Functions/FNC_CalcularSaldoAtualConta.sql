CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtualConta](
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
		Objetivo..........: Listar o saldo atual de todas as contas ou uma conta especifica na tabela Conta
		Autor.............: OrcinoNeto
 		Data..............: 10/05/2024
		Ex................: 
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
								
							DECLARE @Dat_ini DATETIME = GETDATE()
							SELECT	[dbo].[FNC_CalcularSaldoAtualConta](1,NULL,NULL,NULL) AS Resultado,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
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