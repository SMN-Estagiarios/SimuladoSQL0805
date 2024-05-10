CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta]
	@IdCliente INT
	AS 
	/*
	Documentacao
	Arquivo Fonte..: Contas.sql
	Objetivo..........: Cria uma conta na tabela [dbo].[Contas]
	Autor..............: Pedro Avelino
	Data...............: 10/05/2024
	Ex..................: 
							BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

									SELECT	Id,
												IdCliente,
												ValorSaldoInicial,
												ValorCredito,
												ValorDebito,
												DataSaldo,
												DataAbertura,
												DataEncerramento,
												Ativo
										FROM [dbo].[Conta]

								EXEC @RET = [dbo].[SP_InserirNovaConta] 1

										SELECT	Id,
													IdCliente,
													ValorSaldoInicial,
													ValorCredito,
													ValorDebito,
													DataSaldo,
													DataAbertura,
													DataEncerramento,
													Ativo
											FROM [dbo].[Conta]

									SELECT @RET AS RETORNO,
												DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

						--	RETORNO   --
						00.................: Erro ao criar conta
						01.................: Sucesso
																
	*/
	BEGIN
		INSERT INTO [dbo].[Conta]	(
													IdCliente,
													ValorSaldoInicial,
													ValorCredito,
													ValorDebito,
													DataSaldo,
													DataAbertura,
													DataEncerramento,
													Ativo
												) 
			VALUES	(	
							@IdCliente,
							0,
							0,
							0,
							GETDATE(),
							GETDATE(),
							NULL,
							1
						);

		IF @@ROWCOUNT <> 0
			RETURN 1
		ELSE
			RETURN 0
	END
GO