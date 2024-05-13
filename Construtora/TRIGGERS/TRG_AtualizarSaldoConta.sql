CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarSaldoConta]
	ON [dbo].[Lancamento]
	FOR INSERT
	AS
	/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizarSaldoConta.sql
		Objetivo.............:	Atualizar Saldo da tabela [dbo].[Conta]
		Autor................:	Adriel Alexander
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
		DECLARE @Tipo_Lancamento CHAR(1),
				@Data_Lanc DATETIME,
				@Vlr_Lancamento DECIMAL(15,2),
				@IdConta INT;

		--ATRIBUINDO VALORES AS VARIÁVEIS 
		SELECT	@Tipo_Lancamento = TipoOperacao,
				@Data_Lanc = DataLancamento, 
				@Vlr_Lancamento = Valor
			FROM INSERTED

		UPDATE [dbo].[Conta] 
			SET ValorSaldoInicial = (CASE	WHEN @Data_Lanc < DataSaldo 
										THEN ValorSaldoInicial + 
															(CASE WHEN @Tipo_Lancamento = 'C' 
																THEN @Vlr_Lancamento
																ELSE @Vlr_Lancamento* (-1)
																END)
										ELSE ValorSaldoInicial 
									END),

				ValorCredito = (CASE WHEN @Data_Lanc < DataSaldo  OR @Tipo_Lancamento = 'D' 
									THEN ValorCredito
									ELSE (ValorCredito + @Vlr_Lancamento) 
								END),


				ValorDebito = (CASE	WHEN @Data_Lanc < DataSaldo  OR @Tipo_Lancamento = 'C' 
									THEN ValorDebito
									ELSE(ValorDebito + @Vlr_Lancamento)
								END)
			WHERE Id = (SELECT IdConta FROM inserted)
	END