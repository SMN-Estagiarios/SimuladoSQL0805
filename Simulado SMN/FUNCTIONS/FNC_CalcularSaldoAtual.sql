CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtual](
																@IdConta INT = NULL,
																@ValorSldInicial DECIMAL(10,2) = NULL,
																@ValorCredito DECIMAL(10,2) = NULL,
																@ValorDebito DECIMAL(10,2) = NULL
															)
	RETURNS	DECIMAL(10,2)
	AS
	/*
	Documentação
	Arquivo Fonte............:	FNC_CalcularSaldoAtual.sql
	Objetivo.................:	Listar o saldo atual de todas as contas ou uma conta especifica na tabela Conta
	Autor....................:	Grupo de estagiarios SMN
 	Data.....................:	10/05/2024
	Ex.......................:	
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;
								
								DECLARE @DataInicio DATETIME = GETDATE()

								SELECT	[dbo].[FNC_CalcularSaldoAtual](NULL,1000,500,1200) AS Resultado,
										DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		-- Verificar se Id na conta existe
		IF(@IdConta IS NOT NULL)
		
		-- Setendo valores as variaveis
		BEGIN
			SELECT	@ValorSldInicial = c.ValorSaldoInicial,
					@ValorCredito = c.ValorCredito,
					@ValorDebito = c.ValorDebito
				FROM [dbo].[Conta] c WITH(NOLOCK)
				WHERE Id = @IdConta
		END

		-- Caso o Id seja nulo, usar os demais valores passados como parametros
		RETURN @ValorSldInicial + @ValorCredito - @ValorDebito
	
	END
GO