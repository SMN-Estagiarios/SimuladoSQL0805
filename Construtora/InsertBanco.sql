DECLARE @DataInicio DATETIME = GETDATE() - 10

--Indice
INSERT INTO [dbo].[Indice](Id, Nome) 
				  VALUES  (1, 'INCC'),
						  (2, 'IGPM')

--ValorIndice
INSERT INTO [dbo].[ValorIndice](IdIndice, Aliquota, DataInicio)
						VALUES (1, 0.002,  @DataInicio),
							   (2, 0.0031,  @DataInicio)

--Juros
INSERT INTO [dbo].[Juros](Aliquota, DataInicio)
				  VALUES (0.01,  @DataInicio)

--TipoDespesa	
INSERT INTO [dbo].[TipoDespesa](Id, Nome)
						VALUES (1, 'Folha de pagamento'),
							   (2, 'Contas')

--Despesa
INSERT INTO [dbo].[Despesa](IdTipo, Valor, Descricao, DataVencimento)
				    VALUES (1, 120000, 'Folha de pagamento referente ao mês', @DataInicio),
						   (2, 1000, 'Somatório das contas de água e energia do mês', @DataInicio)

--TipoLancamento
INSERT INTO [dbo].[TipoLancamento](Id, Nome)
						VALUES	  (1, 'Transferência'),
								  (2, 'Pagamento de parcela'),
								  (3, 'Compra'),
								  (4, 'Despesa')
		
--Cliente
SET IDENTITY_INSERT [dbo].[Cliente] ON
	INSERT INTO [dbo].[Cliente](Id, Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
						VALUES (0, 'Maerton Financeiro', 'maerton@gmail.com', HASHBYTES('SHA2_256', 'senha111'), 12345678900, 83991396983, '01/01/1950', 1)
SET IDENTITY_INSERT [dbo].[Cliente] OFF
	INSERT INTO [dbo].[Cliente](Nome, Email, Senha, CPF, Telefone, DataNascimento, Ativo)
						VALUES ('Rafael Valentim', 'rafaelvalentim@gmail.com', HASHBYTES('SHA2_256', 'senha222'), 12345678901, 83966415334, '1990-05-15', 1),
							   ('Ricardo Corrales', 'ricardocorrales@gmail.com', HASHBYTES('SHA2_256', 'senha333'), 98765432109, 83926401124, '1985-08-20', 1),
							   ('José Fleumas', 'josefleumas@gmail.com', HASHBYTES('SHA2_256', 'senha444'), 45678901234, 83950732853, '1995-12-10', 1)

--Conta
SET IDENTITY_INSERT [dbo].[Conta] ON
	INSERT INTO  [dbo].[Conta](Id, IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo, DataAbertura, DataEncerramento, Ativo)
					   VALUES (0, 0, 800000, 0, 0, GETDATE(), @DataInicio, NULL, 1)
SET IDENTITY_INSERT [dbo].[Conta] OFF
INSERT INTO [dbo].[Conta](IdCliente, ValorSaldoInicial, ValorCredito, ValorDebito, DataSaldo, DataAbertura, DataEncerramento, Ativo)
					VALUES	 (1, 5000.00, 1000.00, 200.00, '2024-05-10', '2024-01-01', NULL, 1),
							 (2, 7000.00, 200.00, 1000.00, '2024-05-10', '2023-06-01', NULL, 1),
							 (3, 3000.00, 500.00, 300.00, '2024-05-10', '2024-03-15', NULL, 1)

--Predio
INSERT INTO [dbo].[Predio](Nome, CEP, UF, Cidade, Bairro, Logradouro, Numero, TotalPavimento, QuantidadeApartamentoPorPavimento, Entregue)
				VALUES	  ('SoBalanca', 12345678, 'SP', 'São Paulo', 'Centro', 'Rua Aurora', '123', 23, 4, 1),
						  ('TremeTreme', 12345678, 'SP', 'São Paulo', 'Centro', 'Rua Xablau', '623', 52, 6, 1),
						  ('AgoraCai', 12341234, 'SP', 'Pernambuco', 'Centro', 'Rua Vaivai', '153', 10, 2, 1),
						  ('MinhaCasaMinhaQueda', 10220022, 'RJ', 'Rio de Janeiro', 'Centro', 'Rua Pedro', '581', 15, 8, 0),
						  ('SoBaTenhoFelanca', 15987632, 'PB', 'Joao Pessoa', 'Centro', 'Rua Fulano', '126', 20, 6, 0)
			

--Apartamento
INSERT INTO [dbo].[Apartamento](IdPredio, Numero, Pavimento)
						VALUES (1, 101, 1),
							   (1, 102, 1),
							   (2, 201, 2),
							   (2, 202, 2)

--Venda
INSERT INTO [dbo].[Venda](IdCliente, IdApartamento, IdIndice, Valor, DataVenda, Financiado, TotalParcela)
				VALUES	 (1, 1, 1, 150000.00, '2024-04-10', 1, 120),
						 (2, 3, 2, 200000.00, '2024-04-25', 0, 1)

--Compra
INSERT INTO [dbo].[Compra](Valor, DataCompra, Descricao)
				VALUES	  (5000.00, '2024-05-05', 'Material de construção'),
						  (3000.00, '2024-04-28', 'Mobília para apartamento')

--Lancamento
INSERT INTO [dbo].[Lancamento](IdConta, IdTipo, TipoOperacao, Valor, NomeHistorico, DataLancamento)
					VALUES	  (1, 1, 'D', 500.00, 'Transferência para investimento', '2024-05-08'),
							  (2, 4, 'D', 1000.00, 'Pagamento de contas de água e energia', '2024-05-07'),
							  (3, 2, 'C', 200.00, 'Pagamento de parcela do financiamento', '2024-05-10')

--Parcela
INSERT INTO [dbo].[Parcela](IdVenda, IdCompra, IdJuros, IdLancamento, Valor, DataVencimento)
					VALUES (1, NULL, 1, NULL, 1250.00, '2024-06-20'),
						   (NULL, 1, 1, 3, 1000.00, '2024-06-05')						  