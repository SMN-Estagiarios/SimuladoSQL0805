CREATE OR ALTER PROCEDURE [dbo].[SP_GerarCompra]	
	@Valor DECIMAL(10,2),
	@DataCompra DATE,
	@Descricao VARCHAR(500),
	@Parcelas SMALLINT	
	AS
	/*
	Documentação
	Arquivo Fonte.....: Compra.sql
	Objetivo..........: Cria uma compra na entidade Compra.
						A variacel @DataVencimento é a data de vencimento da compra.
	Autor.............: Orcino Neto
	Data..............: 10/05/2024
	EX................:
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS; 
							DBCC FREEPROCCACHE;
	
							DECLARE	@Dat_init DATETIME = GETDATE(),
									@RET INT

							SELECT	Id,
									Valor,
									DataCompra,
									Descricao,
									TotalParcela
								FROM [dbo].[Compra]

							SELECT	IdVenda,
									IdCompra,
									IdJuros,
									IdLancamento,
									Valor,
									DataVencimento
								FROM [dbo].[Parcela]

							EXEC @RET = [dbo].[SP_GerarCompra] 2000,'2024-05-10', 'Galinha de Capoeira',20

							SELECT	Id,
									Valor,
									DataCompra,
									Descricao,
									TotalParcela
								FROM [dbo].[Compra]

							SELECT	IdVenda,
									IdCompra,
									IdJuros,
									IdLancamento,
									Valor,
									DataVencimento
								FROM [dbo].[Parcela]

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
			VALUES(@Valor,@DataCompra,@Descricao,@Parcelas)
	
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1

		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RelatorioContasPagar]	
	@IdCompra INT = NULL	
	AS
	/*
	Documentação
	Arquivo Fonte..: Compra.sql
	Objetivo.......: Gerando Relatorio de todas as contas a Pagar.
	Autor..........: Orcino Neto
	Data...........: 10/05/2024
	EX.............:
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS; 
							DBCC FREEPROCCACHE;
	
							DECLARE	@Dat_init DATETIME = GETDATE(),
											@RET INT								

							EXEC @RET = [dbo].[SP_RelatorioContasPagar] 							

							SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN
	Lista de Retornos:
				0 - Sucesso.
				1 - Erro ao realizar compra.
	*/		
	BEGIN

		SELECT	c.Id,
				c.Valor,
				c.DataCompra,
				c.TotalParcela,
				p.DataVencimento,
				p.IdLancamento,
				p.Valor
			FROM [dbo].[Compra]c WITH(NOLOCK)
				LEFT JOIN [dbo].[Parcela] p WITH(NOLOCK)
					ON c.Id = p.IdCompra
			WHERE p.IdLancamento IS NULL
	
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1

		RETURN 0
	END
GO