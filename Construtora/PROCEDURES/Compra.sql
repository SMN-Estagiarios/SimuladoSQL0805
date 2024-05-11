CREATE OR ALTER PROCEDURE [dbo].[SP_GerarCompra]	
	@Valor DECIMAL(10,2),
	@DataCompra DATE,
	@Descricao VARCHAR(500),
	@Parcelas SMALLINT
	AS
	/*
		Documentação
		Arquivo Fonte.....: Compra.sql
		Objetivo..........: Fazer lançamento na entidade [dbo].[Compra] e sensibilizar a entidade parcela.
								A variacel @DataVencimento é a data de vencimento da compra.
		Autor.............: Grupo de Estagiarios SMN
		Data..............: 10/05/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT

								SELECT	*
									FROM [dbo].[Compra] WITH(NOLOCK)

								SELECT	*
									FROM [dbo].[Parcela] WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_GerarCompra] 200,'2024-05-10', 'Galinha de Capoeira',24

								SELECT	*
									FROM [dbo].[Compra] WITH(NOLOCK)

								SELECT	*
									FROM [dbo].[Parcela] WITH(NOLOCK)

								SELECT	@RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

							Lista de Retornos:
												0 - Sucesso.
												1 - Erro ao realizar compra.
	*/		
	BEGIN
		--Inserir dados na entidade Compra.
		INSERT INTO [dbo].[Compra](Valor,DataCompra,Descricao,TotalParcela)
			VALUES(@Valor, @DataCompra, @Descricao, @Parcelas)
	
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarRelatorioContasAPagar]	
	AS
	/*
		Documentação
		Arquivo Fonte.....: Compra.sql
		Objetivo..........: Gerar o relatorio de todas as contas que a empresa tem a pagar
		Autor.............: Odlavir Florentino
		Data..............: 10/05/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT

								EXEC [dbo].[SP_GerarRelatorioContasAPagar]

								SELECT	DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
	*/
	BEGIN
		-- Recuperar parcelas que a empresa tem a pagar
		SELECT	c.Id,
				c.Descricao,
				p.Valor,
				p.IdJuros,
				p.DataVencimento
			FROM [dbo].[Compra] c WITH(NOLOCK)
				INNER JOIN [dbo].[Parcela] p WITH(NOLOCK)
					ON c.Id = p.IdCompra
			WHERE p.IdLancamento IS NULL;

		-- Recuperar que a empresa tem a pagar
		SELECT	d.Id,
				d.Descricao,
				td.Nome,
				d.Valor,
				d.DataVencimento
			FROM [dbo].[Despesa] d WITH(NOLOCK)
				INNER JOIN [dbo].[TipoDespesa] td WITH(NOLOCK)
					ON td.Id = d.IdTipo
			WHERE d.DataVencimento > GETDATE();
	END