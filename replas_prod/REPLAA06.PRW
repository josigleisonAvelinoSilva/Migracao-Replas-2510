#include "topconn.ch"

/*/{Protheus.doc} REPLAA06
Tratamento para ajustar proximo numero caso esteja errado
@type function
@version 1.0 
@author DO THINK - FERNANDO MUTA
@since 18/01/2025
/*/
User Function REPLAA06(aParam)
local cQry := ""
local cNome
local cProxSeq
local cLog := ""
wfprepenv(aParam[01],aParam[02])

// Nao foi colocado D_E_L_E_T_ propositalmente.
cQry += " SELECT MAX(NUMSEQ) NUMSEQ FROM (SELECT MAX(D1_NUMSEQ) NUMSEQ FROM "+RetSqlName("SD1")
cQry += " 								UNION "
cQry += " 								SELECT MAX(D2_NUMSEQ) NUMSEQ FROM "+RetSqlName("SD2")
cQry += " 								UNION "
cQry += " 								SELECT MAX(D3_NUMSEQ) NUMSEQ FROM "+RetSqlName("SD3")
cQry += " 								) TRB "
tcquery cQry new Alias "TRBMAXSEQ"
cNome := '@@@'+RetSqlName("SD2")
cProxSeq := GetSX8NUM(cNome)
RollBackSX8()
If cProxSeq <= TRBMAXSEQ->NUMSEQ
    conout("REPLAA06 Ultima Seq.(SD1,SD2 e SD3):" + TRBMAXSEQ->NUMSEQ + " Proxima License:" + cProxSeq + " Proxima MV_DOCSEQ:" + GetMv("MV_DOCSEQ")  )
    While cProxSeq <= TRBMAXSEQ->NUMSEQ
        cProxSeq := GetSX8NUM(cNome)
        ConfirmSX8()
        cLog     += cProxSeq + iif(cProxSeq == TRBMAXSEQ->NUMSEQ,",","")
    End    
    PutMv("MV_DOCSEQ", cProxSeq)
    conout("REPLAA06 proxnum : " + cLog )
EndIf    

TRBMAXSEQ->(DbCloseArea())
return
