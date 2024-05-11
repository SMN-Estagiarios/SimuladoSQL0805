USE DB_ConstrutoraLMNC;

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirDespesa]	@IdTipo TINYINT,
													@Descricao VARCHAR(200),
													@Valor DECIMAL(10,2),
													@DataVencimento DATE

AS
	/*
		Documentacao
		Arquivo Fonte.....: Despesa.sql
		Objetivo..........: Inserir registro em despesa
		Autor.............: Grupo de Estagiarios SMN
 		Data..............: 10/04/2024
		Ex................: BEGIN TRAN

								SELECT	*
									FROM [dbo].[Despesa] WITH(NOLOCK)

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE

								DECLARE	@Ret INT,
										@DataInicio DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_InserirDespesa] 1, 'coisa', -19900.00, '2024-04-01'

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao;

								SELECT	*
									FROM [dbo].[Despesa] WITH(NOLOCK)
									--WHERE Id = IDENT_CURRENT('Despesa')
							ROLLBACK TRAN

							RETORNOS: ........: 0 - SUCESSO
												1 - NAO E POSSIVEL INSERIR DESPESA COM DIFERENCA DE TEMPO MAIOR QUE 30 DIAS
												2 - ERRO AO INSERIR UMA DESPESA
	*/
	BEGIN
		--LIMITA O INSERT ATÉ 30 DIAS ANTERIOROES AO DIA EM QUESTAO
		IF DATEDIFF(DAY, @DataVencimento, GETDATE()) > 30
			RETURN 1

		--INSERE DADOS DE DESPESA NA TABELA DESPESA DESCONSIDERANDO VALORES NEGATIVOS
		INSERT INTO [dbo].[Despesa] (IdTipo, Descricao, Valor, DataVencimento)
			VALUES (@IdTipo, @Descricao, ABS(@Valor), @DataVencimento)

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 2

		RETURN 0
	END;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarDespesas]	
	@DataInicio DATE = NULL,
	@DataComparacao DATE = NULL
AS
	/*
		Documentacao
		Arquivo Fonte.....: Despesa.sql
		Objetivo..........: Listar todas as despesas que estao englobados em um intervalo de tempo determinado
		Autor.............: Grupo de Estagiarios SMN
 		Data..............: 10/04/2024
		Ex................: SELECT	*
								FROM [dbo].[Despesa] WITH(NOLOCK)

							DBCC DROPCLEANBUFFERS
							DBCC FREEPROCCACHE

							DECLARE	@DataInicio DATETIME = GETDATE()

							EXEC [dbo].[SP_ListarDespesas] '01-01-2024', '02-01-2024'
							EXEC [dbo].[SP_ListarDespesas] '01-01-2024'

							SELECT	DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		--SELECIONA TODAS AS DESPESAS COM PERÍDO DE VENCIMENTO ENTRE DUAS DATAS
		SELECT	td.Nome,
				d.Descricao,
				d.Valor,
				d.DataVencimento
			FROM [dbo].[Despesa] d WITH(NOLOCK)
				INNER JOIN [dbo].[TipoDespesa] td WITH(NOLOCK)
					ON td.Id = d.IdTipo
			WHERE DataVencimento BETWEEN ISNULL(@DataInicio, GETDATE()) AND ISNULL(@DataComparacao, GETDATE())
	END;
GO