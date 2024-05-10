CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioApartamentoNaoVendido]
	@IdPredio INT = NULL
	AS
	/*
		Documentação
		Arquivo fonte........: Apartamento.sql
		Objetivo.............: Listar todos os os apartamentos não vendidos
		Autor................: Gustavo Targino
		Data.................: 10/05/2024
		Ex...................: BEGIN TRAN
									
									DECLARE @DataInicio DATETIME = GETDATE()

									EXEC [dbo].[SP_RelatorioApartamentoNaoVendido]7
									
									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo

							   ROLLBACK

	*/
	BEGIN
		-- Selecionando os apartamentos que não estão presentes na tabela de venda
		SELECT ap.Numero,
			   ap.Pavimento,
			   p.Nome
			FROM [dbo].[Apartamento] ap WITH(NOLOCK)
				LEFT JOIN [dbo].[Venda] v WITH(NOLOCK)
					ON ap.Id = v.IdApartamento
				INNER JOIN [dbo].[Predio] p WITH(NOLOCK)
					ON p.Id = ap.IdPredio
			WHERE v.IdApartamento IS NULL
			AND p.Id = ISNULL(@IdPredio, p.Id)
	END