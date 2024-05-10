CREATE OR ALTER PROCEDURE [dbo].[SP_InserirCliente] 
	@Nome VARCHAR(200),
	@Email VARCHAR(100),
	@Senha VARCHAR(255),
	@CPF BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
	AS 
	/*
		Documentacao
		Arquivo Fonte........: Cliente.sql
		Objetivo.............: Adicionar um cliente na tabela Cliente
		Autor................: Rafael Mauricio
		Data.................: 10/05/2024
		Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									EXEC @RET = [dbo].[SP_InserirCliente] 'Rafael Mauricio', 'rafael.mauricio@smn.com.br', 'OndaTecnologica', 02948575839, 83988597017, '1990-01-01'

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 
									ROLLBACK TRAN

			--	RETORNO   --
			00.................: Sucesso																
			01.................: Erro ao criar conta
		*/
		BEGIN	
			INSERT INTO [dbo].[Cliente] (Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo) VALUES   				
											(@Nome, @Email, @Senha, @CPF, @Telefone, @DataNascimento, 1);

			IF @@ROWCOUNT <> 0
				RETURN 0
			ELSE
				RETURN 1
		END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirCliente]
	@Id_Cliente INT
	AS
    /*
		Documentacao
		Arquivo Fonte.........: Cliente.sql
		Objetivo..............: Mudar status do cliente para inativo
		Autor.................: Rafael Mauricio
		Data..................: 10/05/2024
		Ex....................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									EXEC @RET = [SP_ExcluirCliente] 1

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									SELECT @RET AS RETORNO,
											DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 

									ROLLBACK TRAN

					--	RETORNO  --
						00.................: Sucesso.
						01.................:	Erro.
	*/
	BEGIN
		UPDATE [dbo].[Cliente]  SET Ativo = 0
			WHERE Id = @Id_Cliente			
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarSenhaCliente]
	@Id_Cliente INT,
	@Senha VARCHAR(64) 
		
	AS
    /*
	Documentacao
	Arquivo Fonte.........: Cliente.sql
	Objetivo..............: Alterar senha do cliente.
	Autor.................: Rafael Mauricio
	Data..................: 10/05/2024
	Ex....................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								SELECT	Id,
										Nome,
										Email,
										Senha,
										CPF,
										Telefone,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] 

								EXEC @RET = [SP_AtualizarSenhaCliente] 2 , 'OndaTecnologica'

								SELECT	Id,
										Nome,
										Email,
										Senha,
										CPF,
										Telefone,
										DataNascimento,
										Ativo
									FROM [dbo].[Cliente] 

								SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 

							ROLLBACK TRAN

					--	RETORNO  --
						00.................: Sucesso.
						01.................:	Erro.
	*/
	BEGIN
		UPDATE [dbo].[Cliente]  SET Senha = @Senha
			WHERE Id = @Id_Cliente			
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarTelefoneCliente]
		@Id_Cliente INT,
		@Telefone BIGINT
		
		AS
        /*
		Documentacao
		Arquivo Fonte.........: Cliente.sql
		Objetivo..............: Alterar telefone do cliente.
		Autor.................: Rafael Mauricio
		Data..................: 10/05/2024
		Ex....................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									EXEC @RET = [SP_AtualizarTelefoneCliente] 2, 83988597017

									SELECT	Id,
											Nome,
											Email,
											Senha,
											CPF,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 

								ROLLBACK TRAN

						--	RETORNO  --
							00.................: Sucesso.
							01.................:	Erro.
	   */
		BEGIN

			UPDATE [dbo].[Cliente]  SET Telefone = @Telefone
				WHERE Id = @Id_Cliente

			IF @@ROWCOUNT <> 0
				RETURN 0
			ELSE
				RETURN 1

		END
GO