#Include "Protheus.ch" 

/*_______________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------+------------+-------+----------------------+------+------------+ฆฆ
ฆฆฆ Fun็ใo    ฆ BOLSAFRA   ฆ Autor ฆ Marcel R. Grosselli  ฆ Data ฆ 11/03/2014 ฆฆฆ
ฆฆ+-----------+------------+-------+----------------------+------+------------+ฆฆ
ฆฆฆ Descri็ไo ฆ Impressใo do Boleto do Banco Safra                            ฆฆฆ
ฆฆ+-----------+---------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/

User Function BOLSAFRA()

LOCAL	aPergs       := {} 
PRIVATE lExec      := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Boleto do Safra"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLSAF"
lEnd     := .F.
cPerg    := PADR("BOLSAF",6)
nTam     := TamSX3("E1_NUM")[1]   
nTam2    := TamSX3("E1_PARCELA")[1]
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

Aadd(aPergs,{"De Prefixo"      ,"","","mv_ch1","C", 3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo"     ,"","","mv_ch2","C", 3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero"       ,"","","mv_ch3","C",nTam,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero"      ,"","","mv_ch4","C",nTam,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela"      ,"","","mv_ch5","C",nTam2,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela"     ,"","","mv_ch6","C",nTam2,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao"      ,"","","mv_ch7","D", 8,0,0,"G","","MV_PAR07","","","","01/01/00","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao"     ,"","","mv_ch8","D", 8,0,0,"G","","MV_PAR08","","","","31/12/06","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Do Cliente"      ,"","","mv_ch9","C", 6,0,0,"G","","MV_PAR09","","",""," ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Cliente"     ,"","","mv_ch10","C", 6,0,0,"G","","MV_PAR10","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})

//---> REMOVIDO compatibiliza็ใo para versใo 12.1.25.
//AjustaSx1(cPerg,aPergs)
Pergunte(cPerg,.T.)

If nLastKey == 27
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)                                                                          

cIndexKey	:= "E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA+E1_TIPO+E1_PARCELA+DTOS(E1_EMISSAO)"
cFilter		+= "E1_FILIAL=='"+SE1->(xFilial())+"'.And.E1_SALDO>0.And."
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And." 
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par07)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par08)+"'.And." 
cFilter     += "E1_CLIENTE>='" + MV_PAR09 + "' .and. E1_CLIENTE<='" + MV_PAR10 +"' .and. "
cFilter		+= "E1_TIPO $ 'BO ,NF ,DP  ,FT ' .and. "      
cFilter     += "E1_XBANCO $ '   ,422'" 

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")

cMarca	:= GetMark()

DbSelectArea("SE1")
dbGoTop()

DEFINE MSDIALOG oDlg TITLE "Sele็ใo de Titulos" FROM 00,00 TO 400,700 PIXEL

oMark := MsSelect():New( "SE1", "E1_OK",,  ,, cMarca, { 001, 001, 170, 350 } ,,, )

oMark:oBrowse:Refresh()
oMark:bAval               := { || ( Marcar( cMarca ), oMark:oBrowse:Refresh() ) }
oMark:oBrowse:lHasMark    := .T.
oMark:oBrowse:lCanAllMark := .F.

DEFINE SBUTTON oBtn1 FROM 180,310 TYPE 1 ACTION (lExec := .T.,oDlg:End()) ENABLE
DEFINE SBUTTON oBtn2 FROM 180,280 TYPE 2 ACTION (lExec := .F.,oDlg:End()) ENABLE

ACTIVATE MSDIALOG oDlg CENTERED
	
If lExec
	Processa({|lEnd|MontaRel()})
Endif

DbSelectArea("SE1")
Set Filter To

RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil

Static Function Marcar(cMarca,oSom)
   Local lOk := .T.
   SE1->(RecLock("SE1",.F.))
   SE1->E1_OK := If( SE1->E1_OK <> cMarca , cMarca, Space(Len(SE1->E1_OK)))
   SE1->(MsUnLock())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ  MontaRelณ Autor ณ Microsiga             ณ Data ณ 06/10/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS			     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MontaRel()
LOCAL aSX5 := {}
LOCAL oPrint, cMaxPar, cQuery, cDocumen, dDataIni
LOCAL aDadosEmp   := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     ,; //[2]Endere็o
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                            ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3),;                         //[7]I.E  
								" "                        }  //

LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText    := {"", "", ""}

LOCAL aCB_RN_NN   := {}
LOCAL nVlrAbat    := 0

Private cNroDoc   :=  " "
Private aDadosTit := {}
Private lSafra    := .F.
Private cDBanco   := ""

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova pแgina

SE1->(dbGoTop())
ProcRegua(RecCount())
While !SE1->(EOF() )
   dDataIni := mv_par11
   cDocumen := SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_CLIENTE + SE1->E1_LOJA
   While !SE1->(EOF()) .And. cDocumen == SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_CLIENTE + SE1->E1_LOJA
		 
      IncProc()

      If SE1->E1_OK <> cMarca //Marked("E1_OK")
         dbSkip()
         Loop
      Endif

      //Posiciona o SA1 (Cliente)
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))  
      
      //---> REMOVIDO compatibiliza็ใo para versใo 12.1.25.
		//SX5->(DbSetOrder(1))
		//lSafra :=SX5->(DbSeek(xFilial("SX5")+"Z3"+ALLTRIM(SA1->A1_COD_MUN)))
		aSX5 := FWGetSX5( 'Z3', PadR( SA1->A1_COD_MUN, 6 ) )
		lSafra := Len( aSX5 ) > 0
      		
      // Calcula o total de parcelas geradas para o titulo
      cQuery := "SELECT MAX(E1_PARCELA) AS E1_PARCELA FROM "+RetSQLName("SE1")+" WHERE D_E_L_E_T_=' ' AND E1_FILIAL='"
      cQuery += SE1->(XFILIAL())+"' AND E1_NUM='"+SE1->E1_NUM+"' AND E1_PREFIXO='"+SE1->E1_PREFIXO+"' AND E1_CLIENTE='"
      cQuery += SE1->E1_CLIENTE+"' AND E1_LOJA='"+SE1->E1_LOJA+"'"
      dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQuery)), "YYY", .T., .F. )
      cMaxPar := YYY->E1_PARCELA
      YYY->(dbCloseArea())
      
      dbSelectArea("SE1")

//      If lSafra                          
          cDBanco  := "Banco Safra S.A."
	       cBanco 	 := "422" //banco safra
	       cAgencia := Substr(GetMv("MV_XAGSAF"),01,05)//1410
	       cConta 	 := Substr(GetMv("MV_XCCSAF"),01,10)//3520-7
	       cSbConta := Substr(GetMv("MV_XSBSAF"),01,03)//000                             
//	       cCarteira:= "02" 
//	       aDadosEmp[1] := SM0->M0_NOMECOM                                 
	       
//	     Else    
	       cDBancoC   := "Banco Ita๚ S/A"
	       cBancoC 	  := "341" //banco Bradesco
	       cAgenciaC  := Substr(GetMv("MV_XAGSCO"),01,05)//1410
	       cContaC 	  := Substr(GetMv("MV_XCCSCO"),01,10)//3520-7
	       cSbContaC  := Substr(GetMv("MV_XSBSCO"),01,03)//000
	       cCarteira := "109"
	       aDadosEmp[8] := "BANCO SAFRA S.A. "
//	   EndIf 
	     
      //Posiciona o SA6 (Bancos)
      SA6->(DbSetOrder(1))
      SA6->(DbSeek(xFilial("SA6")+cBancoC+PadR(cAgenciaC,05)+PadR(cContaC,10),.T.))

      //Posiciona na Arq de Parametros CNAB
      SEE->(DbSetOrder(1))
      SEE->(DbSeek(xFilial("SEE")+"422"+PADR(GetMv("MV_XAGSAF"),5)+PADR(GetMv("MV_XCCSAF"),10)+PADR(GetMv("MV_XSBSAF"),3),.T.))         
    
      aDadosBanco := {cBancoC /*SA6->A6_COD*/,;                                                 // [1]Codigo do Banco
                      SA6->A6_NREDUZ,;                                                          // [2]Nome do Banco
                      SUBSTR(SA6->A6_AGENCIA, 1, 5),;                                           // [3]Ag๊ncia
                      SA6->A6_NUMCON,;                                                          // [4]Conta Corrente
                      SA6->A6_DVCTA,;                                                           // [5]Dํgito da conta corrente
                      cCarteira,;                                                               // [6]Codigo da Carteira
                      SA6->A6_NUMBCO,;                                                          // [7]Numero do Banco
                      SA6->A6_DVAGE}                                                            // [8]Digito Verificador Agencia
      
      If Empty(SA1->A1_ENDCOB) .Or. "MESMO" $ SA1->A1_ENDCOB
         aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;        // [1]Razใo Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;        // [2]C๓digo
         AllTrim(SA1->A1_END )                            ,;        // [3]Endere็o
         AllTrim(SA1->A1_MUN )                            ,;        // [4]Cidade
         SA1->A1_EST                                      ,;        // [5]Estado
         SA1->A1_CEP                                      ,;        // [6]CEP
         SA1->A1_CGC									  ,;        // [7]CGC
         " "           									  ,;      	// [8]PESSOA
         AllTrim(SA1->A1_BAIRRO)                           }        // [9]Bairro   
      Else
         aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;    	// [1]Razใo Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;    	// [2]C๓digo
         AllTrim(SA1->A1_ENDCOB)                          ,;    	// [3]Endere็o
         AllTrim(SA1->A1_MUNC)	                          ,;    	// [4]Cidade
         SA1->A1_ESTC	                                  ,;    	// [5]Estado
         SA1->A1_CEPC                                     ,;    	// [6]CEP
         SA1->A1_CGC								      ,;		// [7]CGC
         " "           								      ,;    	// [8]PESSOA
         AllTrim(SA1->A1_BAIRROC)                          }        // [9]Bairro   
      Endif

      nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

      //Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 
      //Abaixo apenas uma sugestao
      cNroDoc := Strzero(Val(Alltrim(SE1->E1_NUM)),6)+StrZERO(Val(Alltrim(SE1->E1_PARCELA)),2)
      cNroDoc := STRZERO(Val(cNroDoc),11)
      
      aCB_RN_NN := Ret_cBarra( SE1->E1_PREFIXO , SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
                   Subs(aDadosBanco[1],1,3), aDadosBanco[3], aDadosBanco[4], aDadosBanco[5],;
                   aDadosBanco[7], cNroDoc , (SE1->E1_VALOR-(nVlrAbat+SE1->E1_DECRESC)), aDadosBanco[6], "9")
      
      aDadosTit := {SE1->E1_NUM+If(Empty(SE1->E1_PARCELA),"","-"+SE1->E1_PARCELA)+;
                    If(Empty(cMaxPar),"","/"+cMaxPar)  ,;  // [1] N๚mero do tํtulo
                    SE1->E1_EMISSAO                         ,;  // [2] Data da emissใo do tํtulo
                    dDataBase                          ,;  // [3] Data da emissใo do boleto
                    SE1->E1_VENCTO                          ,;  // [4] Data do vencimento
                    (SE1->E1_SALDO - nVlrAbat)              ,;  // [5] Valor do tํtulo
                    aCB_RN_NN[3]                       ,;  // [6] Nosso n๚mero (Ver f๓rmula para calculo)
                    SE1->E1_PREFIXO                         ,;  // [7] Prefixo da NF
                    "DM"                               ,;  // [8] Tipo do Titulo  // Antes -> E1_TIPO
                    SE1->E1_DECRESC							}  // [9] Decrescimo

      aBolText    := {"","","","", ""}
      aBolText[1] := "APOS O VENCIMENTO MORA DIA  R$ "+str(round(((SE1->E1_SALDO+SE1->E1_ACRESC - nVlrAbat)*GETMV("MV_XJURBOL"))/100,2))
      aBolText[2] := "Protesto ap๓s 5 dias corridos"
      aBolText[3] := ""
      aBolText[4] := ""
      aBolText[5] := ""
		
      Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

      SE1->(dbSkip())
   Enddo
EndDo

oPrint:EndPage()     // Finaliza a pแgina
oPrint:Preview()     // Visualiza antes de imprimir
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ  Impress ณ Autor ณ Microsiga             ณ Data ณ 06/10/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ IMPRESSAO DO BOLETO LASERDO ITAU COM CODIGO DE BARRAS      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
 LOCAL oFont7
 LOCAL oFont8
 LOCAL oFont11c
 LOCAL oFont10
 LOCAL oFont14
 LOCAL oFont16n
 LOCAL oFont15
 LOCAL oFont14n
 LOCAL oFont24
 LOCAL nI := 0
 Local cStartPath := GetSrvProfString("StartPath","") 
 Local cBmp := 030

  cBmp := cStartPath + "SAFRA.BMP" //Logo do Banco 

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
  oFont7   := TFont():New("Arial"      ,9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont8   := TFont():New("Arial"      ,9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont8n  := TFont():New("Arial"      ,9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont9   := TFont():New("Arial"      ,9, 9,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont11  := TFont():New("Arial"      ,9,11,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont10  := TFont():New("Arial"      ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont14  := TFont():New("Arial"      ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont18  := TFont():New("Arial"      ,9,18,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont20  := TFont():New("Arial"      ,9,20,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont23  := TFont():New("Arial"      ,9,23,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont16n := TFont():New("Arial"      ,9,16,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont15  := TFont():New("Arial"      ,9,15,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont15n := TFont():New("Arial"      ,9,15,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont14n := TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont24  := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova pแgina

/********************/
/* CABEวALHO BOLETO */
/********************/

nRow1 := -50
 
oPrint:Line (nRow1+0150, 100,nRow1+0150,2300)
oPrint:Say  (nRow1+0080, 180,cDBanco  ,oFont14 )  // [2]Nome do Banco
oPrint:Say  (nRow1+0080,1820,"Recibo do Pagador" ,oFont11 )

// LINHAS HORIZONTAIS
  oPrint:Line (nRow1+0250,100,nRow1+0250,2300 )
  oPrint:Line (nRow1+0350,100,nRow1+0350,2300 )
// LINHAS VERTICAIS
  oPrint:Line (nRow1+0150,1300,nRow1+0350,1300)
  oPrint:Line (nRow1+0150,1800,nRow1+0350,1800)
  oPrint:Line (nRow1+0250,0500,nRow1+0350,0500)
  oPrint:Line (nRow1+0250,1000,nRow1+0350,1000)

// PRIMEIRA LINHA 
  oPrint:Say  (nRow1+0150,100 ,"Beneficiario",oFont8n)
  oPrint:Say  (nRow1+0190,100 ,substr(aDadosEmp[1],1,30)+" "+aDadosEmp[6] ,oFont10) 

  oPrint:Say  (nRow1+0150,1305,"Nosso N๚mero"                                 ,oFont8n)
  cString := Transform(aDadosBanco[6]+aDadosTit[6],"@R 999/99999999-9")
  nCol    := 1325 
  oPrint:Say  (nRow1+0190,nCol,PADL(cString,17),oFont11c)
           
  oPrint:Say  (nRow1+0150,1810,"Vencimento",oFont8n)
  cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
  nCol    := 1830 
  oPrint:Say  (nRow1+0190,nCol,PADL(cString,17),oFont11c)

// SEGUNDA LINHA 
  oPrint:Say  (nRow1+0250,100 ,"Data do Documento"                            ,oFont8n)
  oPrint:Say  (nRow1+0290,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont11c)

  oPrint:Say  (nRow1+0250,505 ,"Nบ do Documento"                              ,oFont8n)
  oPrint:Say  (nRow1+0290,555 ,aDadosTit[7]+aDadosTit[1]                      ,oFont11c) //Prefixo +Numero+Parcela

  oPrint:Say  (nRow1+0250,1005,"Carteira"    		                            ,oFont8n)
  oPrint:Say  (nRow1+0290,1050,aDadosBanco[6]     	                         ,oFont11c) //Tipo do Titulo

  oPrint:Say  (nRow1+0250,1305,"Ag๊ncia / C๓digo Beneficiario",oFont8n)  
	cString := Alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+aDadosBanco[5]

  nCol    := 1325 
  oPrint:Say  (nRow1+0290,nCol,PADL(cString,17) ,oFont11c)
                   
  oPrint:Say  (nRow1+0250,1810,"(=)Valor do Documento"                     	,oFont8n)
  cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
  nCol    := 1830 
  oPrint:Say  (nRow1+0290,nCol,PADL(cString,17),oFont11c)
            
// TERCEIRA LINHA          
  oPrint:Say  (nRow1+350,100 ,"Pagador"                                      ,oFont8n)
  oPrint:Say  (nRow1+380,230 ,aDatSacado[1]+" "+aDatSacado[7]                ,oFont11c)

  //nRow2 := nRow1 + 1125

  oPrint:Box  (nRow1+450, 100, nRow1 + 2100, 2300)

/***********************/
/* BOLETO C\ COD BARRA */
/***********************/

nRow3 := nRow1 + 2175//+ 1125

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+0030, nI, nRow3+0030, nI+30)
Next nI

oPrint:Line (nRow3+0150, 100,nRow3+0150,2300)            
oPrint:Line (nRow3+0080, 660,nRow3+0150, 660)
oPrint:Line (nRow3+0080, 850,nRow3+0150, 850)

If File(cBmp)
   //oPrint:SayBitmap(nRow3+0080,100,cBmp,75,65)
Endif
oPrint:Say  (nRow3+0080,180,cDBancoC ,oFont14 )  // [2]Nome do Banco

oPrint:Say  (nRow3+0075, 673,cBancoC+"-7"  ,oFont18 )   // [1]Numero do Banco
oPrint:Say  (nRow3+0084, 890,aCB_RN_NN[2]  ,oFont14)    // Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+0250,100,nRow3+0250,2300 )
oPrint:Line (nRow3+0350,100,nRow3+0350,2300 )
oPrint:Line (nRow3+0420,100,nRow3+0420,2300 )
oPrint:Line (nRow3+0490,100,nRow3+0490,2300 )

oPrint:Line (nRow3+0350,500 ,nRow3+0490,500 )
oPrint:Line (nRow3+0420,750 ,nRow3+0490,750 )
oPrint:Line (nRow3+0350,1000,nRow3+0490,1000)
oPrint:Line (nRow3+0350,1300,nRow3+0420,1300)
oPrint:Line (nRow3+0350,1480,nRow3+0490,1480)

oPrint:Say  (nRow3+0150,100 ,"Local de Pagamento",oFont8n)
oPrint:Say  (nRow3+0190,100 ,"At้ o vencimento pagแvel em qualquer Banco",oFont9)
           
oPrint:Say  (nRow3+0150,1810,"Vencimento",oFont8n)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol    := 1830  
oPrint:Say  (nRow3+0190,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0250,100 ,"Beneficiario",oFont8n)
oPrint:Say  (nRow3+0290,100 ,aDadosEmp[8]+" - "+ substr(aDadosEmp[1],1,30) ,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+0250,1305,"CNPJ"                                    ,oFont8n)
oPrint:Say  (nRow3+0290,1305,aDadosEmp[6]                              ,oFont10) //CNPJ

oPrint:Say  (nRow3+0250,1810,"Ag๊ncia / C๓digo Beneficiario",oFont8n)
	cString := Alltrim(aDadosBanco[3])+"/"+ALLTRIM(aDadosBanco[4])+"-"+aDadosBanco[5]
nCol    := 1830  //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0290,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0350,100 ,"Data do Documento"                            ,oFont8n)
oPrint:Say  (nRow3+0380,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+0350,505 ,"Nบ do Documento"                              ,oFont8n)
oPrint:Say  (nRow3+0380,605 ,aDadosTit[7]+aDadosTit[1]                      ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+0350,1005,"Esp้cie Docto"                                 ,oFont8n)
oPrint:Say  (nRow3+0380,1050,aDadosTit[8]                                   ,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+0350,1305,"Aceite"                                       ,oFont8n)
oPrint:Say  (nRow3+0380,1350,"NรO"                                          ,oFont10)

oPrint:Say  (nRow3+0350,1485,"Data do Movto"                        ,oFont8n)
oPrint:Say  (nRow3+0380,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)  ,oFont10) // Data impressao

oPrint:Say  (nRow3+0350,1810,"Nosso N๚mero"                                 ,oFont8n)
      cString := Transform(aDadosBanco[6]+aDadosTit[6],"@R 999/99999999-9")
nCol    := 1830  
oPrint:Say  (nRow3+0380,nCol,PADL(cString,17),oFont11c)
    
oPrint:Say  (nRow3+0420,100 ,"Data de Opera็ใo:"                            ,oFont8n)
oPrint:Say  (nRow3+0450,150 , StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)                                      
	
oPrint:Say  (nRow3+0420,505 ,"Carteira"                                     ,oFont8n)
oPrint:Say  (nRow3+0450,555 ,aDadosBanco[6]                                 ,oFont10)

oPrint:Say  (nRow3+0420,755 ,"Esp้cie"                                      ,oFont8n)
oPrint:Say  (nRow3+0450,805 ,"R$"                                           ,oFont10)

oPrint:Say  (nRow3+0420,1005,"Quantidade"                                   ,oFont8n)
oPrint:Say  (nRow3+0420,1485,"Valor"                                        ,oFont8n)

oPrint:Say  (nRow3+0420,1810,"(=)Valor do Documento"                     	,oFont8n)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol    := 1830  
oPrint:Say  (nRow3+0450,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0490,100 ,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do Sacador/Avalista.)",oFont8n)

oPrint:Say  (nRow3+0550,100 ,aBolText[1]  ,oFont10)
oPrint:Say  (nRow3+0590,100 ,aBolText[2]  ,oFont10)
oPrint:Say  (nRow3+0640,100 ,aBolText[3]  ,oFont10)
oPrint:Say  (nRow3+0690,100 ,aBolText[4]  ,oFont10)
oPrint:Say  (nRow3+0740,100 ,aBolText[5]  ,oFont10)

oPrint:Say  (nRow3+0490,1810,"(-)Desconto / Abatimento"                    ,oFont8n)
cString := Alltrim(Transform(aDadosTit[9],"@EZ 99,999,999.99"))
nCol    := 1830  //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0520,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0560,1810,"(-)Outras Dedu็๕es"                          ,oFont8n)
oPrint:Say  (nRow3+0630,1810,"(+)Mora / Multa"                             ,oFont8n)
oPrint:Say  (nRow3+0700,1810,"(+)Outros Acr้scimos"                        ,oFont8n)
oPrint:Say  (nRow3+0770,1810,"(=)Valor Cobrado"                            ,oFont8n)

oPrint:Say  (nRow3+0840,100 ,"Pagador"                                      ,oFont8n)
oPrint:Say  (nRow3+0840,230 ,aDatSacado[1]                                 ,oFont9 )
oPrint:Say  (nRow3+0840,1770,"CNPJ/CPF - "+aDatSacado[7]                   ,oFont9 ) //CNPJ

oPrint:Say  (nRow3+0880,230 ,aDatSacado[3]+" - "+aDatSacado[9]             ,oFont9 )
oPrint:Say  (nRow3+0920,230 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont9) // CEP+Cidade+Estado

oPrint:Say  (nRow3+0985, 100,"Sacador/Avalista "+ substr(aDadosEmp[1],1,30)+" "+aDadosEmp[6]  ,oFont8n)
oPrint:Say  (nRow3+1030,1620,"Autentica็ใo Mecโnica/Ficha de Compensa็ใo"  ,oFont8n)

oPrint:Line (nRow3+0150,1800,nRow3+0840,1800 )
oPrint:Line (nRow3+0560,1800,nRow3+0560,2300 )
oPrint:Line (nRow3+0630,1800,nRow3+0630,2300 )
oPrint:Line (nRow3+0700,1800,nRow3+0700,2300 )
oPrint:Line (nRow3+0770,1800,nRow3+0770,2300 )
oPrint:Line (nRow3+0840,100 ,nRow3+0840,2300 )

oPrint:Line (nRow3+1025,100 ,nRow3+1025,2300 )

MSBAR2("INT25",27.1,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.027,1.5,Nil,Nil,"A",.F.,100,100)

oPrint:EndPage() // Finaliza a pแgina

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRetDados  บAutor  ณMicrosiga           บ Data ณ  06/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera SE1                        					          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ret_cBarra(	cPrefixo,cNumero,cParcela,cTipo,cBanco,cAgencia,cConta,;
                            cDacCC,cNumBco,cNroDoc,nValor,cCart,cMoeda)
Local cNosso	  := ""
Local cDigNosso  := ""
Local cCampoL	  := ""
Local cFatorValor:= ""
Local cLivre	  := ""
Local cDigBarra  := ""
Local cBarra	  := ""
Local cParte1	  := ""
Local cDig1		  := ""
Local cParte2	  := ""
Local cDig2		  := ""
Local cParte3	  := ""
Local cDig3		  := ""
Local cParte4	  := ""
Local cParte5	  := ""
Local cDigital	  := ""
Local aRet		  := {}
Local cNossoBra  := ""
 
// Nosso Numero
If Empty(SE1->E1_NUMBCO)   
    cNossoBra := AllTrim(Strzero(Val(QUMeuNum()),8)) //Nosso N๚mero Safra                  
    cAgencia := Left(Alltrim(cAgencia),4)
    cNosso := cNossoBra 
    cNosso += modulo10(cAgencia+ alltrim(cConta)+ cCart+ cNossoBra)
lse
   cNosso := AllTrim(SE1->E1_NUMBCO)
Endif

//Campo Livre 
cCampoL  := cCart+ alltrim(cNosso)+ alltrim(cAgencia) + AllTrim(cConta) + AllTrim(cDacCC) + "000"                                       

// Campo livre do codigo de barra                   // verificar a conta
If nValor <= 0
   nValor := SE1->E1_SALDO
Endif

cFatorValor := Fator(SE1->E1_VENCTO) + StrZero(nValor * 100,10)

cLivre := cBanco+cMoeda+cFatorValor+cCampoL  

// campo do codigo de barra
cDigBarra := CALC_5p( cLivre )
cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,39)

// composicao da linha digitaADMIN	vel
cParte1  := cBanco + cMoeda + SubStr(cCampoL,1,5)
cDig1    := DIGIT001( cParte1 )
cParte2  := SUBSTR(cCampoL,6,10)
cDig2    := DIGIT001( cParte2 )
cParte3  := SUBSTR(cCampoL,16,10)
cDig3    := DIGIT001( cParte3 )
cParte4  := cDigBarra
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cParte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cParte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cParte3,6,5)+cDig3+" "+;
			cParte4+" "+;
			cParte5 
			
Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)

DbSelectArea("SE1")
SE1->(RecLock("SE1",.F.))
SE1->E1_NUMBCO  := cNosso   // Nosso n๚mero
SE1->E1_PORCJUR := GETMV("MV_XJURBOL")               
SE1->E1_XBANCO  := "422"
SE1->(MsUnlock())
  
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณDIGIT001  บAutor  ณMicrosiga           บ Data ณ  06/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPara calculo da linha digitavel do Unibanco                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIGIT001(cVariavel)
   Local cBase, nUmDois, nSumDig, nDig, nAux, cValor, nDezena

   cBase   := cVariavel
   nUmDois := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nUmDois
      nSumDig += (nAux - If( nAux < 10 , 0, 9))
      nUmDois := 3 - nUmDois
   Next
   cValor := AllTrim(Str(nSumDig,12))
   nAux   := 10 - Val(SubStr(cValor,Len(cValor),1))
   //nDezena := Val(AllTrim(Str(Val(SubStr(cValor,1,1))+1,12))+"0")
   //nAux    := nDezena - nSumDig

   If nAux == 10
      nAux := 0
   EndIf

Return(Str(nAux,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFATOR		บAutor  ณMicrosiga           บ Data ณ  06/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do FATOR  de vencimento para linha digitavel.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Fator(dVencto)
   Local cData  := DTOS(dVencto)
   Local cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCALC_5p   บAutor  ณMicrosiga           บ Data ณ  06/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do digito do nosso numero do                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CALC_5p(cVariavel,lNosso)
   Local cBase, nBase, nAux, nSumDig, nDig

   cBase   := cVariavel
   nBase   := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nBase
      nSumDig += nAux
      nBase   += If( nBase == 9 , -7, 1)
   Next

   nAux := Mod(nSumDig * 10,11)
   If nAux == 0 .Or. nAux == 10
      If lNosso
         nAux := 0
      Else
         nAux := 1
      Endif
   Endif

Return(Str(nAux,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Modulo11 บAutor  ณMicrosiga           บ Data ณ  36/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero do pelo Modulo 10        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function Modulo11(cData,lSafra) //Modulo 11 com base 7

LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
DV:= " "
nN := If(lSafra,9,7)

While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = nN   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		P := 1
	End
	L := L - 1
End
_nResto := mod(D,11)  //Resto da Divisao
//D := 11 - (mod(D,11)) // Diferenca 11 (-) Resto da Divisao
If lSafra
	If _nResto == 0
		return "1"
	elseIf _nResto == 1
		return "0"
	else 
		D := 11 - _nResto
   	DV:=ALLTRIM(STR(D))	
      return DV
	Endif
Else
  if _nResto == 0
      return "0"
  else
	D := 11 - _nResto
   	if D == 10
      	return "P"
   	endif	
  endif 	
Endif
	DV:=AllTrim(STR(D))
Return DV

  */
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AjustaSx1    ณ Autor ณ Microsiga            	ณ Data ณ 06/10/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica/cria SX1 a partir de matriz para verificacao          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                    	  		ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//---> REMOVIDO compatibiliza็ใo para versใo 12.1.25.
/*Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
           "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
           "X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
           "X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
           "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
           "X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
           "X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
           "X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
 	Endif	
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next
Return*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Modulo10 บAutor  ณMicrosiga           บ Data ณ  36/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero do pelo Modulo 10        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Modulo10(cVariavel)
   Local cBase, nBase, nAux, nSumDig, nDig

   cBase   := cVariavel
   nBase   := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nBase
      nAux    -= If( nAux > 9 , 9, 0)
      nSumDig += nAux
      nBase   := If( nBase == 2 , 1, 2)
   Next

   nAux := 10 - Mod(nSumDig,10)
   If nAux == 10
      nAux := 0
   Endif

Return(Str(nAux,1))      

Static Function QUMeuNum( )
   Local cNumero := ""
   Local nTam := TamSx3("EE_FAXATU")[1]

   cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)
   cNumero := Soma1(cNumero)

   SE1->(RecLock("SE1",.F.))
   Replace SE1->E1_NUMBCO With cNumero
   SE1->( MsUnlock( ) )
   
   SEE->(RecLock("SEE",.F.))
   Replace SEE->EE_FAXATU With cNumero
   SEE->( MsUnlock() )

   DbSelectArea("SE1")
Return(SE1->E1_NUMBCO)
