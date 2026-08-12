#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} mta250mnu
Teste de Gravagues de Registros na Tabela SZ9 - Produtos Auxiliares
@type function
@version 1.0  
@author Marcos P.Aversa
@since 28/02/2023
@return variant, gravagco de Registro SZ9
/*/
User Function mta250mnu()
    If RetCodUsr() == "000155"  //--Dothink - Teste de Gravagco SZ9
        Aadd(aRotina, { "Aponta Retorno/Sucata", "U_XAPRETOR()", 0, 2, 0, NIL})
    Endif
Return aRotina 

User Function XAPRETOR()
    local aBobina  := {}
    local lRet     := .T.
    local nI       := 1
    local cBobinas := ""
    //-- Inicio do tratamento para apontamento do Retorno/Sucata
    If Alltrim(SD3->D3_CF) == 'PR0'  .AND.  !Empty( SD3->D3_OP)

        aBobina := GetBobina(SD3->D3_OP)

        For nI := 1 To Len(aBobina)
            If Rastro(aBobina[nI,01])
                cBobinas += "MP: " + AllTrim(aBobina[nI,01]) + ", Lote/Sub-Lote: " + AllTrim(aBobina[nI,04]) + "/" + AllTrim(aBobina[nI,05]) + ";"
            Else
                cBobinas += "MP: " + AllTrim(aBobina[nI,01]) + ";"
            EndIf
            If Len(aBobina) <> nI
                cBobinas += chr(13) + chr(10) 
            EndIf
        Next nI

        If MsgYesNo("Deseja apontar <b>Retorno para Estoque</b> e/ou <b>Sucata</b>?" + chr(13)+ chr(10) + chr(13)+ chr(10) + cBobinas, "Apontamento Retorno/Sucata?")
            lRet := U_REPCPA01(aBobina)
        EndIf

    Else
       MsgAlert("Atencao. Registro nao e uma Producao Valida, Favor verificar !!!!","MTA250MNU")
    Endif

Return    


/*/{Protheus.doc} GetBobina
Funcao responsavel por pegar os codigos de MP
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 10/01/2022
@param cOP, character, Numero da OP
@return array, Array com os codigos das MPs
/*/
Static Function GetBobina(cOP)
    Local cAlias := GetNextAlias()
    Local cQuery := ""
    Local aRet   := {}

    cOP := AllTrim(cOP)

    cQuery += " SELECT * "
	cQuery += " FROM " + RetSqlName("SD4") + " SD4 "
	cQuery += " WHERE SD4.D4_FILIAL ='" + xFilial("SD4") + "' AND "
	cQuery += " SD4.D4_OP = '" + cOP + "' AND "
    cQuery += " SD4.D4_COD LIKE 'MP%' AND "//-- Foi incluido esse tratamento, pois todas as materias prima tem codigo iniciado com 'MP'
	cQuery += " SD4.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD4.D4_COD "

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

    While (cAlias)->(!Eof())
        aAdd( aRet, { (cAlias)->D4_COD,;                                              //-- 01 - Codigo do produto
                      Posicione('SB1',1,xFilial('SB1')+(cAlias)->D4_COD, 'B1_DESC'),; //-- 02 - Descricao do produto
                      (cAlias)->D4_LOCAL,;                                            //-- 03 - Armazem
                      (cAlias)->D4_LOTECTL,;                                          //-- 04 - Lote
                      (cAlias)->D4_NUMLOTE,;                                          //-- 05 - Sub-lote
                      (cAlias)->D4_DTVALID,;                                          //-- 06 - Data de validade
                      (cAlias)->D4_QTDEORI,;                                          //-- 07 - Quantidade empenhada
                      (cAlias)->D4_QUANT } )                                          //-- 08 - Saldo empenhado

        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->(DbCloseArea())

Return aRet

