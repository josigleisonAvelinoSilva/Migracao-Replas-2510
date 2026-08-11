#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REPCPA05
Valida o lote de control digitado pelo usuario
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 21/01/2022
@return logical, Retorno logico
@obs Projeto Apontamento de Perda (Retorno para Estoque e Sucata)
Essa funcao foi criada para solucionar temporariamente uma necessidade de desvio que tivemos para esse projeto.
Esse rotina entrara em desuso assim que a TOTVS responder um chamado que foi aberto no dia 21/01/2022. 
Segue abaixo descricao do chamado:
“Necessidade: Precisamos que seja criado um Ponto de Entrada na Função A103LotCTL() que é usado no X3_VALID
do campo D1_NUMLOTE, esse ponto de entrada deve criado logo no inicial da função para realizarmos um desvio.
Motivo: Precisamos realizar uma validação de usuário (Desvio) antes das validações padrões da própria Totvs. 
Sabemos que existe o campo de validação do usuário, no entanto ele é executado somente depois das validações
padrões e por esse motivo não nos atende.“
/*/
User Function REPCPA05()
    Local cVar			:= ReadVar()
    Local cConteudo		:= &(ReadVar())
    Local cCod			:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})]
    Local nPosLote		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_NUMLOTE"})
    Local nPosLotCTL	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
    Local nPosDvalid	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
    Local nPosLocal		:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_LOCAL"} )
    Local nPosTes		:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_TES"})
    Local aAreaAnt		:= GetArea()
    Local aAreaSB8		:= {}
    Local lRet			:= .T.
    Local lRotAuto      := Type("l103Auto") == "L" .And. l103Auto
    Local lSublPD3Ok    := .F.
    Local cLoteCtlA  	:= ''
    Local cBuscaSF4		:= ""
    Local cBuscaSB8		:= ""
    //Local nPosTipoNF 	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_TIPO_NF"})
    //Local lEasy		    := SuperGetMV("MV_EASY") == "S"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ COMPATIBILIZACAO !!Verifica se e utilizado a rotina MATA100  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Type('l100') <> 'U' .And. l100
        Return A100LotCTL()
    EndIf

    If !(Type('cLoteCtl')=='C')
        cLoteCtlA := CriaVar('D1_LOTECTL')
    Else
        cLoteCtlA := cLoteCtl
    EndIf

    If cA100For+cLoja $ GetMv("RE_FORRPS", .F., "141340540001") 
        IsMPRastro := IsMPRastro(cCod)
    EndIf

    If (!Rastro(cCod) .And. cVar == "M->D1_NUMLOTE" .And. !Empty(cConteudo)) .Or. (!Rastro(cCod) .And. cVar == "M->D1_LOTECTL" .And. !Empty(cConteudo))
        If nPosLote > 0
            aCols[n, nPosLote]   := CriaVar("D1_NUMLOTE")
        EndIf
        aCols[n, nPosLotCTL] := CriaVar("D1_LOTECTL")
        aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
        Help(" ",1,"NAORASTRO")
        lRet     := .F.
    ElseIf !A103VlStr()
        lRet := .F.
    ElseIf cVar == "M->D1_NUMLOTE" .And. !Empty(cConteudo)
        If cTipo == 'D' //-- NF Devolu??o
            dbSelectArea("SB8")
            aAreaSB8 := GetArea()
            dbSetOrder(2)
            If MsSeek(xFilial("SB8")+cConteudo+cLoteCtlA, .F.) .And. B8_PRODUTO+B8_Local == cCod+cLocal
                aAreaSB8[3]          := Recno()
                M->D1_LOTECTL        := SB8->B8_LOTECTL
                aCols[n, nPosLotCTL] := SB8->B8_LOTECTL
                If nPosLote > 0
                    aCols[n, nPosLote]   := cConteudo
                EndIf
            Else
                M->D1_LOTECTL        := CriaVar("D1_LOTECTL")
                M->D1_DTVALID        := CriaVar("D1_DTVALID")
                If nPosLote > 0
                    M->D1_NUMLOTE      := CriaVar("D1_NUMLOTE")
                    aCols[n, nPosLote] := CriaVar("D1_NUMLOTE")
                EndIf
                aCols[n, nPosLotCTL] := CriaVar("D1_LOTECTL")
                aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
            EndIf
            RestArea(aAreaSB8)
        Else
            // Valida sublote informado na rotina automatica de devolucao de poder de terceiros, se for valido mantem o sublote
            If lRotAuto .And. nPosTes > 0 .And. !Empty(aCols[n, nPosTes])
                cBuscaSF4 := xFilial("SF4") + aCols[n, nPosTes]
                If Posicione("SF4", 1, cBuscaSF4, "F4_PODER3") == "D"
                    cBuscaSB8 := xFilial("SB8") + cConteudo + aCols[n, nPosLotCTL] + cCod + aCols[n, nPosLocal]
                    If Posicione("SB8", 2, cBuscaSB8, "B8_NUMLOTE") == cConteudo
                        lSublPD3Ok := .T.
                    EndIf
                EndIf
            EndIf
            If !lSublPD3Ok .And. !IsMPRastro
                M->D1_DTVALID        := CriaVar("D1_DTVALID")
                If nPosLote > 0
                    M->D1_NUMLOTE        := CriaVar("D1_NUMLOTE")
                    aCols[n, nPosLote]   := CriaVar("D1_NUMLOTE")
                EndIf
                aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
            EndIf
        EndIf
    ElseIf cVar == "M->D1_LOTECTL" .And. !Empty(cConteudo) 
        aAreaSB8 := GetArea()
        SB8->(dbSetOrder(3))
        If SB8->(dbSeek(xFilial("SB8")+cCod+aCols[n,nPosLocal]+cConteudo+IF(Rastro(cCod,"S"),aCols[n,nPosLote],"")))
            If aCols[n, nPosDValid] # SB8->B8_DTVALID 
                If Type('lMSErroAuto') <> 'L'
                    Help(" ",1,"A240DTVALI")
                EndIf	
                M->D1_DTVALID := SB8->B8_DTVALID
                aCols[n,nPosDvalid] := SB8->B8_DTVALID						
            EndIf			
        Endif		
        RestArea(aAreaSB8)
    EndIf

    RestArea(aAreaAnt)

Return lRet


/*/{Protheus.doc} IsMPRastro
Rotina que verifica se o produto 
MP tem controle de reastro
@type function
@version 1.0 
@author Dener Lemos - DOTHINK
@since 21/01/2022
@param cProduto, character, Produto
@return logical, Retorno logico
/*/
Static Function IsMPRastro(cProduto)
    Local aAreaSB1 := SB1->(GetArea())
    Local lRet     := .F.

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    If SB1->(DbSeek(xFilial()+cProduto)) .And. SB1->B1_TIPO == "MP" .And. Rastro(SB1->B1_COD)
        lRet := .T.
    EndIf

    RestArea(aAreaSB1)

Return lRet
