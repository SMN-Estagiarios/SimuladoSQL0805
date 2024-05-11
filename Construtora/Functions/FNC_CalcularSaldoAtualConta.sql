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
		Objetivo..........: Listar o saldo atual de uma ou de todas as contas
		Autor.............: Rafael Mauricio 
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;
								
								DECLARE @Dat_ini DATETIME = GETDATE()
								SELECT	[dbo].[FNC_CalcularSaldoAtualConta](NULL,200,500,100) AS Resultado,
										DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
							ROLLBACK TRAN
	*/
	BEGIN
		  --Verificar se Id existe
		IF(@IdConta IS NOT NULL)
			--Atribuir Valores 
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