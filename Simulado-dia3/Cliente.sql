USE DB_ConstrutoraLMNC;

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirCliente] 
	@Nome VARCHAR(500),
	@Email VARCHAR(500),
	@Senha VARCHAR(64),
	@Cpf BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
AS 
	/*
	Documentacao
	Arquivo Fonte.....: Cliente.sql
	Objetivo.............: Cria um cliente na tabela [dbo].[Cliente]
	Autor.................: Pedro Avelino
	Data..................: 10/05/2024
	Ex.....................: 
								BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT	Id,
												Nome,
												Email,
												Senha,
												Cpf,
												Telefone,
												DataNascimento,
												Ativo
										FROM [dbo].[Cliente] 

									EXEC @RET = [dbo].[SP_InserirCliente] 'Finado Betoneira','betuoneira@gmail.com','Beto1234',78965412324,83987741236,'2000-01-01'

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

									SELECT	Id,
												Nome,
												Email,
												Senha,
												Cpf,
												Telefone,
												DataNascimento,
												Ativo
										FROM [dbo].[Cliente] 
								ROLLBACK TRAN

		--	RETORNO   --
		00.................: Erro ao criar conta
		01.................: Sucesso																
		*/
		BEGIN
				
			INSERT INTO [dbo].[Cliente] (Nome,Email,Senha,Cpf,Telefone,DataNascimento,Ativo) VALUES   				
														(@Nome,@Email,@Senha,@Cpf,@Telefone,@DataNascimento,1);

			IF @@ROWCOUNT <> 0
				RETURN 0
			ELSE
				RETURN 1
				
		END;

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirCliente]
		@Id_Cliente INT
AS
        /*
		Documentacao
		Arquivo Fonte.....: Cliente.sql
		Objetivo.............: Mudar para desativo um Cliente
		Autor.................: Pedro Avelino
		Data..................: 10/05/2024
		Ex.....................: 
									BEGIN TRAN
											DBCC DROPCLEANBUFFERS;
											DBCC FREEPROCCACHE;

												DECLARE @RET INT, 
												@Dat_init DATETIME = GETDATE()

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
															Telefone,
															DataNascimento,
															Ativo
													FROM [dbo].[Cliente] 

												EXEC @RET = [SP_ExcluirCliente] 1

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
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
				WHERE Id = @Id_Cliente;			

			IF @@ROWCOUNT <> 0
				RETURN 0
			ELSE
				RETURN 1
		END;

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarSenhaCliente]
		@Id_Cliente INT,
		@Senha VARCHAR(64) 
		
AS
        /*
		Documentacao
		Arquivo Fonte.....: Cliente.sql
		Objetivo.............: Alterar senha do cliente.
		Autor.................: Pedro Avelino
		Data..................: 10/05/2024
		Ex.....................: 
									BEGIN TRAN
											DBCC DROPCLEANBUFFERS;
											DBCC FREEPROCCACHE;

												DECLARE @RET INT, 
												@Dat_init DATETIME = GETDATE()

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
															Telefone,
															DataNascimento,
															Ativo
													FROM [dbo].[Cliente] 

												EXEC @RET = [SP_AtualizarSenhaCliente] 1 , 'BetuMono360'

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
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

		END;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarTelefoneCliente]
		@Id_Cliente INT,
		@Telefone BIGINT
		
		AS
        /*
		Documentacao
		Arquivo Fonte.....: Cliente.sql
		Objetivo.............: Alterar telefone do cliente.
		Autor.................: Pedro Avelino
		Data..................: 10/05/2024
		Ex.....................: 
									BEGIN TRAN
											DBCC DROPCLEANBUFFERS;
											DBCC FREEPROCCACHE;

												DECLARE @RET INT, 
												@Dat_init DATETIME = GETDATE()

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
															Telefone,
															DataNascimento,
															Ativo
													FROM [dbo].[Cliente] 

												EXEC @RET = [SP_AtualizarTelefoneCliente] 1, 83988991664

												SELECT	Id,
															Nome,
															Email,
															Senha,
															Cpf,
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

		END;
GO