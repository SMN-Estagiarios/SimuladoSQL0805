CREATE OR ALTER PROCEDURE [dbo].[SP_ListarClientes]
	@IdCliente INT = NULL
	AS
	/*
		Documentação
		Arquivo fonte........: Cliente.sql
		Objetivo.............: Listar todos os clientes ativos
		Autor................: Gustavo Targino
		Data.................: 10/05/2024
		Ex...................: BEGIN TRAN
									
									DECLARE @DataInicio DATETIME = GETDATE()

									EXEC [dbo].[SP_ListarClientes]
									
									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo

							   ROLLBACK

	*/
	BEGIN
		-- Selecionando os clientes ativos
		SELECT c.Id,
			   c.Nome,
			   c.Email,
			   c.Senha,
			   c.CPF,
			   c.DataNascimento,
			   c.Telefone
			FROM [dbo].[Cliente] c WITH(NOLOCK)
				WHERE c.Id = ISNULL(@IdCliente, c.Id)
				AND c.Ativo = 1

	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_AdicionarCliente]
	@Nome VARCHAR(100),
	@Email VARCHAR(120),
	@Senha VARCHAR(64),
	@CPF BIGINT,
	@Telefone BIGINT,
	@DataNascimento DATE
	AS
	/*
		Documentação
		Arquivo fonte........: Cliente.sql
		Objetivo.............: Adicionar um cliente
		Autor................: Gustavo Targino
		Data.................: 10/05/2024
		Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;
									DECLARE @DataInicio DATETIME = GETDATE(),
											@Ret INT

									SELECT * FROM [dbo].[Cliente] WITH(NOLOCK)

									EXEC @Ret = [dbo].[SP_AdicionarCliente] 'Gustavo', 'gustavo.targino@smn.com.br', 'Hallo Leute', 12121212121, 81992693880, @DataInicio
									
									SELECT * FROM [dbo].[Cliente] WITH(NOLOCK)

									SELECT @Ret Retorno,
										   DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo
							   ROLLBACK

		Retornos.............: 0 - Cliente inserido com sucesso
							   1 - Já possui um cliente com este email, cpf ou telefone
							   2 - Erro ao inserir cliente

	*/
	BEGIN
		-- Verificando se existe algum registro com este email, cpf ou telefone
		IF EXISTS (
					SELECT TOP 1 1
						FROM [dbo].[Cliente] c WITH(NOLOCK)
							WHERE  c.CPF = @CPF
								OR c.Email = @Email
								OR c.Telefone = @Telefone
				  )
			RETURN 1

		-- Inserindo o cliente
		INSERT INTO [dbo].[Cliente] (Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
			VALUES (@Nome, @Email, HASHBYTES('SHA2_256', @Senha), @CPF, @Telefone, @DataNascimento, 1)
		
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 2

		RETURN 0

	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarCliente]
	@CPF BIGINT,
	@Nome VARCHAR(100) = NULL,
	@SenhaNova VARCHAR(64) = NULL,
	@Telefone BIGINT = NULL
	AS
	/*
		Documentação
		Arquivo fonte........: Cliente.sql
		Objetivo.............: Atualizar nome, senha ou telefone de um cliente
		Autor................: Gustavo Targino
		Data.................: 10/05/2024
		Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;
									DECLARE @DataInicio DATETIME = GETDATE(),
											@Ret INT

									SELECT * FROM [dbo].[Cliente] WITH(NOLOCK)
									
									EXEC @Ret = [dbo].[SP_AtualizarCliente] 12345678901, 'Maria Silva Santos', 'Maria123', 83999999999
									
									SELECT * FROM [dbo].[Cliente] WITH(NOLOCK)

									SELECT @Ret Retorno,
										   DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo
							   ROLLBACK

		Retornos.............: 0 - Cliente atualizado com sucesso
							   1 - Não existe cliente com este CPF
							   2 - Já existe um cliente com este telefone
							   3 - Erro ao atualizar cliente

	*/
	BEGIN
		-- Verificando se existe algum registro com este email, cpf ou telefone
		IF NOT EXISTS (
					SELECT TOP 1 1
						FROM [dbo].[Cliente] c WITH(NOLOCK)
							WHERE  c.CPF = @CPF
				  )
			RETURN 1

		-- Verificando se existe algum registro com este telefone
		IF EXISTS (
					SELECT TOP 1 1
						FROM [dbo].[Cliente] c WITH(NOLOCK)
							WHERE c.Telefone = c.Telefone
 				  )
			RETURN 2

		-- Atualizando o cliente
		UPDATE [dbo].[Cliente] 
			SET Nome = ISNULL(@Nome, Nome),
				Senha = ISNULL(@SenhaNova, Senha),
				Telefone = ISNULL(@Telefone, Telefone)
			WHERE CPF = @CPF
		
		-- Checagem de erro
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 3

		RETURN 0

	END