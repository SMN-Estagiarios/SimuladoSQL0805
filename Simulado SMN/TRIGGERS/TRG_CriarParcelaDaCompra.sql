CREATE OR ALTER TRIGGER [dbo].[TRG_CriarParcelaDaCompra]
	ON [dbo].[Compra]
	FOR INSERT
	AS
	/*
	Documentacao
	Arquivo Fonte............:	TRG_CriarParcelaDaCompra.sql
	Objetivo.................:	Cria parcela(s) da compra realizada.
	Autor....................:	Grupo de Estagiarios SMN
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
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

										EXEC @RET = [dbo].[SP_GerarCompra] 1600,'2024-05-30', 'Galinha de Capoeira', 10

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
	*/
	BEGIN
		
		-- Declarando as variaveis
		DECLARE	@IdCompra INT,
				@Valor DECIMAL(10,2),
				@DataCompra DATE,
				@TotalParcela SMALLINT,
				@Count INT = 1,
				@ValorParcela DECIMAL(10,2)

		SELECT	@IdCompra = i.Id,
				@Valor = i.Valor,
				@DataCompra = i.DataCompra,
				@TotalParcela = i.TotalParcela
			FROM inserted i

		-- Setando o valor da parcela.
		SET @ValorParcela = @Valor / @TotalParcela

		-- Verificando se a compra foi parcelada.
		IF @TotalParcela <= 1
			BEGIN
				-- Inserindo dados da compra em Parcela.
				INSERT INTO [dbo].[Parcela](IdVenda, IdCompra, IdJuros, IdLancamento, Valor, DataVencimento)
					VALUES (NULL, @IdCompra, 1, NULL, @Valor, @DataCompra)
				
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					RAISERROR ('Erro ao Inserir uma parcela', 16, 1)
			END

		ELSE
			BEGIN 
				-- Loop para criação das parcelas
				WHILE @Count <= @TotalParcela
					BEGIN
						-- Inserindo as parcelas da compra.
						INSERT INTO [dbo].[Parcela](IdVenda, IdCompra, IdJuros, IdLancamento, Valor, DataVencimento)
							VALUES(NULL, @IdCompra, 1, NULL, @ValorParcela, DATEADD(MONTH, @Count, @DataCompra))
						SET @Count +=1
						
						IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
							RAISERROR ('Erro ao Inserir quantidade de parcelas', 16, 1)
					END
			END
		
	END
GO