#INCLUDE "protheus.ch"
User Function ENVNOTA()

	Local aCores      := {}

	Private aRotina   :=MenuDef()
	Private cCadastro :="Testa Envio de NF"
	Private aParam    :={}
	Private aRet      :={}                  
	Private nOpc      :=0

	aCores    := {{"F2_FIMP==' ' .AND. AllTrim(F2_ESPECIE)=='SPED'",'DISABLE' },;	//NF n„o transmitida
				  {"F2_FIMP=='S'",'ENABLE'},;									//NF Autorizada
				  {"F2_FIMP=='T'",'BR_AZUL'},;									//NF Transmitida
				  {"F2_FIMP=='D'",'BR_CINZA'},;									//NF Uso Denegado
				  {	"F2_FIMP=='N'",'BR_PRETO'}}									//NF nao autorizada    

	DbSelectArea("SF2")
	DbSetOrder(1)

	mBrowse( 6, 1,22,75,"SF2",,,,,,aCores)

	Return()
	***********************************************************
Static Function MenuDef()
	Local aRotina := {  { "Pesquisar" 	,"AxPesqui"	 , 0 , 1 },;
                    	{ "Visualizar"	,"AxVisual"  , 0 , 2 },;
                	    { "Envia NF  "	,"U_ENVNOTA1", 0 , 2 } }
Return( aRotina )
********************************************************** 
User Function ENVNOTA1()
IF Aviso("AtenÁ„o","Confirma o envio da NF.: " + SF2->F2_DOC + " - " + SF2->F2_SERIE ,{"Sim","N„o"}) == 1
	//-- Transmissao da Nota para o SEFAZ
    cNotaFeita := SF2->F2_DOC
    cSerie     := SF2->F2_SERIE
    cErro := ""
	msgRun("Processando transmiss„o de nota...","Aguarde",{|| fTransAuto() })	

	//If !U_REFATA07(cNotaFeita, cSerie, @cErro)
	//	Help( Nil, Nil, "ERROR", Nil, cErro, 1, 0 )
    //EndIf
    //Aviso("AtenÁ„o", "OK...!!!!!", {"Voltar"})
Endif

Return
*********************************


/*/{Protheus.doc} fTransAuto

Faz a transmiss√£o autom√°tica de nota.

@author Fabio Abinajm.
@since 16/07/2015
@version 1.0
/*/
Static Function fTransAuto

	Local cModel := "55"
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	Local cIdEnt := RetIdEnti()
	Local aArea  := SF2->(GetArea())
	Local lOk    := .T.

	Local oWS
	Local cAmbiente   := ""
	Local cModalidade := ""
	//Local cVersaoCTe  := ""
	Local cVersao     := ""
	Local cRet        := ""
	Local lEnd        := .F.

	Private bFiltraBrw := {|| .T. }

	oWS := WsSpedCfgNFe():New()

	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nAmbiente  := 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"

	lOk := oWS:CFGAMBIENTE()

	cAmbiente := oWS:cCfgAmbienteResult

	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo   := cModel

	lOk := oWS:CFGModalidade()

	cModalidade    := oWS:cCfgModalidadeResult


	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:cVersao    := "0.00"
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"

	lOk := oWS:CFGVersao()

	cVersao := oWS:cCfgVersaoResult

//lOk := oWS:CFGVersaoCTe()
//cVersaoCTe     := oWS:cCfgVersaoCTeResult

	If lOk
		If ValType(SubStr(cAmbiente,1,1)) == "U"
			Msgalert("Identificamos uma instabilidade no serviÁo e-mail, favor executar a rotina de transmiss„o manual atÈ que o serviÁo seja normalizado.")
		Else
			cAmbiente   := SubStr(cAmbiente,1,1)
			cModalidade := SubStr(cModalidade,1,1)
			
			cRet := SpedNFeTrf(aArea[1],SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC,cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,.F.,.T.)
			If !IsInCallStack("U_IMPAUT")
				msgInfo(cRet)
			EndIf	
		Endif
	Else

		alert("Erro nos par√¢metros para transmiss√£o!")

	EndIf

Return lOk

