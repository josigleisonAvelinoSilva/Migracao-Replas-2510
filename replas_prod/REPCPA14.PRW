#include "totvs.ch"
#include "topconn.ch"


/*/{Protheus.doc} REPCPA14
Rotina executada via JOB que realiza gravacoes adicionais no Motor e outras tabelas usadas na 0201.
Foi necessario essa tratamento apos a migracao de versao do protheus release 2410.
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 09/01/2025
/*/
User Function REPCPA14()

    wfprepenv("01", "0201")

    //-- 
    GrpPVItem()

    //-- 
    GrvMotor()

Return


//--
Static Function GrpPVItem()
    //Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	Local cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Local cQuery   := ""

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    cQuery := " SELECT SC2.R_E_C_N_O_ C2_RECNO "
    cQuery += " FROM " + RetSQLName("SC2") + " SC2 "
    cQuery += " WHERE SC2.C2_FILIAL = '" + cFilDest + "' "
    cQuery += " AND SC2.C2_DESTINA = 'P' "
    cQuery += " AND (SC2.C2_PEDIDO = ' ' OR SC2.C2_ITEMPV = ' ') "
    cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY NEWID() "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    _QRY->(dbGoTop())
    While _QRY->(!EoF())
        SC2->(dbGoTo(_QRY->C2_RECNO))
        
        //-- Bloqueio do registro se possivel
        If dbRLock()
            //-- Altera o conteudo do registro
            RecLock("SC2", .F.)
                SC2->C2_PEDIDO := SC2->C2_NUM
                SC2->C2_ITEMPV := SC2->C2_ITEM
            SC2->(MsUnlock())

            //-- Desbloqueia o registro
            dbRUnlock(_QRY->C2_RECNO)
        EndIf

        _QRY->(dbSkip())
    EndDo

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

Return


//--
Static Function GrvMotor()
    Local aAreaAnt := GetArea()
    Local aAreaSC2 := SC2->(GetArea())
    //Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
	Local cFilDest := GetMV("RE_FILDEST", .F., "0201")
    Local cQuery   := ""

    dbSelectArea("SC2")
    SC2->(dbSetOrder(1))

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    cQuery := " SELECT D3_FILIAL, D3_OP, D3_COD, D3_QUANT, D3_EMISSAO, D3_USUARIO, "
    cQuery += " C2_PEDIDO, C2_ITEMPV, C2_DESTINA, C2_XFILORI, C2_XPVORIG, C2_XITOK, SC2.R_E_C_N_O_ C2_RECNO "
    cQuery += " FROM " + RetSQLName("SD3") + " SD3 "
    cQuery += " INNER JOIN " + RetSQLName("SC2") + " SC2 "
    cQuery += " ON SC2.C2_FILIAL = SD3.D3_FILIAL "
    cQuery += " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN = SD3.D3_OP "
    cQuery += " AND NOT EXISTS (SELECT * FROM " + RetSQLName("SZ8") + " SZ8 WHERE Z8_FILIAL = SC2.C2_FILIAL AND Z8_PVDEST = SC2.C2_PEDIDO AND Z8_ITEMPV = SC2.C2_ITEMPV AND SZ8.D_E_L_E_T_ = ' ') "
    cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SD3.D3_FILIAL = '" + cFilDest + "' "
    cQuery += " AND SD3.D3_CF = 'PR0' "
    cQuery += " AND SD3.D3_ESTORNO <> 'S' "
    cQuery += " AND SD3.D3_EMISSAO >= '20250106' "
    cQuery += " AND SD3.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    TCQUERY cQuery New Alias "_QRY"

    _QRY->(dbGoTop())
    While _QRY->(!EoF())
        SC2->(dbGoTo(_QRY->C2_RECNO))
        
		//-- Chama a rotina de Inclusao para o Novo Motor 
		U_REFATA8B(SC2->C2_XFILORI, SC2->C2_XPVORIG)

        _QRY->(dbSkip())
    EndDo

    If Select("_QRY") > 0
        _QRY->(dbCloseArea())
    EndIf

    RestArea(aAreaSC2)
    RestArea(aAreaAnt)

Return
