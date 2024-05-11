CREATE OR ALTER PROCEDURE [dbo].[SP_InserirCliente] 
	@Nome VARCHAR(100),
	@Email VARCHAR(120),
	@Senha VARCHAR(64),
	@Cpf BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
	AS 
	/*
	Documentacao
	Arquivo Fonte........: Cliente.sql
	Objetivo.............: Registrar cliente na tabela [dbo].[Cliente]
	Autor................: Thays Carvalho
	Data.................: 10/05/2024
	Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@DataInicio DATETIME = GETDATE()

									SELECT	Id,
											Nome,
											Email,
											Senha,
											Cpf,
											Telefone,
											DataNascimento,
											Ativo
										FROM [dbo].[Cliente] 

									EXEC @RET = [dbo].[SP_InserirCliente] 'Thays Carvalho','thays@smn.com','Sashimi123',14345678911,83988645230,'1987-01-05'

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @DataInicio, GETDATE()) AS TempoExecucao

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

							RETORNO
							0: Sucesso
							1: Erro ao criar conta - CPF já cadastrado																
	*/

	--Verifica se CPF já está cadastrado
		BEGIN
			IF EXISTS (SELECT TOP 1 1
										FROM [dbo].[Cliente] WITH (NOLOCK)
										WHERE cpf = @Cpf)
				BEGIN
					RETURN 1
				END
	--Insere novo cliente na tabela
			INSERT INTO [dbo].[Cliente] (Nome,Email,Senha,Cpf,Telefone,DataNascimento,Ativo)
				VALUES (@Nome,@Email,@Senha,@Cpf,@Telefone,@DataNascimento,1);
				
				RETURN 0
		END
GO