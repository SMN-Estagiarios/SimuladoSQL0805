CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarSaldoConta]
	ON [dbo].[Lancamento]
	FOR INSERT
	AS
	/*
	Documentacao
	Arquivo Fonte............:	TRG_AtualizarSaldoConta.sql
	Objetivo.................:	Atualizar Saldo da tabela [dbo].[Conta]
	Autor....................:	Grupo de estagiarios SMN
	Data.....................:	10/05/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DataInicio DATETIME = GETDATE();

									SELECT	ValorSaldoInicial,
											ValorCredito,
											ValorDebito,
											DataSaldo,
											DataAbertura,
											DataEncerramento,
											Ativo
									FROM [dbo].[Conta] WITH(NOLOCK)
	
									SELECT TOP 20	Id,
													IdConta,
													IdTipo,
													IdTransferencia,
													Valor,
													TipoOperacao,
													DataLancamento,
													NomeHistorico
										FROM [dbo].[Lancamento]
										ORDER BY DataLancamento DESC

									INSERT INTO Lancamento(	
															IdConta,
															IdTipo,
															TipoOperacao,
															Valor,
															NomeHistorico,
															DataLancamento
															)
										VALUES	(
													2,
													1,
													'C',
													2000,
													'TESTE TRIGGER',
													GETDATE()
												)

									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

									SELECT	ValorSaldoInicial,
											ValorCredito,
											ValorDebito,
											DataSaldo,
											DataAbertura,
											DataEncerramento,
											Ativo
									FROM [dbo].[Conta] WITH(NOLOCK)
	
									SELECT TOP 20	Id,
													IdConta,
													IdTipo,
													IdTransferencia,
													Valor,
													TipoOperacao,
													DataLancamento,
													NomeHistorico
										FROM [dbo].[Lancamento]
										ORDER BY DataLancamento DESC
								ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando as variaveis
		DECLARE @Tipo_Lancamento CHAR(1),
				@Data_Lanc DATETIME,
				@Vlr_Lancamento DECIMAL(15,2),
				@IdConta INT;

		-- Setando valores as variáveis 
		SELECT	@Tipo_Lancamento = i.TipoOperacao,
				@Data_Lanc = i.DataLancamento,
				@Vlr_Lancamento = i.Valor
			FROM inserted i

		UPDATE [dbo].[Conta] 
			SET ValorSaldoInicial = (CASE	WHEN @Data_Lanc < DataSaldo 
											THEN ValorSaldoInicial + 
																	(CASE WHEN @Tipo_Lancamento = 'C' 
																			THEN @Vlr_Lancamento
																			ELSE @Vlr_Lancamento* (-1)
																	END)
											ELSE ValorSaldoInicial
									END),

				ValorCredito = (CASE WHEN @Data_Lanc < DataSaldo OR @Tipo_Lancamento = 'D'
									THEN ValorCredito
									ELSE (ValorCredito + @Vlr_Lancamento) 
								END),

				ValorDebito = (CASE	WHEN @Data_Lanc < DataSaldo  OR @Tipo_Lancamento = 'C'
									THEN ValorDebito
									ELSE(ValorDebito + @Vlr_Lancamento)
								END)
			WHERE Id = @IdConta
	END
GO