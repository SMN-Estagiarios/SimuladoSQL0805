--Dropar tabelas
DROP TABLE Parcela
GO
DROP TABLE Lancamento
GO
DROP TABLE TipoLancamento
GO
DROP TABLE Transferencia
GO
DROP TABLE Despesa
GO
DROP TABLE TipoDespesa
GO
DROP TABLE Juros
GO
DROP TABLE Compra
GO
DROP TABLE Venda
GO
DROP TABLE Conta
GO
DROP TABLE Apartamento
GO
DROP TABLE Predio
GO
DROP TABLE Cliente
GO
DROP TABLE ValorIndice
GO
DROP TABLE Indice
GO

--Dropar Procedures
DROP PROCEDURE [dbo].[SP_InserirCliente]
GO
DROP PROCEDURE [dbo].[SP_DesativarCliente]
GO
DROP PROCEDURE [dbo].[SP_AtualizarCliente]
GO
DROP PROCEDURE [dbo].[SP_ListarCliente]
GO
DROP PROCEDURE [dbo].[SP_InserirVenda]
GO

--Dropar Jobs
DROP PROCEDURE [dbo].[SPJOB_GerarParcela]
GO