CREATE OR ALTER TRIGGER [dbo].[TRG_CriarParcelaDaCompra]
	ON [dbo].[Compra]
	FOR INSERT
	AS
	/*
	DOCUMENTACAO
		Arquivo Fonte....:	TRG_CriarParcelaDaCompra.sql
		Objetivo.........:	Cria parcela ou parcelas da compra realizada.
		Autor............:	Grupo de Estagiarios SMN
		Data.............:	10/05/2024
		Ex...............:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE	@Dat_init DATETIME = GETDATE(),
												@RET INT

								SELECT	*
									FROM [dbo].[Compra] WITH(NOLOCK)

								SELECT	*
									FROM [dbo].[Parcela]  WITH(NOLOCK)

								EXEC @RET = [dbo].[SP_GerarCompra] 1600,'2024-05-30', 'Galinha de Capoeira', 1

								SELECT	*
									FROM [dbo].[Compra] WITH(NOLOCK)

								SELECT	*
									FROM [dbo].[Parcela]  WITH(NOLOCK)

									SELECT @RET AS RETORNO,
												DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
	*/
	BEGIN
		DECLARE	@IdCompra INT,
				@Valor DECIMAL(10,2),
				@DataCompra DATE,
				@TotalParcela SMALLINT,
				@Count INT = 1,
				@ValorParcela DECIMAL(10,2);

		SELECT	@IdCompra = Id,
				@Valor = Valor,
				@DataCompra = DataCompra,
				@TotalParcela = TotalParcela
			FROM INSERTED

		--Setando o valor da parcela.
		SET @ValorParcela = @Valor / @TotalParcela

		--Verificação a compra foi parcelada.
		IF @TotalParcela <= 1
			BEGIN
				--Inserir dados da compra na entidade Parcela.
				INSERT INTO [dbo].[Parcela](IdVenda,IdCompra,IdJuros,IdLancamento,Valor,DataVencimento)
					VALUES(NULL, @IdCompra, 1, NULL, @Valor, @DataCompra)

				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						ROLLBACK TRAN;
						RAISERROR('Erro ao inserir parcela.', 16, 1);
						RETURN;
					END
			END

		ELSE
			BEGIN 
				--Loop para criação das parcelas
				WHILE @Count <= @TotalParcela
					BEGIN
						--Inserir as parcelas da compra.
						INSERT INTO [dbo].[Parcela](IdVenda,IdCompra,IdJuros,IdLancamento,Valor,DataVencimento)
							VALUES(NULL,@IdCompra,1,NULL,@ValorParcela, DATEADD(MONTH,@Count,@DataCompra))

						IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
							BEGIN
								ROLLBACK TRAN;
								RAISERROR('Erro ao inserir parcela.', 16, 1);
								RETURN;
							END

						SET @Count += 1
					END
			END
	END
GO