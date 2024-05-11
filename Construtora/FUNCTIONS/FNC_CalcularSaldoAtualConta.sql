CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtualConta](
														 @IdConta INT = NULL, 
														 @ValorSaldoInicial DECIMAL(10,2) = NULL, 
														 @ValorCredito DECIMAL(10,2) = NULL, 
														 @ValorDebito DECIMAL(10,2) = NULL
														)
	 RETURNS  DECIMAL(10,2)
	 AS 
	 /*
		Documenta��o
		Arquivo Fonte.....: FNC_CalcularSaldoAtualConta.sql
		Objetivo..........: Listar o saldo atual de uma ou de todas as contas
		Autor.............: Jo�o Victor Maia
 		Data..............: 10/05/2024
		Ex................: 
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
								
							DECLARE @Dat_ini DATETIME = GETDATE()

							SELECT	[dbo].[FNC_CalcularSaldoAtual](NULL,200,500,100) AS Resultado,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
	*/
	BEGIN

		  --Verificar se o Id existe
		IF(@IdConta IS NOT NULL)

			--Atribuir valores �s vari�veis
			BEGIN
				SELECT @ValorSaldoInicial = ValorSaldoInicial,
					   @ValorCredito = ValorCredito,
					   @ValorDebito = ValorDebito
					FROM [dbo].[Conta] WITH(NOLOCK)
					WHERE Id = @IdConta
			END

			--Caso O Id seja nulo, ir� calcular atrav�s dos par�metros
		RETURN @ValorSaldoInicial + @ValorCredito - @ValorDebito
	END
GO