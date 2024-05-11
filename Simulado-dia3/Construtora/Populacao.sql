USE DB_ConstrutoraLMNC;

DECLARE @DataInicio DATETIME = GETDATE() - 10

INSERT INTO [dbo].[Indice](Id, Nome) 
		VALUES	(1, 'INCC'),
				(2, 'IGPM')

INSERT INTO [dbo].[ValorIndice](IdIndice, Aliquota, DataInicio)
		VALUES	(1, 0.002,  @DataInicio),
				(2, 0.0031,  @DataInicio)

INSERT INTO [dbo].[Juros](Aliquota, DataInicio)
	VALUES	(0.01,  @DataInicio)
	
INSERT INTO [dbo].[TipoDespesa](Id, Nome)
	VALUES	(1, 'Folha de pagamento'),
			(2, 'Contas')

INSERT INTO [dbo].[Despesa](IdTipo, Valor, Descricao, DataVencimento)
	VALUES	(1, 120000, 'Folha de pagamento referente ao mês', @DataInicio),
			(2, 1000, 'Somatório das contas de água e energia do mês', @DataInicio)

INSERT INTO [dbo].[TipoLancamento](Id, Nome)
	VALUES	(1, 'Transferência'),
			(2, 'Compra'),
			(3, 'Despesa'),
			(4, 'Pagamento de parcela'),
			(5, 'Recebimento de parcela')
		
SET IDENTITY_INSERT [dbo].[Cliente] ON
INSERT INTO [dbo].[Cliente](Id, Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
	VALUES (0, 'Maerton Financeiro', 'maerton@example.com', HASHBYTES('SHA2_256', 'euamopipoca'), 12345678900, '8399139698', '01/01/1950', 1)
SET IDENTITY_INSERT [dbo].[Cliente] OFF

SET IDENTITY_INSERT [dbo].[Conta] ON
INSERT INTO  [dbo].[Conta](Id, IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo, DataAbertura, DataEncerramento, Ativo)
	VALUES	(0, 0, 800000, 0, 0, GETDATE(), @DataInicio, NULL, 1)
SET IDENTITY_INSERT [dbo].[Conta] OFF

-- Inserir clientes
INSERT INTO [dbo].[Cliente](Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
	VALUES	('Maria Silva', 'maria@example.com', 'senha123', 12345678901, 987654321, '1990-05-15', 1),
			('João Oliveira', 'joao@example.com', 'senha456', 98765432109, 123456789, '1985-08-20', 1),
			('Ana Santos', 'ana@example.com', 'senha789', 45678901234, 999888777, '1995-12-10', 1);

-- Inserir mais prédios
INSERT INTO [dbo].[Predio](Nome, CEP, UF, Cidade, Bairro, Logradouro, Numero, TotalPavimento, QuantidadeApartamentoPorPavimento, Entregue)
	VALUES	('SoBalanca', 12345678, 'SP', 'São Paulo', 'Centro', 'Rua Aurora', '123', 23, 4, 1),
			('TremeTreme', 12345678, 'SP', 'São Paulo', 'Centro', 'Rua Xablau', '623', 52, 6, 1),
			('AgoraCai', 12341234, 'SP', 'Pernambuco', 'Centro', 'Rua Vaivai', '153', 10, 2, 1),
			('MinhaCasaMinhaQueda', 10220022, 'RJ', 'Rio de Janeiro', 'Centro', 'Rua Pedro', '581', 15, 8, 0),
			('SoBaTenhoFelanca', 15987632, 'PB', 'Joao Pessoa', 'Centro', 'Rua Fulano', '126', 20, 6, 0)

-- Inserir contas
INSERT INTO [dbo].[Conta](IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo, DataAbertura, DataEncerramento, Ativo)
	VALUES	(1, 5000.00, 1000.00, 200.00, '2024-05-10', '2024-01-01', NULL, 1),
			(2, 7000.00, 200.00, 1000.00, '2024-05-10', '2023-06-01', NULL, 1),
			(3, 3000.00, 500.00, 300.00, '2024-05-10', '2024-03-15', NULL, 1);

-- Inserir compras
INSERT INTO [dbo].[Compra](Valor, DataCompra, Descricao, TotalParcela)
	VALUES	(5000.00, '2024-05-05', 'Material de construção', 2),
			(3000.00, '2024-04-28', 'Mobília para apartamento', 5);

-- Inserir lançamentos
INSERT INTO [dbo].[Lancamento](IdConta, IdTipo, TipoOperacao, Valor, NomeHistorico, DataLancamento)
	VALUES	(1, 1, 'D', 500.00, 'Transferência para investimento', '2024-05-08'),
			(2, 4, 'D', 1000.00, 'Pagamento de contas de água e energia', '2024-05-07'),
			(3, 2, 'C', 200.00, 'Pagamento de parcela do financiamento', '2024-05-10');

-- Inserir parcelas
INSERT INTO [dbo].[Parcela](IdVenda, IdCompra, IdJuros, IdLancamento, Valor, DataVencimento)
	VALUES	(NULL, 1, NULL, 3, 1000.00, '2024-06-05');