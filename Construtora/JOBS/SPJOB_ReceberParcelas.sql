CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ReceberParcelas]
	AS
	/*
	Documentacao
	Arquivo fonte............:	SPJOB_ReceberParcelas.sql
	Objetivo.................:	Atualizar ao receber o pagamento de uma parcela.
	Autor....................:	Grupo de Estagiarios SMN
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									SELECT *
										FROM [dbo].[Parcela]

									SELECT *
										FROM [dbo].[Lancamento]

									DECLARE	@DataInicio DATETIME = GETDATE();

									EXEC [dbo].[SPJOB_ReceberParcelas]

									SELECT	DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

									SELECT *
										FROM [dbo].[Parcela]

									SELECT *
										FROM [dbo].[Lancamento]
								ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando as variaveis
		DECLARE	@IdLancamento INT,
				@DataAtual DATETIME = GETDATE(),
				@ERRO INT,
				@Linha INT;

		-- Criando uma tabela temporaria para armazenar dados importantes para as querys
		CREATE TABLE #Tabela	(
									IdParcela INT,
									IdConta INT,
									IdTipo INT,
									TipoOperacao CHAR(1),
									Valor DECIMAL(15,2),
									NomeHistorico VARCHAR(50),
									DataLancamento DATE
								)

		-- Inserindo os dados na tabela temporaria
		INSERT INTO #Tabela	(
								IdParcela,
								IdConta,
								IdTipo,
								TipoOperacao,
								Valor,
								NomeHistorico,
								DataLancamento	
							)
			SELECT	p.Id,
					ct.Id,
					4,
					'D',
					p.Valor,
					CONCAT('Pagamento da parcela ', p.Id),
					@DataAtual
				FROM [dbo].[Parcela] p WITH(NOLOCK)
					FULL JOIN [dbo].[Venda] v WITH(NOLOCK)
						ON p.IdVenda = v.Id
					INNER JOIN [dbo].[Cliente] c WITH(NOLOCK)
						ON v.IdCliente = c.Id
					INNER JOIN [dbo].[Conta] ct WITH(NOLOCK)
						ON c.Id = ct.IdCliente
				WHERE DATEDIFF(DAY, @DataAtual, p.DataVencimento) = 0
					AND [dbo].[FNC_CalcularSaldoAtualConta] (ct.Id, NULL, NULL, NULL) >= p.Valor

				SELECT * FROM #Tabela

		-- Enquanto existir registro na tabela temporaria, devera ser executado o insert em lancamento e atualizar a tabela de parcela
		WHILE EXISTS	(
							SELECT TOP 1 1
								FROM #Tabela
						)
			BEGIN
				-- Insert em lancamento
				INSERT INTO [dbo].[Lancamento]	(
													IdConta,
													IdTipo,
													TipoOperacao,
													Valor,
													NomeHistorico,
													DataLancamento	
												)
					SELECT TOP 1	IdConta,
									IdTipo,
									TipoOperacao,
									Valor,
									NomeHistorico,
									DataLancamento	
						FROM #Tabela

				SELECT	@Linha = @@ROWCOUNT,
						@ERRO = @@ERROR,
						@IdLancamento = SCOPE_IDENTITY();

				IF @ERRO <> 0 OR @Linha <> 1
					BEGIN
						ROLLBACK TRAN;
						RAISERROR('Erro ao inserir lancamento', 16, 1);
						RETURN;
					END

				-- Atualizar a tabela parcela
				UPDATE [dbo].[Parcela]
					SET IdLancamento = @IdLancamento
					WHERE Id =	(
									SELECT TOP 1 IdParcela
										FROM #Tabela
								);

				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						ROLLBACK TRAN;
						RAISERROR('Erro ao atualizar o id de lancamento na parcela', 16, 1);
						RETURN;
					END

				-- Deletar o primeiro registro da tabela temporaria
				DELETE FROM #Tabela
					WHERE IdParcela =	(
											SELECT TOP 1 IdParcela
												FROM #Tabela
										);
			END

		-- Drop da tabela temporaria
		DROP TABLE #Tabela;
	END
GO