USE DB_ConstrutoraLMNC

GO

CREATE PROCEDURE [dbo].[SP_ExtratoContaBancaria]
	@IdConta INT,
	@DataInicio DATE = NULL,
	@DataTermino DATE = NULL

AS

	/*
		Documenta��o
		Arquivo Fonte.....: Relatorio.sql
		Objetivo..........: Lista o hist�rico de transa��es de uma determinada conta banc�ria em um per�odo espec�fico;
		Autor.............: Pedro Avelino
		Data..............: 10/05/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								EXEC [dbo].[SP_ExtratoContaBancaria] NULL, NULL

								SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN

	*/
BEGIN

	--Verificando se a conta banc�ria existe
	IF NOT EXISTS (SELECT 1 FROM [dbo].[Conta] WHERE Id = @IdConta)
		BEGIN
			PRINT 'Conta banc�ria n�o encontrada.';
			RETURN;
		END;

	--Se as datas de in�cio e t�rmino n�o forem especificadas, definir para todo o per�odo
	IF @DataInicio IS NULL
		SET @DataInicio = '1900101'; 
	IF @DataTermino IS NULL
		SET @DataTermino = '99991231';

	--Consulta para obter o extrato da conta banc�ria
	SELECT l.Id AS IdLancamento,
		   l.DataLancamento,
		   l.Valor,
		   l.TipoOperacao,
		   l.NomeHistorico
		FROM [dbo].[Lancamento] l
		WHERE l.IdConta = @IdConta
			AND l.DataLancamento >= @DataInicio
			AND l.DataLancamento <= @DataTermino
		ORDER BY l.DataLancamento DESC;
END;


