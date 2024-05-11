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
		Autor.............: Orcino Neto
		Data..............: 10/05/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT

								SELECT Id,
											Valor,
											DataCompra,
											Descricao,
											TotalParcela
									FROM [dbo].[Compra]

								SELECT IdVenda,
											IdCompra,
											IdJuros,
											IdLancamento,
											Valor,
											DataVencimento
									FROM [dbo].[Parcela]

								EXEC @RET = [dbo].[SP_GerarCompra] 200,'2024-05-10', 'Galinha de Capoeira',24

								SELECT Id,
											Valor,
											DataCompra,
											Descricao,
											TotalParcela
									FROM [dbo].[Compra]

								SELECT IdVenda,
											IdCompra,
											IdJuros,
											IdLancamento,
											Valor,
											DataVencimento
									FROM [dbo].[Parcela]

								SELECT @RET AS RETORNO,
											DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

							Lista de Retornos:
										0 - Sucesso.
										1 - Erro ao realizar compra.
	*/		
	BEGIN
		--Inserir dados na entidade Compra.
		INSERT INTO [dbo].[Compra](Valor,DataCompra,Descricao)
			VALUES(@Valor,@DataCompra,@Descricao)
	
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarComprasAbertas]
	AS
	/*
		Documentação
		Arquivo Fonte.....: Compra.sql
		Objetivo..........: Procedure para listar todas as compras não pagas pela empresa
		Autor.............: João Victor Maia
		Data..............: 10/05/2024
		Ex................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS; 
								DBCC FREEPROCCACHE;
	
								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_ListarComprasAbertas]

								SELECT @RET AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
		Retornos..........:	0 - Sucesso
	*/
	BEGIN

		--Listar as compras não pagas
		SELECT	c.Id,
				c.Valor,
				c.DataCompra,
				c.Descricao
			FROM [dbo].[Compra] c WITH(NOLOCK)
				LEFT JOIN [dbo].[Parcela] p WITH(NOLOCK)
					ON c.Id = p.IdCompra
			WHERE p.Id IS NULL
	END
GO