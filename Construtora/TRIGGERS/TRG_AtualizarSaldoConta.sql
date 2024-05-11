CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarSaldoConta]
	ON [dbo].[Lancamento]
	FOR INSERT
	AS
	/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizarSaldoConta.sql
		Objetivo.............:	Atualizar Saldo da tabela Conta
		Autor................:	Odlavir Florentino
		Data.................:	10/05/2024
		Ex...................:  BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT *
										FROM [dbo].[Conta] WITH(NOLOCK)
	
								   SELECT TOP 20 *
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										ORDER BY DataLancamento DESC

									INSERT INTO Lancamento(	
															IdConta, 
															IdTipo,	
															TipoOperacao,
															Valor,
															NomeHistorico,
															DataLancamento
												          )
									VALUES				  (
															2, 
															1, 
															'C', 
															2000, 
															'TESTE TRIGGER', 
															GETDATE()
														  )

									SELECT DATEDIFF(MILLISECOND, @DATA_INI,GETDATE()) AS TempoExecução

									SELECT *
										FROM [dbo].[Conta] WITH(NOLOCK)
	
								   SELECT TOP 20 *
										FROM [dbo].[Lancamento] WITH(NOLOCK)
										ORDER BY DataLancamento DESC
								ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @TipoLancamento CHAR(1),
				@DataLancamento DATETIME,
				@ValorLancamento DECIMAL(15,2),
				@IdConta INT;

		--ATRIBUINDO VALORES AS VARIÁVEIS 
		SELECT	@TipoLancamento = TipoOperacao,
				@DataLancamento = DataLancamento, 
				@ValorLancamento = Valor
			FROM inserted

		UPDATE [dbo].[Conta] 
			SET ValorSaldoInicial = (CASE	WHEN @DataLancamento < DataSaldo 
										THEN ValorSaldoInicial + 
															(CASE WHEN @TipoLancamento = 'C' 
																THEN @ValorLancamento
																ELSE @ValorLancamento* (-1)
																END)
										ELSE ValorSaldoInicial 
									END),

				ValorCredito = (CASE WHEN @DataLancamento < DataSaldo  OR @TipoLancamento = 'D' 
									THEN ValorCredito
									ELSE (ValorCredito + @ValorLancamento) 
								END),


				ValorDebito = (CASE	WHEN @DataLancamento < DataSaldo  OR @TipoLancamento = 'C' 
									THEN ValorDebito
									ELSE(ValorDebito + @ValorLancamento)
								END)
			WHERE Id = @IdConta
	END