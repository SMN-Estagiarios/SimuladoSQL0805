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
							A variavel @DataVencimento é a data de vencimento da compra.
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