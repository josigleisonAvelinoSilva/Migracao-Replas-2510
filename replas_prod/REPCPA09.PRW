#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} REPCPA09
Rotina que grava em uma tabela espeficifica (SZ9) as bobinas 
que foram apontadas como "Retorno para Estoque" e/ou "Sucata",
para que seja feita a devolucao para a REPLAS e posteriormente
enviada com o novo codigo
@type function
@version 1.0 
@author Marcos P.Aversa
@since 02/02/2023
@param aPerda, array, Array com os produtos da perda
@param cErro, character, Variavel que grava os erros
@return logical, Retorno logico
/*/
User Function REPCPA09(aPerda, cErro)
    local aArea    := GetArea()
    local cOP      := ""
    local cProduto := ""
    local cArmOri  := ""
    local cMotivo  := ""   
    local cProdDes := ""
    local cArmDes  := ""
    local cSbLtDes := ""
    local cLotDes  := ""
    local cLotOri  := ""
    local cSbLtOri := ""
    local dValDes  := ctod("  /  /  ")
    local nQtdDes  := 0
    local nQtdBDes := 0
    local nQtdOri  := 0
    local nI
    local cRastro  := "N"

    dbSelectArea("SZ9")
    SZ9->(dbSetOrder(1))

    For nI := 1 To Len(aPerda)
        cOP      := aPerda[nI, 01]
        cProduto := aPerda[nI, 02]
        cArmOri  := aPerda[nI, 03]
        cMotivo  := aPerda[nI, 05]
        cProdDes := aPerda[nI, 07]
        cArmDes  := aPerda[nI, 08]
        cLotOri  := aPerda[nI, 09]
        cSbLtOri := aPerda[nI, 10]
        dValDes  := aPerda[nI, 11]
        nQtdDes  := aPerda[nI, 06]
        nQtdBDes := aPerda[nI, 12]

        cRastro  := GetAdvFVal("SB1", "B1_RASTRO", xFilial("SB1") + cProdDes, 1, "N" )

        If cRastro != 'N' 
            //-- Descobre o Sub-lote
            cSbLtDes := cSbLtOri //NextLote(cProdDes, "S")
            //-- Descobre o Lote
            cLotDes  := NextLote(cProdDes, "L") //NextLote(cProdDes, "L", cSbLtDes)
        Else
            //-- Descobre o Sub-lote
            cSbLtDes := " "
            //-- Descobre o Lote
            cLotDes  := " "
        Endif    

        //-- Indice 3
        //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
        nQtdOri := GetAdvFVal("SB8", "B8_QTDORI", xFilial("SB8") + cProduto + cArmOri + cLotOri + cSbLtOri, 3, 0)

        RecLock("SZ9", .T.)
            SZ9->Z9_FILIAL  := xFilial("SZ9")
            SZ9->Z9_OP      := cOP
            SZ9->Z9_PRODORI := cProduto
            SZ9->Z9_LOCORI  := cArmOri
            SZ9->Z9_DATA    := dDataBase
            SZ9->Z9_MOTIVO  := cMotivo
            SZ9->Z9_LOCORI  := cArmOri
            SZ9->Z9_LOTORI  := cLotOri
            SZ9->Z9_SBLTORI := cSbLtOri
            SZ9->Z9_QTDORI  := nQtdOri
            SZ9->Z9_LOCDES  := cArmDes
            SZ9->Z9_PRODDES := cProdDes
            SZ9->Z9_LOTDES  := cLotDes
            SZ9->Z9_SBLTDES := cSbLtDes
            SZ9->Z9_QTDDES  := nQtdDes  //-- Peso Liquido
            SZ9->Z9_QTDBDES := nQtdBDes //-- Peso Bruto
            SZ9->Z9_DVLDES  := dValDes
            SZ9->Z9_STATUS  := "N"
        SZ9->(MsUnlock())
    Next nI

    RestArea(aArea)

Return .T.
