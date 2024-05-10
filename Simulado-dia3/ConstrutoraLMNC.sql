CREATE DATABASE DB_ConstrutoraLMNC 
GO 

USE DB_ConstrutoraLMNC
GO  

CREATE TABLE Indice(
	Id TINYINT, 
	Nome VARCHAR(20) NOT NULL
	CONSTRAINT PK_IdIndice PRIMARY KEY (Id)
);


CREATE TABLE ValorIndice (
	Id SMALLINT IDENTITY,
	IdIndice TINYINT NOT NULL,
	Aliquota DECIMAL(4,3) NOT NULL,
	DataInicio DATE NOT NULL

	CONSTRAINT PK_IdValorIndice PRIMARY KEY (Id),
	CONSTRAINT FK_IdIndice_ValorIndice FOREIGN KEY (IdIndice) REFERENCES Indice(Id)
);

CREATE TABLE Cliente (
	Id INT IDENTITY,
	Nome VARCHAR(100) NOT NULL,
	Email VARCHAR(120) NOT NULL,
	Senha VARCHAR(64) NOT NULL,
	CPF BIGINT NOT nULL,
	Telefone BIGINT NOT NULL,
	DataNascimento DATE NOT NULL,
	Ativo BIT NOT NULL

	CONSTRAINT PK_Cliente PRIMARY KEY (Id)
);

CREATE TABLE Predio (
	Id SMALLINT IDENTITY,
	Nome VARCHAR(40) NOT NULL,
	CEP INT NOT NULL,
	UF CHAR(2) NOT NULL,
	Cidade VARCHAR(60) NOT NULL,
	Bairro VARCHAR (60) NOT NULL,
	Logradouro VARCHAR(80) NOT NULL,
	Numero VARCHAR(4) NOT NULL,
	TotalPavimento TINYINT NOT NULL,
	QuantidadeApartamentoPorPavimento TINYINT NOT NULL,
	Entregue BIT NOT NULL

	CONSTRAINT PK_IdPredio PRIMARY KEY (Id)
);

CREATE TABLE Apartamento (
	Id INT IDENTITY, 
	IdPredio SMALLINT NOT NULL,
	Numero TINYINT NOT NULL,
	Pavimento TINYINT NOT NULL

	CONSTRAINT PK_IdApartamento PRIMARY KEY(Id),
	CONSTRAINT FK_IdPredio_Apartamento FOREIGN KEY (IdPredio) REFERENCES Predio (Id)
);

CREATE TABLE Conta(
	Id INT IDENTITY,
	IdCliente INT NOT NULL,
	ValorSaldoInicial DECIMAL (10,2) NOT NULL, 
	ValorCredito DECIMAL (10,2) NOT NULL,
	ValorDebito DECIMAL (10,2) NOT NULL, 
	DataSaldo DATE NOT NULL,
	DataAbertura DATE NOT NULL,
	DataEncerramento DATE, 
	Ativo BIT NOT NULL

	CONSTRAINT PK_IdConta PRIMARY KEY(Id),
	CONSTRAINT FK_IdCliente_Conta FOREIGN KEY(IdCliente) REFERENCES Cliente(Id)
);

CREATE TABLE Venda(
	Id INT IDENTITY, 
	IdCliente INT NOT NULL,
	IdApartamento INT NOT NULL,
	IdIndice TINYINT,
	Valor DECIMAL (10,2) NOT NULL,
	DataVenda DATE NOT NULL,
	Financiado BIT NOT NULL,
	TotalParcela SMALLINT NOT NULL

	CONSTRAINT PK_IdVenda PRIMARY KEY (Id),
	CONSTRAINT FK_IdCliente_Venda FOREIGN KEY (IdCliente) REFERENCES Cliente(Id),
	CONSTRAINT FK_IdApartamento_Venda FOREIGN KEY (IdApartamento) REFERENCES Apartamento(Id),
	CONSTRAINT FK_IdIndice_Venda FOREIGN KEY (IdIndice) REFERENCES Indice(Id)
);

CREATE TABLE Compra(
	Id INT IDENTITY,
	Valor DECIMAL(10,2) NOT NULL,
	DataCompra DATE NOT NULL,
	Descricao VARCHAR(500) NOT NULL,
	TotalParcela SMALLINT NOT NULL,
	
	CONSTRAINT PK_IdCompra PRIMARY KEY (Id)
);
 

CREATE TABLE Juros (
	Id TINYINT IDENTITY,
	Aliquota DECIMAL(4,3) NOT NULL,
	DataInicio DATE NOT NULL

	CONSTRAINT PK_IdJuros PRIMARY KEY (Id)
);

CREATE TABLE TipoDespesa (
	Id TINYINT,
	Nome VARCHAR(40) NOT NULL

	CONSTRAINT PK_IdTipoDespesa PRIMARY KEY (Id)
);

CREATE TABLE Despesa (
	Id INT IDENTITY,
	IdTipo TINYINT NOT NULL,
	Descricao VARCHAR(200) NOT NULL,
	Valor DECIMAL(10,2) NOT NULL,
	DataVencimento DATE

	CONSTRAINT PK_IdDespesa PRIMARY KEY (Id),
	CONSTRAINT FK_IdTipo_Despesa FOREIGN KEY (IdTipo) REFERENCES TipoDespesa(Id)
);


CREATE TABLE Transferencia (
	Id INT IDENTITY, 
	IdContaCredito INT NOT NULL, 
	IdContaDebito INT NOT NULL, 
	Valor DECIMAL (10,2) NOT NULL,
	NomeHistorico VARCHAR (200) NOT NULL,
	DataTransferencia DATETIME NOT NULL

	CONSTRAINT PK_IdTransferencia PRIMARY KEY (Id),
	CONSTRAINT FK_IdContaCredito_Transferencias FOREIGN KEY (IdContaCredito) REFERENCES Conta(Id),
	CONSTRAINT FK_IdContaDebito_Transferencias FOREIGN KEY (IdContaDebito) REFERENCES Conta(Id)
);

CREATE TABLE TipoLancamento (
	Id TINYINT,
	Nome VARCHAR(30) NOT NULL

	CONSTRAINT PK_IdTipoLancamento PRIMARY KEY (Id)
);

CREATE TABLE Lancamento (
	Id INT IDENTITY, 
	IdConta INT NOT NULL,
	IdTipo TINYINT NOT NULL,
	IdTransferencia INT,
	IdDespesa INT,
	TipoOperacao CHAR(1) NOT NULL,
	Valor Decimal (10,2) NOT NULL,
	NomeHistorico VARCHAR(200) NOT NULL,
	DataLancamento DATETIME NOT NULL

	CONSTRAINT PK_IdLancamentos PRIMARY KEY(Id),
	CONSTRAINT FK_IdConta_Lancamento FOREIGN KEY (IdConta) REFERENCES Conta(Id),
	CONSTRAINT FK_IdTipo_Lancamento FOREIGN KEY (IdTipo) REFERENCES TipoLancamento(Id),
	CONSTRAINT FK_IdTransferencia_Lancamento FOREIGN KEY (IdTransferencia) REFERENCES Transferencia(Id),
	CONSTRAINT FK_IdDespesa_Lancamento FOREIGN KEY (IdDespesa) REFERENCES Despesa(Id),
	CONSTRAINT CHK_Tipo_Operacao_C_D CHECK(TipoOperacao = 'C' OR TipoOperacao = 'D')
);

CREATE TABLE Parcela (
	Id INT IDENTITY, 
	IdVenda INT,
	IdCompra INT,
	IdJuros TINYINT,
	IdLancamento INT,
	Valor DECIMAL (10,2) NOT NULL,
	DataVencimento DATE NOT NULL

	CONSTRAINT PK_IdParcela PRIMARY KEY (Id),
	CONSTRAINT FK_IdVenda_Parcela FOREIGN KEY (IdVenda) REFERENCES Venda(Id),
	CONSTRAINT FK_IdLancamento_Parcela FOREIGN KEY (IdLancamento) REFERENCES Lancamento(Id),
	CONSTRAINT FK_IdCompra_Parcela FOREIGN KEY (IdCompra) REFERENCES Compra(Id),
	CONSTRAINT FK_IdJuros_Parcela FOREIGN KEY (IdJuros) REFERENCES Juros(Id)
);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------INSERTS DE DADOS----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE DB_ConstrutoraLMNC;
GO

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
	VALUES	(5000.00, '2024-05-05', 'Material de construção', 1),
			(3000.00, '2024-04-28', 'Mobília para apartamento', 1);

-- Inserir lançamentos
INSERT INTO [dbo].[Lancamento](IdConta, IdTipo, TipoOperacao, Valor, NomeHistorico, DataLancamento)
	VALUES	(1, 1, 'D', 500.00, 'Transferência para investimento', '2024-05-08'),
			(2, 4, 'D', 1000.00, 'Pagamento de contas de água e energia', '2024-05-07'),
			(3, 2, 'D', 200.00, 'Pagamento de parcela do financiamento', '2024-05-10');

-- Inserir parcelas
INSERT INTO [dbo].[Parcela](IdVenda, IdCompra, IdJuros, IdLancamento, Valor, DataVencimento)
	VALUES	(NULL, 1, 1, 3, 1000.00, '2024-06-05');