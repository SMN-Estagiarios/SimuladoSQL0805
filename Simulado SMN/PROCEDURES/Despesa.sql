CREATE OR ALTER PROCEDURE [dbo].[SP_InserirDespesa]
	@IdTipo TINYINT,
	@Descricao VARCHAR(200),
	@Valor DECIMAL(10,2),
	@DataVencimento DATE
	AS
	/*
	Documentacao
	Arquivo Fonte............:	Despesa.sql
	Objetivo.................:	Inserir registro em despesa
	Autor....................:	Grupo de Estagiarios SMN
	Data.....................:	10/04/2024
	Ex.......................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS
									DBCC FREEPROCCACHE

									SELECT	Id,
											IdTipo,
											Descricao,
											Valor,
											DataVencimento
										FROM [dbo].[Despesa] WITH(NOLOCK)

									DECLARE	@Ret INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Ret = [dbo].[SP_InserirDespesa] 1, 'coisa', -19900.00, '2024-04-01'
									SELECT @Ret AS Retorno, DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

									SELECT	Id,
											IdTipo,
											Descricao,
											Valor,
											DataVencimento
										FROM [dbo].[Despesa] WITH(NOLOCK)
										WHERE Id = IDENT_CURRENT('Despesa')
								ROLLBACK TRAN

								RETORNOS:............:	
														0 - Sucesso
														1 - Erro ao inserir despesa com diferenca de tempo maior que 30 dias
														2 - Erro ao inserir uma despesa
	*/
	BEGIN
		-- Limita o insert até 30 dias anterioroes ao dia em questao
		IF DATEDIFF(day, @DataVencimento, GETDATE()) > 30
			RETURN 1

		-- Insere dados de despesa na tabela despesa desconsiderando valores negativos
		INSERT INTO [dbo].[Despesa] (IdTipo, Descricao, Valor, DataVencimento)
			VALUES (@IdTipo, @Descricao, ABS(@Valor), @DataVencimento)
		
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 2
		
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarDespesas]
	@DataInicio DATE = NULL,
	@DataComparacao DATE = NULL
	AS
	/*
	Documentacao
	Arquivo Fonte............:	Despesa.sql
	Objetivo.................:	Listar todas as despesas que estao englobados em um intervalo de tempo determinado
	Autor....................:	Grupo de Estagiarios SMN
 	Data.....................:	10/04/2024
	Ex.......................:	DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
									
								DECLARE	@DataInicio DATETIME = GETDATE()
									
								SELECT	Id,
										IdTipo,
										Descricao,
										Valor,
										DataVencimento
									FROM [dbo].[Despesa] WITH (NOLOCK)

								EXEC [dbo].[SP_ListarDespesas] '01-01-2024', '02-01-2024'
								EXEC [dbo].[SP_ListarDespesas] '01-01-2024'
									
								SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao

	*/
	BEGIN
		-- Caso a data de inicio seja nula, usa-se o getdate()
		IF @DataInicio IS NULL
			SET @DataInicio = GETDATE()

		-- Seleciona todas as despesas com perído de vencimento entre duas datas
		SELECT	td.Nome,
				d.Descricao,
				d.Valor,
				d.DataVencimento
			FROM [dbo].[Despesa] d WITH(NOLOCK)
				INNER JOIN [dbo].[TipoDespesa] td WITH(NOLOCK)
					ON td.Id = d.IdTipo
				WHERE DataVencimento BETWEEN ISNULL(@DataInicio, GETDATE()) AND ISNULL(@DataComparacao, GETDATE())
	END
GO
