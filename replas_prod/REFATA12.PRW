#include "totvs.ch"
#include "topconn.ch"


//--
User Function REFATA12()
    Local aAreaAnt := GetArea()
    Local aAreaSA1 := SA1->(GetArea())
    Local aLista   := {}
    Local cFilOrig := GetMV("RE_FILORIG", .F., "0302")
    Local cRet     := ""
    Local oDlgVen
    Local oVen
    Local oBtn01

    //-- Parametro que contem os usuario aptos a modificar os pedido de venda de Filmes, nao influenciando no processo das Resinas
    If !IsBlind() .And. cFilAnt == cFilOrig .And. __cUserId $ GetMV("RE_MPVEND", .F., "000000/000120/000111/000147/000173/000013/")
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))

        If SA1->(dbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI)) .And. !Empty(SA1->A1_XVEND2)
            //-- Vendedor padrao
            aAdd(aLista, {SA1->A1_VEND, Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME")})

            //-- Vendedor adicional, usado para filmes
            aAdd(aLista, {SA1->A1_XVEND2, Posicione("SA3",1,xFilial("SA3")+SA1->A1_XVEND2,"A3_NOME")})
            
            DEFINE MSDIALOG oDlgVen TITLE OemToAnsi("Escolha Vendedor") FROM 000, 000 TO 165, 340 COLORS 0, 16777215 PIXEL
                oDlgVen:lMaximized := .F.

                @ 001,001 LISTBOX oVen VAR cPromo Fields HEADER "Codigo","Nome do Vendedor" SIZE 170, 60 PIXEL OF oDlgVen
                oVen:SetArray(aLista)
                oVen:bLine := {|| {aLista[oVen:nAt,1], aLista[oVen:nAt,2]}}

                @ 65,105 BUTTON oBtn01 PROMPT "Confirma" SIZE 50,12 ACTION (cRet := aLista[oVen:nAt,1], oDlgVen:end()) PIXEL
            ACTIVATE MSDIALOG oDlgVen CENTERED
        EndIf
    EndIf

    If Empty(cRet)
        cRet := M->C5_VEND1
    EndIf

    RestArea(aAreaSA1)
    RestArea(aAreaAnt)

Return cRet
