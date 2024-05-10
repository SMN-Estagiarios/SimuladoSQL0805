CREATE OR ALTER PROCEDURE [dbo].[SP_RelaotrioContasAPagar]
	AS
	/*
		DOC
	*/
	BEGIN
		SELECT	d.Id,
				d.IdTipo,
				d.Descricao,
				d.Valor,
				d.DataVencimento
			FROM Despesa d
				LEFT JOIN Lancamento l
					ON d.Id = d.Id
				WHERE --fk de lancamento nula
	END