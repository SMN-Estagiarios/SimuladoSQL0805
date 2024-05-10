CREATE OR ALTER PROCEDURE [dbo].[SP_InserirDespesa]	
	@IdTipo TINYINT,
	@Descricao VARCHAR(200),
	@Valor DECIMAL(10,2),
	@DataVencimento DATE

	AS
	/*
		Documentacao
		Arquivo Fonte.....: Despesa.sql
		Objetivo.............: Inserir registro em despesa
		Autor.................: Todos
 		Data..................: 10/05/2024
		Ex....................: 
									BEGIN TRAN

										SELECT	Id,
												IdTipo,
												Descricao,
												Valor,
												DataVencimento
											FROM [dbo].[Despesa] WITH(NOLOCK)

										DBCC DROPCLEANBUFFERS
										DBCC FREEPROCCACHE

										DECLARE	@Ret INT,
												@DataInicio DATETIME = GETDATE()

										EXEC @Ret = [dbo].[SP_InsereDespesa] 1, 'coisa', -19900.00, '01-20-2024'
										SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo

										SELECT	Id,
												IdTipo,
												Descricao,
												Valor,
												DataVencimento
											FROM [dbo].[Despesa] WITH(NOLOCK)
											WHERE Id = IDENT_CURRENT('Despesa')
									ROLLBACK TRAN

		RETORNOS: ........: 
				0 - SUCESSO
				1 - NAO E POSSIVEL INSERIR DESPESA COM DIFERENCA DE TEMPO MAIOR QUE 30 DIAS
	*/
	BEGIN
		--LIMITA O INSERT ATÉ 30 DIAS ANTERIOROES AO DIA EM QUESTAO
		IF DATEDIFF(day, @DataVencimento, GETDATE()) > 30
			RETURN 1

		--INSERE DADOS DE DESPESA NA TABELA DESPESA DESCONSIDERANDO VALORES NEGATIVOS
		INSERT INTO [dbo].[Despesa] (IdTipo, Descricao, Valor, DataVencimento)
			VALUES (@IdTipo, @Descricao, ABS(@Valor), @DataVencimento)
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarDespesas]	@DataInicio DATE,
													@DataComparacao DATE

	AS
	/*
		Documentacao
		Arquivo Fonte.....: despesa.sql
		Objetivo.............: Listar todas as despesas que estao englobados em um intervalo de tempo determinado
		Autor.................: Todos
 		Data..................: 10/05/2024
		Ex.....................: 
									SELECT	Id,
											IdTipo,
											Descricao,
											Valor,
											DataVencimento
										FROM [dbo].[Despesa] WITH(NOLOCK)

									DBCC DROPCLEANBUFFERS
									DBCC FREEPROCCACHE

									DECLARE	@Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_ListaDespesas] '01-01-2024', '02-01-2024'
									SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo
	*/
	BEGIN
		--CASO A DATA DE INICIO SEJA NULA, USA-SE O GETDATE()
		IF @DataInicio IS NULL
			SET @DataInicio = GETDATE()

		--SELECIONA TODAS AS DESPESAS COM PERÍDO DE VENCIMENTO ENTRE DUAS DATAS
		SELECT	td.Nome,
				d.Descricao,
				d.Valor,
				d.DataVencimento
			FROM [dbo].[Despesa] d WITH(NOLOCK)
				INNER JOIN [dbo].[TipoDespesa] td WITH(NOLOCK)
					ON td.Id = d.IdTipo
				WHERE DataVencimento BETWEEN @DataInicio AND @DataComparacao
		RETURN 0
	END
GO
