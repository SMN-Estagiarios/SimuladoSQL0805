CREATE OR ALTER PROCEDURE [dbo].[SP_GerarCompra]
	@Valor DECIMAL(10,2),
	@DataCompra DATE,
	@Descricao VARCHAR(500),
	@Parcelas SMALLINT
	AS
	/*
	Documentacao
	Arquivo fonte............:	Compra.sql
	Objetivo.................:	Fazer lançamento em Compra e sensibilizar a entidade parcela.
								A variavel @DataVencimento é a data de vencimento da compra.
	Autor....................:	Grupo de Estagiarios SMN
	Data.....................:	10/05/2024
	EX.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS; 
									DBCC FREEPROCCACHE;
	
									DECLARE	@RET INT,
											@DataInicio DATETIME = GETDATE()

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

									EXEC @RET = [dbo].[SP_GerarCompra] 200,'2024-05-10', 'Galinha de Capoeira',24

									SELECT	@RET AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao
								
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

								ROLLBACK TRAN

								RETORNO.........:
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