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
		Documentação
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
		  --Verificar se o parâmetro não é nulo
		IF(@IdConta IS NOT NULL) 
			BEGIN
				--A função faz uma consulta para obter os valores de saldo inicial, crédito e débito da conta associada ao IdConta
				SELECT @ValorSldInicial = ValorSaldoInicial,
					   @ValorCredito = ValorCredito,
					   @ValorDebito = ValorDebito
					FROM [dbo].[Conta] WITH(NOLOCK)
					WHERE Id = @IdConta
			END;
			--Retorna o saldo atual da conta, que é calculado somando o saldo inicial, os créditos e subtraindo os débitos;
		RETURN @ValorSldInicial + @ValorCredito - @ValorDebito
	END;
GO