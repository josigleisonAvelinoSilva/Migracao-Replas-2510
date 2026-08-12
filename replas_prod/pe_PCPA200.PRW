#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#Include "TbiConn.ch"


/*/{Protheus.doc} PCPA200
Ponto de Entrada MVC da rotina de estruturas
@type function
@version 1.0  
@author Fernando B.Muta
@since 11/2024
@return variant, Retorno variavel
/*/
User Function PCPA200()
    Local aParam   := PARAMIXB
    Local xRet     := .T.
    Local oObj     := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOpcX    
    Local cFilOrig 
    Local oView  
    Local oModel 
    Local oMdlPai
    private cProduto


    If aParam <> NIL
        oObj     := aParam[01]
        cIdPonto := aParam[02]
        cIdModel := aParam[03]

        If cIdPonto == "MODELVLDACTIVE"
            //-- Na ativacao do modelo
        ElseIf cIdPonto == "FORMPOS"
            //-- Validacao total do formulario
        ElseIf cIdPonto == "FORMLINEPRE"
            //-- Pre validacao da linha do formulario
        ElseIf cIdPonto == "FORMLINEPOS"
            //-- Validacao da linha do formulario 
        ElseIf cIdPonto == "MODELCOMMITTTS"
            //-- Apos a gravacao total do modelo e dentro da transacao
        ElseIf cIdPonto == "MODELCOMMITNTTS"
            If IsInCallStack("U_REPLAA07")
                cProduto := Padr(_cCodPrd1, Len(SG1->G1_COD))
                nOpcX    := 3
            Else
                //-- Apos a gravacao total do modelo e fora da transacao
                oView     := FwViewActive()
                oModel    := oView:GetModel()                
                oMdlPai   := oModel:GetModel("SG1_MASTER")
                cProduto  := oMdlPai:GetValue("G1_COD") 
                nOpcX     := oModel:GetOperation()  /*  1 - View,  3 - Insert,  4 - Update, 5 - Delete,  6 - Only Update */
            Endif

            cFilOrig  := GetMV( "RE_FILORIG", .F., "0302" )
            //Local cFilDest := GetMV( "RE_FILDEST", .F., "0201" )
            If ( nOpcX == 3 .Or. nOpcX == 4 ) .And. FWCodFil() == cFilOrig .And.;
                U_REFATA02( 1, cProduto ) .And. U_REFATA02( 3, cProduto ) .And.;
                !IsInCallStack( "U_REESTA06" )
                //-- Rotina para inclusao de entrutura na filial da Industria MM SP
                U_REESTA06()
            EndIf
            
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //-- Antes de gravar a tabela do formulario
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
            //-- Apos a gravacao da tabela do formulario
        ElseIf cIdPonto == "MODELCANCEL"
            //-- No Botao Cancelar
        ElseIf cIdPonto == "BUTTONBAR"
            //-- Adicionando Botao na Barra de Botoes
        EndIf    
    EndIf

Return xRet
