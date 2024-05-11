USE DB_ConstrutoraLMNC;

GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtualConta]	(
																	@IdConta INT = NULL, 
																	@ValorSldInicial DECIMAL(10,2) = NULL, 
																	@ValorCredito DECIMAL(10,2) = NULL, 
																	@ValorDebito DECIMAL(10,2) = NULL
																)
	 RETURNS  DECIMAL(10,2)
	 AS 
	 /*
		Documenta��o
		Arquivo Fonte.....: FNC_CalcularSaldoAtualConta.sql
		Objetivo..........: Listar o saldo atual de todas as contas ou uma conta especifica na tabela Conta
		Autor.............: Pedro Avelino 
 		Data..............: 10/05/2024
		Ex................: DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
								
							DECLARE @Dat_ini DATETIME = GETDATE()
							SELECT	[dbo].[FNC_CalcularSaldoAtualConta](NULL,200,500,100) AS Resultado,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
	*/
	BEGIN
		  --Verificar se o par�metro n�o � nulo
		IF(@IdConta IS NOT NULL) 
			BEGIN
				--A fun��o faz uma consulta para obter os valores de saldo inicial, cr�dito e d�bito da conta associada ao IdConta
				SELECT @ValorSldInicial = ValorSaldoInicial,
					   @ValorCredito = ValorCredito,
					   @ValorDebito = ValorDebito
					FROM [dbo].[Conta] WITH(NOLOCK)
					WHERE Id = @IdConta
			END;
			--Retorna o saldo atual da conta, que � calculado somando o saldo inicial, os cr�ditos e subtraindo os d�bitos;
		RETURN @ValorSldInicial + @ValorCredito - @ValorDebito
	END;
GO