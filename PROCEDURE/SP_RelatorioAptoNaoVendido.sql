CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioAptoNaoVendidos]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: venda.sql
		Objetivo..........: Listar apartamentos na vendidos
		Autor.............: Gabriel Damiani Puccinelli
 		Data..............: 10/05/2024
		Ex................: BEGIN TRAN

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_RelatorioAptoNaoVendidos]
								SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

							ROLLBACK TRAN
	*/
	BEGIN
		--RETORNA APARTAMENTOS QUE NÃOO TEM REGISTRO EM VENDA
		SELECT	a.IdPredio AS Predio,
				a.Numero AS NumeroApartamento
			FROM [dbo].[Apartamento] a WITH(NOLOCK)
				LEFT JOIN [dbo].[Venda] v WITH(NOLOCK)
					ON a.Id = v.IdApartamento
				WHERE v.IdApartamento IS NULL
	END
GO