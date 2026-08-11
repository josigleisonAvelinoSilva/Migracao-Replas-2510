#include "totvs.ch"
#include "topconn.ch"


//-- U_REFATA13()
User Function REFATA13()
    Local cMoeda     := ""
    Local cNmCli     := ""
    Local nMVMCusto  := Val(SuperGetMv("MV_MCUSTO"))
    Local nMCusto    := 0
    Local nMCustoCli := 0
    Local nLimCred   := 0
    Local nSalPed    := 0
    Local nSalPedL   := 0
    Local nSalDup    := 0
    Local nSalDupM   := 0
    Local nSalFin    := 0
    Local nLcFin     := 0
    Local nLcFinM    := 0
    Local nSalFinM   := 0
    Local __LIMCREDM
    Local __SALDUP  
    Local __SALDOLC 
    Local __SIMB    

    If !IsBlind() .And. INCLUI
        dbSelectArea("SA1")           // Posiciona cliente
        dbSetOrder(1)
        If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
            nMCusto := If(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMVMCusto)
            cMoeda  := " "+Pad(SuperGetMv("MV_SIMB"+AllTrim(STR(nMCusto))),4)
            cNmCli  :=  AllTrim(SA1->A1_NREDUZ)

            //-- Verifica o tipo de analise a ser efetuado ( Filial ou Matriz )
            If ( SuperGetMv("MV_CREDCLI") == "L" )
                nLimCred := SA1->A1_LC
                nSalPed  := SA1->A1_SALPED + SA1->A1_SALPEDB
                nSalPedL := SA1->A1_SALPEDL
                nSalDup  := SA1->A1_SALDUP
                nSalDupM := SA1->A1_SALDUPM
                nSalFin  := SA1->A1_SALFIN
                nLcFin   := SA1->A1_LCFIN
                nLcFinM  := SA1->A1_SALFINM
            Else
                //-- Soma-se Todos os Limites de Credito do Cliente
                dbSelectArea("SA1")
                dbSetOrder(1)
                cFilSA1		:= xFilial("SA1")
                dbSeek(cFilSA1+M->C5_CLIENTE)
                While ( !Eof() .And. cFilSA1 == SA1->A1_FILIAL .And. M->C5_CLIENTE ==  SA1->A1_COD )
                    nMCustoCli := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMVMCusto)
                    nLimCred += xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
                    nSalPed  += xMoeda(SA1->A1_SALPED+SA1->A1_SALPEDB,nMCustoCli,nMCusto,dDataBase)
                    nSalPedL += xMoeda(SA1->A1_SALPEDL,nMCustoCli,nMCusto,dDataBase)
                    nSalDup  += SA1->A1_SALDUP
                    nSalDupM += xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
                    nSalFin  += SA1->A1_SALFIN
                    nLcFin   += xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
                    nSalFinM += xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
                    dbSelectArea("SA1")
                    dbSkip()
                EndDo
            EndIf

            __LIMCREDM := nLimCred
            __SALDUP   := nSalDup
            __SALDOLC  := xMoeda(nLimCred-nSaldupM-nSalPedL,nMCusto,1)
            __SIMB     := SuperGetMv("MV_SIMB"+Alltrim(STR(nMCusto)))

            FWAlertInfo("Limite de Crédito: <strong>" + __SIMB + " " + Alltrim(Transform(__LIMCREDM,PesqPict("SA1","A1_LC",17,nMcusto)))+"</strong>"+CRLF+CRLF+;
                        "Saldo Duplicatas: <strong>" + __SIMB + " " + Alltrim(Transform(__SALDUP,PesqPict("SA1","A1_SALDUP",17,1)))+"</strong>"+CRLF+CRLF+;
                        "Saldo Lim. Crédito: <strong><font size='4' color='green'>" + __SIMB + " " + Alltrim(Transform(__SALDOLC,PesqPict("SA1","A1_SALDUP",17,1)))+"</font></strong>",;
                        "Limites Cliente - " + cNmCli)
        EndIf
    EndIf

Return .T.
