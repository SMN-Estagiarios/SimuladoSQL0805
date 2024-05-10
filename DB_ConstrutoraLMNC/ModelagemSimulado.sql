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
	DataInicio DATE NOT NULL,
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
	Entregue BIT NOT NULL,
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
	Ativo BIT NOT NULL,
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
	Descricao VARCHAR(500) NOT NULL
	CONSTRAINT PK_IdCompra PRIMARY KEY (Id)
);

CREATE TABLE Juros (
	Id TINYINT IDENTITY,
	Aliquota DECIMAL(4,3) NOT NULL,
	DataInicio DATE NOT NULL,
	CONSTRAINT PK_IdJuros PRIMARY KEY (Id)
);

CREATE TABLE TipoDespesa (
	Id TINYINT,
	Nome VARCHAR(40) NOT NULL
	CONSTRAINT PK_IdTipoDespesa PRIMARY KEY (Id),
);

CREATE TABLE Despesa (
	Id INT IDENTITY,
	IdTipo TINYINT NOT NULL,
	Descricao VARCHAR(200) NOT NULL,
	DataVencimento DATE
	CONSTRAINT PK_IdDespesa PRIMARY KEY (Id),
	CONSTRAINT FK_IdTipo_Despesa FOREIGN KEY (IdTipo) REFERENCES TipoDespesa(Id),
);


CREATE TABLE Transferencia (
	Id INT IDENTITY, 
	IdContaCredito INT NOT NULL, 
	IdContaDebito INT NOT NULL, 
	Valor DECIMAL (10,2) NOT NULL,
	NomeHistorico VARCHAR (200) NOT NULL,
	DataTransferencia DATETIME NOT NULL,
	CONSTRAINT PK_IdTransferencia PRIMARY KEY (Id),
	CONSTRAINT FK_IdContaCredito_Transferencias FOREIGN KEY (IdContaCredito) REFERENCES Conta(Id),
	CONSTRAINT FK_IdContaDebito_Transferencias FOREIGN KEY (IdContaDebito) REFERENCES Conta(Id)
);

CREATE TABLE TipoLancamento (
	Id TINYINT,
	Nome VARCHAR(20) NOT NULL
	CONSTRAINT PK_IdTipoLancamento PRIMARY KEY (Id),
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
	DataLancamento DATETIME NOT NULL,
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
	IdJuros TINYINT NOT NULL,
	IdLancamento INT,
	Valor DECIMAL (10,2) NOT NULL,
	DataVencimento DATE NOT NULL,
	CONSTRAINT PK_IdParcela PRIMARY KEY (Id),
	CONSTRAINT FK_IdVenda_Parcela FOREIGN KEY (IdVenda) REFERENCES Venda(Id),
	CONSTRAINT FK_IdLancamento_Parcela FOREIGN KEY (IdLancamento) REFERENCES Lancamento(Id),
	CONSTRAINT FK_IdCompra_Parcela FOREIGN KEY (IdCompra) REFERENCES Compra(Id),
	CONSTRAINT FK_IdJuros_Parcela FOREIGN KEY (IdJuros) REFERENCES Juros(Id)
);