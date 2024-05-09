CREATE OR ALTER PROCEDURE spBuscarRelatorioGerencial
    @dataGeracao DATETIME,
    @empresa NUMERIC = NULL,
    @diretorComercial NUMERIC = NULL,
    @gerenteComercial NUMERIC = NULL,
    @usuarioBackoffice NUMERIC = NULL,
    @usuarioAuditoria NUMERIC = NULL
AS BEGIN
    SET NOCOUNT ON;
    
    DECLARE @30dias_atras AS DATETIME = cast(@dataGeracao - 30 AS date),
            @60dias_atras AS DATETIME = cast(@dataGeracao - 60 AS date),
            @90dias_atras AS DATETIME = cast(@dataGeracao - 90 AS date),
            @120dias_atras AS DATETIME = cast(@dataGeracao - 120 AS date),
            @150dias_atras AS DATETIME = cast(@dataGeracao - 150 AS date),
            @180dias_atras AS DATETIME = cast(@dataGeracao - 180 AS date);

    ;WITH Gerencial AS (
        SELECT  gere.CEDE_CD_CGC_CPF AS CnpjCedente,
                cede.CEDE_NM_RAZAO_SOCIAL AS RazaoSocialCedente,
                ISNULL(cede.CEDE_FL_LIMINAR, '0') AS TemLiminar,
                ISNULL(cede.CEDE_FL_CARTORIO, '0') AS TemCartorio,
                ISNULL(gere.CEDE_FL_RENOVACAO, '0') AS Renovacao,
                cede.CEDE_VL_LIMITE_SACADO AS LimiteSacado,
                gcon.GCON_DS_NOME AS Comercial,
                gcon.GCON_DS_SIGLA AS SiglaComercial,
                (SELECT CAST(gere.GERE_DT_GERACAO - MAX(OPER.OPER_DT_OPERACAO) AS NUMERIC(4))
                    FROM ATVTOPER OPER WITH (NOLOCK)
                        INNER JOIN ATVTOPOF OPOF WITH (NOLOCK)
                            ON OPOF.OPER_CD_OPERACAO = OPER.OPER_CD_OPERACAO
                    WHERE OPER.CEDE_CD_CGC_CPF = gere.CEDE_CD_CGC_CPF
                        AND OPER.OPER_DT_OPERACAO <= gere.GERE_DT_GERACAO
                ) AS DiasUltimaOperacao,
                SUM(gere.CEDE_VL_LIMITE) AS LimiteCedente,
                MAX(gere.CEDE_VL_LIMITE_CRED_OPER) AS LimiteCedenteCreditoOperacao,
                MAX(gere.CEDE_TX_DESAGIO) AS Desagio,
                SUM(gere.GERE_VL_OPERADO) AS ValorOperado,
                SUM(gere.GERE_QT_OPERADO) AS QuantidadeOperado,
                SUM(gere.GERE_VL_LIQUIDADO) AS ValorLiquidado,
                SUM(gere.GERE_QT_LIQUIDADO) AS QuantidadeLiquidado,
                ISNULL(SUM(gere.GERE_VL_CARTEIRA), 0) AS ValorCarteira,
                SUM(gere.GERE_QT_CARTEIRA) AS QuantidadeCarteira,
                ISNULL(SUM(gere.GERE_VL_ATRASO_RECOMPRA), 0) AS ValorAtrasoRecompra,
                SUM(gere.GERE_QT_ATRASO_RECOMPRA) AS QuantidadeAtrasoRecompra,
                ISNULL(SUM(gere.GERE_VL_ATRASO), 0) AS ValorAtraso,
                SUM(gere.GERE_QT_ATRASO) AS QuantidadeAtraso,
                SUM(gere.GERE_VL_CONTA_GRAFICA) AS ValorContaGrafica,
                SUM(gere.GERE_QT_DIAS_CG_NEGATIVO) AS QuantidadeDiasCgNegativo,
                SUM(gere.GERE_VL_OPERADO_SIMPLES) AS ValorOperadoSimples,
                SUM(gere.GERE_QT_OPERADO_SIMPLES) AS QuantidadeOperadoSimples,
                SUM(gere.GERE_VL_LIQUIDADO_SIMPLES) AS ValorLiquidadoSimples,
                SUM(gere.GERE_QT_LIQUIDADO_SIMPLES) AS QuantidadeLiquidadoSimples,
                ISNULL(SUM(gere.GERE_VL_CARTEIRA_SIMPLES), 0) AS ValorCarteiraSimples,
                SUM(gere.GERE_QT_CARTEIRA_SIMPLES) AS QuantidadeCarteiraSimples,
                ISNULL(SUM(gere.GERE_VL_ATRASO_SIMPLES), 0) AS ValorAtrasoSimples,
                ISNULL(SUM(gere.GERE_QT_ATRASO_SIMPLES), 0) AS QuantidadeAtrasoSimples,
                SUM(gere.GERE_VL_AMOSTRA_CONF) AS ValorAmostraConferencia,
                SUM(gere.GERE_QT_AMOSTRA_CONF) AS QuantidadeAmostraConferencia,
                ISNULL(SUM(gere.GERE_VL_CONFIRMAR), 0) AS ValorConfirmar,
                SUM(gere.GERE_QT_CONFIRMAR) AS QuantidadeConfirmar,
                SUM(gere.GERE_VL_MAIOR_CONFIRMAR) AS ValorMaiorConfirmar,
                MAX(FILI.FILI_CD_FILIAL) AS IdEmpresa,
                MAX(FILI.FILI_NM_FILIAL) AS NomeEmpresa,
                MAX(FILI.FILI_NM_NOME_REDUZIDO) AS NomeReduzidoEmpresa,
                MAX(gere.GERE_QT_DIAS_CP_NEGATIVO) AS QuantidadeDiasCpNegativo,
                SUM(gere.GERE_VL_CONTA_PROGRAMADA) AS ValorContaProgramada,
                SUM(gere.GERE_CE_VALOR) AS ValorComprovanteEntrega,
                SUM(gere.GERE_CE_QTDE) AS QuantidadeComprovanteEntrega,
                MAX(gere.GERE_CE_DIAS) AS PrazoComprovanteEntrega,
                SUM(gere.GERE_VL_IRREGULARES) AS ValorIrregulares,
                ISNULL(geco.Descricao, cede.CEDE_NM_RAZAO_SOCIAL) AS GrupoEconomico,
                geco.IdGrupo AS IdGrupoEconomico,
                gere.GERE_VL_PROTESTO AS ValorProtesto
            FROM ATVTGERE GERE WITH (NOLOCK)
                INNER JOIN ATVTCEDE CEDE WITH (NOLOCK)
                    ON gere.CEDE_CD_CGC_CPF = cede.CEDE_CD_CGC_CPF
                INNER JOIN ATVTGCON GCON WITH (NOLOCK)
                    ON cede.GCON_CD_GERENTE_CONTAS = gcon.GCON_CD_GERENTE_CONTAS
                INNER JOIN ATVTFILI FILI WITH (NOLOCK)
                    ON gcon.FILI_CD_FILIAL = FILI.FILI_CD_FILIAL
                LEFT JOIN GrupoEconomico geco WITH (NOLOCK)
                    ON geco.IDGrupo = cede.IDGrupo
            WHERE (gere.GERE_DT_GERACAO = @dataGeracao)
                AND (@empresa IS NULL OR gcon.fili_cd_filial = @empresa) 
                AND (@diretorComercial IS NULL OR cede.GCON_CD_GERENTE_CONTAS_DIR_COM = @diretorComercial)
                AND (@gerenteComercial IS NULL OR gcon.GCON_CD_GERENTE_CONTAS = @gerenteComercial)
                AND (@usuarioBackoffice IS NULL OR cede.USUA_CD_CODIGO = @usuarioBackoffice)
                AND (@usuarioAuditoria IS NULL OR cede.USUA_CD_CODIGO_COMERCIAL = @usuarioAuditoria)
            GROUP BY gere.CEDE_CD_CGC_CPF,
                    gere.GERE_DT_GERACAO,
                    cede.CEDE_NM_RAZAO_SOCIAL,
                    cede.CEDE_FL_LIMINAR,
                    cede.CEDE_FL_CARTORIO,
                    gere.CEDE_FL_RENOVACAO,
                    cede.CEDE_VL_LIMITE_SACADO,
                    gcon.GCON_DS_NOME,
                    gcon.GCON_DS_SIGLA,
                    geco.Descricao,
                    geco.IdGrupo,
                    gere.GERE_VL_PROTESTO
                HAVING (CAST(SUM(gere.GERE_VL_CONTA_GRAFICA) AS INTEGER) <> 0
                    OR CAST(SUM(gere.GERE_VL_CARTEIRA) AS INTEGER) <> 0
                    OR CAST(SUM(gere.GERE_VL_CARTEIRA_SIMPLES) AS INTEGER) <> 0
                )
    ), Liquidados AS (
        SELECT  titu.cede_cd_cgc_cpf AS CnpjCedente,
                SUM(CASE WHEN tofi_dt_pagamento >= @30dias_atras AND tofi_dt_pagamento <= @dataGeracao THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados30,
                SUM(CASE WHEN tofi_dt_pagamento >= @30dias_atras AND tofi_dt_pagamento < @dataGeracao AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados30,
                SUM(CASE WHEN tofi_dt_pagamento >= @60dias_atras AND tofi_dt_pagamento < @30dias_atras THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados60,
                SUM(CASE WHEN tofi_dt_pagamento >= @60dias_atras AND tofi_dt_pagamento < @30dias_atras AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados60,
                SUM(CASE WHEN tofi_dt_pagamento >= @90dias_atras AND tofi_dt_pagamento < @60dias_atras THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados90,
                SUM(CASE WHEN tofi_dt_pagamento >= @90dias_atras AND tofi_dt_pagamento < @60dias_atras AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados90,
                SUM(CASE WHEN tofi_dt_pagamento >= @120dias_atras AND tofi_dt_pagamento < @90dias_atras THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados120,
                SUM(CASE WHEN tofi_dt_pagamento >= @120dias_atras AND tofi_dt_pagamento < @90dias_atras AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados120,
                SUM(CASE WHEN tofi_dt_pagamento >= @150dias_atras AND tofi_dt_pagamento < @120dias_atras THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados150,
                SUM(CASE WHEN tofi_dt_pagamento >= @150dias_atras AND tofi_dt_pagamento < @120dias_atras AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados150,
                SUM(CASE WHEN tofi_dt_pagamento >= @180dias_atras AND tofi_dt_pagamento < @150dias_atras THEN tofi_vl_liquidacao ELSE 0 END) AS Liquidados180,
                SUM(CASE WHEN tofi_dt_pagamento >= @180dias_atras AND tofi_dt_pagamento < @150dias_atras AND tofi_cd_forma_baixa in (1, 3, 5, 7, 9) THEN tofi_vl_liquidacao ELSE 0 END) AS FatorLiquidados180
            FROM atvttitu titu WITH (NOLOCK)
                INNER JOIN ATVTTOFI tofi WITH (NOLOCK)
                    ON titu.OPER_CD_OPERACAO = tofi.OPER_CD_OPERACAO
                        AND titu.TITU_CD_SEQUENCIAL = tofi.TITU_CD_SEQUENCIAL
            WHERE ((tofi_dt_pagamento
                    BETWEEN @180dias_atras
                    AND @dataGeracao)
                OR tofi_dt_pagamento IS NULL)
            GROUP BY titu.cede_cd_cgc_cpf
    )
    SELECT  ger.CnpjCedente,
            ger.RazaoSocialCedente,
            ger.GrupoEconomico,
            ger.IdGrupoEconomico,
            ger.TemLiminar,
            ger.TemCartorio,
            ger.Renovacao,
            ger.LimiteSacado,
            ger.Comercial,
            ger.SiglaComercial,
            ger.DiasUltimaOperacao,
            ger.LimiteCedente,
            ger.LimiteCedenteCreditoOperacao,
            ger.Desagio,
            ger.ValorOperado,
            ger.QuantidadeOperado,
            ger.ValorLiquidado,
            ger.QuantidadeLiquidado,
            ger.ValorCarteira,
            ger.QuantidadeCarteira,
            ger.ValorAtrasoRecompra,
            ger.QuantidadeAtrasoRecompra,
            ger.ValorAtraso,
            ger.QuantidadeAtraso,
            ger.ValorContaGrafica,
            ger.QuantidadeDiasCgNegativo,
            ger.ValorOperadoSimples,
            ger.QuantidadeOperadoSimples,
            ger.ValorLiquidadoSimples,
            ger.QuantidadeLiquidadoSimples,
            ger.ValorCarteiraSimples,
            ger.QuantidadeCarteiraSimples,
            ger.ValorAtrasoSimples,
            ger.QuantidadeAtrasoSimples,
            ger.ValorAmostraConferencia,
            ger.QuantidadeAmostraConferencia,
            ger.ValorConfirmar,
            ger.QuantidadeConfirmar,
            ger.ValorMaiorConfirmar,
            ger.ValorIrregulares,
            ger.ValorProtesto,
            ger.IdEmpresa,
            ger.NomeEmpresa,
            ger.NomeReduzidoEmpresa,
            ger.QuantidadeDiasCpNegativo,
            ger.ValorContaProgramada,
            ger.ValorComprovanteEntrega,
            ger.QuantidadeComprovanteEntrega,
            ger.PrazoComprovanteEntrega,
            liq.CnpjCedente,
            liq.Liquidados30,
            liq.FatorLiquidados30,
            liq.Liquidados60,
            liq.FatorLiquidados60,
            liq.Liquidados90,
            liq.FatorLiquidados90,
            liq.Liquidados120,
            liq.FatorLiquidados120,
            liq.Liquidados150,
            liq.FatorLiquidados150,
            liq.Liquidados180,
            liq.FatorLiquidados180
        FROM Gerencial ger WITH (NOLOCK)
            INNER JOIN Liquidados liq WITH (NOLOCK)
                ON liq.CnpjCedente = ger.CnpjCedente
        ORDER BY RazaoSocialCedente
END;
