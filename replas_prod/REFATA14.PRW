#include "totvs.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} REFATA14
Rotina automatica para criar Produtos x Codigo de valores declaratórios
@type function
@author dener.lemos@dothink.com.br
@since 06/07/2026
@return logical, Retorno logico
/*/
User Function REFATA14(cProduto)
    Local aRegra    := {}
    Local cMsgErro  := ""
    Local nI        := 0

    If ValType(cProduto) == "C" .And. !Empty(cProduto)
        aRegra := GetRegra(cProduto)
        For nI := 1 To Len(aRegra)
            If !CriaF3K(aRegra[nI], @cMsgErro)
                If Empty(cMsgErro)
                    cMsgErro := "Ocorreu um erro desconhecido ao criar Produtos x Codigo de valores declaratórios."
                EndIf
                FWLogMsg("INFO", /*cTransactionId*/, "Produtos", /*cCategory*/, /*cStep*/, /*cMsgId*/, cMsgErro, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
                cMsgErro := ""
            EndIf
        Next
    EndIf

Return .T.

/*/{Protheus.doc} GetRegra
Pega as regras na tabela auxiliar SZI para cadastro de Produtos x Codigo de valores declaratórios
@type function
@author dener.lemos@dothink.com.br
@since 06/07/2026
@param cProduto, character, Produto
@return array, Array com as regras
/*/ 
Static Function GetRegra(cProduto)
	Local aAreaAnt  := GetArea()
	Local cAliasQry	:= GetNextAlias()
    Local aStruSZI	:= SZI->(dbStruct())
    Local jItem		:= Nil
	Local nI		:= 0
	Local cCampo	:= ""
    Local aRet		:= {}	

	BeginSQL Alias cAliasQry
		SELECT R_E_C_N_O_ REC_SZI
		FROM %Table:SZI%
		WHERE %NotDel%
		ORDER BY ZI_FILIAL, ZI_CFOP
	EndSQL

	If !(cAliasQry)->(EoF())
		While !(cAliasQry)->(EoF())
			SZI->(dbGoTo((cAliasQry)->REC_SZI))
			If !SZI->(EoF())
				jItem := JSONObject():New()
				For nI := 1 To Len(aStruSZI)
					cCampo := AllTrim(aStruSZI[nI][1])
					jItem[cCampo] := SZI->(FieldGet(FieldPos(cCampo)))
				Next
                jItem["ZI_PROD"] := cProduto
				aAdd(aRet, jItem)
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)

Return aRet

/*/{Protheus.doc} CriaF3K
Função para criar Produtos x Codigo de valores declaratórios
@type function
@author dener.lemos@dothink.com.br
@since 06/07/2026
@param jDados, json, Dados do produto x codigo de valores declaratórios
@param cMsgErro, character, Mensagem de erro caso ocorra algum problema na criação do registro
@return logical, Retorno lógico indicando sucesso ou falha na criação do registro
/*/
Static Function CriaF3K(jDados, cMsgErro)
	Local oModel    := Nil
    Local cFilBak   := FWCodFil()
    Local aErro		:= {}
    Local lRet		:= .F.

    cFilAnt := jDados["ZI_FILIAL"]

    oModel := FWLoadModel("FISA140")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    If oModel:Activate()
        oModel:SetValue("MODEL_F3K", "F3K_FILIAL", jDados["ZI_FILIAL"])
        oModel:SetValue("MODEL_F3K", "F3K_PROD", jDados["ZI_PROD"])

        oModel:SetValue("F3KDETAIL", "F3K_CST", jDados["ZI_CST"])
        oModel:SetValue("F3KDETAIL", "F3K_CODREF", jDados["ZI_CODREF"])
        oModel:SetValue("F3KDETAIL", "F3K_CFOP", jDados["ZI_CFOP"])
        oModel:SetValue("F3KDETAIL", "F3K_CODAJU", jDados["ZI_CODAJU"])

        //-- Valida as informacoes
        If oModel:VldData()
            lRet := oModel:CommitData()
        Else
            aErro := oModel:GetErrorMessage()
            If ValType(aErro) == "A"
                Default cMsgErro := ""
                cMsgErro += "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], ' + CRLF 
                cMsgErro += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], ' + CRLF
                cMsgErro += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], ' + CRLF
                cMsgErro += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], ' + CRLF
                cMsgErro += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], ' + CRLF
                cMsgErro += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], ' + CRLF
                cMsgErro += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], ' + CRLF
                cMsgErro += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], ' + CRLF
                cMsgErro += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'						
            Else
                cMsgErro := "Ocorreu um erro desconhecido na validação do modelo."
            EndIf
        EndIf				
        oModel:Deactivate()
    Else
        cMsgErro := "Não foi possível ativar o modelo de dados do cadastro de Produtos(MATA010)."
    EndIf

    oModel:Destroy()
    If ValType(oModel) == "O"
        FreeObj(oModel)
        oModel := Nil
    EndIf

    cFilAnt := cFilBak

Return lRet
