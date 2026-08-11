#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#INCLUDE "rwmake.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"

Static __cEmpIni	:= ""
Static __cFilIni	:= "" 

#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ xCmdFatEst  ³ Autor ³   Meliora/Gustavo  ³ Data ³        L  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ESPELHAMENTO DE ESTOQUE COMMEND X Lonk                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*------------------------------------------------*
User Function XRLSMOTOR(_nMnJob,_lAuto,_lManu,_cPrcSZZ,_cSeeAutoMT,_cCodProdZY)
*------------------------------------------------*
Default _lAuto    := iIF(Empty(FunName()),.T.,.F.)
Default _nMnJob   := ''
Default _lManu    := .T.
Default _cPrcSZZ  := ''

Default _cSeeAutoMT := ''
Default _cCodProdZY := ''

Private _lManual  := _lManu
Private _cJob     := _nMnJob
Private _lReturn  := .T.
Private _aEmp     := {}
Private _aEstoque := {}
Private __cUseSys := ''
Private _lSld_Imp := .F.

Private _cPedido  := ''
Private _cNota    := ''
Private _cCrtSZZ  := ''

Private _cWfMsg   := ''

Private P_OK      :=1
Private P_OBS     :=2
Private P_NOTA    :=3
Private P_SERIE   :=4
Private P_CODB1   :=5
Private P_QTDCOM  :=6 
Private P_PRCCOM  :=7
Private P_TOTCOM  :=8
Private P_ITORIG  :=9
Private P_CHVNFE  :=10

Private Z_END   :=1
Private Z_QTD   :=2
Private Z_REC   :=3
Private Z_LIN   :=4

Private _lAutoNfe  := .T.
Private aPvlNfs    := {}     

Private SYS_STATUS  := 01
Private SYS_OBS     := 02
Private SYS_DOC     := 03
Private SYS_SERIE   := 04
Private SYS_PRODUTO := 05
Private SYS_QUANT   := 06
Private SYS_VALOR   := 07
Private SYS_TOTAL   := 08
Private SYS_ITEM    := 09
Private SYS_LOCAL   := 10
Private SYS_SEFAZ   := 11
Private SYS_CC      := 12

Private cMV_MOTOR1 := GetMv("MV_MOTOR1")

IF !_lAuto
	xCmdTelaEE(_cSeeAutoMT)
Else
	xIniMotor(_cPrcSZZ,@_cCodProdZY)
ENDIF
        
Return(.T.)

*------------------------*
Static Function xCmdTelaEE(_cSeeAutoMT)
*------------------------*                  
Private cXml    := '' , oXml
Private aXML    := {} 
Private _aITXML := {}  

Private _oPRD := Nil

Private _cPerg   := 'CMFATEST'
Private _cFilSZZ := ''

Private _aITIMP := {}
Private _aCBIMP := {}


Private _oOk    := LoadBitmap( GetResources(), "BR_VERDE"    ) 
Private _oNo    := LoadBitmap( GetResources(), "BR_VERMELHO" ) 
Private _oXX    := LoadBitmap( GetResources(), "BR_CANCEL" ) 
Private _oOff   := LoadBitmap( GetResources(), "BR_PRETO" ) 

Private _cImgCB     := ''
Private oImgFR
Private oImgNF 
Private _cLogo      := ''
Private oImgLogo 
Private _cUsuario   := ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))
Private aRatSDE	    := {}
Private cNota		:= Space(09)  
Private cSerie		:= Space(03)
Private _cNatOp		:= ''
Private _cCNPJ		:= Space(18)
Private _cMensag	:= ''
Private nTotalNF	:= 0
Private nTotIt		:= 0
Private _cFornecedor:= ''
Private _cTelefone	:= ''
Private _cInscr		:= ''
Private _cEnd		:= ''
Private _cCidade	:= ''
Private _cEmissao	:= ''
Private cUm			:= ''
Private nDescont	:= 0   
Private _cNFiscal   := ''
Private _nValIPI    := 0
Private _aBrTela    := {}

Private _lSeeAutoMT := !Empty(_cSeeAutoMT)

IF !FILE(_cLogo)
	_cLogo := ''
ENDIF

DbSelectArea('SZZ')

//³ Fontes do windows usadas											
DEFINE FONT oFont1 NAME "Arial Black" SIZE 6,17
DEFINE FONT oFont2 NAME "Courier New" SIZE 8,14
DEFINE FONT oFont3 NAME "Arial Black" SIZE 13,20
DEFINE FONT oFont4 NAME "Arial Black" SIZE 13,15
DEFINE FONT oFont5 NAME "Arial Black" SIZE 7,17
DEFINE FONT oFont6 NAME "Courier New" SIZE 6,20
DEFINE FONT oFont7 NAME "Courier New" SIZE 7,20
DEFINE FONT oFont8 NAME "Arial"       SIZE 12,25

DEFINE FONT oFont9 NAME "Courier New" SIZE 9,20

//---> REMOVIDO compatibilização para versão 12.1.25.
/*_cEmpresa  := SM0->M0_CODIGO
_cCorrente := SM0->M0_CODFIL*/

_cEmpresa  := FWCodEmp()
_cCorrente := FwCodFil()

//---> REMOVIDO compatibilização para versão 12.1.25.
//PutSx1(_cPerg,"01","Emissão De       ","Emissão De       ","Emissão De       ","mv_ch01","D",08,00,00,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","")
//PutSx1(_cPerg,"02","Emissão Ate      ","Emissão Ate      ","Emissão Ate      ","mv_ch02","D",08,00,00,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","")
//PutSx1(_cPerg,"03","Processo De:     ","Processo De:     ","Processo De      ","mv_ch03","C",06,00,00,"G","",/*"SA2"*/,"","","mv_par03","","","","","","","","","","","","","","","","")
//PutSx1(_cPerg,"04","Processo Ate:    ","Processo Ate:    ","Processo Ate     ","mv_ch04","C",06,00,00,"G","",/*"SA2"*/,"","","mv_par04","","","","","","","","","","","","","","","","")
//PutSx1(_cPerg,"05","Tipo de Processo?","Tipo de Processo?","Tipo de Processo?","mv_ch05","N",01,00,00,"C","","   ","","","mv_par05","Normal","Normal","Normal","","Beneficiamento","Beneficiamento","Beneficiamento","Ambos","Ambos","Ambos","","","","","","",{'Normal, Beneficiamento ou Ambos'})

//³ Filial e empresa atual												
//---> REMOVIDO compatibilização para versão 12.1.25.
/*DbSelectarea("SM0")
Dbsetorder(1)
Dbgotop()
Dbseek(_cEmpresa+_cCorrente)*/

cSerie		:= ''
cEspecie	:= ''
cAlmox		:= ''
cUnidades	:= ''
cPedCom		:= .F.
cNDF		:= .F.
cAlmoPed	:= Space(02)
cZeros		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resolucao da tela													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize  := MsAdvSize()
_nTop  := 650
_nRight:= 1300
_nSize := 631

_cCNPJ	:= ''
lAchou	:= .F.
cNota	:= ''
cEmissao:= ''
cChave	:= ''
_cOpcao	:= ''


IF Empty(_cSeeAutoMT)                          
	_aParamINI := {}; _aRetIni := {}; _aTpFluxo	:= {"Remessa Material","Gera Ordem Prod","Produção da OP","Faturamento",'TODOS'} 
	_aStatus := {"1-C/Pendecia","2-Desativado","3-Processado","4-TODOS"}
	aAdd(_aParamINI,{9,"MOTOR DE PROCESSO - Parametros Iniciais",150,7,.T.})
	
	aAdd(_aParamINI,{1,"Emissão De"  ,Ctod(Space(8)),"","","","",50,.T.}) 
	aAdd(_aParamINI,{1,"Emissão Ate" ,Ctod(Space(8)),"","","","",50,.T.}) 
	
	aAdd(_aParamINI,{1,"Processo De" ,Space(06),"","","SZZ","",0,.F.}) 
	aAdd(_aParamINI,{1,"Processo Ate",Space(06),"","","SZZ","",0,.T.}) 
	
	aAdd(_aParamINI,{2,"Tipo Processo",5,_aTpFluxo,50,"",.T.})
	
	aAdd(_aParamINI,{2,"Status Processo",4,_aStatus,50,"",.T.})
	
	If !ParamBox(_aParamINI,"Configuração",@_aRetIni)
	   	Return
	ENDIF
	MV_PAR01 := _aRetIni[2]
	MV_PAR02 := _aRetIni[3]
	MV_PAR03 := _aRetIni[4]
	MV_PAR04 := _aRetIni[5]
	MV_PAR05 := Upper(ALLTRIM(_aRetIni[6]))
	If ValType(_aRetIni[7]) == "N"
		_aRetIni[7] := Alltrim(Str(_aRetIni[7]))
	EndIf
	MV_PAR06 := Upper(ALLTRIM(Left(_aRetIni[7],1)))
	
	//IF !Pergunte(_cPerg,.T.)
	//	Return
	//ENDIF
ELSE 
	MV_PAR01 := StoD('')	
	MV_PAR02 := StoD('20500101') 
	MV_PAR03 := _cSeeAutoMT  
	MV_PAR04 := _cSeeAutoMT
	MV_PAR05 := 'TODOS'
	MV_PAR06 := '4'
ENDIF

Private _dMVPAR01 := MV_PAR01
Private _dMVPAR02 := MV_PAR02
Private _cMVPAR03 := MV_PAR03
Private _cMVPAR04 := MV_PAR04
Private _cMVPAR05 := MV_PAR05
Private _cMVPAR06 := MV_PAR06

_cFilSZZ := " SZZ->ZZ_FILIAL = '" + xFilial('SZZ') +"' .And. "					+;
			" DtoS(SZZ->ZZ_DATA) >= '"+DtoS(_dMVPAR01)+"' .And. "				+;
           	" DtoS(SZZ->ZZ_DATA) <= '"+DtoS(_dMVPAR02)+"' .And. "				+;
           	" SZZ->ZZ_PROCESS >= '"+_cMVPAR03+"' .And. "	+;
           	" SZZ->ZZ_PROCESS <= '"+_cMVPAR04+"' "

IF _cMVPAR05 <> 'TODOS' 
	_cFilSZZ += " .And. ALLTRIM(SZZ->ZZ_CODDESC) $ '"+_cMVPAR05+"'"
ENDIF

// aHeaders 							
_aTitCB := {}
AADD(_aTitCB,{"ZZ_ID"		,,"ID"			})
AADD(_aTitCB,{"ZZ_IDENT"	,,"Descrição"	})
AADD(_aTitCB,{"ZZ_OCORREN"	,,"Ocorrencia"	})
AADD(_aTitCB,{"ZZ_CHAVE"	,,"Informação"  })
AADD(_aTitCB,{"ZZ_ORIGEM"	,,"ORIGEM"  	})
AADD(_aTitCB,{"ZZ_DESTINO"	,,"DESTINO"  	})
AADD(_aTitCB,{"ZZ_OBS"		,,"Observação"  })

DbSelectarea("SZZ")
SZZ->(Dbgotop())

//legenda de cores					
_aCoresCB := {	{ 'SZZ->ZZ_OCORREN == "1"', 'BR_VERMELHO' 	},;
		    	{ 'SZZ->ZZ_OCORREN == "2"', 'BR_CANCEL'   	},;             
		    	{ 'SZZ->ZZ_OCORREN == "3"', 'BR_VERDE'   	},;		    	
		    	{ 'SZZ->ZZ_OCORREN == "4"', 'BR_AMARELO'   	}}		    	
          
cMarca := GetMark()
linverte:=.f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da rotina											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oTela TITLE OemToAnsi("MOTOR DE PROCESSO - REMESSA / RETORNO DE MATERIAL") FROM 120,040 TO _nTop,_nRight PIXEL Style 128
oTela:lEscClose := .F. 
  
@ 004,615 BITMAP ResName OemToAnsi("CANCEL") OF oTela Size 015,015 ON CLICK( SZZ->(DbClearFilter()) ,oTela:End() ) NoBorder  Pixel 

//TITULO DA TELA
@ 005,150 Say OemToAnsi("MOTOR DE PROCESSO - REMESSA / RETORNO DE MATERIAL") SIZE 400,20 FONT oFont8 OF oTela PIXEL COLOR CLR_HBLUE

@ 017,287 Say OemToAnsi(ALLTRIM(UPPER(FwFilialName( _cEmpresa, _cCorrente, 1 )))) SIZE 400,20 FONT oFont1 OF oTela PIXEL COLOR CLR_HRED

//Quadro Legenda Cabeçalho
@ 028,003 TO 041,188

@ 031,005 BITMAP oBmp RESNAME "BR_VERMELHO" oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 031,015 Say OemToAnsi('Não Iniciado') PIXEL OF oTela 
@ 031,050 BITMAP oBmp RESNAME "BR_CANCEL" oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 031,060 Say OemToAnsi('Erro de Processo') PIXEL OF oTela
@ 031,105 BITMAP oBmp RESNAME "BR_VERDE"  oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 031,115 Say OemToAnsi('Concluido') PIXEL OF oTela

@ 031,141 BITMAP oBmp RESNAME "BR_PRETO"  oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 031,150 Say OemToAnsi('Motor Excluido') PIXEL OF oTela

//Botao cabecalho
IF !_lSeeAutoMT
	@ 030,203 BUTTON OemToAnsi("Parametros")	SIZE 65,10 ACTION MsgRun("Parametros do Processo...",,{|| u_AxSZY() })
	@ 030,273 BUTTON OemToAnsi("Relatório") 	SIZE 65,10 ACTION MsgRun("Imprimindo Relatorio...",,{|| xImpRel() })
	@ 030,343 BUTTON OemToAnsi("Reset Job")  	SIZE 65,10 ACTION MsgRun("Processando Job MOTOR...",,{|| xStartJob(1) })
	@ 030,413 BUTTON OemToAnsi("Start New Job")	SIZE 65,10 ACTION MsgRun("Processando Job MOTOR...",,{|| xStartJob(2) })
ENDIF

//CABECALHO 
DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbGoTop())
//SET FILTER TO &(_cFilSZZ)
//SZZ->(DbGoTop())         

xQrySZZ(@_aBrTela)
IF Empty(_aBrTela)
	MsgInfo('Nenhum processo localizado!'+ENTER+'Revise os parametros',"Atencao")
	_aBrTela := Array(1,7,'');_aBrTela[1,1]:=.F.
	//Return
EndIF
@ 050,002 LISTBOX _oPRD FIELDS HEADER "","Processo","Tipo","Formatação","Emissão","Nota(s) Fiscal(s)","Item(s)",;
				COLSIZES 020,050,050,050,050,200,050;
				SIZE 632,098 OF oTela PIXEL
				xAtuTela(@_oPRD)
				
//ITENS
OBRWP := MsSelect():New("SZZ","","",_aTitCB,@lInverte,@cMarca,{155,002,263,_nSize},,,,,_aCoresCB)
       OBRWP:oBrowse:bLDblClick := {|| xSeeJob() }
       //OBRWI:oBrowse:oFont := TFont():New ("Arial", 05, 18)
	
ACTIVATE DIALOG oTela CENTER

//[ZERA VARIAVEL DE CONTROLE PARA FINALIACAO DO PROCESSO]
_lUseRPEXECPE := Nil

Return                                

*-------------------------------*
Static Function xQrySZZ(_aBrTela)
*-------------------------------*
_aBrTela := {}
_cQry := " SELECT DISTINCT (SELECT COUNT(*) PEND FROM "+RetSqlName('SZZ')+" TEMP WHERE TEMP.D_E_L_E_T_=''  AND TEMP.ZZ_PROCESS = SZZ.ZZ_PROCESS AND TEMP.ZZ_OCORREN NOT IN (' ','3','4')) PENDENCIA, "+ENTER
_cQry += "        ZZ_CODDESC TIPO ,ZZ_PROCESS PROCESS, ZZ_ITEM ITEM, ZZ_DATA EMISSAO, ZZ_NOMEXEC NOMEXEC "+ENTER
_cQry += " FROM "+RetSqlName('SZZ')+" SZZ  "+ENTER
_cQry += " WHERE SZZ.D_E_L_E_T_=''  "+ENTER
_cQry += "   AND ZZ_FILIAL  = '"+xFilial('SZZ')+"'  "+ENTER
_cQry += "   AND ZZ_PROCESS BETWEEN '"+_cMVPAR03+"' AND '"+_cMVPAR04+"'  "+ENTER
_cQry += "   AND ZZ_DATA    BETWEEN '"+DtoS(_dMVPAR01)+"' AND '"+DtoS(_dMVPAR02)+"' "+ENTER
IF _cMVPAR05 <> 'TODOS' 
	_cQry += " AND RTRIM(LTRIM(ZZ_CODDESC)) LIKE '%"+_cMVPAR05+"%'"+ENTER
ENDIF
_cQry += " ORDER BY ZZ_PROCESS "+ENTER
If Select("_TMA") > 0
	_TMA->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_TMA",.F.,.T.) 
DbSelectArea("_TMA");_TMA->(dbGoTop())
While _TMA->(!Eof())
	_lStatus := u_xScanRastro(_TMA->PROCESS)[1] //RETORNA RASTRO DO MOTOR DE PROCESSO
	
	If _cMVPAR06 == '4' .OR. (_TMA->PENDENCIA==0 .AND. _cMVPAR06 == '3') .OR. (!_lStatus .AND. _cMVPAR06 == '2') .OR. (_TMA->PENDENCIA>0 .AND. _cMVPAR06 == '1')
		aADD(_aBrTela,{iIF(!_lStatus,'9',iIF(_TMA->PENDENCIA==0,'1','2')),_TMA->PROCESS, _TMA->TIPO, _TMA->NOMEXEC, DtoC(StoD(_TMA->EMISSAO)), 'NF', _TMA->ITEM})	
	eNDIF
	_TMA->(DbSkip())
EndDo
Return
                
//"","Processo","Descrição","Emissão","Nota(s) Fiscal(s)","Item(s)"

*----------------------------------------------------*
Static Function PROCESREG(_aBrTela,_nLin,_oPRD,oTela)
*----------------------------------------------------*
SZZ->(DbClearFilter())

DbSelectArea('SZZ');SZZ->(DbGoTop())

_cFilSZZ := " SZZ->ZZ_FILIAL = '" + xFilial('SZZ') +"' .And. "+;
           	" SZZ->ZZ_PROCESS = '"+_aBrTela[_nLin,02]+"' "
           	
SET FILTER TO &(_cFilSZZ)
SZZ->(DbGoTop())

_oPRD:Refresh()
_oPRD:SetFocus()
OBRWP:obrowse:Refresh()
//OBRWP:obrowse:Setfocus()                      
ObjectMethod(oTela,"Refresh()")   

Return

*-----------------------------*
Static Function xStartJob(_nButton)
*-----------------------------*
Local _cNextID     := '000'
Local _aAllPrc     := u_xRpsListaPrc(iIF(_nButton==1,SZZ->ZZ_CODEXEC,))
Default _nButton   := 0 

If Empty(__cEmpIni+__cFilIni)
	__cEmpIni	:= cEmpAnt
	__cFilIni	:= cFilAnt
EndIf 

IF Empty(_aAllPrc)
	Return(.F.)
ENDIF        

IF	_nAviso := Aviso("MOTOR DE PROCESSO","                                  ATENÇÃO"+ENTER+;
					'A Execucao do processo é exclusicamente off-line, por conta da variação entre as Empresas.'+ENTER+;
					'Caso deseje executar manualmente, deverá aguardar o processo automatico concluir todos os passos Pre Configurados.'+ENTER+ENTER+;
					'Opções:'+ENTER+'Processar - Executar MOTOR'+ENTER+'Canceçar - Sair da Rotina MOTOR',{"Processar","CANCELAR"},3)==2
	Return
ENDIF

IF Len(_aAllPrc) == 0
	Return
ENDIF
	
IF _nButton == 2

	IF MsgYesNo('Esse processo fará automaticamente todos os passo definidos pela configuração corrente'+ENTER+ENTER+;
				'Lista de Processamentos:'+ENTER+_aAllPrc[2],'Motor REPLAS')					
		u_XRLSMOTOR(,.T.,.T.,,,_aAllPrc[3])
	ENDIF
	
ElseIF _nButton == 1

	IF !NextProcess(@_cNextID)
		Return               
	ENDIF
	IF MsgYesNo('Esse processamento condiz em preencher todos requisitos do MOTOR DE PROCESSO'+ENTER+ENTER+;
				'Lista de Processamentos habilitados'+ENTER+_aAllPrc[2],'Motor REPLAS')
									
		u_XRLSMOTOR(_cNextID,.T.,.T.,SZZ->ZZ_PROCESS,,_aAllPrc[3])
	ENDIF
EndIF

Return

*---------------------------*
User Function xRpsListaPrc(_cIdStart,_cSelIdProd)
*---------------------------*
Local _aProcess := {}
Local _cDescr   := ''               

Default _cSelIdProd := ''

Default _cIdStart := RetCodNewJob(_cIdStart,@_cSelIdProd,'1') //'000001'//RETORNO NUMERO DO PROCESSO PARA EXECUCAO - ATIVO COMO 010

IF Empty(_cIdStart)
	Alert('Não existe configuração inicial "010" para empresa vigente!'+ENTER+'Revise os parametros da rotina!')
	Return(_aProcess)
ENDIF

_cQry := " SELECT ZY_CODIGO CODIGO, ZY_SEQ SEQ, ZY_DESCRI DESCRI , ZY_DESCUSR DESCUSR, ZY_EMPRESA EMPRESA, ZY_MSBLQL MSBLQL, R_E_C_N_O_ RECSZY "+ENTER
_cQry += " FROM "+RetSqlName('SZY')+" "+ENTER
_cQry += " WHERE D_E_L_E_T_  = ''  "+ENTER
_cQry += " AND ZY_EMPRESA    = '"+__cEmpIni+"'  "+ENTER
_cQry += " AND ZY_XFILIAL    = '"+__cFilIni+"' "+ENTER
_cQry += " AND ZY_CODIGO     = '"+_cIdStart+"' "+ENTER
_cQry += " ORDER BY ZY_CODIGO, ZY_SEQ "+ENTER
If Select("_PRC") > 0
	_PRC->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_PRC",.F.,.T.) 
DbSelectArea("_PRC");_PRC->(dbGoTop())
While _PRC->(!Eof())
	IF _PRC->MSBLQL == '2'
		aADD(_aProcess,{_PRC->CODIGO, _PRC->SEQ, _PRC->DESCRI , _PRC->DESCUSR, _PRC->EMPRESA, _PRC->MSBLQL, _PRC->RECSZY})	
		_cDescr += '['+_PRC->SEQ +'] - '+AllTrim(_PRC->DESCUSR) +ENTER
	ENDIF
	_PRC->(DbSkip())
EndDo

IF aScan(_aProcess,{|s| Left(s[2],2)=='01'}) == 0
	conout('Não existe processo ativo para empresa corrente.'+ENTER+'Revise as configurações do Motor de Processo','Atenção')
	_aProcess := {}
ENDIF           

Return({_aProcess,_cDescr,_cIdStart})

*---------------------------------*
Static Function xIniMotor(_cPrcSZZ,_cCodProdZY)
*---------------------------------*
Local _lStarMT   := .F.
Local _aAllPrc   := u_xRpsListaPrc(_cCodProdZY)[1]
Local _cRetNFs   := ''
Local _aReProcPV := {.F.,'4'}

IF Empty(_aAllPrc[1])
	Return
ENDIF
ConOut('______________INICIO DO PROCESSO "xCmdMOTOR"______________')

CHKFILE("SZY");CHKFILE("SZZ")
DbSelectArea('SZY');SZY->(DbGoTop())

//INICIA PROCESSO DE LISTAGEM DA MERCADORIAS QUE SERAO MOVIMENTADAS 
IF ( Empty(_cJob) .Or. _cJob <= '010' ) .And. Type('_oPRD') <> 'U'
	MsgRun("Montando Estrutura","Favor aguarde ... ",{|| xScanItens(@_aEstoque,@__cUseSys,@_lSld_Imp,@_lmanual,_cJob,@_cRetNFs,_cCodProdZY) })
	IF EMPTY(_aEstoque)
		RETURN
	ENDIF
	
	_cCrtSZZ := CmdControlZZ(,,,,,,,_cCodProdZY) //GERA CODIGO DE MOTOR
	WfControl('010',.T.,_cRetNFs,,,,,_cCodProdZY)
	RlGrvSZZ('SF1','F1_XMOTOR' ,_cCrtSZZ)
	MsgInfo('Numero de Processo Gerado: '+_cCrtSZZ,'MOTOR DE PROCESSO')
		
Else //Reprocessamento	
	_cCrtSZZ  := _cPrcSZZ //_cInfoQry := Posicione("SZZ",1,xFilial("SZZ")+_cPrcSZZ+'010',"ZZ_USESYS"); _cCrtSZZ := _cPrcSZZ	
	_cIdOld   := xProcDefore(_cJob)
	
	//Retorna Dados de OUTRA SEQUENCIA SZZ [1=ZZ_USESYS | 2=ZZ_CHAVE]
	_aRetSZZ  := xRetSZZ(_cPrcSZZ, iIF(Empty(_cIdOld),'010',_cIdOld))			                                          
	_cInfoQry := _aRetSZZ[1]
	If _aRetSZZ[3] == "MATA410" .and. "Triangular" $ _aRetSZZ[2]
		_cPedido  := _aRetSZZ[2]
	Else
		_cPedido  := ""
	EndIf
	
	If _aRetSZZ[3] <> "MATA410"
		_cNota 	  := _aRetSZZ[2]
	Else
		_cNota 	  := ""
	EndIf
	
	If _aRetSZZ[3] == "MATC090"
		If Empty(_cPedido) .and. !Empty(_cNota)
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+_cNota))
				_cPedido := SD2->D2_PEDIDO
				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+_cPedido))
			EndIf
		EndIf
	EndIf
	
	LoadUserSys(@_aEstoque, _cInfoQry)
EndIF	

IF Len(_aEstoque) == 0 .and. Empty(_cInfoQry)
	MsgInfo('Erro ao efetuar download da estrutura ['+_cIdOld+'].'+ENTER+'Dados nao localizados...','Motor de Processo')
	REturn
ENDIF

DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbgoTop());SZZ->(DbSeek(xFilial('SZZ')+_cCrtSZZ))
IF !Empty(_cJob) //PARA REPROCESSAMENTO
	While SZZ->(!EOf()) .And. _cCrtSZZ == SZZ->ZZ_PROCESS             
		IF _cJob == SZZ->ZZ_ID
			_lStarMT := .T.
			
			IF ALLTRIM(SZZ->ZZ_ROTINA) $ 'MATA410|MATC090'
				IF SZZ->ZZ_NEXTPV <> 'X'
					_aReProcPV := {.T.,SZZ->ZZ_NEXTPV}; _cPedido  := _cNota := AllTrim(SZZ->ZZ_CHAVE)
				ENDIF
			ENDIF
			EXIT
		ENDIF
	SZZ->(DbSkip())
	ENDDO
Else
	DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbgoTop())
	IF SZZ->(DbSeek(xFilial('SZZ')+_cCrtSZZ))
		_lStarMT := .T.
		xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID) //posiciona no processo correto para SZY (Parametros)
	ENDIF
ENDIF
   
IF _lStarMT
	//xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID)
ENDIF

//LOOP DE PROCESSAMENTO	
WHILE _lStarMT
		
	IF Empty(_cJob) .Or. SZY->ZY_PROXIMO >= _cJob .Or. Empty(SZY->ZY_PROXIMO) //PARA REPROCESSAMENTO NAO DEVE PULAR PARA A PROXIMA EXECUCAO
		IF Empty(_cNextSZZ := SZY->ZY_PROXIMO)
			_lStarMT := .F.; Exit
		ENDIF	
	
		//POSICIONA NA INFORMAÇÃO DO ID QUE SERA PROCESSADO
		DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbgoTop());SZZ->(DbSeek(xFilial('SZZ')+_cCrtSZZ+_cNextSZZ))
		IF _cCrtSZZ+_cNextSZZ <> SZZ->ZZ_PROCESS+SZZ->ZZ_ID
			ALERT('ERRO DE POSICIONAMENTO SZZ - Proximo ID')
			EXIT
		ENDIF
	ENDIF
		
	xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID)
		
	MsgRun(AllTrim(SZZ->ZZ_IDENT), ALLTRIM(SZY->ZY_ROTDESC)+' ['+AllTrim(SZZ->ZZ_ORIGEM)+' > '+AllTrim(SZZ->ZZ_ORIGEM)+']',{|| xEXECUTA(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,@_aReProcPV) })
 	IF !_lReturn
		Exit
	ENDIF	
ENDDO

IF Type('_oPRD') <> 'U'
	xAtuTela(@_oPRD)
	PROCESREG(_aBrTela, iIF(!Empty(_cJob),_oPRD:nAt,Len(_aBrTela)) ,_oPRD,oTela)
ENDIF

//[##]
//Public _lUseRPEXECPE := Nil
_lUseRPEXECPE := Nil
RETURN

*-----------------------------------------------*
Static Function LoadUserSys(_aEstoque, _cInfoQry)
*-----------------------------------------------*
Local _aEstoque := {}
Local _aInfoQry := StrTokArr(AllTrim(_cInfoQry),"**")
Local _nS, _nR

For _nR:=1 To Len(_aInfoQry)
	_aTemp := {}
	_aInfoTmp := StrTokArr(AllTrim(_aInfoQry[_nR]),"|")
	IF Len(_aInfoTmp) <= 1
		loop
	ENDIF   
	
	For _nS:=1 To Len(_aInfoTmp)
		IF _nS==1
			aADD(_aTemp,!_aInfoTmp[_nS]=='.F.')
		ElseIF cValToChar(_nS) $ '6/7/8'      	
			aADD(_aTemp,VAl(_aInfoTmp[_nS]))
		Else 
			aADD(_aTemp,_aInfoTmp[_nS])
		EndIF
	Next _nS
	aADD(_aEstoque,_aTemp)
Next 
Return

/*
//PROCESSAMENTO DE FINALIZACAO DO PROCESSO
IF Empty(_cJob) .Or. _cJob <= '98'
	ConOut('[XRLSMOTOR / xEndereca] - FIM DO PROCESSO ') 
	CmdControlZZ(_cCrtSZZ,'98',.T.,'CONCLUIDO','')   
ENDIF

//PROCESSAMENTO DE ENVIO DE WORKFLOW DE NOTIFICACAO
IF Empty(_cJob) .Or. _cJob <= '99'
	FwMsgRun(,{|| CmdSendMail(_aEmp,_aEstoque,_cPedido,_cNota,_cWfMsg,,_cCrtSZZ) }, "Aguarde Processamento...","Enviando E-mail de notificação "+_aEmp[1][1])
ENDIF
*/
*------------------------------------------*
Static Function WfControl(_cID,_lOk,_cMSg,aListBox,_cMsTemp,__cUseSys,_cRotina,_cCodZZProc)
*------------------------------------------*
//Local _cMsTemp := ''
Default aListBox := {}
Default _cMsTemp := ''
Default __cUseSys := ''
Default _cRotina := ''

//IF _nOpc == 1 //<!-- <><><><><><><><><><><><><><><><><><><> BLOCO NECESSIDADE DE COMPRAS - EE <><><><><><><><><><><><><><><><><><><> -->
	IF !_lOk
		CmdControlZZ(_cCrtSZZ,_cID,.F.,_cMSg/*CHAVE*/,_cMsTemp/*OBS*/,__cUseSys,_cRotina,_cCodZZProc)
	Else
		CmdControlZZ(_cCrtSZZ,_cID,.T.,_cMSg/*CHAVE*/,_cMsTemp/*OBS*/,__cUseSys,_cRotina,_cCodZZProc)
    EndIF
//ENDIF
RETURN

*----------------------------------*
Static Function CmdControlZZ(_cCodSZZ,_cID, _lStatus,_cChv, _cObs,__cUseSys,_cRotina,_cProcesso)
*----------------------------------*
Local _aSZZ :=  {}
Local _nC
Local cSql	:= ""	
Local cUsaSeq := GetNewPar("MV_XUSASEQ","1")										

Private cMV_MOTOR1 := GetMv("MV_MOTOR1")

Default _cCodSZZ   := ''
Default _cID       := ''  
Default _lStatus   := .F.
Default _cChv      := '' 
Default _cObs      := ''
Default __cUseSys  := ''
Default _cRotina   := ''
Default _cProcesso := iIF(Empty(_cCodZZProc),'100001',_cCodZZProc)

_aSZZ    := u_xRpsListaPrc(_cProcesso)[1]

_cOldEmp := cEmpAnt;_cOldFil := cFilAnt

SZZ->(DbClearFilter())

IF Empty(_cCodSZZ)
	
	If cUsaSeq == '0'
		//DbUseArea(.T.,"TOPCONN",TCGENQRY(,,"SELECT MAX(ZZ_PROCESS) MAXSZZ FROM "+RetsqlName('SZZ')+" SZZ WHERE ZZ_FILIAL='"+xFilial('SZZ')+"' AND ZZ_CODEXEC='"+SZY->ZY_CODIGO+"'"),"_MAX",.F.,.T.)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,"SELECT MAX(ZZ_PROCESS) MAXSZZ FROM "+RetsqlName('SZZ')+" SZZ WHERE ZZ_FILIAL='"+xFilial('SZZ')+"'" ),"_MAX",.F.,.T.)  
		DbSelectArea("_MAX")
		_cCodSZZ := iIF(!Empty(_MAX->MAXSZZ),Soma1(_MAX->MAXSZZ),'000001')
		_MAX->(DbCloseArea())
	Else
		
		//(TSM David - 01/11/2017)incluida obtenção de código via sequence devido concorrencia de processamento
		If Select("QRYSEQ") > 0
			QRYSEQ->(DbCloseArea())
		EndIf
		
		BeginSql Alias "QRYSEQ"
			%noparser%
			SELECT 
				COUNT(*) as SEQ
			FROM sys.sequences
				WHERE name = 'xseqprocess'
		EndSql
		
		If QRYSEQ->SEQ = 0
			cSql := "CREATE SEQUENCE xseqprocess AS int START WITH 1 INCREMENT BY 1"
			TcSqlExec(cSql)
		EndIf
		
		If Select("QRYPRX") > 0
			QRYPRX->(DbCloseArea())
		EndIf
		
		BeginSql Alias "QRYPRX"
			%noparser%
			SELECT NEXT VALUE FOR xseqprocess as SEQ
		EndSql
		
		_cCodSZZ := StrZero(QRYPRX->SEQ,TamSX3('ZZ_PROCESS')[1])
		DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbGoTop())
		While SZZ->(DbSeek(xFilial('SZZ')+_cCodSZZ))
			If Select("QRYPRX") > 0
				QRYPRX->(DbCloseArea())
			EndIf
			
			BeginSql Alias "QRYPRX"
				%noparser%
				SELECT NEXT VALUE FOR xseqprocess as SEQ
			EndSql
			
			_cCodSZZ := StrZero(QRYPRX->SEQ,TamSX3('ZZ_PROCESS')[1])
		EnDdo
	EndIF
EndIf
DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbGoTop())
_lExit := SZZ->(DbSeek(xFilial('SZZ')+_cCodSZZ))

IF !_lExit
	Sleep(1000)
	For _nC:=1 To Len(_aSZZ)  
		IF 	RecLock('SZZ',.T.)
				Replace SZZ->ZZ_FILIAL  With xFilial('SZZ')
				Replace SZZ->ZZ_XFILIAL With cFilAnt      
				Replace SZZ->ZZ_CODDESC With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_DESCOD')
				Replace SZZ->ZZ_CODEXEC With _aSZZ[_nC][1]
				Replace SZZ->ZZ_PROCESS With _cCodSZZ				
				Replace SZZ->ZZ_NOMEXEC With _aSZZ[_nC][3]
				Replace SZZ->ZZ_DATA  	With dDataBase
				Replace SZZ->ZZ_STATUS  With '1'				
				
				Replace SZZ->ZZ_ID  	With _aSZZ[_nC][2]
				Replace SZZ->ZZ_IDENT  	With _aSZZ[_nC][4]
				Replace SZZ->ZZ_ITEM  	With cValToChar(Len(_aEstoque))								
				
				Replace SZZ->ZZ_ORIGEM  With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_RAZAO')
				Replace SZZ->ZZ_FROMEMP With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_EMPRESA')
				Replace SZZ->ZZ_FROMFIL With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_MFILIAL')
				Replace SZZ->ZZ_DESTINO With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_TORAZA')
				Replace SZZ->ZZ_TOEMP   With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_TOEMP')
				Replace SZZ->ZZ_TOFIL   With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_TOFILIA')

				Replace SZZ->ZZ_OCORREN With CriaVar('ZZ_OCORREN')
				Replace SZZ->ZZ_CHAVE  	With CriaVar('ZZ_CHAVE')
				Replace SZZ->ZZ_OBS		With CriaVar('ZZ_OBS') 										
				
				Replace SZZ->ZZ_ROTINA  With xInfoSZY(_aSZZ[_nC][1],_aSZZ[_nC][2],'ZY_ROTINA')

				Replace SZZ->ZZ_NEXTPV  With IIF(ALLTRIM(SZZ->ZZ_ROTINA) == 'MATA410','1','X')
			SZZ->(MsUnLock())
		ENDIF
	Next _nC
	//ConfirmSX8()
Else
	DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbGoTop())
	IF SZZ->(DbSeek(xFilial('SZZ')+_cCodSZZ+_Cid))  
		IF 	RecLock('SZZ',.F.)			
				Replace SZZ->ZZ_OCORREN With iIF(_lStatus,'3','2')
				Replace SZZ->ZZ_CHAVE  	With _cChv
				Replace SZZ->ZZ_OBS		With _cObs        
				
				IF _Cid == '010' .Or. !Empty(__cUseSys)
					Replace SZZ->ZZ_USESYS	With __cUseSys
				ENDIF
				
				IF !EMPTY(_cRotina)
					Replace SZZ->ZZ_ROTINA  With _cRotina				
				ENDIF
			SZZ->(MsUnLock())
		ENDIF  
	ENDIF
ENDIF 

//ChangeEmp(_cOldEmp,_cOldFil)

Return(_cCodSZZ) 

*--------------------------------------------------------------------*
Static Function xScanItens(_aEstoque,__cUseSys,_lSld_Imp,_lmanual,_cJob,_cRetNFs,_cCodProdZY)
*--------------------------------------------------------------------*
Local _aAls := Separa('SF1|SD1','|')
Local _aNFs := {} //{85701,85815,85816} 
Local _ng, _nf

Local _nOpcX := 0 

Local _aFilNF := {}
Local _cPerMT := 'XRLSMOTOR'
Local oSim    := LoadBitmap(GetResources(), "CHECKED")	//LoadBitmap( GetResources(), "LBOK")	//LoadBitmap(GetResources(), "CHECKED")
Local oNao    := LoadBitmap(GetResources(), "UNCHECKED") ///LoadBitmap( GetResources(), "LBNO")	//LoadBitmap(GetResources(), "UNCHECKED")  
Local oDlgArq
Local oArq, aAcesso, oAllAcesso
Local oDlg
Local _aButtons:= {}

PRIVATE N_COLREC := 9

//---> REMOVIDO compatibilização para versão 12.1.25.
/*PutSx1(_cPerMT,"01","Data Emissão NF De"	,"Data Emissão NF De"	,"Data Emissão NF De"	,"mv_ch01","D",08,00,00,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","",{'Data da Emissao da Nota Fiscal'})  
PutSx1(_cPerMT,"02","Data Emissão NF Ate"	,"Data Emissão NF Ate"  ,"Data Emissão NF Ate"	,"mv_ch02","D",08,00,00,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","",{'Data da Emissao da Nota Fiscal'}) 
PutSx1(_cPerMT,"03","Nota Fiscal De" 		,"Nota Fiscal De"       ,"Nota Fiscal De"     	,"mv_ch03","C",09,00,00,"G","","SF1","","","mv_par03","","","","","","","","","","","","","","","","")
PutSx1(_cPerMT,"04","Nota Fiscal Ate"		,"Nota Fiscal Ate"      ,"Nota Fiscal Ate"     	,"mv_ch04","C",09,00,00,"G","","SF1","","","mv_par04","","","","","","","","","","","","","","","","")
PutSx1(_cPerMT,"05","Serie De" 	   			,"Serie De"    		    ,"Serie De"        		,"mv_ch05","C",03,00,00,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
PutSx1(_cPerMT,"06","Serie Ate"				,"Serie Ate"     		,"Serie Ate"       		,"mv_ch06","C",03,00,00,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
PutSx1(_cPerMT,"07","Fornecedor De"      	,"Fornecedor De"      	,"Fornecedor De"      	,"mv_ch07","C",08,00,00,"C","","   ","","","mv_par07","","","","","","","","","","","","","","","","",{'Codigo do Fornecedor Inicial'})   
PutSx1(_cPerMT,"08","Loja De"      			,"Loja De"         		,"Loja De"         		,"mv_ch08","C",04,00,00,"C","","   ","","","mv_par08","","","","","","","","","","","","","","","","",{'Codigo do Loja Inicial'})   
PutSx1(_cPerMT,"09","Fornecedor Ate"      	,"Fornecedor Ate"      	,"Fornecedor Ate"      	,"mv_ch09","C",08,00,00,"C","","   ","","","mv_par09","","","","","","","","","","","","","","","","",{'Codigo do Fornecedor Final'})   
PutSx1(_cPerMT,"10","Loja Ate"     			,"Loja Ate"        		,"Loja Ate"      		,"mv_ch10","C",04,00,00,"C","","   ","","","mv_par10","","","","","","","","","","","","","","","","",{'Codigo do Loja Inicial'})   
PutSx1(_cPerMT,"11","Tipo de Filtro        ","Tipo de Filtro       ","Tipo de Filtro       ","mv_ch11","N",01,00,00,"C","","   ","","","mv_par11","PENDENTE","PENDENTE","PENDENTE","","Processados","Processados","Processados","Ambos","Ambos","Ambos","","","","","","",{'Pendete,processados ou ambos'})   */
   
IF !Pergunte(_cPerMT,.T.)
	Return
ENDIF

_dDataIni := MV_PAR01
_dDataFim := MV_PAR02
_cDocIni  := MV_PAR03
_cDocFim  := MV_PAR04 
_cSerIni  := MV_PAR05
_cSerFim  := MV_PAR06 
_cForIni  := MV_PAR07
_cLojIni  := MV_PAR08
_cForFim  := MV_PAR09
_cLojFim  := MV_PAR10
_nFilNfe  := MV_PAR11

_cQry := " SELECT	F1_DOC NOTA, F1_TIPO TIPONF, F1_SERIE SERIE, F1_EMISSAO EMISSAO, F1_FORNECE FORNECE, F1_LOJA LOJA ,"+ENTER
_cQry += "  		CASE WHEN F1_TIPO IN ('D','B') THEN A1_NOME ELSE A2_NOME END NOME, SF1.R_E_C_N_O_ F1REC"+ENTER
_cQry += "   FROM "+RetSqlName('SF1')+" SF1 "+ENTER                                                                                      
_cQry += "   LEFT JOIN "+RetSqlName('SA1')+" SA1 ON SA1.D_E_L_E_T_='' AND A1_FILIAL='"+xFilial('SA1')+"' AND A1_COD=F1_FORNECE AND A1_LOJA=F1_LOJA "+ENTER
_cQry += "   LEFT JOIN "+RetSqlName('SA2')+" SA2 ON SA2.D_E_L_E_T_='' AND A2_FILIAL='"+xFilial('SA2')+"' AND A2_COD=F1_FORNECE AND A2_LOJA=F1_LOJA "+ENTER
_cQry += "     WHERE SF1.D_E_L_E_T_=''  "+ENTER
_cQry += "       AND F1_FILIAL  = '"+xFilial('SF1')+"'  "+ENTER
_cQry += "       AND F1_EMISSAO BETWEEN '"+DtoS(_dDataIni)+"' AND '"+DtoS(_dDataFim)+"' "+ENTER
_cQry += "       AND F1_DOC     BETWEEN '"+_cDocIni+"' AND '"+_cDocFim+"' "+ENTER
_cQry += "       AND F1_SERIE   BETWEEN '"+_cSerIni+"' AND '"+_cSerFim+"' "+ENTER
_cQry += "       AND F1_FORNECE BETWEEN '"+_cForIni+"' AND '"+_cForFim+"' "+ENTER
_cQry += "       AND F1_LOJA    BETWEEN '"+_cLojIni+"' AND '"+_cLojFim+"' "+ENTER
IF _nFilNfe == 1
	_cQry += "       AND F1_XMOTOR  = ' ' "+ENTER
ElseIF _nFilNfe == 2 
	_cQry += "       AND F1_XMOTOR <> ' ' "+ENTER
ENDIF

IF !Empty(_cCodProdZY)
	_cQry += "       AND F1_DOC + 	F1_SERIE + F1_FORNECE + F1_LOJA IN "+ENTER 
	_cQry += "           ( "+ENTER
	_cQry += "       		SELECT D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA 
	_cQry += "       		  FROM "+RetSqlName('SD1')+" SD1 
	_cQry += "       		  INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' AND D1_COD = D1_COD AND B1_XGRUPO = '"+ Right(_cCodProdZY,1) +"'
	_cQry += "                  WHERE SD1.D_E_L_E_T_ = '' 
	_cQry += "                    AND D1_FILIAL  = '"+xFilial('SF1')+"'  "+ENTER
	_cQry += "                    AND D1_EMISSAO BETWEEN '"+DtoS(_dDataIni)+"' AND '"+DtoS(_dDataFim)+"' "+ENTER
	_cQry += "                    AND D1_DOC     BETWEEN '"+_cDocIni+"' AND '"+_cDocFim+"' "+ENTER
	_cQry += "                    AND D1_SERIE   BETWEEN '"+_cSerIni+"' AND '"+_cSerFim+"' "+ENTER
	_cQry += "                    AND D1_FORNECE BETWEEN '"+_cForIni+"' AND '"+_cForFim+"' "+ENTER
	_cQry += "                    AND D1_LOJA    BETWEEN '"+_cLojIni+"' AND '"+_cLojFim+"' "+ENTER
	_cQry += "      	  ) "+ENTER
ENDIF
_cQry += " ORDER BY F1_DOC, F1_SERIE, F1_EMISSAO, F1_FORNECE "

If Select("_TMA") > 0
	_TMA->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_TMA",.F.,.T.) 
DbSelectArea("_TMA");_TMA->(dbGoTop())
While _TMA->(!Eof())
	aADD(_aFilNF,{.F.,_TMA->NOTA,_TMA->SERIE, _TMA->TIPONF, DtoC(StoD(_TMA->EMISSAO)), _TMA->FORNECE, _TMA->LOJA, _TMA->NOME, cValToChar(_TMA->F1REC) })	
	_TMA->(DbSkip())
EndDo   

IF Len(_aFilNF) > 0  
	DEFINE MSDIALOG oDlgArq TITLE OemtoAnsi("MOTOR DE PROCESSO - Documento de Entrada") FROM 0,0 TO 600,1000 OF oDlg PIXEL Style 128
	oDlgArq:lEscClose := .F.
	
		//@ 002,001 SAY  "Pesquisa:" SIZE 100,08 OF oDlgArq PIXEL
		//@ 001,055 MSGET _cCx PICTURE("@!") SIZE 100,008 OF oDlgArq PIXEL
		//@ 002,170 Button "&Pesquisar" Action(xScanCaixa(@oArq,@_cCx)) Size 030,008 PIXEL OF oDlgArq
		
		@ 033,001 LISTBOX oArq FIELDS HEADER OemtoAnsi(""), OemtoAnsi("Nota Fiscal"),	OemtoAnsi("Serie"),	OemtoAnsi("Tipo"),OemtoAnsi("Emissão"),	OemtoAnsi("Cli/For"),	OemtoAnsi("Loja"),	OemtoAnsi("Nome"),	OemtoAnsi("Cod Recno");
					FIELDSIZES 14,50,50,50,50,50,50 SIZE 500,265 PIXEL	
	
		oArq:SetArray(_aFilNF)
		oArq:bLine      := {|| {If(_aFilNF[oArq:nAt,1],oSim,oNao), _aFilNF[oArq:nAt,2], _aFilNF[oArq:nAt,3], _aFilNF[oArq:nAt,4], _aFilNF[oArq:nAt,5], _aFilNF[oArq:nAt,6], _aFilNF[oArq:nAt,7], _aFilNF[oArq:nAt,8], _aFilNF[oArq:nAt,9]}}
		oArq:bLDblClick := {|| AEval(_aFilNF,{|x| x[1]:=.F.}),_aFilNF[oArq:nAt,1]:=.T., oArq:DrawSelect(), oArq:Refresh() }					 							
	
		//@ 280,005 CHECKBOX oAllAcesso VAR lAllAcesso PROMPT OemtoAnsi("Seleciona todos os Itens") SIZE 80, 09 PIXEL ON CLICK( AEval(_aFilNF,{|x| x[1]:=lAllAcesso}),oArq:Refresh())
		
	ACTIVATE MSDIALOG oDlgArq CENTERED ON INIT ( EnchoiceBar(oDlgArq,{|| iIF( aScan(_aFilNF,{|s| s[1]==.T.})==0,MsgInfo('Seleciona uma nota válida!','Atencao'), (_nOpcX:=1,oDlgArq:End())) },{|| oDlgArq:End() },,_aButtons ),oDlgArq:Refresh() )
Else
	MsgInfo('Não foram encontrados registros relacionados.',"Atencao")
EndIF   

IF _nOpcX == 1
	For _nf:=1 To Len(_aFilNF)
		IF _aFilNF[_nf][1]
	   		aADD(_aNFs,VAL(_aFilNF[_nf][N_COLREC]))
	 	ENDIF
	Next _nf	  
ENDIF                           

ProcRegua(Len(_aNFs))

For _ng:=1 To Len(_aNFs) 
	DbSelectArea('SF1');SF1->(DbSetOrder(1));SF1->(DbGoTo(_aNFs[_ng]))
	IF _aNFs[_ng] <> SF1->(Recno())
		Loop
	ENDIF               
	IncProc('['+StrZero(_aNFs[_ng],3)+'] Download Nota Fiscal: '+SF1->F1_DOC)
		
	DbSelectArea('SD1');SD1->(DbSetOrder(1));SD1->(DbGoTop()) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
	IF SD1->(DbSeek(xFilial('SD1')+ SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ))
		WHILE SD1->(!EOF()) .And. xFilial('SD1')+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial('SF1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			
			nD1_CUSTO := Iif( cMV_MOTOR1==1, SD1->D1_VUNIT, (SD1->D1_CUSTO/SD1->D1_QUANT) )
			
			AADD(_aEstoque,{.F.,SPACE(5),SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_COD, SD1->D1_QUANT, nD1_CUSTO, SD1->D1_TOTAL, SD1->D1_ITEM, SD1->D1_LOCAL }) //#aqui
			
			__cUseSys += ".F."+"|"+SPACE(5)+"|"+SD1->D1_DOC+"|"+SD1->D1_SERIE+"|"+SD1->D1_COD+"|"+cValToChar(SD1->D1_QUANT)+"|"+cValToChar(SD1->D1_VUNIT)+"|"+cValToChar(SD1->D1_TOTAL)+"|"+cValToChar(SD1->D1_ITEM)+"|"+SD1->D1_LOCAL+'|'+'SEFAZ'+'|'+'CC'+'**'	
			
			IF !(SD1->D1_DOC+SD1->D1_SERIE $ _cRetNFs)
				_cRetNFs  += SD1->D1_DOC+SD1->D1_SERIE+','
			ENDIF
			SD1->(DbSkip())
		ENDDO 
	ENDIF
Next _ng

IF !Empty(_cRetNFs)
	_cRetNFs := SubStr(_cRetNFs,1,Len(_cRetNFs)-1)
ENDIF
		
Return   
/*
*-----------------------------------*
Static Function xScanCaixa(oArq,_cCx)
*-----------------------------------*  
IF ( _nPCx := aScan(_aFilCadie,{|s| Upper(_cCx) $ Upper(s[2]) })) > 0
	oArq:nAt := _nPCx
	oArq:DrawSelect()
	oArq:Refresh() 
ENDIF
Return
*/
*---------------------------------------------------*
Static Function xInfoSZY(_cCodSZY,_cSeqSZY,_cCpoSZY) 
*---------------------------------------------------*
Local _cIndi   := ''                                      
Local _nRecSZY := SZY->(Recno())
Local _aTm     := {TamSX3('ZY_CODIGO')[1],TamSX3('ZY_EMPRESA')[1],TamSX3('ZY_MFILIAL')[1]}

Default _cCodSZY := '' 
Default _cSeqSZY := ''
Default _cCpoSZY := ''

DbSelectArea('SZY');SZY->(DbSetOrder(4));SZY->(DbGoTop());SZY->(DbSeek(xFilial('SZY') + PadR(_cCodSZY,_aTm[1]) + __cEmpIni + __cFilIni + _cSeqSZY))
//RetIndex('SZY')
//ZY_FILIAL, ZY_CODIGO, ZY_EMPRESA, ZY_MFILIAL, ZY_SEQ, R_E_C_N_O_, D_E_L_E_T_
IF !Empty(_cCpoSZY)
	_cIndi := AllTrim(Posicione('SZY',4,xFilial('SZY') + PadR(_cCodSZY,_aTm[1])+__cEmpIni+__cFilIni+ _cSeqSZY,_cCpoSZY))
	DbSelectArea('SZY');SZY->(DbSetOrder(4));SZY->(DbGoTop());SZY->(DbGoTo(_nRecSZY))
Endif                         

Return(_cIndi)

*-----------------------------*
Static Function xAtuTela(_oPRD)
*-----------------------------*
_aBrTela := {}
xQrySZZ(@_aBrTela)   

IF !Empty(_aBrTela)

	_oPRD:SetArray(_aBrTela)
	//_oXX - MOTOR ESTORNADO | _oOk - MOTOR OK | _oNo - MOTOR COM PENDENCIAS
	
	_oPRD:bLine := { || {	iIF(_aBrTela[_oPRD:nAt,01]=='9',_oOff,  iIF(_aBrTela[_oPRD:nAt,01]=='1',_oOk,_oNo) )  ,;
								_aBrTela[_oPRD:nAt,02] ,;
								_aBrTela[_oPRD:nAt,03] ,;
								_aBrTela[_oPRD:nAt,04] ,;
								_aBrTela[_oPRD:nAt,05] ,;
		                        _aBrTela[_oPRD:nAt,06] ,;
		                        _aBrTela[_oPRD:nAt,07] }}				                        
	_oPRD:BCHANGE    := {|| PROCESREG(_aBrTela,_oPRD:nAt,_oPRD,oTela) } 		
	_oPRD:bLDblClick := {|| xTelaRastro(_aBrTela[_oPRD:nAt,02]) }
	_oPRD:Refresh()
	_oPRD:SetFocus()
ENDIF	
	
Return        

*-----------------------------------*
Static Function NextProcess(_cNextID)
*-----------------------------------*
Local _lExec   := .F.
Local _aArExec := GetArea()
Local _aArExZZ := SZZ->(GetArea())
Local _nRecSZZ := SZZ->(Recno())
Local _cCodPrc := SZZ->ZZ_PROCESS

DbSelectArea('SZZ');SZZ->(DbGoTop());SZZ->(DbSeek(xFilial('SZZ')+_cCodPrc))
/*While SZZ->(!Eof()) .And. SZZ->ZZ_PROCESS==_cCodPrc
   	IF SZZ->ZZ_OCORREN <> '3'   		
	   	_lExec := .T.	
   		Exit
   	ENDIF  
	SZZ->(DbSkip())
EndDo*/
//LOOP DE PROCESSAMENTO	
WHILE !_lExec
	xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID)
	IF Empty(_cNextSZZ := SZY->ZY_PROXIMO)
		Exit
	ENDIF	

	//POSICIONA NA INFORMAÇÃO DO ID QUE SERA PROCESSADO
	DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbgoTop());SZZ->(DbSeek(xFilial('SZZ')+_cCodPrc+_cNextSZZ))
	IF _cCodPrc+_cNextSZZ <> SZZ->ZZ_PROCESS+SZZ->ZZ_ID
		ALERT('ERRO DE POSICIONAMENTO SZZ')
		EXIT
	ENDIF		
	
   	IF !(SZZ->ZZ_OCORREN $ '3|4')
	   	_lExec := .T.	
   		Exit
   	ENDIF  	
ENDDO                                           

IF !_lExec
	MsgAlert('Nao existe pendencia em aberta no processo '+_cCodPrc,'Atenção')
Else
	_cNextID := SZZ->ZZ_ID
	IF !MsgYesNo('O Processo '+_cCodPrc+', '+SZZ->ZZ_ID+' - '+AllTrim(SZZ->ZZ_IDENT)+'.'+ENTER+ENTER+'Encontra-se em aberto, deseja iniciar o processmento MOTOR DE PROCESSO ?','Reprocessamento EE')
		_lExec := .F.
	ENDIF	
ENDIF

DbSelectArea('SZZ');SZZ->(DbGoTo(_nRecSZZ))
RestArea(_aArExec)
RestArea(_aArExZZ)
Return(_lExec)

*---------------------------------------------------------------*
STATIC FUNCTION xEXECUTA(_lReturn,_aEstoque,_cPedido,_cNota,_cWfMsg,_cJob,_aReProcPV)
*---------------------------------------------------------------*
Local _cNotOri 	:= ""
Local _cNotTri 	:= ""
Local _cPedOri 	:= ""
Local _cPedTri 	:= ""
Local _nRecTri 	:= 0
Local _cMsgOri 	:= ""
Local _cMsgTri 	:= ""
Local _cCargaOri:= ""
Local _SeqCarOri:= ""
Local _SeqEntOri:= ""
Local _nRecC9Ori:= 0
Local _cCliOri	:= ""
Local _cCliTri	:= ""
Local _cSerieFat:= xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID,'ZY_SERIE')
Local _cCarga	:= ""
Local _cSeqcar	:= ""
Local _cSeqent	:= ""
Local _nRecSF2	:= 0
Local _aAreaTri	:= {}

PRIVATE _AAREA 	:= GETAREA()
PRIVATE _AARZY 	:= SZY->(GETAREA())
PRIVATE _AARZZ 	:= SZZ->(GETAREA())
Private aHedTrfExc  := {}
Private aColTrfExc  := {}

xChageEmp('ORI')

IF AllTrim(SZY->ZY_ROTINA) == 'MATA410'
	ProcRegua(3)
	
	IncProc('GERANDO PEDIDO DE VENDA')                                
    xScanPedOff(@_cPedido,@_cNota,@_aReProcPV)
    
    If !Empty(_cPedido) .and. SC5->C5_NUM <> _cPedido
    	SC5->(DbSetOrder(1))
    	SC5->(DbSeek(xFilial("SC5")+_cPedido))
    EndIf
    
	IF SZY->ZY_NFTRIAN  //CASO FOR NOTA FISCAL TRIANGULAR
		_cNotOri := IIf(!Empty(_cNota),_cNota,SC5->C5_NOTA)
		_cPedOri := SC5->C5_NUM
		IF !xPedTrigul(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,@_aReProcPV)[2] 
			xChageEmp(,.T.) //RETORNA PARA EMPRESA DE ORIGEM PARA GRACAVAO DE DADOS
			
			//caso não se refira a triangulação mas a mesma esteja parametrizada para
			// transmitir a nota, realiza o processo para nota original da triangulação
			IF SZY->ZY_SEFAZ == '1' .AND. _lReturn
				_lRetSefaz := .T.
				FwMsgRun(,{|| xAutoNfeCmd(_cNotOri,@_lRetSefaz,@_aReProcPV) }, "Aguarde Processamento...",'Verificando Transmissao Sefaz Origem Triangulação '+_cNotOri)
				_lReturn := _lRetSefaz
			ENDIF
			
			RETURN(_lReturn)
		Else
			//Guarda o recno do pedido triangular gerado
			_nRecTri := SC5->(Recno())
			_cPedTri := SC5->C5_NUM  
		ENDIF
	Else
		xGeraPV(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,@_aReProcPV)
	Endif
	
	IF SZY->ZY_FATPV == 'S' .AND. _lReturn
		IncProc('LIBERANDO PEDIDO DE VENDA')
		xLiberPV(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,@_aReProcPV)	
		
		//caso se refira a triangulação guarda nota
		IF SZY->ZY_NFTRIAN 
			_cNotTri := _cNota
		EndIF
	ENDIF
	
	IF SZY->ZY_SEFAZ == '1' .AND. _lReturn
 		//Caso se refira a triangulação grava as mensagens e transmite nota de origem
 		If !Empty(_cNotTri) .and. !Empty(_cNotOri) .and. !Empty(_cPedTri) .and. !Empty(_cPedOri) 
 			_aAreaTri := GetArea()
 			//Posiciona no pedido de origem da triangulação
 			SC5->(DbSetOrder(1))
 			SC5->(DbSeek(xFilial("SC5")+_cPedOri))
 			_cCliTri := SC5->(C5_CLIENT+C5_LOJAENT)
 			_cCliOri := SC5->(C5_CLIENTE+C5_LOJACLI)
 			
 			//Posiciona no cliente de entrega para montar mensagem que vai ser gravada na nota de origem
 			SA1->(DbSetOrder(1))
 			SA1->(DbSeek(xFilial("SA1")+_cCliTri))
 			_cMsgOri := "Mercadoria destinada a industrialização por meio de nossa NF. "+_cNotTri+", "
 			_cMsgOri += "desta data. "+Alltrim(SA1->A1_NOME)+", "+Alltrim(SA1->A1_END)+", CNPJ: "+Alltrim(SA1->A1_CGC)+", Incrição Estadual: "+Alltrim(SA1->A1_INSCR)+", "
 			_cMsgOri += "CEP: "+Alltrim(SA1->A1_CEP)+" Pedido: "+_cPedTri
 			
 			//Posiciona no cliente de entrega para montar mensagem que vai ser gravada na nota de triangulação
 			SA1->(DbSeek(xFilial("SA1")+_cCliOri))
 			_cMsgTri:= "Mercadoria destinada a industrialização por meio de nossa NF. "+_cNotOri+", "
 			_cMsgTri += "desta data na qual foram destacados os impostos e dest. a industrialização por conta e ordem de: "
 			_cMsgTri += Alltrim(SA1->A1_NOME)+", "+Alltrim(SA1->A1_END)+", CNPJ: "+Alltrim(SA1->A1_CGC)+", Incrição Estadual: "+Alltrim(SA1->A1_INSCR)+", "
 			_cMsgTri += "CEP: "+Alltrim(SA1->A1_CEP)+" Pedido: "+_cPedOri
 			
 			//Grava mensagem no Pedido de Origem
 			SC5->(DbSeek(xFilial("SC5")+_cPedOri))
 			RecLock("SC5",.F.)
 				SC5->C5_XMENOTA := _cMsgOri
 			SC5->(MsUnLock())
 			
 			//Grava mensagem no Pedido de Triangulação
 			SC5->(DbSeek(xFilial("SC5")+_cPedTri))
 			RecLock("SC5",.F.)
 				SC5->C5_XMENOTA := _cMsgTri
 			SC5->(MsUnLock())
 			
 			//Ajusta dados referente a carga
 			SF2->(DbSetOrder(1))
 			_cVeiculo 	:= ""
 			_nRecSF2 	:= SF2->(Recno())
 			//Posiciona Nota Origem para obter dados de carga 
 			If SF2->(DbSeek(xFilial("SF2")+padr(_cNotOri,TamSX3('F2_DOC')[1])+_cSerieFat))
 				_cCarga  := SF2->F2_CARGA
 				_cSeqcar := SF2->F2_SEQCAR
 				_cSeqent := SF2->F2_SEQENT
 				RecLock("SF2",.F.)
					SF2->F2_CARGA := ""
					SF2->F2_SEQCAR:= ""
					SF2->F2_SEQENT:= ""
				SF2->(MsUnlock())
 				//Posiciona Nota de Remessa para atualizar informação de carga
 				If SF2->(DbSeek(xFilial("SF2")+padr(_cNotTri,TamSX3('F2_DOC')[1])+_cSerieFat))
 					RecLock("SF2",.F.)
 						SF2->F2_CARGA := _cCarga
 						SF2->F2_SEQCAR:= _cSeqcar
 						SF2->F2_SEQENT:= _cSeqent
 					SF2->(MsUnlock())
 				EndIf
 				SF2->(DbGoTo(_nRecSF2))
 			Endif
 			RestArea(_aAreaTri)
 			//Transmite para Sefaz nota fiscal de Origem
 			_lRetSefaz := .T.
 			
 			//reposiciona para garantir que o cliente correto saia na danfe
 			SF2->(DbSetOrder(1))
 			SF2->(DbSeek(xFilial("SF2")+padr(_cNotOri,TamSX3('F2_DOC')[1])+_cSerieFat))
 			
 			SA1->(DbSetOrder(1))
 			SA1->(DbSeek(xFilial("SA1")+_cCliOri))
 			
 			FwMsgRun(,{|| xAutoNfeCmd(_cNotOri,@_lRetSefaz,@_aReProcPV) }, "Aguarde Processamento...",'Verificando Transmissao Sefaz Origem Triangulação '+_cNotOri)
 			_lReturn := _lRetSefaz
 			
 			If !_lReturn
 				Return(_lReturn)
 			EndIf
 			
 			//reposiciona para garantir que o cliente correto saia na danfe
 			SF2->(DbSetOrder(1))
 			SF2->(DbSeek(xFilial("SF2")+padr(_cNotTri,TamSX3('F2_DOC')[1])+_cSerieFat))
 			
 			SA1->(DbSetOrder(1))
 			SA1->(DbSeek(xFilial("SA1")+_cCliTri))
 		
 		EndIf
		_lRetSefaz := .T.
		FwMsgRun(,{|| xAutoNfeCmd(_cNota,@_lRetSefaz,@_aReProcPV) }, "Aguarde Processamento...",'Verificando Transmissao Sefaz '+_cNota)
		_lReturn := _lRetSefaz
	ENDIF
	
	//Caso se refira a triangulação e a origem é o faturamento de carga ajusta a carga para pedido de triangulação
 	If _lReturn .and. Alltrim(FunName()) == 'MATA460B' .and.  !Empty(_cNotTri) .and. !Empty(_cNotOri) .and. !Empty(_cPedTri) .and. !Empty(_cPedOri)
 		_aAreaTri := GetArea()
 		SC9->(DbSetOrder(1))
 		If SC9->(DbSeek(xFilial("SC9")+_cPedOri)) .and. !Empty(SC9->C9_CARGA)
 			//Guarda dados da carga de origem
 			_cCargaOri := SC9->C9_CARGA
 			_SeqCarOri := SC9->C9_SEQCAR
 			_SeqEntOri := SC9->C9_SEQENT
 			
 			//Atualiza dados da carga no pedido de origem
 			RecLock("SC9",.F.)
 				SC9->C9_CARGA := ""
 				SC9->C9_SEQCAR:= ""
 				SC9->C9_SEQENT:= ""
 			SC9->(MsUnlock())
 			
 			If SC9->(DbSeek(xFilial("SC9")+_cPedTri)) .and. Empty(SC9->C9_CARGA)
	 			//Atualiza dados da carga no pedido de triangulação
	 			RecLock("SC9",.F.)
	 				SC9->C9_CARGA := _cCargaOri
	 				SC9->C9_SEQCAR:= _SeqCarOri
	 				SC9->C9_SEQENT:= _SeqEntOri
	 			SC9->(MsUnlock())
	
	 			//Posiciona no item da caraga (DAI) para atualizar com dados do pedido de triangulação
	 			DAI->(DbSetOrder(4))
	 			GW1->(DbSetOrder(8))
	 			If DAI->(DbSeek(xFilial("DAI")+_cPedOri))
	 				RecLock("DAI",.F.)
	 					DAI->DAI_PEDIDO := _cPedTri
	 					DAI->DAI_CLIENT	:= SC9->C9_CLIENTE
	 					DAI->DAI_LOJA	:= SC9->C9_LOJA
	 					DAI->DAI_NFISCA	:= SC9->C9_NFISCAL
	 					DAI->DAI_SERIE	:= SC9->C9_SERIENF
	 				DAI->(MsUnlock())
	 				
	 				//Posiciona no Romaneio para ajuste da carga de remessa
	 				If GW1->(DbSeek(xFilial("GW1")+_cNotTri))
	 					RecLock("GW1",.F.)
	 					GW1->GW1_SIT	:= "4" //Embarcado
	 					GW1->GW1_NRROM	:= DAI->(DAI_COD+DAI_SEQCAR)
	 				Endif
	 				
	 				//Posiciona no Romaneio para ajuste da carga de venda
	 				If GW1->(DbSeek(xFilial("GW1")+_cNotOri))
	 					RecLock("GW1",.F.)
	 					GW1->GW1_SIT	:= "3" //Liberado
	 					GW1->GW1_NRROM	:= ""
	 				Endif
	 			EndIf
	 		EndIf
 		EndIf
 		RestArea(_aAreaTri)
	Endif
	//Transmissao sefaz 	                 
ELSEIF AllTrim(SZY->ZY_ROTINA) == 'MATA460'
	IF SZY->ZY_SEFAZ == '1' .AND. _lReturn
		_lRetSefaz := .T.
		FwMsgRun(,{|| xAutoNfeCmd(_cNota,@_lRetSefaz,@_aReProcPV) }, "Aguarde Processamento...",'Verificando Transmissao Sefaz '+_cNota)
		_lReturn := _lRetSefaz
	ENDIF
ELSEIF  AllTrim(SZY->ZY_ROTINA) == 'MATA103'      
	IncProc('ENTRADA DE MERCADORIA')
	xEntraNF(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,.F.)	//#aqui
ELSEIF  AllTrim(SZY->ZY_ROTINA) == 'MATA140'      
	IncProc('PRE-NOTA DE ENTRADA DE MERCADORIA')
	xEntraNF(@_lReturn,@_aEstoque,@_cPedido,@_cNota,@_cWfMsg,_cJob,.T.)
ENDIF

xChageEmp(,.T.) //RETORNA PARA EMPRESA DE ORIGEM PARA GRACAVAO DE DADOS

RESTAREA(_AAREA)
RESTAREA(_AARZY)
RESTAREA(_AARZZ)

RETURN(_lReturn)     

*------------------------------------------------*
Static Function xChageEmp(_cOpc,_lEmpINI)
*------------------------------------------------*
	Default _cOpc    := 'ORI'       
	Default _lEmpINI := .F.

	IF _lEmpINI   
		_cAbreEmp := xInfoSZY(SZZ->ZZ_CODEXEC,'010','ZY_EMPRESA')
		_cAbreFil := xInfoSZY(SZZ->ZZ_CODEXEC,'010','ZY_XFILIAL')
	ELSE
		_cAbreEmp := iIF(_cOpc=='ORI',SZZ->ZZ_FROMEMP,SZZ->ZZ_TOEMP)
		_cAbreFil := iIF(_cOpc=='ORI',SZZ->ZZ_FROMFIL,SZZ->ZZ_TOFIL)
	ENDIF

	// Se o tratamento for no mesmo contexto de empresa e filial, não é 
	// necessário modificar as configurações de empresa e filial.
	If cEmpAnt == _cAbreEmp .AND. cFilAnt == _cAbreFil
		Return
	Endif

	cEmpAnt := _cAbreEmp
	cFilAnt := _cAbreFil 

	IF EMPTY(_cAbreEmp) .OR. EMPTY(cFilAnt)
		ALERT('ATENCAO'+ENTER+ENTER+'Erro na abertura das empresas: ['+cEmpAnt+'] ou ['+cFilAnt+'], Revise estrutura SZY e SZZ')
		Return
	ENDIF

	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	
	// Abertura da empresa e filial correspondente ao que for necessário modificação.
	//OpenSM0( cEmpAnt + cFilAnt, .F. )
	// Verificar a conexão com o DbAccess.
	//Connect()
	// Verificar autorização de licenças da empresa.
	//CheckAut( cEmpAnt + cFilAnt )
	// Efetuar abertura dos arquivos de dicionários.
	//OpenSxs(,,.F.,.F.)
	// Inicialização das variáveis de ambiente.
	//InitPublic()
	// Abertura dos alias dos dicionário e eliminação de filtros.
	//OpenData()
Return

*--------------------------------------------------------------*
Static Function xGeraPV(_lReturn,_aEstoque,_cPedido,_cNota,_cWfMsg,_cJob,_aReProcPV)
*--------------------------------------------------------------*
Local _aCabec    := {}
Local _aLinhas   := {}
Local _aAux1     := {}
Local aNota      := {}
Local lGeraPedido:= .F.
Local _cAlias    := SZY->ZY_TIPOCF 
Local _lEditBloq := SZY->ZY_AUTOMAT == 'M'
Local _lOnlyEdit := SZY->ZY_SEQ     == _cJob
Local _nOpcAlt   := 1
Local _nJ
lOCAL _aFormula  := {'',''} 

Local cQuery := ''
Local aInfAdic := {}
Local cC5_XMENNOT := ''
Local i := 0

ConOut('[xCmdFatEst / xCompraProd] - Acessando Empressa '+cFilAnt+'/'+cEmpAnt)	
               
//VALIDA SE PROCESSO FOI 'PARADO' NO PEDIDO DE VENDA______________
IF _aReProcPV[1]
	IF _aReProcPV[2] <> '1' .And. (!Empty(SZZ->ZZ_CHAVE) .Or. !Empty(_cPedido)) //1=PEDIDO;2=FATURAMENTO;3=SEFAZ;4=FIM    |AND| TEM QUE TER O CODIGO QUE FEZ A INCLUSAO DO PEDIDO OU NOTA
		RETURN(_lReturn:=.T.)
	ENDIF
	_aReProcPV := {.F.,'1'}; _lOnlyEdit := .F. //Desabilita o "_lOnlyEdit", pois o pedido não foi gerado no processo de origem ou seja campo 'ZZ_CHAVE' em branco
ENDIF

/*** PROCURA CLIENTE/LOJA ***/		
DbSelectArea(_cAlias);(_cAlias)->(DbSetOrder(1));(_cAlias)->(DbSeek(xFilial(_cAlias)+SZY->ZY_CLIFOR+SZY->ZY_LOJA))


//Valida se pedido ja existe para que não inclua novamente
If xExiProc("SC5",{SZY->ZY_CLIFOR,SZY->ZY_LOJA,SZZ->ZZ_PROCESS,SZZ->ZZ_ID})
	_cPedido := SC5->C5_NUM
	IF !xScanPedOK(@_cPedido) .And. GetMV('RP_SPEDIMT',.F.,.F.) //NOVO - FORCA POSICIONAMENTO DO ITEM DO PEDIDO DE VENDA                                                 		
		WfControl(SZZ->ZZ_ID,.F.,iIF(.F.,_cPedido,),,'ERRO posicao Pedido '+ENTER+SC5->C5_NUM+' x '+SC5->C5_NUM,,'MATA410',SZZ->ZZ_CODEXEC)
		RETURN(_lReturn:=.F.)		
	ENDIF
	
	WfControl(SZZ->ZZ_ID,.T.,_cPedido,,'Pedido Gerado com Sucesso',,'MATA410',SZZ->ZZ_CODEXEC)

	RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)
	RlGrvSZZ('SC5','C5_XMOTOID',SZZ->ZZ_ID)
	RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'2') //PROXIMO PASSO FATURMENTO
	GravaLogOK(xFilial("SC6")+/*SC6->C6_NUM*/SC5->C5_NUM,'C6_FILIAL+SC6->C6_NUM',1,'SC6' ,@__cUseSys,4)
		
	ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Incluso com sucesso!')
	Return(_lReturn:=.T.)
EndIf

/*** NUMERO DO PEDIDO DE VENDA ***/	  
/*
While .T.
	IF _lOnlyEdit .And. !Empty(AllTrim(SZZ->ZZ_CHAVE))
		_cPedido := AllTrim(SZZ->ZZ_CHAVE)
		DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbSeek(xFilial('SC5')+_cPedido));Exit		
	Else     
		_lOnlyEdit := .F.
		_cPedido := GetSX8Num("SC5", "C5_NUM")
		DbSelectArea('SC5');SC5->(DbSetOrder(1))
		IF !SC5->(DbSeek(xFilial('SC5')+_cPedido))
			DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop());Exit
		EndIF
	ENDIF
EndDo
*/
ConOut('[xCmdFatEst / xCompraProd] - Guarda numero do pedido de Venda '+_cPedido)		

	
/*** CABEÇALHO DO PEDIDO DE VENDA ***/	
//aAdd(_aCabec,{"C5_NUM"   	,_cPedido  									,Nil})
aAdd(_aCabec,{"C5_TIPO"   	,SZY->ZY_TIPODOC							,Nil})
aAdd(_aCabec,{"C5_CLIENTE"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_COD')    	,Nil})
aAdd(_aCabec,{"C5_LOJACLI"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_LOJA')   	,Nil})
aAdd(_aCabec,{"C5_CLIENT"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_COD')    	,Nil})
//(David-TSM)Incluído o preenchimento dos campos C5_LOJAENT E C5_TIPOCLI que não estavam 
//sendo preenchidos automaticamente
aAdd(_aCabec,{"C5_LOJAENT"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_LOJA')   	,Nil})
If _cAlias == "SA2"
	aAdd(_aCabec,{"C5_TIPOCLI"	,"R"   	,Nil})
Else
	aAdd(_aCabec,{"C5_TIPOCLI"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_TIPO')   	,Nil})
Endif
aAdd(_aCabec,{"C5_CONDPAG"	,SZY->ZY_CONDPAG							,Nil})
aAdd(_aCabec,{"C5_TPFRETE"	,'C'										,Nil})
aAdd(_aCabec,{"C5_XMOTOR"	,SZZ->ZZ_PROCESS							,Nil})
aAdd(_aCabec,{"C5_XMOTOID"	,SZZ->ZZ_ID									,Nil})
aAdd(_aCabec,{"C5_FECENT"	,ddatabase									,Nil})
		
AddCpoObr(@_aCabec)

/*** SETA NUMERAÇÃO DOS ITENS ***/	
_cItem := "01"

//CASO FOR DEVOLUÇÃO DEVE POSICIONAR NA NOTA DE ORIGEM
//OU PARA BUSCAR ITENS ORIGINARIO DE OUTRA ETAPA
IF SZY->ZY_TIPODOC == 'D' .Or. !Empty(SZY->ZY_DEVSEQ)
	//Retorna Dados de OUTRA SEQUENCIA SZZ [1=ZZ_USESYS | 2=ZZ_CHAVE]
	_aRetSZZ  := xRetSZZ(SZZ->ZZ_PROCESS, SZY->ZY_DEVSEQ)
	_cInfoQry := _aRetSZZ[1]
	LoadUserSys(@_aEstoque, _cInfoQry)
ENDIF
//Obtem a mensagem digitada na nota de entrada 
If FunName() $ 'MATA103/MATA140'
	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(xFilial("SF1")+_aEstoque[1,P_NOTA]+_aEstoque[1,P_SERIE])) .and. !Empty(SF1->F1_MENNOTA)
		aAdd(_aCabec,{"C5_MENNOTA"	, Alltrim(SF1->F1_MENNOTA) ,Nil})
	Endif
Endif

For _nJ:=1 To Len(_aEstoque)
	ConOut('[xCmdFatEst / xCompraProd] - Leitura dos Iten(s): '+cValToChar(_nJ))	

	ConOut('[xCmdFatEst / xCompraProd] - Quantidade de Compra: '+cValToChar(_aEstoque[_nJ][P_QTDCOM]))
	
	ConOut('[xCmdFatEst / xCompraProd] - Validando Produto: '+AllTrim(_aEstoque[_nJ][P_CODB1]))
	
	/*** SETA O PRODUTO ***/
	DbSelectArea('SB1');SB1->(DbSetOrder(1)) 
	IF !SB1->(DbSeek(xFilial('SB1')+_aEstoque[_nJ][P_CODB1]))
		ConOut('[xCmdFatEst / xCompraProd] - Produto invalido: '+xFilial('SB1')+'/'+AllTrim(SB1->B1_COD))
		WfControl(SZZ->ZZ_ID,.F.,'Produto invalido: '+xFilial('SB1')+'/'+AllTrim(SB1->B1_COD),,,,,SZZ->ZZ_CODEXEC)
		RETURN(_lReturn:=.F.)
	ENDIF
	ConOut('[xCmdFatEst / xCompraProd] - Produto Valido: '+AllTrim(SB1->B1_COD))			
	
	_aAux1 := {}
	xNoZero(@_aEstoque[_nJ][P_QTDCOM], @_aEstoque[_nJ][P_PRCCOM])
	
	//Tratamento para: Quando a Mercadorai for MOD, será gerado um pedido seprado para Faturamento, esta definicao é tratado pela funcao: RlModVend
	IF AllTrim(_aEstoque[_nJ][P_OBS])=='MOD' .And. Empty(SZY->ZY_DEVSEQ)
		Loop
	ENDIF
	IF (!Empty(SZY->ZY_DEVSEQ) .And. SZY->ZY_TIPODOC == 'N' .And. AllTrim(_aEstoque[_nJ][P_OBS]) <> 'MOD') .And. Left(SZY->ZY_CODIGO,1) <> '4'
		Loop
	ENDIF
	
	DbSelectArea("SF4");SF4->(DbSetOrder(1))
	DbSelectArea("SM4");SM4->(DbSetOrder(1))
	IF SF4->(DbSeek(xFilial("SF4")+SZY->ZY_TES))
		IF !( SF4->F4_FORMULA $ _aFormula[1]) .And. !Empty(SF4->F4_FORMULA)
			IF SM4->(DbSeek(xFilial('SM4')+SF4->F4_FORMULA))
				_aFormula[1] := SF4->F4_FORMULA          + '|'
				_aFormula[2] := '' //Formula(SF4->F4_FORMULA) + '|'
			ENDIF
		ENDIF
	ENDIF
	
	/*** ITENS DO PEDIDO DE VENDA ***/	
	aAdd(_aAux1,{"C6_ITEM"   	,_cItem	      				,Nil})
	aAdd(_aAux1,{"C6_PRODUTO"	,SB1->B1_COD				,Nil})
	aAdd(_aAux1,{"C6_UM"	    ,SB1->B1_UM				    ,Nil})     
	aAdd(_aAux1,{"C6_QTDVEN" 	,_aEstoque[_nJ][P_QTDCOM]	,Nil})
	aAdd(_aAux1,{"C6_LOCAL"  	,SB1->B1_LOCPAD 			,Nil})
	aAdd(_aAux1,{"C6_TES"    	,SZY->ZY_TES				,Nil})
	//aAdd(_aAux1,{"C6_QTDLIB" 	,_nQtdCompra			   	,Nil})
	aAdd(_aAux1,{"C6_PRUNIT" 	,_aEstoque[_nJ][P_PRCCOM]	,Nil})
	aAdd(_aAux1,{"C6_PRCVEN" 	,_aEstoque[_nJ][P_PRCCOM]	,Nil}) // Bcolisse  - 14/08 -alterado para tratar problema com execauto em nota de serviço.
	aAdd(_aAux1,{"C6_VALOR" 	,Round(_aEstoque[_nJ][P_QTDCOM]*_aEstoque[_nJ][P_PRCCOM],TamSX3("C6_VALOR")[2])	,Nil})
	aAdd(_aAux1,{"C6_ENTREG" 	,dDataBase					,Nil})
	
	IF SZY->ZY_TIPODOC == 'D'
		aAdd(_aAux1,{"C6_NFORI" 	,_aEstoque[_nJ][P_NOTA]		,Nil}) //#aqui
		aAdd(_aAux1,{"C6_SERIORI" 	,_aEstoque[_nJ][P_SERIE]	,Nil})
		aAdd(_aAux1,{"C6_ITEMORI" 	,StrZero(VAL(_aEstoque[_nJ][P_ITORIG]),TamSX3('D1_ITEM')[1]),Nil})

	// "Suspensão do ICMS nos termos do Art.402 Dec. Nº 45490/00 e suspensão do IPI nos termos do "
	// "Art.43.VII-Dec.7212/10 e destacar a que NFE se refere ao Retorno"
	Elseif SZY->ZY_TIPODOC == 'N' .AND. SB1->B1_TIPO == 'MP' .AND. cFilAnt == '0201'
		cQuery := "SELECT TOP 1 D1_DOC, D1_SERIE, D1_ITEM "
		cQuery += "  FROM "+RetSQLName("SD1")+" SD1 "
		cQuery += " WHERE D1_FILIAL = "+ValToSql(xFilial("SD1"))+" "
		cQuery += "       AND D1_COD = "+ValToSql(SB1->B1_COD)+" "
		cQuery += "       AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY D1_EMISSAO DESC "
		cQuery := ChangeQuery(cQuery)
		cTRB := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTRB,.F.,.T.) 
		If (cTRB)->(.NOT.BOF()) .AND. (cTRB)->(.NOT.EOF())
			AAdd(aInfAdic,{SB1->B1_COD,(cTRB)->D1_DOC,(cTRB)->D1_SERIE,(cTRB)->D1_ITEM})
			aAdd(_aAux1,{"C6_NFORI"  ,(cTRB)->D1_DOC  ,Nil}) //#aqui RLEG
			aAdd(_aAux1,{"C6_SERIORI",(cTRB)->D1_SERIE,Nil})
			aAdd(_aAux1,{"C6_ITEMORI",(cTRB)->D1_ITEM ,Nil})
		Endif
		(cTRB)->(DbCloseArea())

	ElseIF SZY->ZY_TIPODOC == 'F'
		//aAdd(_aAux1,{"C6_NFORI" 	,_aSC6[1]		,Nil})               
		//aAdd(_aAux1,{"C6_SERIORI" 	,_aSC6[2]		,Nil})
		//aAdd(_aAux1,{"C6_ITEMORI" 	,_aSC6[3]		,Nil})
		//aAdd(_aAux1,{"C6_IDENTB6" 	,_aSC6[4]		,Nil})   		     
		//F4Poder3(cProduto,cLocal,M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
	ENDIF
	If SC6->(FieldPos("C6_XMOTOR")) > 0 .and. SC6->(FieldPos("C6_XMOTOID")) > 0
		aAdd(_aAux1,{"C6_XMOTOR"	,SZZ->ZZ_PROCESS							,Nil})
		aAdd(_aAux1,{"C6_XMOTOID"	,SZZ->ZZ_ID									,Nil})
	Endif
	AAdd(_aLinhas, _aAux1)
	
	_aEstoque[_nJ][P_OK] := .T. 
	lGeraPedido          := .T.
	/*** ADICIONA O NOVO ITEM ***/
	_cItem := Soma1(_cItem)			
Next _nJ

If Len(aInfAdic)>0
	cC5_XMENNOT := "Suspensão do ICMS nos termos do Art.402 Dec.Nº 45490/00 e suspensão do IPI nos' termos do Art.43.VII-Dec.7212/10 p/ os seguintes prod: "+CRLF
	For i := 1 To Len(aInfAdic)
		cC5_XMENNOT += "Prod:"+RTrim(aInfAdic[i,1])+" Docto:"+aInfAdic[i,2]+" Série:"+aInfAdic[i,3]+" It:"+aInfAdic[i,4]+CRLF
	Next i
	aAdd(_aCabec,{"C5_XMENNOT",cC5_XMENNOT,NIL})
Endif

IF !EMPTY(_aFormula[2]) 
	//aAdd(_aCabec,{"C5_MENNOTA"	,StrTran(_aFormula[2],'|',', ') ,Nil})
ELSEIF !EMPTY(_aFormula[1])
	aAdd(_aCabec,{"C5_MENPAD"	,SEPARA(_aFormula[1],'|')[1] ,Nil})
ENDIF
					
lMsHelpAuto := .T.
lMsErroAuto := .F.
_lExecMta410 := .F.
	
/*** GERAÇÃO DO PEDIDO DE VENDA ***/		
IF lGeraPedido .Or. _lOnlyEdit
		ConOut('[xCmdFatEst / xCompraProd] - ExecAuto Pedido '+_cPedido)		

		IF !_lOnlyEdit
			FwMsgRun(,{|| MSExecAuto({|x,y,z| Mata410(x,y,z)},_aCabec,_aLinhas,3) }, "Aguarde Processamento...","Incluindo o pedido " + _cPedido + "("+cEmpAnt+'/'+cFilAnt+")")
			_lExecMta410 := .T.
		ENDIF

		IF _lEditBloq .AND. !lMsErroAuto
			_cPedido := SC5->C5_NUM
			PRIVATE aRotina := {{ OemToAnsi("Pesquisar"),"AxPesqui"	,0,1,0 ,.F.},;	
								{ OemToAnsi("Visual"),"A410Visual"	,0,2,0 ,NIL},;	
								{ OemToAnsi("Incluir"),"A410Inclui"	,0,3,0 ,NIL},;	
								{ OemToAnsi("Alterar"),"A410Altera"	,0,4,20,NIL}}																
			PRIVATE cCadastro := OemToAnsi("Alteração Pedido - MOTOR DE PROCESSO")                                                                              
			PRIVATE ALTERA := .T.
			PRIVATE INCLUI := .F.
			lMsErroAuto := .F.
			FwMsgRun(,{|| _nOpcAlt := A410Altera('SC5',SC5->(Recno()),4) }, "Aguarde Processamento...","Alterando o pedido " + _cPedido + "("+cEmpAnt+'/'+cFilAnt+")")		
			_lExecMta410 := .T.
		ENDIF
			
		If lMsErroAuto .Or. _nOpcAlt <> 1
			//DisarmTransaction()
			RollBackSX8()

			makedir("\EXECAUTO\")
			IF File("\EXECAUTO\"+'xCmdFatEst_'+_cPedido+'.txt')
				FErase("\EXECAUTO\"+'xCmdFatEst_'+_cPedido+'.txt')
			EndIf

		 	_cErro 	:=	MostraErro("\EXECAUTO\",'xCmdFatEst_'+_cPedido+'.txt')
 						
 			//_cErro := MemoRead('system\xCmdFatEsystemst_'+_cPedido+'.txt')
			ConOut('[xCmdFatEst / xCompraProd] - ERRO ExecAuto Pedido '+_cPedido+ENTER+_cErro)		
			WfControl(SZZ->ZZ_ID,.F.,iIF(!lMsErroAuto,_cPedido,),,'ERRO ExecAuto Pedido '+_cPedido+ENTER+_cErro,,'MATA410',SZZ->ZZ_CODEXEC)
			RETURN(_lReturn:=.F.)
		EndIf
		
		IF !_lExecMta410 //Validacao para que exista PEdido de venda valido		
			WfControl(SZZ->ZZ_ID,.F.,iIF(.F.,_cPedido,),,'ERRO ExecAuto Pedido '+ENTER+'Pedido de Venda não criado.',,'MATA410',SZZ->ZZ_CODEXEC)
			RETURN(_lReturn:=.F.)		
		ENDIF
		
		_cPedido := SC5->C5_NUM
		IF !xScanPedOK(@_cPedido) .And. GetMV('RP_SPEDIMT',.F.,.F.) //NOVO - FORCA POSICIONAMENTO DO ITEM DO PEDIDO DE VENDA                                                 		
			RollBackSX8()		
			WfControl(SZZ->ZZ_ID,.F.,iIF(.F.,_cPedido,),,'ERRO posicao Pedido '+ENTER+SC5->C5_NUM+' x '+SC5->C5_NUM,,'MATA410',SZZ->ZZ_CODEXEC)
			RETURN(_lReturn:=.F.)		
		ENDIF
		
		WfControl(SZZ->ZZ_ID,.T.,_cPedido,,'Pedido Gerado com Sucesso',,'MATA410',SZZ->ZZ_CODEXEC)
		ConfirmSX8()

		RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)
		RlGrvSZZ('SC5','C5_XMOTOID',SZZ->ZZ_ID)
		RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'2') //PROXIMO PASSO FATURMENTO
		GravaLogOK(xFilial("SC6")+/*SC6->C6_NUM*/SC5->C5_NUM,'C6_FILIAL+SC6->C6_NUM',1,'SC6' ,@__cUseSys,4)
			
		ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Incluso com sucesso!')								
	/*** RETORNA O PEDIDO ORIGINAL ***/
ELSE
	ConOut('[xCmdFatEst / xCompraProd] - ERRO ExecAuto Pedido '+_cPedido+ENTER+'Sem estoque disponivel para "compra".')		
	//DisarmTransaction()
	RollBackSX8()		
	WfControl(SZZ->ZZ_ID,.F.,'Sem informacao para o Pedido '+_cPedido+ENTER+'Sem estoque disponivel para "compra".',,,,,SZZ->ZZ_CODEXEC)
	RETURN(_lReturn:=.F.)
ENDIF
		
Return(_lReturn:=.T.)

*----------------------------------*
Static Function xScanPedOK(_cPedido)
*----------------------------------*
Local _lPedOk := .F.

_cQryScan := " SELECT C5_NUM PEDSCAN, SC5.R_E_C_N_O_ RECSC5 FROM "+RetSqlNAme('SC5')+" SC5 (NOLOCK) WHERE SC5.D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial('SC5')+"' AND C5_XMOTOR = '"+SZZ->ZZ_PROCESS+"' AND C5_XMOTOID = '"+SZZ->ZZ_ID+"' AND C5_EMISSAO = '"+DtoS(dDataBase)+"' "
If Select("_SCN") > 0
	_SCN->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryScan),"_SCN",.F.,.T.) 
DbSelectArea("_SCN");_SCN->(dbGoTop())

IF !Empty(_SCN->PEDSCAN)  
	IF _cPedido == _SCN->PEDSCAN
		_lPedOk := .T.
	ELSE   		
		DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbgoTo(_SCN->RECSC5))
		IF _SCN->RECSC5 <> SC5->(RECNO()) .OR. _SCN->PEDSCAN <> SC5->C5_NUM
			_lPedOk := .F.
		ELSE 
			_lPedOk  := .T.	
			_cPedido := SC5->C5_NUM
		ENDIF
	ENDIF
ENDIF

Return(_lPedOk)

*-------------------------------------------------------------------------------------*
Static Function xPedTrigul(_lReturn,_aEstoque,_cPedido,_cNota,_cWfMsg,_cJob,_aReProcPV)
*-------------------------------------------------------------------------------------* 
Local _aCabec    := {}
Local _aLinhas   := {}
Local _aAux1     := {}
Local aNota      := {}
Local lGeraPedido:= .F.
Local _cAlias    := 'SA1'
Local _lOnlyEdit := SZY->ZY_SEQ     == _cJob
Local _nOpcAlt   := 1
Local _nJ
lOCAL _aFormula  := {'',''}  
Local _aTriangular := {SZY->ZY_NFTRIAN,''}

IF !_aTriangular[1]
	Return({_aTriangular[1],.F.})
ENDIF        

ConOut('[xCmdFatEst / xCompraProd] - Acessando Empressa '+cFilAnt+'/'+cEmpAnt)	
               
//VALIDA SE PROCESSO FOI 'PARADO' NO PEDIDO DE VENDA______________
IF _aReProcPV[1]
	IF _aReProcPV[2] <> '1' //1=PEDIDO;2=FATURAMENTO;3=SEFAZ;4=FIM
		Return({_aTriangular[1],.T.})
	ENDIF
	_aReProcPV := {.F.,'1'}
ENDIF

//PROCESSAMENTO PARA NOTA FISCAL TRIANGULAR
_aTriangular[2] := SC5->C5_NUM

//VALIDACAO SE OS CLIENTES SAO DIFERENTES
IF (SC5->C5_CLIENTE + SC5->C5_LOJACLI) == (SC5->C5_CLIENT + SC5->C5_LOJAENT)
	WfControl(SZZ->ZZ_ID,.T.,'[Cfg Não Triangular]',,'Cliente Entrega '+SC5->C5_CLIENT+'-'+SC5->C5_LOJAENT,,'MATA410',SZZ->ZZ_CODEXEC)
	_lReturn := .T.
	Return({_aTriangular[1], .F.})
ENDIF

//Valida se pedido ja existe para que não inclua novamente
If xExiProc("SC5",{SC5->C5_CLIENT,SC5->C5_LOJAENT,SZZ->ZZ_PROCESS,SZZ->ZZ_ID})
	_cPedido := SC5->C5_NUM
		
	DbSelectArea("SC6")
	DbSetOrder(1)
	If SC6->(DbSeek(xFilial("SC6") + _cPedido))
		//Estorna Liberação caso seja criado pedido com os itens liberados
		//Parametro MV_PAR01 = 1 (Sugere Qtd Liberada) f12 na tela de pedidos
		While !SC6->(EoF()) .and. SC6->C6_NUM == _cPedido
			MaAvalSC6("SC6",4,"SC5")
			SC6->(DbSkip())
		EndDo
	EndIf
	                                                  		
	WfControl(SZZ->ZZ_ID,.T.,_cPedido,,'Pedido Gerado com Sucesso'+iIF(_aTriangular[1],' [TRIANGULAR]',''),,'MATA410',SZZ->ZZ_CODEXEC)

	RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)
	RlGrvSZZ('SC5','C5_XMOTOID',SZZ->ZZ_ID)
	RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'2') //PROXIMO PASSO FATURMENTO
	GravaLogOK(xFilial("SC6")+SC6->C6_NUM,'C6_FILIAL+SC6->C6_NUM',1,'SC6' ,@__cUseSys,4)
		
	ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Incluso com sucesso!')
	_lReturn := .T.
	Return({_aTriangular[1], .T.})
EndIf

/*If !Empty(_cPedido)
	WfControl(SZZ->ZZ_ID,.T.,_cPedido,,'Pedido Gerado com Sucesso'+iIF(_aTriangular[1],' [TRIANGULAR]',''),,'MATA410',SZZ->ZZ_CODEXEC)
	_lReturn := .T.
	Return({_aTriangular[1], .T.})
Endif*/
		
/*** CABEÇALHO DO PEDIDO DE VENDA ***/	
aAdd(_aCabec,{"C5_TIPO"   	,SC5->C5_TIPO		,Nil})
aAdd(_aCabec,{"C5_CLIENTE"	,SC5->C5_CLIENT    	,Nil})
aAdd(_aCabec,{"C5_LOJACLI"	,SC5->C5_LOJAENT   	,Nil})
//(David-TSM)Incluído o preenchimento dos campos C5_LOJAENT E C5_TIPOCLI que não estavam 
//sendo preenchidos automaticamente
aAdd(_aCabec,{"C5_CLIENT"	,SC5->C5_CLIENT    	,Nil})
aAdd(_aCabec,{"C5_LOJAENT"	,SC5->C5_LOJAENT   	,Nil})
aAdd(_aCabec,{"C5_TIPOCLI"	,SC5->C5_TIPOCLI   	,Nil})
aAdd(_aCabec,{"C5_CONDPAG"	,SC5->C5_CONDPAG	,Nil})
//aAdd(_aCabec,{"C5_TPFRETE"	,'C'   	            ,Nil}) // Alterado por Leandro Dentello em 12/07/17 para NF de Remessa sempre pagar Frete, visto que a de venda deve ir sem frete pela Rej. SEFAZ 521
aAdd(_aCabec,{"C5_TPFRETE"	,SC5->C5_TPFRETE    ,Nil}) // é para considerar o tipo de frete do pedido de vendas origem. Rleg 10/12/2020.
aAdd(_aCabec,{"C5_TRANSP"	,SC5->C5_TRANSP		,Nil})
aAdd(_aCabec,{"C5_REDESP"	,SC5->C5_REDESP		,Nil})
aAdd(_aCabec,{"C5_VOLUME1"	,SC5->C5_VOLUME1	,Nil})
aAdd(_aCabec,{"C5_ESPECI1"	,SC5->C5_ESPECI1	,Nil})
aAdd(_aCabec,{"C5_PESOL"	,SC5->C5_PESOL	    ,Nil})
aAdd(_aCabec,{"C5_PBRUTO"	,SC5->C5_PBRUTO	    ,Nil})

//Grava veiculo no pedido de acordo a carga
DAI->(DbSetOrder(4))
DAK->(DbSetOrder(1))
If DAI->(DbSeek(xFilial("DAI")+SC5->C5_NUM)) .AND.;
   DAK->(DbSeek(xFilial("DAK")+DAI->DAI_COD))
	
	aAdd(_aCabec,{"C5_VEICULO"	,DAK->DAK_CAMINH		,Nil})

EndIf
aAdd(_aCabec,{"C5_XMOTOR"	,SZZ->ZZ_PROCESS	,Nil})
aAdd(_aCabec,{"C5_XMOTOID"	,SZZ->ZZ_ID			,Nil})
aAdd(_aCabec,{"C5_FECENT"	,dDataBase		,Nil})

/*** PROCURA CLIENTE/LOJA ***/		
DbSelectArea('SA1');('SA1')->(DbSetOrder(1));('SA1')->(DbSeek(xFilial('SA1')+SC5->C5_CLIENT+SC5->C5_LOJAENT))

/* 
While .T.
	IF _lOnlyEdit .And. !Empty(AllTrim(SZZ->ZZ_CHAVE))
		_cPedido := AllTrim(SZZ->ZZ_CHAVE)
		DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbSeek(xFilial('SC5')+_cPedido));Exit		
	Else     
		_lOnlyEdit := .F.
		_cPedido := GetSX8Num("SC5", "C5_NUM")
		DbSelectArea('SC5');SC5->(DbSetOrder(1))
		IF !SC5->(DbSeek(xFilial('SC5')+_cPedido))
			DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop());Exit
		EndIF
	ENDIF
EndDo
ConOut('[xCmdFatEst / xCompraProd] - Guarda numero do pedido de Venda '+_cPedido)		
*/		
AddCpoObr(@_aCabec)

/*** SETA NUMERAÇÃO DOS ITENS ***/	
_cItem := "01"

//CASO FOR DEVOLUÇÃO DEVE POSICIONAR NA NOTA DE ORIGEM
//OU PARA BUSCAR ITENS ORIGINARIO DE OUTRA ETAPA
IF SZY->ZY_TIPODOC == 'D' .Or. !Empty(SZY->ZY_DEVSEQ)
	//Retorna Dados de OUTRA SEQUENCIA SZZ [1=ZZ_USESYS | 2=ZZ_CHAVE]
	_aRetSZZ  := xRetSZZ(SZZ->ZZ_PROCESS, SZY->ZY_DEVSEQ)
	_cInfoQry := _aRetSZZ[1]
	LoadUserSys(@_aEstoque, _cInfoQry)
ENDIF
	
For _nJ:=1 To Len(_aEstoque)
	
	/*** SETA O PRODUTO ***/
	DbSelectArea('SB1');SB1->(DbSetOrder(1)) 
	IF !SB1->(DbSeek(xFilial('SB1')+_aEstoque[_nJ][P_CODB1]))
		ConOut('[xCmdFatEst / xCompraProd] - Produto invalido: '+xFilial('SB1')+'/'+AllTrim(SB1->B1_COD))
		WfControl(SZZ->ZZ_ID,.F.,'Produto invalido: '+xFilial('SB1')+'/'+AllTrim(SB1->B1_COD),,,,,SZZ->ZZ_CODEXEC)
		Return({_aTriangular[1], _lReturn:=.F.})
	ENDIF
	ConOut('[xCmdFatEst / xCompraProd] - Produto Valido: '+AllTrim(SB1->B1_COD))			
	
	_aAux1 := {}
	xNoZero(@_aEstoque[_nJ][P_QTDCOM], @_aEstoque[_nJ][P_PRCCOM])
	
	DbSelectArea("SF4");SF4->(DbSetOrder(1))
	DbSelectArea("SM4");SM4->(DbSetOrder(1))
	IF SF4->(DbSeek(xFilial("SF4")+SZY->ZY_TES))
		IF !( SF4->F4_FORMULA $ _aFormula[1]) .And. !Empty(SF4->F4_FORMULA)
			IF SM4->(DbSeek(xFilial('SM4')+SF4->F4_FORMULA))
				_aFormula[1] := SF4->F4_FORMULA          + '|'
				_aFormula[2] := '' //Formula(SF4->F4_FORMULA) + '|'
			ENDIF
		ENDIF
	ENDIF
	
	/*** ITENS DO PEDIDO DE VENDA ***/	
	aAdd(_aAux1,{"C6_ITEM"   	,_cItem	      				,Nil})
	aAdd(_aAux1,{"C6_PRODUTO"	,SB1->B1_COD				,Nil})
	aAdd(_aAux1,{"C6_UM"     	,SB1->B1_UM				,Nil})
	aAdd(_aAux1,{"C6_QTDVEN" 	,_aEstoque[_nJ][P_QTDCOM]	,Nil})
	aAdd(_aAux1,{"C6_LOCAL"  	,SB1->B1_LOCPAD 			,Nil})
	aAdd(_aAux1,{"C6_TES"    	,SZY->ZY_TES				,Nil})
	//aAdd(_aAux1,{"C6_QTDLIB" 	,_nQtdCompra			   	,Nil})
	aAdd(_aAux1,{"C6_PRUNIT" 	,_aEstoque[_nJ][P_PRCCOM]	,Nil})
	aAdd(_aAux1,{"C6_PRCVEN" 	,_aEstoque[_nJ][P_PRCCOM]	,Nil})// Bcolisse  - 14/08 -alterado para tratar problema com execauto em nota de serviço.
	aAdd(_aAux1,{"C6_VALOR" 	,Round(_aEstoque[_nJ][P_QTDCOM]*_aEstoque[_nJ][P_PRCCOM],TamSX3("C6_VALOR")[2])	,Nil})
	aAdd(_aAux1,{"C6_ENTREG" 	,dDataBase					,Nil})
	
	If SC6->(FieldPos("C6_XMOTOR")) > 0 .and. SC6->(FieldPos("C6_XMOTOID")) > 0
		aAdd(_aAux1,{"C6_XMOTOR"	,SZZ->ZZ_PROCESS							,Nil})
		aAdd(_aAux1,{"C6_XMOTOID"	,SZZ->ZZ_ID									,Nil})
	Endif
	
	AAdd(_aLinhas, _aAux1)
	
	_aEstoque[_nJ][P_OK] := .T. 
	lGeraPedido          := .T.
	/*** ADICIONA O NOVO ITEM ***/
	_cItem := Soma1(_cItem)
				
Next _nJ

IF !EMPTY(_aFormula[2]) 
	//aAdd(_aCabec,{"C5_MENNOTA"	,StrTran(_aFormula[2],'|',', ') ,Nil})
ELSEIF !EMPTY(_aFormula[1])
	//aAdd(_aCabec,{"C5_MENPAD"	,SEPARA(_aFormula[1],'|')[1] ,Nil})
ENDIF
						
lMsHelpAuto := .T.
lMsErroAuto := .F.
	
/*** GERAÇÃO DO PEDIDO DE VENDA ***/		
IF lGeraPedido .Or. _lOnlyEdit
		ConOut('[xCmdFatEst / xCompraProd] - ExecAuto Pedido '+_cPedido)		

		IF !_lOnlyEdit
			FwMsgRun(,{|| MSExecAuto({|x,y,z| Mata410(x,y,z)},_aCabec,_aLinhas,3) }, "Aguarde Processamento...","Incluindo o pedido [Triangular] " + _cPedido + "("+cEmpAnt+'/'+cFilAnt+")")
		ENDIF                                             
			
		If lMsErroAuto .Or. _nOpcAlt <> 1
			//DisarmTransaction()
			RollBackSX8()

			makedir("\EXECAUTO\")
			IF File("\EXECAUTO\"+'xCmdFatEst_'+_cPedido+'.txt')
				FErase("\EXECAUTO\"+'xCmdFatEst_'+_cPedido+'.txt')
			EndIf
		 	_cErro 	:=	MostraErro("\EXECAUTO\",'xCmdFatEst_'+_cPedido+'.txt')
 						
 			//_cErro := MemoRead('system\xCmdFatEsystemst_'+_cPedido+'.txt')
			ConOut('[xCmdFatEst / xCompraProd] - ERRO ExecAuto Pedido '+_cPedido+ENTER+_cErro)		
			WfControl(SZZ->ZZ_ID,.F.,iIF(!lMsErroAuto,_cPedido,),,'ERRO ExecAuto Pedido '+_cPedido+ENTER+_cErro,,'MATA410',SZZ->ZZ_CODEXEC)
			Return({_aTriangular[1], _lReturn:=.F.})
		EndIf
		_cPedido := SC5->C5_NUM
		
		DbSelectArea("SC6")
		DbSetOrder(1)
		If SC6->(DbSeek(xFilial("SC6") + _cPedido))
			//Estorna Liberação caso seja criado pedido com os itens liberados
			//Parametro MV_PAR01 = 1 (Sugere Qtd Liberada) f12 na tela de pedidos
			While !SC6->(EoF()) .and. SC6->C6_NUM == _cPedido
				MaAvalSC6("SC6",4,"SC5")
				SC6->(DbSkip())
			EndDo
		EndIf
		                                                  		
		WfControl(SZZ->ZZ_ID,.T.,_cPedido,,'Pedido Gerado com Sucesso'+iIF(_aTriangular[1],' [TRIANGULAR]',''),,'MATA410',SZZ->ZZ_CODEXEC)
		ConfirmSX8()

		RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)
		RlGrvSZZ('SC5','C5_XMOTOID',SZZ->ZZ_ID)
		RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'2') //PROXIMO PASSO FATURMENTO
		GravaLogOK(xFilial("SC6")+SC6->C6_NUM,'C6_FILIAL+SC6->C6_NUM',1,'SC6' ,@__cUseSys,4)
			
		ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Incluso com sucesso!')								
	/*** RETORNA O PEDIDO ORIGINAL ***/
ELSE
	ConOut('[xCmdFatEst / xCompraProd] - ERRO ExecAuto Pedido '+_cPedido+ENTER+'Sem estoque disponivel para "compra".')		
	//DisarmTransaction()
	RollBackSX8()		
	WfControl(2,.F.,'Sem informacao para o Pedido '+_cPedido+ENTER+'Sem estoque disponivel para "compra".',,,,,SZZ->ZZ_CODEXEC)
	Return({_aTriangular[1], _lReturn:=.F.})
ENDIF
		
Return({_aTriangular[1], _lReturn:=.T.})

*--------------------------*
Static Function RPSX3(_cAls)  
*--------------------------*  
Local _aCpo := {}
Local aField := {}
Local nI := 0

//---> REMOVIDO compatibilização para versão 12.1.25.
/*DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(_cAls))  

While !SX3->(Eof()) .And. X3_ARQUIVO == _cAls
	If X3USO(SX3->X3_USADO) .And. SX3->X3_TIPO <> "V" .And. X3Obrigat(SX3->X3_CAMPO)
		aAdd(_aCpo,SX3->X3_CAMPO)
	EndIf		
	SX3->(DbSkip())
EndDo*/

aField := FwSx3Util():GetAllFields( _cAls )

For nI := 1 To Len( aField )
	If X3USO( GetSx3Cache( aField[ nI ] ,'X3_USADO'));
	   .And. GetSx3Cache( aField[ nI ] ,'X3_TIPO') <> 'V';
		.And. X3Obrigat( GetSx3Cache( aField[ nI ] ,'X3_CAMPO ') )
		
		aAdd( _aCpo, GetSx3Cache( aField[ nI ] ,'X3_CAMPO ') )
	Endif
Next nI

Return(_aCpo)

*--------------------------------*
Static Function AddCpoObr(_aCabec)
*--------------------------------*
Local _nH 
Local _aObrig := RPSX3('SC5')

For _nH:=1 To Len(_aObrig)
	IF aScan(_aCabec,{|s| Upper(AllTrim(s[1])) == Upper(AllTrim(_aObrig[_nH])) }) == 0
		IF Empty(_cInfoPad := CriaVar(_aObrig[_nH]))
			//(David-TSM) Realizado tratamento para retorno do tipo
			//de informação corrreto para que não haja possibilidade de erro
			_cTipo := GetSx3Cache(_aObrig[_nH],"X3_TIPO")
			IF _cTipo == 'D'
				_cInfoPad := dDataBase
			ENDIF
			//ElseIF _cTipo == 'N'
			//_cInfoPad := '1'
		ENDIF
		aAdd(_aCabec,{_aObrig[_nH]	,_cInfoPad ,'.T.'})
	EndIF
Next _nH
Return

*----------------------*
Static Function xSeeJob
*----------------------*
Local _aTela     := {SZZ->ZZ_CHAVE, oTela, OBRWP, SZZ->(Recno())}
Local _cGrvTemp  := CmdSendMail(,,,,,.T.)

If .NOT. ExistDir('c:\temp')
	MakeDir('c:\temp')
Endif

IF SZZ->ZZ_OCORREN=='1'
	MsgInfo(SZZ->ZZ_ID+' - '+SZZ->ZZ_IDENT+ENTER+'Processo ainda nao iniciado!','Atenção')
	Return
ENDIF     

IF SZZ->ZZ_OCORREN == '2'
	_cGrvTemp  += '<pre>'+SZZ->ZZ_OBS+'</pre>'
	__cFileLog := MemoWrite('c:\temp\'+SZZ->ZZ_PROCESS+SZZ->ZZ_ID+".HTML",_cGrvTemp)
	ShellExecute("Open",'c:\temp\'+SZZ->ZZ_PROCESS+SZZ->ZZ_ID+".HTML","","",1)	
	
ELSEIF SZZ->ZZ_OCORREN == '3' .OR. SZZ->ZZ_OCORREN == '4' 
	_cChave  := AllTrim(SZZ->ZZ_CHAVE)
	_cRotina := AllTrim(SZZ->ZZ_ROTINA)

	xChageEmp('ORI') //ABRE EMPRESA DE ORIGEM DA INFORMACAO ONDE O PROCESSO FOI GERADO	
	PROPENMATA(_cChave,_cRotina)	
	xChageEmp(,.T.) //RETORNA PARA EMPRESA DE ORIGEM PARA GRACAVAO DE DADOS	                      	
	
ENDIF
RETURN 

*------------------------------------------------------------------*
Static Function CmdSendMail(_aEmp,_aEstoque,_cPedido,_cNota,_cWfMsg,_lRet, _cCrtSZ2)
*------------------------------------------------------------------*
Local _cAssunto := 'Notificação Motor de Processo'
Local cServer   := "mail.meliora.com.br"
Local cAccount  := "gustavo.oliveira@meliora.com.br"
Local cEnvia    := "gustavo.oliveira@meliora.com.br"
Local cPassword := "topgear"
Local cRecebe   := xInfoSZY(SZZ->ZZ_CODEXEC,'010','ZY_EMAIL')
Local cReccy    := cRecebe

Local cTos	   := ''
Local lEnviado := .F.
Local _lGrv    := .F.
DEfault _lRet  := .F.

/*** ALTERAÇÃO PARA EMPRESA DA ORIGEM DO ENDERECO ***/
//ChangeEmp(_aEmp[1][1],_aEmp[1][2])	
ConOut('[xCmdFatEst / CmdSendMail] - @@ Iniciando processo de WorkFlow...')
  		
_cHtm := ' <html>			'+iIF(_lGrv,ENTER,'')
_cHtm += '<body>			'+iIF(_lGrv,ENTER,'')
_cHtm += '			'+iIF(_lGrv,ENTER,'')
_cHtm += '<img align=Left src="http://www.replas.com.br/templates/replas/images/replas-logo.png" width="190" height="60" hspace="1"> 						'+iIF(_lGrv,ENTER,'')
_cHtm += '<img align=Right src="https://www.totvs.com/assets/images/logo.png" width="190" height="60" hspace="1"> 						'+iIF(_lGrv,ENTER,'')
_cHtm += '			'+iIF(_lGrv,ENTER,'')
_cHtm += '			'+iIF(_lGrv,ENTER,'')
_cHtm += '<br>																														'+iIF(_lGrv,ENTER,'')
_cHtm += ' </font></b></p>  																												'+iIF(_lGrv,ENTER,'')
_cHtm += ' <div align="left">  																												'+iIF(_lGrv,ENTER,'')
_cHtm += ' <br><br>																															'+iIF(_lGrv,ENTER,'')
_cHtm += ' <p><center><font Color="#000080" face="Arial" size="5">MOTOR DE PROCESSO</font></center> 				'+iIF(_lGrv,ENTER,'')
_cHtm += '<center><font Color="#000080" face="Arial" size="4"><u>Notificação</u></font></center></p> 					'+iIF(_lGrv,ENTER,'')				
_cHtm += '<br> 																													'+iIF(_lGrv,ENTER,'')

IF _lRet 
	Return(_cHtm)
ENDIF           

//_cHtm += _cWfMsg
DbSelectArea('SZ2');SZ2->(DbGoTop());SZ2->(DbSeek(xFilial('SZ2')+_cCrtSZ2))
While SZ2->(!Eof()) .And. SZ2->Z2_PROCESS==_cCrtSZ2
   	IF !( SZ2->Z2_ID $ '06/98/99' )
	   	_cHtm += SZ2->Z2_OBS
   	ENDIF  
	SZ2->(DbSkip())
EndDo
 
_cHtm += '<br><br> 																												'+iIF(_lGrv,ENTER,'')
_cHtm += ' 																														'+iIF(_lGrv,ENTER,'')
_cHtm += '</div> 																												'+iIF(_lGrv,ENTER,'')
_cHtm += '<br> 																	 												'+iIF(_lGrv,ENTER,'')
_cHtm += '<hr> 																													'+iIF(_lGrv,ENTER,'')
_cHtm += '</body> 																												'+iIF(_lGrv,ENTER,'')
_cHtm += '<center><font face="Arial" size="0.3">*** ATENCAO: MENSAGEM ENVIADA AUTOMATICAMENTE, POR FAVOR NAO RESPONDA ESSE EMAIL***</font></center> '+iIF(_lGrv,ENTER,'')
_cHtm += '</html> '


If !Empty(cReccy)
   If Right(Alltrim(cRecebe),1) <> ';'
   		cRecebe := Alltrim(cRecebe) + ';' + Alltrim(cReccy)
   Else
   		cRecebe := Alltrim(cRecebe) + Alltrim(cReccy)
   End If

End If 

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou     //realiza conexão com o servidor de internet

If lConectou
	lRet := Mailauth(cAccount,cPassword)
	if lRet
		SEND MAIL FROM cEnvia;
		TO cRecebe;
		SUBJECT _cAssunto ;
		BODY _cHtm ;
		RESULT lEnviado
	Else
		SEND MAIL FROM cEnvia;
		TO cRecebe;
		SUBJECT _cAssunto;
		BODY _cHtm;
		RESULT lEnviado
	Endif
Endif

If lEnviado
	ConOut('[xCmdFatEst / CmdSendMail] - @@ E-MAIL Enviado com sucesso.')
	CmdControlZ2(_cCrtSZ2,'99',.T.,'E-Mail Enviado com suacesso!'/*CHAVE*/,cRecebe/*OBS*/) 
Else
	_cHtm := ""
	GET MAIL ERROR _cHtm
	ConOut('[xCmdFatEst / CmdSendMail] - @@ E-MAIL ERRO no envio: ' +_cHtm)
	//Alert(_cHtm)
	CmdControlZ2(_cCrtSZ2,'99',.T.,'FALHA no envio do E-mail!'/*CHAVE*/,_cHtm/*OBS*/) 
Endif        
ConOut('[xCmdFatEst / CmdSendMail] - @@ Finalizando WorkFlow...')

DISCONNECT SMTP SERVER Result lDisConectou
return 

*-------------------------*
STATIC FUNCTION PROPENMATA(_cChave,_cRotina)	
*-------------------------*
Local _cLogErr := ''
xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID)

PRIVATE aRotina   := {}
PRIVATE cCadastro := ''   
		
IF _cRotina == 'MATA410'
	CHKFILE("SC5");DbSelectArea('SC5');	SC5->(DbSetORder(1))
	IF SC5->(DbSeek(xFilial('SC5')+PadR(_cChave,TamSX3('C5_NUM')[1])))
		aRotina   := { 	{OemToAnsi("Pesquisar") 	,"AxPesqui"  	,00,01	},{OemToAnsi("Visual")		,"AxVisual"		,00,02	} }
		cCadastro := OemToAnsi('Pedido de Venda MOTOR DE PROCESSO')   	
		a410Visual('SC5',SC5->(Recno()), 2)
	Else
		_cLogErr += 'Pedido de Venda não localizada'+ENTER+ENTER+'DOC:'+AllTrim(_cChave)+ENTER+'SERIE: '+ENTER+'CLI/FOR: '+SZY->ZY_CLIFOR+' - '+SZY->ZY_LOJA
	ENDIF     
	
ELSEIF  _cRotina == 'MATC090'
	CHKFILE("SF2");DbSelectArea('SF2');	SF2->(DbSetORder(1))
	IF SF2->(DbSeek(xFilial('SF2')+PadR(_cChave,TamSX3('F2_DOC')[1]) + SZY->ZY_SERIE + Iif(!SZY->ZY_NFTRIAN, (SZY->ZY_CLIFOR + SZY->ZY_LOJA) , '') ))
		aRotina   := { 	{OemToAnsi("Pesquisar") 	,"AxPesqui"  	,00,01	},{OemToAnsi("Visual")		,"AxVisual"		,00,02	} }
		cCadastro := OemToAnsi('Faturamento MOTOR DE PROCESSO')   	
		Mc090Visual('SF2',SF2->(Recno()),2)
	Else
		_cLogErr += 'Nota Fiscal não localizada'+ENTER+ENTER+'DOC:'+AllTrim(_cChave)+ENTER+'SERIE: '+ENTER+'CLI/FOR: '+SZY->ZY_CLIFOR+' - '+SZY->ZY_LOJA
	ENDIF 
	      		
ELSEIF  _cRotina $ 'MATA103,MATA140'
	CHKFILE("SF1");DbSelectArea('SF1');	SF1->(DbSetORder(1))
	IF SF1->(DbSeek(xFilial('SF1')+PadR(_cChave,TamSX3('F1_DOC')[1]) + SZY->ZY_SERIE + SZY->ZY_CLIFOR + SZY->ZY_LOJA ))
		aRotina   := { 	{OemToAnsi("Pesquisar") 	,"AxPesqui"  	,00,01	},{OemToAnsi("Visual")		,"AxVisual"		,00,02	} }
		cCadastro := OemToAnsi('Entrada Mercadoria - MOTOR DE PROCESSO')   	
		//Mc090Visual('SF2',SF2->(Recno()),2)
		A103NFiscal('SF1',SF1->(Recno()),2)
	Else
		_cLogErr += 'Nota Fiscal não localizada'+ENTER+ENTER+'DOC:'+AllTrim(_cChave)+ENTER+'SERIE: '+ENTER+'CLI/FOR: '+SZY->ZY_CLIFOR+' - '+SZY->ZY_LOJA
	ENDIF 	
		
ELSEIF  _cRotina == 'MATA650'
 	CHKFILE("SC2");DbSelectArea('SC2');SC2->(DbSetORder(1))
	IF SC2->(DbSeek(xFilial('SC2')+_cChave))
		aRotina   := { 	{OemToAnsi("Pesquisar") 	,"AxPesqui"  	,00,01	},{OemToAnsi("Visual")		,"AxVisual"		,00,02	} }
		cCadastro := OemToAnsi('Ordem de Produção - MOTOR DE PROCESSO')   	
		//Mc090Visual('SF2',SF2->(Recno()),2)
		A650View('SC2',SC2->(Recno()),2)
	Else
		_cLogErr += 'OP não localizada'+ENTER+ENTER+'DOC:'+AllTrim(_cChave)
	ENDIF  	
ENDIF

IF !Empty(_cLogErr)        
	MsgInfo(_cLogErr,'Atenção')
ENDIF
//xRetTelaOri(_aTela)

RETURN


*------------------------------------------------------------------*
Static Function xLiberPV(_lReturn,_aEstoque,_cPedido,_cNota,_cWfMsg,_cJob,_aReProcPV)
*------------------------------------------------------------------*
Local nItemNf	 := 50 
Local _cSerieFat := xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID,'ZY_SERIE')
Local aArea := {}
Local aMvPar := {}
Local nMv := 0

/*** ALTERAÇÃO PARA EMPRESA DE COMPRAS ***/
IF !_lReturn
	RETURN
ENDIF

//VALIDA SE PROCESSO FOI 'PARADO' NO FATURAMENTO______________
IF _aReProcPV[1]
	IF _aReProcPV[2] <> '2' //1=PEDIDO;2=FATURAMENTO;3=SEFAZ;4=FIM
		RETURN(_lReturn:=.T.)
	ENDIF
	_aReProcPV := {.F.,'2'}
ENDIF

For nMv := 1 To 60
	AAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv

ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Inicio Liberacao')
/*** PROCESSO DE LIBERAÇÃO DO PEDIDO DE VENDA ***/
Pergunte("MTALIB",.F.)
MV_PAR01 := 2 //TESTE DE ALTERACAO PARA NAO GERA SUGESTAO DE QTD DE VENDA 
MV_PAR02 := _cPedido
MV_PAR03 := _cPedido
MV_PAR04 := '    '
MV_PAR05 := 'ZZZZ'
MV_PAR06 := STOD("20000101")
MV_PAR07 := STOD("20490101")
MV_PAR08 := 2 
lLIBER   := .F.
lTRANSF  := .F.
INCLUI   := .F.
//A440PROCES()

aArea := {;
    SF2->(GetArea()),;
    SZZ->(GetArea()),;
    SC9->(GetArea()),;
    SF4->(GetArea()),;
    SB2->(GetArea()),;
    SB1->(GetArea()),;
    SE4->(GetArea()),;
    SC5->(GetArea()),;
    SC6->(GetArea()),;
    SX5->(GetArea()),;
    GetArea();
}

DbSelectArea("SX5")
SX5->(DbSetOrder(1))

DbSelectArea("SC6")
cC6_FILTER := SC6->(dbFilter())
SC6->(dbClearFilter())

SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial("SC6") + _cPedido))

/*** LIBERAÇÃO POR ITEM ***/
While SC6->( .NOT. EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == _cPedido
	
	//Caso não tenha nota apaga a liberação para que seja realizada novamente
	If Empty(SC6->C6_NOTA) 
		MaAvalSC6("SC6",4,"SC5")
	Else
		SC6->(DbSkip())   
		Loop
	EndIf
	
	nQtdLib := 0
	nQtdLib := SC6->C6_QTDVEN
				                
	/*** LIBERAÇÃO, APROVAÇÃO DE CREDITO AUTOMATICO ***/	
	MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN ,.T.,.T.,.F.,.T.,.F.,.F.)

	SC6->(DbSkip())
EndDo

ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Liberacao com sucesso')
			
ConOut('[xCmdFatEst / xCompraProd] - Pedido '+_cPedido+', Inicio Faturamento')					
/*** GERA O FATURAMENTO DO PEDIDO DE VENDA ***/
aPvlNfs     := {}
aMata520Cab :={}
lItemBloq   := .F.
_lTudoOk    := .T.
_cNota	  	:= ""
_nPos       := 0              
	
DbSelectArea("SC5");SC5->(DbSetOrder(1));SC5->(DbSeek(xFilial("SC5")+_cPedido))			
DbSelectArea("SC6");SC6->(DbSetOrder(1))		                                                                                  		
DbSelectArea("SE4");SC6->(DbSetOrder(1));SC6->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))		
DbSelectArea("SB1");SB1->(DbSetOrder(1))			
DbSelectArea("SB2");SB2->(DbSetOrder(1))			
DbSelectArea("SF4");SF4->(DbSetOrder(1))			
DbSelectArea("SC9");SC9->(DbSetOrder(1));SC9->(DbSeek(xFilial("SC9")+_cPedido))
			
While SC9->(!Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cPedido
			
	If (!EMPTY(SC9->C9_BLCRED) .Or. !EMPTY(SC9->C9_BLEST)) .or. !Empty(SC9->C9_NFISCAL)
		If !Empty(SC9->C9_NFISCAL)
			_cNota := SC9->C9_NFISCAL
		EndIf 
		SC9->(DbSkip())
		Loop
	EndIf
					
	SC6->(DbSeek(xFilial("SC6")+_cPedido + SC9->C9_ITEM) )
	SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO) )
	SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO + SC6->C6_LOCAL) )
	SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
					
	aAdd(aPvlNfs,{ SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, SC9->C9_QTDLIB, SC9->C9_PRCVEN,SC9->C9_PRODUTO,(SF4->F4_ISS=="S"),SC9->(RecNo()),SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo())})										
	If SC9->(FieldPos("C9_XMOTOR")) > 0 .and. SC9->(FieldPos("C9_XMOTOID")) > 0
		RlGrvSZZ('SC9','C9_XMOTOR' ,SZZ->ZZ_PROCESS)
		RlGrvSZZ('SC9','C9_XMOTOID',SZZ->ZZ_ID)
	Endif
	SC9->(DbSkip())
ENDDO

If Len(aPvlNfs) >0 
	Pergunte("MT460A",.F.)

	If Len(_cSerieFat) < Len(SF2->F2_SERIE)
		_cSerieFat := PadR(_cSerieFat,Len(SF2->F2_SERIE))
	Endif

	_cNota := MaPvlNfs(aPvlNfs,_cSerieFat,(lMostraCtb:=.F.),(lAglutCtb:=.F.),(lCtbOnLine:=.F.),(lCtbCusto:=.F.),(lReajuste:=.F.),(nCalAcrs:=0),(nArredPrcLis:=0),(lAtuSA7:=.T.),(lECF:=.F.),(cEmbExp:=Nil))
	
	ConOut('[xCmdFatEst / xCompraProd][1] - Gerando NF.:'+_cNota+"/"+_cSerieFat+" - Pedido No."+_cPedido)		            		            
ENDIF

_lNf := !Empty(_cNota)
WfControl(SZZ->ZZ_ID,_lNf,iiF(_lNf,_cNota,_cPedido),,iIF(_lNf,'FATURAMENTO GERADO','ERRO LIBERAÇÃO PV: '+_cPedido),,iiF(_lNf,'MATC090','MATA410') ,SZZ->ZZ_CODEXEC)

IF _lNf
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+padr(_cNota,TamSX3('F2_DOC')[1])+_cSerieFat))
	//CARREGA VARIAVEL COM INFORMACOES DOS ITENS
	GravaLogOK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA',3,'SD2' ,@__cUseSys)
	RlGrvSZZ('SF2','F2_XMOTOR',SZZ->ZZ_PROCESS)
	RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'3') //PROXIMO PASSO SEFAZ
ENDIF

For nMv := 1 To Len( aMvPar )
	&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

AEval(aArea, {|a| RestArea(a)})

Return(_lReturn:=_lNf) 

*----------------------------------------------------*
Static Function GravaLogOK(_cChave,_cComper,_nInd,_cAlsGrv,__cUseSys,_nForceLeg,_cFilter,_lClear) //#aqui
*----------------------------------------------------*
Local _lAchaMod := .F.
local _cCodServ := AllTrim(GetMV('RP_CODSERV',.F.,''))
Default _lClear := .T.
Default _nForceLeg := 0
Default _cFilter   := ''
Private _aArea := GetArea()

DbSelectArea(_cAlsGrv);(_cAlsGrv)->(DbGoTop());(_cAlsGrv)->(DbSetOrder(_nInd))
IF _lClear
	__cUseSys := ''
ENDIF
IF (_cAlsGrv)->(DbSeek(_cChave,.T.))
	Do While (_cAlsGrv)->(!EOF()) .And. _cChave == &(_cComper) 
		
		//Filtro no While do Processo
		IF !Empty(_cFilter)
			IF !&(_cFilter)
				(_cAlsGrv)->(DbSkip())
				Loop
		    EndIF
		ENDIF
		
		IF GetMV('RP_NOZERO',.F.,.F.)
			IF 	RecLock(_cAlsGrv,.F.)
					IF _cAlsGrv == 'SD1'
						Replace SD1->D1_QUANT With  iIF(SD1->D1_QUANT ==0,1,SD1->D1_QUANT )
						Replace SD1->D1_VUNIT With  iIF(SD1->D1_VUNIT ==0,1,SD1->D1_VUNIT )
						Replace SD1->D1_TOTAL With  ROUND(SD1->D1_QUANT*SD1->D1_TOTAL,TamSX3('D1_TOTAL')[2])
					ElseIF _cAlsGrv == 'SD2'
						Replace SD2->D2_QUANT  With iIF(SD2->D2_QUANT ==0,1,SD2->D2_QUANT )
						Replace SD2->D2_PRCVEN With iIF(SD2->D2_PRCVEN==0,1,SD2->D2_PRCVEN)
						Replace SD2->D2_TOTAL With  ROUND(SD2->D2_QUANT*SD2->D2_PRCVEN,TamSX3('D2_TOTAL')[2])											
					ENDIF					
				(_cAlsGrv)->(MsUnLock())
			ENDIF
		ENDIF
					
		IF _cAlsGrv == 'SD2'//______________________[DOCUMENTO DE SAIDA]__________________________
			__cUseSys += ".F."+"|"+SPACE(5)+"|"+SD2->D2_DOC+"|"+SD2->D2_SERIE+"|"+SD2->D2_COD+"|"+cValToChar(SD2->D2_QUANT)+"|"+cValToChar(SD2->D2_PRCVEN)+"|"+cValToChar(SD2->D2_TOTAL)+"|"+cValToChar(SD2->D2_ITEM)+"|"+cValToChar(SD2->D2_LOCAL)+'|'+'SEFAZ'+'|'+'CC'+'**'		
		eLSEIF _cAlsGrv == 'SD1'//______________________[DOCUMENTO DE ENTRADA]__________________________
			__cUseSys += ".F."+"|"+SPACE(5)+"|"+SD1->D1_DOC+"|"+SD1->D1_SERIE+"|"+SD1->D1_COD+"|"+cValToChar(SD1->D1_QUANT)+"|"+cValToChar(SD1->D1_VUNIT)+"|"+cValToChar(SD1->D1_TOTAL)+"|"+cValToChar(SD1->D1_ITEM)+"|"+cValToChar(SD1->D1_LOCAL)+'|'+'SEFAZ'+'|'+'CC'+'**'				
		eLSEIF _cAlsGrv == 'SC6'//______________________[PEDIDO DE VENDA]__________________________
			__cUseSys += ".F."+"|"+SPACE(5)+"|"+SC6->C6_NUM+"|"+Space(05)+"|"+SC6->C6_PRODUTO+"|"+cValToChar(SC6->C6_QTDVEN)+"|"+cValToChar(SC6->C6_PRCVEN)+"|"+cValToChar(SC6->C6_VALOR)+"|"+cValToChar(SC6->C6_ITEM)+"|"+cValToChar(SC6->C6_LOCAL)+'|'+'SEFAZ'+'|'+'CC'+'**'								
		eLSEIF _cAlsGrv == 'SD4'//______________________[EMPENHO OP]__________________________
			//IF 'MOD' $ AllTrim(SD4->D4_COD) .And. !_lAchaMod .AND. posicione("SB1",1,xFilial('SB1') + SD4->(D4_COD), 'B1_TIPO') == 'MO' 
			//IF !_lAchaMod .AND. posicione("SB1",1,xFilial('SB1') + SD4->(D4_COD), 'B1_TIPO') == 'MO' // alteração Bruno Colisse + Carlos p/ contemplar b1_tipo = MO
			IF Alltrim(_cCodServ) $ AllTrim(SD4->D4_COD) .And. !_lAchaMod //(TSM-David) Ajuste para identificar serviço pelo código e não mais pelo tipo
				_aServico := LoadServPrd(_cCodServ, SD4->D4_OP); _cCC := StrTran(AllTrim(SD4->D4_COD),'MOD','')
				_lAchaMod := .T.
				//__cUseSys += ".F."+"|"+'MOD'+"|"+SD4->D4_OP+"|"+Space(05)+"|"+_cCodServ+"|"+cValToChar(_aServico[1])+"|"+cValToChar(_aServico[2])+"|"+cValToChar(_aServico[3])+"|"+cValToChar(SD4->D4_TRT)+'|'+Space(3)+'|'+'SEFAZ'+'|'+_cCC+'**'			
				//(TSM - David) Ajustada a gravação de dados da MOD para considerar quantidade gravada no SD4 e não SC2, pois no momento
				//do empenho a quantidade pode ser alterada
				__cUseSys += ".F."+"|"+'MOD'+"|"+SD4->D4_OP+"|"+Space(05)+"|"+_cCodServ+"|"+cValToChar(SD4->D4_QTDEORI)+"|"+cValToChar(_aServico[2])+"|"+cValToChar(_aServico[3])+"|"+cValToChar(SD4->D4_TRT)+'|'+Space(3)+'|'+'SEFAZ'+'|'+_cCC+'**'
			//ELSEIF !('MOD' $ AllTrim(SD4->D4_COD))  .AND. posicione("SB1",1,xFilial('SB1') + SD4->(D4_COD), 'B1_TIPO') != 'MO'
			//ELSEIF Posicione("SB1",1,xFilial('SB1') + SD4->(D4_COD), 'B1_TIPO') != 'MO' // alteração Bruno Colisse + Carlos p/ contemplar b1_tipo = MO
			ELSEIF !Alltrim(_cCodServ) $ AllTrim(SD4->D4_COD)
				_aValores := LoadVarCusto(SD4->D4_COD,SD4->D4_LOCAL)
				__cUseSys += ".F."+"|"+RlModVend(SD4->D4_OP,SD4->D4_COD)+"|"+SD4->D4_OP+"|"+Space(05)+"|"+SD4->D4_COD+"|"+cValToChar(SD4->D4_QTDEORI)+"|"+cValToChar(_aValores[1])+"|"+cValToChar(ROUND(SD4->D4_QTDEORI*_aValores[1],TamSX3('C6_VALOR')[1]))+"|"+cValToChar(SD4->D4_TRT)+'|'+Space(3)+'|'+'SEFAZ'+'|'+'CC'+'**'						
			ENDIF			                                                                                                
		eLSEIF _cAlsGrv == 'SD3'//______________________[PRODUCAO DE OP]__________________________
	// ALTERAÇÃO CARLOS - 2017.06.09 - Para pegar custo unitário e não valor total da OP
//			_nVlCust := Round(SD3->D3_CUSTO1,TamSX3('C6_VALOR')[2]); _nVlCust:=iIF(_nVlCust==0,1,_nVlCust)		
			_nVlCust := Round((SD3->D3_CUSTO1/SD3->D3_QUANT),TamSX3('C6_VALOR')[2]); _nVlCust:=iIF(_nVlCust==0,1,_nVlCust)
			__cUseSys += ".F."+"|"+SPACE(5)+"|"+SD3->D3_OP+"|"+Space(05)+"|"+SD3->D3_COD+"|"+cValToChar(SD3->D3_QUANT)+"|"+cValToChar(_nVlCust)+"|"+cValToChar(ROUND(SD3->D3_QUANT*_nVlCust,TamSX3('C6_VALOR')[2]))+"|"+cValToChar(SD3->D3_TM)+'|'+Space(3)+'|'+'SEFAZ'+'|'+'CC'+'**'															
		ENDIF                                                                                                                                                                                                                                       
		
		(_cAlsGrv)->(DbSkip())
	EndDo	

	IF 	RecLock('SZZ',.F.)			
			Replace SZZ->ZZ_USESYS		With __cUseSys //_lClear##]
			IF _nForceLeg > 0 //ALTERA LEGENDA FORCANDO STATUS
				Replace SZZ->ZZ_OCORREN With cValToChar(_nForceLeg)
			ENDIF
		SZZ->(MsUnLock())
	ENDIF	
ENDIF           

RestArea(_aArea)	
Return

*----------------------------------------------*
STATIC FUNCTION RlGrvSZZ(_cTable,_cCampo,_cInfo)
*----------------------------------------------*
IF (_cTable)->(FieldPos(_cCampo)) > 0
	IF	RECLOCK(_cTable,.F.) 
			REPLACE (_cTable)->&(_cCampo) WITH _cInfo
		(_cTable)->(MsUnLock())
	ENDIF                      
ENDIF
RETURN
*------------------------------------------------------------------*
Static Function xEntraNF(_lReturn,_aEstoque,_cPedido,_cNota,_cWfMsg,_cJob,lPreNF)
*------------------------------------------------------------------*
Local _nF 
Local aItens 	 := {}
Local aCab   	 := {}
Local _cAlias    := SZY->ZY_TIPOCF 
Local _cSerieFat := xInfoSZY(SZZ->ZZ_PROCESS,SZZ->ZZ_ID,'ZY_SERIE') //Retorna numero da serie cadastrada
Local _cIdOld    := xProcDefore(SZZ->ZZ_ID) //Rastreia ultima processo anterior ao em execucao
Local _lDevolucao:= (SZY->ZY_TIPODOC == 'D' .Or. !Empty(SZY->ZY_DEVSEQ))
Local _lBeneficia:=  SZY->ZY_TIPODOC == 'B' 
Local _lEditBloq := SZY->ZY_AUTOMAT == 'M'
Local _cCodOp	 := ""
Local _cCodServ  := AllTrim(GetMV('RP_CODSERV',.F.,''))
local _lApontSer := GETNEWPAR('RP_APONSER',.T.)
local _lApontPrd := GETNEWPAR('RP_APONPRD',.T.)

_cEmpresa  := FWCodEmp()
_cCorrente := FwCodFil()

Default lPreNF 	 := .F.

DbSelectArea('SF1');DbSelectArea('SD1');SF1->(DbSetOrder(1))
ConOut('[xCmdFatEst / xCompraProd] - Acessando Empressa '+cFilAnt+'/'+cEmpAnt)	

/*** PROCURA CLIENTE/LOJA ***/		
DbSelectArea(_cAlias);(_cAlias)->(DbSetOrder(1));(_cAlias)->(DbSeek(xFilial(_cAlias)+SZY->ZY_CLIFOR+SZY->ZY_LOJA))

//Retorna Dados de OUTRA SEQUENCIA SZZ [1=ZZ_USESYS | 2=ZZ_CHAVE]
_aRetSZZ  := xRetSZZ(SZZ->ZZ_PROCESS, iIF(!_lDevolucao,_cIdOld,SZY->ZY_DEVSEQ))
_cInfoQry := _aRetSZZ[1]  
_cPedido  := _cNota := _aRetSZZ[2]

//(David-TSM) Verifica se existe OP para processo de motor 
_cCodOp := ""	
If Select("QRYSC2") > 0
	QRYSC2->(DbCloseArea())
Endif
BeginSql Alias "QRYSC2"
	SELECT 
		C2_NUM,
		C2_ITEM,
		C2_SEQUEN
	FROM %table:SC2% SC2
	WHERE  C2_FILIAL = %xFilial:SC2%
	       AND C2_XMOTOR = %Exp:SZZ->ZZ_PROCESS% 
	       AND C2_QUJE = 0 
	       AND SC2.%notDel%
EndSql
If !QRYSC2->(EoF())
	_cCodOp := QRYSC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
EndIf
QRYSC2->(DbCloseArea())

LoadUserSys(@_aEstoque, _cInfoQry) //".F."+"|"+SPACE(5)+"|"+SD1->D1_DOC+"|"+SD1->D1_SERIE+"|"+SD1->D1_COD+"|"+cValToChar(SD1->D1_QUANT)+"|"+cValToChar(SD1->D1_VUNIT)+"|"+cValToChar(SD1->D1_TOTAL)+'**'

_cSerieFat := SZY->ZY_SERIE
//(David-TSM) Caso caso número da nota ja exista para o fornecedor procura um código unico
//para evitar chave duplicada
While SF1->(DbSeek(xFilial("SF1")+Padr(_cNota,TamSX3('F1_DOC')[1])+Padr(_cSerieFat,TamSX3('F1_SERIE')[1])+(_cAlias)->&(RIGHT(_cAlias,2)+'_COD')+(_cAlias)->&(RIGHT(_cAlias,2)+'_LOJA')))
	FTVD720Not(@_cSerieFat, @_cNota)
	ConOut('[xCmdFatEst / xCompraProd] - Obtendo Número de NF único '+_cSerieFat+'/'+_cNota)
End
/*** CABEÇALHO DA NF DE ENTRADA ***/		
aadd(aCab,{"F1_TIPO"   	,SZY->ZY_TIPODOC})		
aadd(aCab,{"F1_FORMUL" 	,"N"})		
aadd(aCab,{"F1_DOC"    	,_cNota})		
aadd(aCab,{"F1_SERIE"  	,_cSerieFat})		
aadd(aCab,{"F1_EMISSAO"	,dDataBase})		
aadd(aCab,{"F1_FORNECE"	,(_cAlias)->&(RIGHT(_cAlias,2)+'_COD')})		
aadd(aCab,{"F1_LOJA"   	,(_cAlias)->&(RIGHT(_cAlias,2)+'_LOJA')})		
If lPreNF
	aadd(aCab,{"F1_ESPECIE"	,"NFE"})
Else
	aadd(aCab,{"F1_ESPECIE"	,"SPED"})
EndIf		
aadd(aCab,{"F1_COND"	,SZY->ZY_CONDPAG})
IF Len(_aEstoque) > 0
	IF !EMPTY(_aEstoque[1][P_CHVNFE]) .And. !('SEFAZ' $ _aEstoque[1][P_CHVNFE])
		aadd(aCab,{"F1_CHVNFE"	,_aEstoque[1][P_CHVNFE]})
	ENDIF
ENDIF
aadd(aCab,{'F1_XMOTOR'	,SZZ->ZZ_PROCESS})
aadd(aCab,{'F1_XMOTOID'	,SZZ->ZZ_ID})

For _nF:=1 To Len(_aEstoque)
	ConOut('[xCmdFatEst / xEntraProd] - Montando Iten(s) ITEM '+cValToChar(_nF)+' - PROD '+AllTrim(_aEstoque[_nF,SYS_PRODUTO])+' - Empresa'+cEmpAnt+'/'+cFilAnt) 
	aLinha:={}                                                     
	
	xNoZero(@_aEstoque[_nF][SYS_QUANT], @_aEstoque[_nF][SYS_VALOR])
	
	/*** ITEM DA NF DE ENTRADA ***/
	AADD(aLinha,{"D1_COD"		,_aEstoque[_nF][SYS_PRODUTO]	,NIL})
	AADD(aLinha,{"D1_QUANT"		,_aEstoque[_nF][SYS_QUANT]  	,NIL})
	AADD(aLinha,{"D1_VUNIT"		,_aEstoque[_nF][SYS_VALOR]		,NIL})
	AADD(aLinha,{"D1_TES"		,SZY->ZY_TES  					,NIL})
	
	IF _lDevolucao
		aAdd(aLinha,{"D1_NFORI" 	,_aEstoque[_nF][P_NOTA]		,Nil})
		aAdd(aLinha,{"D1_SERIORI" 	,_aEstoque[_nF][P_SERIE]	,Nil})
		aAdd(aLinha,{"D1_ITEMORI" 	,StrZero(VAL(_aEstoque[_nF][P_ITORIG]),TamSX3('D2_ITEM')[1]) ,Nil})		
	ENDIF
	//[Totvs/Gustavo - 04/02/2017] - Solicitação Marli e Carlos, adição do Centro de Custo proveniente do MOD contido na Estrutura de Produto SG1.
	IF Len(_aEstoque[_nF]) >= SYS_CC .And.  SD1->(FieldPos('D1_CC')) > 0 .And. !Empty(_aEstoque[_nF][SYS_CC]) .And. AllTrim(_aEstoque[_nF][SYS_CC]) <> 'CC'
		AADD(aLinha,{'D1_CC'		,_aEstoque[_nF][SYS_CC]  	,NIL})
	ENDIF
	
	//(David-TSM) Caso se refira a pre-nota preenche Armazem para que seja realizada movimentação
	//de estoque correta
	If Len(_aEstoque[_nF]) >= SYS_LOCAL .And. !Empty(SZY->ZY_LOCAL)
		AADD(aLinha,{'D1_LOCAL'		,SZY->ZY_LOCAL  	,NIL})
	ElseIf Len(_aEstoque[_nF]) >= SYS_LOCAL .And. lPreNF .And. !Empty(_aEstoque[_nF][SYS_LOCAL])
		AADD(aLinha,{'D1_LOCAL'		,_aEstoque[_nF][SYS_LOCAL]  	,NIL})
	EndIf
	
	//(David-TSM)Deixada a gravação do D1_TOTAL por último para que o mesmo não
	//tenha a possibilidade de ficar zerado
	AADD(aLinha,{"D1_TOTAL"		,Round(_aEstoque[_nF][SYS_QUANT]*_aEstoque[_nF][SYS_VALOR],TamSX3("D1_TOTAL")[2]) ,NIL})
	
	//(David-TSM) grava a ordem de produção caso a mesma exista e os parâmetros permitam
	If	!Empty(_cCodOp) .and.;
		( ( _lApontSer .and. Alltrim(_aEstoque[_nF][SYS_PRODUTO]) == Alltrim(_cCodServ) ) .OR.;
		  ( _lApontPrd .and. Alltrim(_aEstoque[_nF][SYS_PRODUTO]) <> Alltrim(_cCodServ) ) )
		  
		AADD(aLinha,{'D1_OP'		,_cCodOp  	,NIL})
	
	EndIf
	
	If SD1->(FieldPos("D1_XMOTOR")) > 0 .and. SD1->(FieldPos("D1_XMOTOID")) > 0
		aAdd(aLinha,{"D1_XMOTOR"	,SZZ->ZZ_PROCESS							,Nil})
		aAdd(aLinha,{"D1_XMOTOID"	,SZZ->ZZ_ID									,Nil})
	Endif
	
	AADD(aItens,aLinha)     	
Next _nF
			       	
lMsHelpAuto := .T.
lMsErroAuto := .F.
		
/*** PROCESSO DE INCLUSÃO DA NF DE ENTRADA ***/    
If !lPreNF
	IF !_lEditBloq
		//Processa({|| MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)},"Incluindo a NF. na "+Alltrim(FwFilialName( _cEmpresa, _cCorrente, 1 ))+" n. "+_cNota+"/"+_cSerieFat)
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)
	Else
		Processa({|| MATA103(aCab, aItens, 3, .T.) },"Incluindo a NF. na "+Alltrim(FwFilialName( _cEmpresa, _cCorrente, 1 ))+" n. "+_cNota+"/"+_cSerieFat)
		MATA103(aCab, aItens, 3, .T.)
	ENDIF
Else
	IF !_lEditBloq
		Processa({|| MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,3)},"Incluindo a NF. na "+Alltrim(FwFilialName( _cEmpresa, _cCorrente, 1 ))+" n. "+_cNota+"/"+_cSerieFat)
	Else
		Processa({|| MATA140(aCab, aItens, 3, .T.) },"Incluindo a NF. na "+Alltrim(FwFilialName( _cEmpresa, _cCorrente, 1 ))+" n. "+_cNota+"/"+_cSerieFat)
	ENDIF
EndIf

				
If lMsErroAuto
	makedir("\EXECAUTO\")
	if File("\EXECAUTO\"+'xEntraProd_'+_cNota+'.txt')
		FErase("\EXECAUTO\"+'xEntraProd_'+_cNota+'.txt')
	endif
 	_cErro 	:=	MostraErro("\EXECAUTO\",'xEntraProd_'+_cNota+'.txt')
 		
	ConOut('[xCmdFatEst / xEntraProd] - ERRO ExecAuto Doc.Entrada '+_cNota+'/'+_cSerieFat+ENTER+_cErro)		
	WfControl(SZZ->ZZ_ID,.F.,,,_cErro,,,SZZ->ZZ_CODEXEC)
 	RETURN(_lReturn:=.F.)
Else
	If !lPreNF
		WfControl(SZZ->ZZ_ID,.T.,_cNota,,'NOTA FISCAL GERADA',,'MATA103',SZZ->ZZ_CODEXEC)
	Else
		WfControl(SZZ->ZZ_ID,.T.,_cNota,,'PRE-NOTA GERADA',,'MATA140',SZZ->ZZ_CODEXEC)
	EndIf
	GravaLogOK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,'D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA',1,'SD1' ,@__cUseSys)
	RlGrvSZZ('SF1','F1_XMOTOR' ,SZZ->ZZ_PROCESS) //GRAVA CAMPO DE RASTRO PARA @MOTO2R 
	RlGrvSZZ('SF1','F1_XMOTOID',SZZ->ZZ_ID)
EndIf

	
Return Nil      

*-----------------------------------------*
Static Function xNoZero(_nNoQuant, _nNoVal)
*-----------------------------------------*
IF GetMV('RP_NOZERO',.F.,.F.)
	_nNoQuant := iIF(_nNoQuant==0,1,_nNoQuant)
	_nNoVal   := iIF(_nNoVal  ==0,1,_nNoVal  ) 
ENDIF
Return

*---------------------------------------*
Static Function xRetSZZ(_cPrcZZ, _cSeqZZ)
*---------------------------------------*
//1=ZZ_USESYS; 2=ZZ_CHAVE
Local _aRetZZ  := Array(3,'')
Local _nRecSZZ := SZZ->(Recno())
Local _aBackZZ := {Posicione("SZZ",1,xFilial("SZZ")+_cPrcZZ+_cJob,"ZZ_USESYS"), AllTrim(Posicione("SZZ",1,xFilial("SZZ")+_cPrcZZ+_cJob,"ZZ_CHAVE")),, AllTrim(Posicione("SZZ",1,xFilial("SZZ")+_cPrcZZ+_cJob,"ZZ_ROTINA"))}

_aRetZZ[1] := Posicione("SZZ",1,xFilial("SZZ")+_cPrcZZ+_cSeqZZ,"ZZ_USESYS")
_aRetZZ[2] := AllTrim(SZZ->ZZ_CHAVE)
_aRetZZ[3] := Alltrim(SZZ->ZZ_ROTINA)

//TRATAMENTO PARA 020 QUANDO O 010 NAO GRAVA USERSYS
IF EMPTY(_aRetZZ[1]) .AND. !EMPTY(_aBackZZ[1])   
	_aRetZZ := aClone(_aBackZZ)
ENDIF

DbSelectArea('SZZ');SZZ->(DbGoTo(_nRecSZZ))

Return(_aRetZZ)

*------------------------------------*
Static Function xProcDefore(_cProcAtu)
*------------------------------------*
Local _cPDef := '' 

_cQey := " SELECT ZY_SEQ SEQOLD "+ENTER
_cQey += " FROM "+RetSqlName('SZY')+ENTER
_cQey += " SZY WHERE SZY.D_E_L_E_T_= ' ' "+ENTER
_cQey += " AND ZY_FILIAL  = '"+xFilial('SZY')+"' "+ENTER
_cQey += " AND ZY_CODIGO  = '"+SZZ->ZZ_CODEXEC+"' "+ENTER
_cQey += " AND ZY_PROXIMO = '"+_cProcAtu+"' "+ENTER
_cQey += " AND ZY_EMPRESA = '"+__cEmpIni+"'  "+ENTER
_cQey += " AND ZY_XFILIAL = '"+__cFilIni+"' "

If Select("_PRR") > 0
	_PRR->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQey),"_PRR",.F.,.T.) 
DbSelectArea("_PRR");_PRR->(dbGoTop())

_cPDef := _PRR->SEQOLD

Return(_cPDef)
      
          
                          
//CHAMADA DOS PONTOS DE ENTRADA
*---------------------*
User Function RPEXECPE
*---------------------*
Local _cOrigem    := ParamIXB
Local _aRetAutoMT := {.F.,''}
Local _cFilCliFor := ""
Local _cCLiFor	  := ""
Local _lMsgMot	  := GetNewPar("RP_MSGMOTO",.T.)

If Empty(__cEmpIni+__cFilIni)
	__cEmpIni	:= cEmpAnt
	__cFilIni	:= cFilAnt
EndIf 

IF _cOrigem == 'MATA460' .And. FunName() <> 'XRLSMOTOR' 	//_____________[ FATURAMENTO - PEDIDO DE VENDA ]_____________
                      
	//CONTROLE DE EXECUCAO PARA NAO DUPLICAR FUNCAO
	_lUseRPEXECPE := iIF(Type('_lUseRPEXECPE')<>'U',_lUseRPEXECPE,.F.)
	IF !_lUseRPEXECPE
		Return
	ENDIF
	_lUseRPEXECPE := .F.
	
	_cPedVend := LoadPedFat()
	DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop())
	IF SC5->(DbSeek(xFilial('SC5')+_cPedVend)) .And. Empty(SC5->C5_XMOTOR)
		IF Empty( _cIdExec := u_RpScanSZY('4', xGrpMerc('4','SD2',SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) ) ) //TIPO FATURAMENTO
			//MsgInfo('ID para geração do Motor não informado.'+ENTER+'Revise o processo!','Atenção')
			conout('[RPEXECPE] '+_cOrigem+' '+_cPedVend+' ID para geração do Motor não identificado na tabela SZY.')
			Return(.F.)
		Else
			_cFilCliFor := xInfoSZY(_cIdExec,"010","ZY_FILCLFO")
			_cCLiFor	:= xInfoSZY(_cIdExec,"010","ZY_CLIFOR")+xInfoSZY(_cIdExec,"010","ZY_LOJA")
			If _cFilCliFor == "1" .and. Alltrim(SC5->(C5_CLIENTE+C5_LOJACLI)) <> Alltrim(_cCLiFor) 
				Return(.F.)
			EndIf
		ENDIF
		_aRetScan   := {'010'} 
		_aRetAutoMT := u_RPExcIdMT(_cIdExec,_aRetScan[1])	//u_RPExcIdMT('100004',_aRetScan[1])
	ENDIF                 
	
ElseIF _cOrigem == 'MATA250'//_____________[  PRODUÇÃO - OP  ]_____________
	DbSelectArea('SD3');SD3->(DbSetOrder(1));SD3->(DbGoTop())
	DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop())	
	IF SD3->(DbSeek(xFilial('SD3')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,.T.)) .And. SC5->(DbSeek(xFilial('SC5')+SC2->C2_PEDIDO))
			IF Empty( _cIdExec    := u_RpScanSZY('3', xGrpMerc('3','SC2',SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) ) ) //TIPO PRODUCAO DA ORDEM
				MsgInfo('ID para geração do Motor não informado.'+ENTER+'Revise o processo!','Atenção')
				Return(.F.)
			ENDIF			
			_aRetScan   := {'010'}//u_RPScanIDMT(_cCodSZZ,SC5->C5_NUM,'ZZ_CHAVE') 
			_aRetAutoMT := u_RPExcIdMT(_cIdExec,_aRetScan[1]) 	//u_RPExcIdMT('100003',_aRetScan[1])
		//ENDIF
	ENDIF
	
ElseIF _cOrigem == 'MATA650'//_____________[  ABERTURA DE ORDEM DE PRODUCAO  ]_____________
	DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop())
	DbSelectArea('SD4');SD4->(DbSetOrder(2));SD4->(DbGoTop())
	IF SC5->(DbSeek(xFilial('SC5')+SC2->C2_PEDIDO)) .And. SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
			Sleep(1000)
			IF Empty( _cIdExec    := u_RpScanSZY('2', xGrpMerc('2','SC2',SD4->D4_OP) ) )//TIPO ORDEM DE PRODUCAO
				MsgInfo('ID para geração do Motor não informado.'+ENTER+'Revise o processo!','Atenção')
				Return(.F.)
			ENDIF			
			_aRetScan   := {'010'}//u_RPScanIDMT(_cCodSZZ,SC5->C5_NUM,'ZZ_CHAVE') 
			_aRetAutoMT := u_RPExcIdMT(_cIdExec,_aRetScan[1]) //u_RPExcIdMT('100002',_aRetScan[1])
	ELSE
		MsgInfo('Motor não processado, Pedido ou Empenho não localizado.'+ENTER+'Pedido de Venda: '+SC2->C2_PEDIDO+ENTER+'OP Empenho Prod.: '+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,'Atencao')
	ENDIF
ElseIF _cOrigem == 'MATA103' .And. FunName() <> 'XRLSMOTOR' 	//_____________[ FATURAMENTO - PEDIDO DE VENDA ]_____________
                      
	//CONTROLE DE EXECUCAO PARA NAO DUPLICAR FUNCAO
	_lUseRPEXECPE := iIF(Type('_lUseRPEXECPE')<>'U',_lUseRPEXECPE,.F.)
	IF !_lUseRPEXECPE
		Return
	ENDIF
	_lUseRPEXECPE := .F.
	
	IF Empty( _cIdExec := u_RpScanSZY('5', xGrpMerc('4','SD1',SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) ) ) //TIPO FATURAMENTO
		//MsgInfo('ID para geração do Motor não informado.'+ENTER+'Revise o processo!','Atenção')
		conout('[RPEXECPE] '+_cOrigem+' '+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+' ID para geração do Motor não identificado na tabela SZY.')
		Return(.F.)
	Else
		_cFilCliFor := xInfoSZY(_cIdExec,"010","ZY_FILCLFO")
		_cCLiFor	:= xInfoSZY(_cIdExec,"010","ZY_CLIFOR")+xInfoSZY(_cIdExec,"010","ZY_LOJA")
		If _cFilCliFor == "1" .and. Alltrim(SF1->(F1_FORNECE+F1_LOJA)) <> Alltrim(_cCLiFor) 
			Return(.F.)
		EndIf
	ENDIF
	_aRetScan   := {'010'} 
	_aRetAutoMT := u_RPExcIdMT(_cIdExec,_aRetScan[1])	//u_RPExcIdMT('100004',_aRetScan[1])
ENDIF    


//Mensagem ao final do processamento de cada chamada
IF _aRetAutoMT[1] .AND. _lMsgMot
	IF !Empty(_cCodMTNew := _aRetAutoMT[2])
		MsgInfo("MOTOR DE PROCESSO - "+ _cCodMTNew +", gerado com sucesso!","MOTOR DE PROCESSO","INFO") //IF MsgYesNo("MOTOR DE PROCESSO - "+ _cCodMTNew +", gerado com sucesso!"+ENTER+ENTER+'Deseja visualizar as movimentações processadas ?')
			FwMsgRun(,{|| u_XRLSMOTOR(,,,,_cCodMTNew,_cIdExec) }, "Aguarde Processamento...",'Verificando Motor de Processos')
		//ENDIF
	ENDIF	
ENDIF

Return       

//RETORNA DADOS DO SZZ FILTRANDO PELO CAMPO DE INFORMAÇÃO E CHAVE DE SZZ PARA EMPRESA E FILIAL
*---------------------------------------------------*
User Function RPScanIDMT(_cCodSZZ,_cChvMT,_cCpoMTRet)
*---------------------------------------------------*
Local _aRetMT := Array(1,'')

_cAllZZ := " SELECT * "+ENTER
_cAllZZ += "  FROM "+RetSqlName('SZZ')+" SZZ  "+ENTER
_cAllZZ += "   WHERE SZZ.D_E_L_E_T_= ''  "+ENTER
_cAllZZ += "     AND ZZ_FILIAL     = ''  "+ENTER
_cAllZZ += "     AND ZZ_PROCESS    = '"+_cCodSZZ+"' "+ENTER 
_cAllZZ += "     AND "+_cCpoMTRet+"= '"+_cChvMT+"' "+ENTER
If Select("_ALL") > 0
	_ALL->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cAllZZ),"_ALL",.F.,.T.) 
DbSelectArea("_ALL");_ALL->(dbGoTop())
IF !Empty(_ALL->ZZ_PROCESS)
	_aRetMT[1] := _ALL->ZZ_ID
ENDIF

Return(_aRetMT)

*------------------------------------------------*
User Function RPExcIdMT(_cProcesso,_cID)
*------------------------------------------------*
Local _lPrID       := .F.    
Local __cUseSys    := ''
lOCAL _lExecRot    := .F.

Default _cProcesso := ''
Default _cID       := ''      

//Private _cCrtSZZ := _cProcesso
Private _aEstoque := {}
Private _aAllPrc  := u_xRpsListaPrc(_cProcesso) //LISTA ITENS DE PROCESSO

//u_XRLSMOTOR(,.T.,.T.)
IF Empty(_aAllPrc[1])
	Return
ENDIF

Sleep(1000)
Private _cCrtSZZ  := CmdControlZZ(,,,,,,,_cProcesso) //GERA CODIGO DE MOTOR

DbSelectArea('SZZ');SZZ->(DbSetOrder(1));SZZ->(DbgoTop())
IF SZZ->(DbSeek(xFilial('SZZ')+_cCrtSZZ + _cID))
	xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID)

	
	//APENAS PARA GRAVAÇÃO DE DADOS - PROCESSAMENTOS MANUAIS
	IF SZZ->ZZ_STATUS $ '1|4' //EM ABERTO OU AGUARDANDO ETAPA PROCESSO  
	        
		IF AllTrim(SZY->ZY_ROTINA) == 'MATA460'
			_lExecRot := .T.
			RlGrvSZZ('SF2','F2_XMOTOR' ,SZZ->ZZ_PROCESS)
			RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)		
			WfControl(SZZ->ZZ_ID,.T.,SF2->F2_DOC,,'FATURAMENTO AO CLIENTE',,'MATC090',SZZ->ZZ_CODEXEC)                               
			_cFil := ''
			GravaLogOK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA',3,'SD2' ,@__cUseSys,,)
			
		ElseIF AllTrim(SZY->ZY_ROTINA) $ 'MATA103,MATA140' 
			_lExecRot := .T.
			If FunNAme() == 'MATA103' 
				RlGrvSZZ('SF1','F1_XMOTOR' ,SZZ->ZZ_PROCESS) //GRAVA CAMPO DE RASTRO PARA @MOTO2R 
				WfControl(SZZ->ZZ_ID,.T.,SF1->F1_DOC,,"ENTRADA DE NOTA",,SZY->ZY_ROTINA,SZZ->ZZ_CODEXEC)
				GravaLogOK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,'D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA',1,'SD1' ,@__cUseSys)
			eNDiF
		
		//PROCESSO DE INTEGRACAO ENTRE GERACAO DA ORDEM DE PRODUCAO X MOTOR DE PROCESSO_______________________________________
		ElseIF AllTrim(SZY->ZY_ROTINA) == 'MATA650' 
			_lExecRot := .T.
			RlGrvSZZ('SC2','C2_XMOTOR' ,SZZ->ZZ_PROCESS)
			//RlGrvSZZ('SC5','C5_XMOTOR' ,SZZ->ZZ_PROCESS)
			//RlGrvSZZ('SC5','C5_XMOTOID',SZZ->ZZ_ID)						
					
			WfControl(SZZ->ZZ_ID,.T.,SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,,'OP GERADA',,'MATA650',SZZ->ZZ_CODEXEC)
			GravaLogOK(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,'SD4->D4_FILIAL+AllTrim(SD4->D4_OP)',2,'SD4' ,@__cUseSys)    
		
		//PROCESSO DE INTEGRACAO ENTRE PRODUCAO DA ORDEM X MOTOR DE PROCESSO___________________________________________________
		ElseIF AllTrim(SZY->ZY_ROTINA) == 'MATA250' 
			_lExecRot := .T.
			RlGrvSZZ('SD3','D3_XMOTOR' ,SZZ->ZZ_PROCESS)
					
			WfControl(SZZ->ZZ_ID,.T.,SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,,'OP PRODUZIDA',,'MATA650',SZZ->ZZ_CODEXEC)                               
			_cFil := "SD3->D3_CF == 'PR0' .And. SD3->D3_ESTORNO <> 'S' "
			GravaLogOK(xFilial("SD3")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,'SD3->D3_FILIAL+AllTrim(SD3->D3_OP)',1,'SD3' ,@__cUseSys,,_cFil)
			
		ENDIF
		IF _lExecRot
		    u_XRLSMOTOR(_cID,.T.,.T.,SZZ->ZZ_PROCESS,,_cProcesso)
		    _lPrID := .T.
		ENDIF
	    
    Else //EXECUTA PROCESSAMENTO DE ID PENDENTE 
		u_XRLSMOTOR(_cID,.T.,.T.,SZZ->ZZ_PROCESS)
    ENDIF    
ENDIF

Return({_lPrID,_cCrtSZZ})

//-----------------------------------------------------------------------------------------------------------------------   
*--------------------------*
Static Function xAutoNfeCmd(_cNota,_lRetSefaz,_aReProcPV)
*--------------------------*
Local   _cSerieFat  := xInfoSZY(SZZ->ZZ_CODEXEC,SZZ->ZZ_ID,'ZY_SERIE')
Local   aParams     :=  {cEmpAnt,cFilAnt,'5','1',_cSerieFat,_cnota,_cnota}//xReadInfo() 
Local   lJobOn      :=  File("autonf.cfg")// Ativa e Desativa a Transmissao Auto
Local   lOnDemand   :=  .F. // Modo de Execucao 1=Rotina direta , 2=StartJob
Local	nX			:=	0
Local	nY			:=	0
Local	cAtivo		:=	""
Local	aRotina		:=	{"AutoNfeEnv"}
Local  _lRetSefaz   := .T.
Private	__lPyme	:=	.F.	// EXISTBLOCK E EXECBLOCK

//VALIDA SE PROCESSO FOI 'PARADO' NO FATURAMENTO______________
IF _aReProcPV[1]
	IF _aReProcPV[2] <> '3' //1=PEDIDO;2=FATURAMENTO;3=SEFAZ;4=FIM
		RETURN(_lRetSefaz:=.T.)
	ENDIF
	_aReProcPV := {.F.,'3'}
ENDIF

//If /*lJobOn .And.*/ _lAutoNfe .And. Len(aParams)>0
/*
	While !KillApp()
		AutoNfeEnv(aParams[1],aParams[2],aParams[3],aParams[4],Padr(aParams[5],3),aParams[6],aParams[7])
		ConOut("??????????? PAUSA DE "+aParams[3]+' Segundos...')
		Sleep(1000 * Val(aParams[3]))
		_lRetSefaz := xSpedNFe6Mnt(Padr(aParams[5],3),aParams[6],aParams[7],,,'55')
		Exit
	EndDo
Else
	ConOut("AUTONFE --> OFF")
	_lRetSefaz := .F.
	RETURN
EndIf
*/

Return(_lRetSefaz)                                                                    

*------------------------------------------------------------------------*
Static Function xSpedNFe6Mnt(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe,cModel)
*------------------------------------------------------------------------*
Local cIdEnt   := ""
local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aPerg    := {}
Local aParam   := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
Local aSize    := {}
Local aObjects := {}
Local aListBox := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cParNfeRem := ''
Local lOK        := .F.
Local _nWt, _nA
Local cFilLogOk	 := ""
Local _nTentrf	 := GetMV('CM_NTENTTF',.F.,50)
Local _cMsgCompl := ""
Local nPosStatus := 0

Default cSerie   := ''
Default cNotaIni := ''
Default cNotaFim := ''
Default lCTe     := .F.
Default lMDFe    := .F.
Default cModel	 := ""

_cEmpresa  := FWCodEmp()
_cCorrente := FwCodFil()

cParNfeRem := _cEmpresa + _cCorrente + "SPEDNFEREM"

aadd(aPerg,{1,"Serie da Nota Fiscal",aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,"Nota fiscal inicial",aParam[02],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
aadd(aPerg,{1,"Nota fiscal final",aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])

//³Obtem o codigo da entidade                                              
cIdEnt := RetIdEnti()
If !Empty(cIdEnt)
	lOK        := .T.//ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeRem,.T.,.T.) aParam[1]:=; acessou esse 
	cSerie   := aParam[01] :=  cSerie
	cNotaIni := aParam[02] := cNotaIni
	cNotaFim :=	aParam[03] := cNotaFim				
	For _nWt:=1 To _nTentrf                                                                                             
		For _nA:=1 To 5
			SLEEP(1000)
		next	
		aListBox := xGetListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte)
		
		IF !Empty(aListBox)
			
			IF LEN(aListBox[1][9]) <> 0
				nPosStatus := ascan(aListBox[1][9],{|x| x[9] == '100' })
				If nPosStatus > 0   
			  		ConOut('[xCmdFatEst / Status Sefaz] - NFE TRANSMITIDA COM SUCESSO, PROTOCOLO: '+aListBox[1][2]+' | '+CVALTOCHAR(aListBox[1][9][nPosStatus][4])+' - '+aListBox[1][9][nPosStatus][10]) 		
			  		WfControl(SZZ->ZZ_ID,.T.,_cNota,,aListBox[1][2]+' | '+CVALTOCHAR(aListBox[1][9][nPosStatus][4])+' - '+aListBox[1][9][nPosStatus][10],,,SZZ->ZZ_CODEXEC)//WfControl(5,.T.,'',aListBox)                       
			  		//ALTERACAO DA DESCRICAO SEFAZ PARA O CODIGO DA CHAVE DE TRANSMISSAO
			  		If !Empty(__cUseSys)
			  			__cUseSys := Replace(__cUseSys,'SEFAZ',SF2->F2_CHVNFE)
			  			cFilLogOk := '.F.'
			  		Else
			  			cFilLogOk := nil
			  		EndIf		  		
			  		GravaLogOK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,'D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA',3,'SD2' ,@__cUseSys,,cFilLogOK,.F.)
			  		MsgRun('NFE TRANSMITIDA COM SUCESSO, PROTOCOLO: '+aListBox[1][2]+' | '+CVALTOCHAR(aListBox[1][9][nPosStatus][4])+' - '+aListBox[1][9][nPosStatus][10],"Aguarde...",{|| InKey(2) })
			  		RlGrvSZZ('SZZ','ZZ_NEXTPV' ,'4') //PROXIMO PASSO FIM
			  		RETURN(.T.)
			  	ENDIF
				IF aListBox[1][9][1][9] == '103'
					IF _nWt==_nTentrf
				  		_cMsgCompl := "Por favor, verifique a causa no monitor SEFAZ. Após realizar os ajustes, retransmita a mesma manualmente e execute novamente a rotina de MOTOR."
				  		ConOut('[xCmdFatEst / Status Sefaz] - EM PROCESSO > PROTOCOLO: '+aListBox[1][2]+' - '+CVALTOCHAR(aListBox[1][9][1][4])+' - '+aListBox[1][9][1][10]) 			
				  		WfControl(SZZ->ZZ_ID,.F.,_cNota,,aListBox[1][2]+' | '+CVALTOCHAR(aListBox[1][9][1][4])+' - '+aListBox[1][9][1][10]+" "+_cMsgCompl,,,SZZ->ZZ_CODEXEC)//WfControl(5,.T.,'',aListBox)                       
				  		RETURN(.F.)
				 	EndIF
				ELSEIF aListBox[1][9][1][9] <> '100'
					If !Empty(aListBox[1][9][1][9]) .or. _nWt==_nTentrf
				  		_cMsgCompl := "Por favor, verifique a causa no monitor SEFAZ. Após realizar os ajustes, retransmita a mesma manualmente e execute novamente a rotina de MOTOR."
				  		ConOut('[xCmdFatEst / Status Sefaz] - PROCESSO SERA PARADO POR ERRO NO DANFE '+aListBox[1][9][1][9])
				  		WfControl(SZZ->ZZ_ID,.F.,_cNota,,aListBox[1][2]+' | '+CVALTOCHAR(aListBox[1][9][1][4])+' - '+aListBox[1][9][1][10]+" "+_cMsgCompl,,,SZZ->ZZ_CODEXEC)//WfControl(5,.T.,'',aListBox)                       
				  		RETURN(.F.)
				  	EndIf
			  	EndIf
			Else
				IF _nWt==_nTentrf
					_cMsgCompl := "Por favor, verifique a causa no monitor SEFAZ. Após realizar os ajustes, retransmita a mesma manualmente e execute novamente a rotina de MOTOR."
					ConOut('[xCmdFatEst / Status Sefaz] - ERRO PROCESSO NFE SEFAZ - SEM COMUNICACAO '+aListBox[1][6]) 			
					WfControl(SZZ->ZZ_ID,.F.,_cNota,,'Erro transmissao NFE-Sefaz: ERRO PROCESSO NFE SEFAZ - SEM COMUNICACAO '+aListBox[1][6]+" "+_cMsgCompl,,,SZZ->ZZ_CODEXEC)//WfControl(5,.T.,'',aListBox)                       
		  			RETURN(.F.)
				EndIF		
			ENDIF
		ENDIF
	  	ConOut("??????????? PAUSA DE "+cValToChar(GetMV('CM_EEWAITF',.F.,1))+' Segundos...')
		Sleep(1000 * GetMV('CM_EEWAITF',.F.,3))
  	Next _nWt			
Else
	Aviso("SPED",'WF sefaz nao configurado',{'Fechar'},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

WfControl(SZZ->ZZ_ID,.F.,_cNota,,'NOTA COM PROBLEMA DE TRANSMISSAO SEFAZ',,,SZZ->ZZ_CODEXEC)//WfControl(5,.T.,'',aListBox)                       
RETURN(.F.)



*---------------------------------------------------------------------------------*
Static Function xGetListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg)
*---------------------------------------------------------------------------------*	
local aLote			:= {}
local aListBox			:= {}
local cId				:= ""
local cProtocolo		:= ""	
local cRetCodNfe		:= ""
local cAviso			:= ""
	
local nAmbiente			:= ""
local nModalidade		:= ""
local cRecomendacao		:= ""
local cTempoDeEspera	:= ""
local nTempomedioSef	:= ""
local nX				:= 0

local oOk				:= LoadBitMap(GetResources(), "ENABLE")
local oNo				:= LoadBitMap(GetResources(), "DISABLE")
		
default lMsg			:= .T.
default lCte			:= .F.
	
//processa monitoramento
aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)

if empty(cAviso)
	for nX := 1 to len(aRetorno)				
		cId				:= aRetorno[nX][1]
		cProtocolo		:= aRetorno[nX][4]	
		cRetCodNfe		:= aRetorno[nX][5]
		nAmbiente		:= aRetorno[nX][7]
		nModalidade	:= aRetorno[nX][8]
		cRecomendacao	:= aRetorno[nX][9]
		cTempoDeEspera:= aRetorno[nX][10]
		nTempomedioSef:= aRetorno[nX][11]
		aLote			:= aRetorno[nX][12]
								
		aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
							cId,;
							if(nAmbiente == 1,"Produção","Homologação"),; //"Produção"###"Homologação"
							if(nModalidade ==1 .Or. nModalidade == 4 .Or. nModalidade == 6, "Normal","Contingência"),; //"Normal"###"Contingência"
							cProtocolo,;
							cRecomendacao,;
							cTempoDeEspera,;
							nTempoMedioSef,;
							aLote;
							})
	Next
Else
	ConOut('[xCmdFatEst / Status Sefaz] - AVISO: '+cAviso)
EndIF
    
Return(aListBox)

*--------------------------------*
Static Function RlModVend(_cCodOP,_cPrdComp)
*--------------------------------*
Local _cItModCob := Space(5)

DbSelectArea('SC2');SC2->(DbSetOrder(1))
If DbSeek(xFilial('SC2')+_cCodOP)	 
	DbSelectArea('SG1');SG1->(DbSetOrder(1))
	If DbSeek(xFilial('SG1')+AllTrim(SC2->C2_PRODUTO))	
		Do While SG1->(!EoF()) .And. AllTrim(SG1->G1_COD) == AllTrim(SC2->C2_PRODUTO)
			IF AllTrim(_cPrdComp) == AllTrim(SG1->G1_COMP)
				//If SG1->G1_XMODVND == '2' .And. SC2->C2_REVISAO >= SG1->G1_REVINI .and. SC2->C2_REVISAO <= SG1->G1_REVFIM		
				IF SC2->C2_REVISAO >= SG1->G1_REVINI .and. SC2->C2_REVISAO <= SG1->G1_REVFIM .AND. 'MOD' $ ALLTRIM(SG1->G1_COMP)
					_cItModCob := 'MOD'
					Exit 	
				EndIf 
			ENDIF			
			SG1->(DbSkip())
		EndDo
	EndIf         
EndIF
Return(_cItModCob)

*-------------------------*
Static Function LoadPedFat
*-------------------------*
Local _cRetPV := ''
_cQry := " SELECT DISTINCT D2_PEDIDO PEDIDO "+ENTER
_cQry += "  FROM "+RetSqlName('SD2')+" SD2  "+ENTER
_cQry += "   WHERE SD2.D_E_L_E_T_= ''  "+ENTER
_cQry += "     AND D2_FILIAL     = '"+xFilial('SD2')+"'  "+ENTER
_cQry += "     AND D2_DOC        = '"+SF2->F2_DOC+"'  "+ENTER
_cQry += "     AND D2_SERIE      = '"+SF2->F2_SERIE+"'  "+ENTER
_cQry += "     AND D2_CLIENTE    = '"+SF2->F2_CLIENTE+"'  "+ENTER
_cQry += "     AND D2_LOJA       = '"+SF2->F2_LOJA+"'  "+ENTER
If Select("_TMB") > 0
	_TMB->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_TMB",.F.,.T.) 
DbSelectArea("_TMB");_TMB->(dbGoTop())
IF !Empty(_TMB->PEDIDO)
	_cRetPV := _TMB->PEDIDO
EndIF

Return(_cRetPV)
*----------------------------------------------*
Static Function LoadVarCusto(_cCodProd,_cCodArm)
*----------------------------------------------*
Local _aRetCC := {1}

DbSelectArea('SB1');SB1->(DbSetOrder(1));SB1->(DbGoTop())
IF SB1->(DbSeek(xFilial('SB1')+_cCodProd))
	_aRetCC[1] := iIF(Empty(SB1->B1_UPRC),1,SB1->B1_UPRC)
ENDIF
Return(_aRetCC)

*---------------------*
Static Function xImpRel
*---------------------*
Local _nOpc := Aviso("AVISO","MOTOR DE PROCESSOS"+ENTER+"Impressao de relatórios vinculados ao Motor",{"Movimento Merc.","Motor Processo","SAIR"})

IF _nOpc == 1
	u_RPRMOT01()
ElseIF _nOpc == 2
	u_RPRMOT02()
ENDIF

Return

*---------------------------*
Static Function RetCodNewJob(_cIdStart,_cSelIdProd,_cOpcExec,_cTpMerc)
*---------------------------*
Local _aFilTP  := {}
Local _cFilRet := ''
Local oArq 
Local _nOpcP := 0

Local oSim   := LoadBitmap(GetResources(), "CHECKED")	//LoadBitmap( GetResources(), "LBOK")	//LoadBitmap(GetResources(), "CHECKED")
Local oNao   := LoadBitmap(GetResources(), "UNCHECKED") ///LoadBitmap( GetResources(), "LBNO")	//LoadBitmap(GetResources(), "UNCHECKED")  
Local oDlgArq
Local oArq
Local oDlg
Local _aButtons:= {}

Default _cIdStart := ''
Default _cOpcExec := ''
Default _cTpMerc := ''

IF !Empty(_cIdStart)
	_cSelIdProd := _cIdStart
	Return(_cIdStart)
ENDIF

_cNew := " SELECT ZY_CODIGO CODIGO, ZY_DESCUSR DESCRICAO, ZY_DESCRI DESCMAT "+ENTER
_cNew += "  FROM "+RetSqlName('SZY')+" SZY (NOLOCK) "+ENTER
_cNew += "   WHERE SZY.D_E_L_E_T_    = ''  "+ENTER
_cNew += "     AND ZY_FILIAL         = '"+xFilial('SZY')+"'  "+ENTER
_cNew += "     AND ZY_XFILIAL        = '"+cFilAnt+"'  "+ENTER
_cNew += "     AND ZY_SEQ            = '010'  "+ENTER
_cNew += "     AND LEFT(ZY_CODIGO,1) = '"+_cOpcExec+"' "+ENTER
IF _cTpMerc $ '1|2|3'
	_cNew += " AND RIGHT(ZY_CODIGO,1) = '"+_cTpMerc+"' "+ENTER
ENDIF
If Select("_TMA") > 0
	_TMA->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cNew),"_TMA",.F.,.T.) 
DbSelectArea("_TMA");_TMA->(dbGoTop())
While _TMA->(!Eof())
	aADD(_aFilTP,{.F.,_TMA->CODIGO,_TMA->DESCRICAO, _TMA->DESCMAT})	
	_TMA->(DbSkip())
EndDo   

IF Len(_aFilTP) > 0  
	DEFINE MSDIALOG oDlgArq TITLE OemtoAnsi("MOTOR DE PROCESSO - Tipo de Operação") FROM 0,0 TO 250,745 OF oDlg PIXEL Style 128
	oDlgArq:lEscClose := .F.
		
		@ 033,001 LISTBOX oArq FIELDS HEADER OemtoAnsi(""), OemtoAnsi("CODIGO"),	OemtoAnsi("DESCRIÇÃO"),	OemtoAnsi("MATERIAL");
					FIELDSIZES 14,050,160,080 SIZE 380,100 PIXEL	
	
		oArq:SetArray(_aFilTP)
		oArq:bLine      := {|| {If(_aFilTP[oArq:nAt,1],oSim,oNao), _aFilTP[oArq:nAt,2], _aFilTP[oArq:nAt,3], _aFilTP[oArq:nAt,4] }}
		oArq:bLDblClick := {|| AEval(_aFilTP,{|x| x[1]:=.F.}),_aFilTP[oArq:nAt,1]:=.T., oArq:DrawSelect(), oArq:Refresh() }					 							
			
	ACTIVATE MSDIALOG oDlgArq CENTERED ON INIT ( EnchoiceBar(oDlgArq,{|| iIF( aScan(_aFilTP,{|s| s[1]==.T.})==0,MsgInfo('Seleciona um processo válido!','Atencao'), (_nOpcP:=1,oDlgArq:End())) },{|| oDlgArq:End() },,_aButtons ),oDlgArq:Refresh() )
Else
	MsgInfo('Não foram encontrados registros relacionados.',"Atencao")
EndIF

IF _nOpcP == 1           
	IF (_nOk := aScan(_aFilTP,{|s| s[1]==.T.})) > 0
		IF MSGYESNO('Deseja iniciar o processamento:'+ENTER+ENTER+_aFilTP[_nOk][2]+ENTER+_aFilTP[_nOk][3]+ENTER+_aFilTP[_nOk][4],'ATENCAO')
			_cFilRet    := _aFilTP[_nOk][2]
			_cSelIdProd := _cFilRet
		ENDIF
	ENDIF
ENDIF
Return(_cFilRet)

*--------------------------------*
User Function RpScanSZY(_cOpcExec,_cTpMerc)
*--------------------------------*
//1=COMPRA;2=ABERTURA DE OP; 3=PRODUCAO DA OP; 4=FATURAMENTO
Local _cRetExZY := ''                                       
Default _cTpMerc := ''

_cQryZ := " SELECT ZY_CODIGO CODEXEC						"+ENTER
_cQryZ += "  FROM "+RetSqlName('SZY')+" SZY  				"+ENTER
_cQryZ += "   WHERE SZY.D_E_L_E_T_ = ''  					"+ENTER
_cQryZ += "     AND ZY_FILIAL         = '"+xFilial('SZY')+"'"+ENTER
_cQryZ += "     AND ZY_XFILIAL        = '"+cFilAnt+"'  		"+ENTER
_cQryZ += "     AND LEFT(ZY_CODIGO,1) = '"+_cOpcExec+"'  	"+ENTER
_cQryZ += "     AND ZY_SEQ            = '010' 				"+ENTER

//0=Outros; 1=Filme; 2=Resina Nacional; 3=Resina Importada
IF _cTpMerc $ '1|2|3'
	_cQryZ += " AND RIGHT(ZY_CODIGO,1) = '"+_cTpMerc+"' "+ENTER
ENDIF

//_cQryZ += " AND ZY_GRUPO IN ('BOPP')
If Select("_TMA") > 0
	_TMA->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryZ),"_TMA",.F.,.T.) 
DbSelectArea("_TMA");_TMA->(dbGoTop())
_nItens := Contar("_TMA","!Eof()"); _TMA->(DbGoTop())

IF _nItens == 1
	_cRetExZY := _TMA->CODEXEC
ElseIF _nItens > 1
	_cRetExZY := RetCodNewJob(,,_cOpcExec,_cTpMerc)
ENDIF

Return(_cRetExZY)

*---------------------------------------------*
Static Function LoadServPrd(_cCodServ, _cSrvOP)
*---------------------------------------------*
Local _aRetSrv := {1,1,1}
Local _aRecs   := {SC6->(Recno())   , SB1->(Recno())}
Local _aIecs   := {SC6->(IndexOrd()), SB1->(IndexOrd())}

DbSelectArea('SB1');SB1->(DbGoTop())
DbSelectArea('SC6');SC6->(DbGoTop());SC6->(DbSetOrder(1))
IF SB1->(DbSeek(xFilial('SB1')+_cCodServ))
		
	_cQryC2 := " SELECT C2_QUANT QTDOP FROM "+RetSqlName('SC2')+" SC2 WHERE SC2.D_E_L_E_T_ = '' AND C2_FILIAL = '"+xFilial('SC2')+"' AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+_cSrvOP+"' "
	If Select("_TMA") > 0
		_TMA->(DbCloseArea())
	EndIf       	 
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryC2),"_TMA",.F.,.T.) 
	DbSelectArea("_TMA");_TMA->(DbGoTop())		
	IF  !Empty(_TMA->QTDOP) //SC6->(DbSeek(xFilial('SC6')+SC2->C2_PEDIDO + SC2->C2_ITEMPV + SC2->C2_PRODUTO))
		_aRetSrv[1] := _TMA->QTDOP //SC6->C6_QTDVEN
	ENDIF
	IF !Empty(SB1->B1_PRV1)
		_aRetSrv[2] := SB1->B1_PRV1	
		_aRetSrv[3] := ROUND(_aRetSrv[1]*SB1->B1_PRV1,TamSX3('C6_VALOR')[2])
	ENDIF
ENDIF                                  

DbSelectArea('SC6');SC6->(DbGoTo(_aIecs[1]));SC6->(DbGoTo(_aRecs[1]))
DbSelectArea('SB1');SB1->(DbGoTo(_aIecs[2]));SC6->(DbGoTo(_aRecs[2]))

Return(_aRetSrv)

*---------------------*
User Function RPMOTORC5
*---------------------*
Local _lRetExC5 := .T.

_cQryC5 := " SELECT DISTINCT D2_PEDIDO PEDNOTA FROM "+RetSqlName('SD2')+" SD2 (NOLOCK) WHERE SD2.D_E_L_E_T_ = '' AND D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND D2_LOJA = '"+SF2->F2_LOJA+"' " 
If Select("_TMA") > 0
	_TMA->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryC5),"_TMA",.F.,.T.) 
DbSelectArea("_TMA");_TMA->(dbGoTop())
While _TMA->(!Eof())
	DbSelectArea('SC5');SC5->(DbSetOrder(1));SC5->(DbGoTop()) 
	IF SC5->(DbSeek(xFilial('SC5')+_TMA->PEDNOTA))	
		IF 	RecLock('SC5',.F.)
				Replace SC5->C5_XMOTOR With CriaVar('C5_XMOTOR')
			SC5->(MsUnLock())
		ENDIF
	ENDIF
	_TMA->(DbSkip())
EndDo                     

Return(_lRetExC5)

*----------------------------------------------*
Static Function xGrpMerc(_cGrOpc,_cGrAls,_cGrChav)
*----------------------------------------------* 
Local _aArGrp1 := GetArea()
Local _aArGrp2 := (_cGrAls)->(GetArea())
Local _cXGRUPO := Space( Len( SB1->B1_XGRUPO ) )

//Local _nOrder  := iIF(_cGrOpc=='4',3,1)
DbSelectArea(_cGrAls);(_cGrAls)->(DbGoTop()) //;(_cGrAls)->(DbSetOrder(_nOrder))

IF _cGrOpc $ '2|3'
	IF (_cGrAls)->(DbSeek(xFilial(_cGrAls)+_cGrChav,.T.))
		_cXGRUPO := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_XGRUPO")
	ENDIF		
ElseIF  _cGrOpc $ '4' .and. _cGrAls == "SD2"
	_cQryB1 := " SELECT DISTINCT B1_XGRUPO "+ENTER
	_cQryB1 += " FROM  "+RetSqlName('SD2')+" SD2  "+ENTER
	_cQryB1 += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D2_COD AND B1_XGRUPO IN ('1','2','3') "+ENTER
	_cQryB1 += " WHERE SD2.D_E_L_E_T_ = '' AND D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA = '"+_cGrChav /*SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA*/+"' " +ENTER
	If Select("_TMA") > 0
		_TMA->(DbCloseArea())
	EndIf       	 
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryB1),"_TMA",.F.,.T.) 
	DbSelectArea("_TMA");_TMA->(DbGoTop())
	While _TMA->(!Eof())
		_cXGRUPO := _TMA->B1_XGRUPO
		IF _cXGRUPO $ "1|2|3" 
			EXIT			
		ENDIF
		_TMA->(DbSkip())
	EndDo
ElseIF  _cGrOpc $ '4' .and. _cGrAls == "SD1"
	_cQryB1 := " SELECT DISTINCT B1_XGRUPO "+ENTER
	_cQryB1 += " FROM  "+RetSqlName('SD1')+" SD1  "+ENTER
	_cQryB1 += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D1_COD AND B1_XGRUPO IN ('1','2','3') "+ENTER
	_cQryB1 += " WHERE SD1.D_E_L_E_T_ = '' AND D1_FILIAL = '"+xFilial('SD1')+"' AND D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA = '"+_cGrChav /*SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_CLIENTE+SF1->F1_LOJA*/+"' " +ENTER
	If Select("_TMA") > 0
		_TMA->(DbCloseArea())
	EndIf       	 
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryB1),"_TMA",.F.,.T.) 
	DbSelectArea("_TMA");_TMA->(DbGoTop())
	While _TMA->(!Eof())
		_cXGRUPO := _TMA->B1_XGRUPO
		IF _cXGRUPO $ "1|2|3" 
			EXIT			
		ENDIF
		_TMA->(DbSkip())
	EndDo                     		
ENDIF

RestArea(_aArGrp1); RestArea(_aArGrp2)
Return(_cXGRUPO)

*------------------------------------------*
Static Function xScanPedOff(_cPedido,_cNota,_aReProcPV)
*------------------------------------------*
//IF Empty(_cPedido) .And. Empty(_cNota) .And. 'ERRO LIBERAÇÃO PV' $ SZZ->ZZ_OBS
IF Empty(_cPedido) .OR. Empty(_cNota)
	_cQryScan := " SELECT MAX(C5_NUM) PEDSCAN, MAX(C5_SERIE+C5_NOTA) NOTASCAN FROM "+RetSqlName('SC5')+" SC5 WHERE SC5.D_E_L_E_T_='' AND C5_FILIAL='"+xFilial('SC5')+"' AND C5_XMOTOR = '"+SZZ->ZZ_PROCESS+"' AND C5_XMOTOID = '"+SZZ->ZZ_ID+"' "
	If Select("_SCN") > 0
		_SCN->(DbCloseArea())
	EndIf	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryScan),"_SCN",.F.,.T.)
		 
	DbSelectArea("_SCN");_SCN->(dbGoTop())
	IF !Empty(_SCN->PEDSCAN) .and. Empty(_cPedido) 
   		_cPedido:= _SCN->PEDSCAN
 	ENDIF
 	
 	IF !Empty(_SCN->NOTASCAN) .and. Empty(_cNota)
 		_cNota := _SCN->PEDSCAN
 	Endif 
 	
 	If !Empty(_cPedido) .or. !Empty(_cNota)
 		_aReProcPV := {.T.,SZZ->ZZ_NEXTPV}
 	Endif 
ENDIF

Return

*---------------------------------*
User Function xScanRastro(_xMotor)
*---------------------------------*
Local _lMotOk   := .T.  
Local _aTodos   := {}
Default _xMotor := ''

_cQrySts := " SELECT 'PEDIDO'   ORIGEM, C5_FILIAL FILIAL ,C5_NUM CHAVE, C5_XMOTOR MOTOR FROM "+RetSqlName('SC5')+" SC5 (NOLOCK) WHERE SC5.D_E_L_E_T_ = '' AND C5_XMOTOR = '"+_xMotor+"' "+ENTER
_cQrySts += " UNION ALL "+ENTER
_cQrySts += " SELECT 'ENTRADA'  ORIGEM, F1_FILIAL FILIAL ,F1_DOC CHAVE ,F1_XMOTOR MOTOR FROM "+RetSqlName('SF1')+" SF1 (NOLOCK) WHERE SF1.D_E_L_E_T_ = '' AND F1_XMOTOR = '"+_xMotor+"' "+ENTER
_cQrySts += " UNION ALL "+ENTER
_cQrySts += " SELECT 'OP'       ORIGEM, C2_FILIAL FILIAL, C2_NUM CHAVE, C2_XMOTOR MOTOR FROM "+RetSqlName('SC2')+" SC2 (NOLOCK) WHERE SC2.D_E_L_E_T_ = '' AND C2_XMOTOR = '"+_xMotor+"' "+ENTER
_cQrySts += " UNION ALL "+ENTER
_cQrySts += " SELECT 'SAIDA'    ORIGEM, F2_FILIAL FILIAL ,F2_DOC CHAVE ,F2_XMOTOR MOTOR FROM "+RetSqlName('SF2')+" SF2 (NOLOCK) WHERE SF2.D_E_L_E_T_ = '' AND F2_XMOTOR = '"+_xMotor+"' "+ENTER
_cQrySts += " UNION ALL "+ENTER
_cQrySts += " SELECT 'PRODUCAO' ORIGEM, D3_FILIAL FILIAL, D3_DOC CHAVE, D3_XMOTOR MOTOR FROM "+RetSqlName('SD3')+" SD3 (NOLOCK) WHERE SD3.D_E_L_E_T_ = '' AND D3_XMOTOR = '"+_xMotor+"' "+ENTER
If Select("_STS") > 0
	_STS->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQrySts),"_STS",.F.,.T.) 
DbSelectArea("_STS");_STS->(dbGoTop())
_lMotOk := !Empty(_STS->MOTOR)
While _STS->(!Eof())
	Aadd(_aTodos, {_STS->ORIGEM, _STS->FILIAL, _STS->CHAVE, _STS->MOTOR})
	_STS->(DbSkip())
EndDo

Return({_lMotOk, _aTodos})

*----------------------------------*
Static Function xTelaRastro(_xMotor)
*----------------------------------*
Local _aRastro  := U_xScanRastro(_xMotor) //RETORNA RASTRO DO MOTOR DE PROCESSO
Local _aLRastro := _aRastro[2]
Local _oRast, _oLRast

IF !Empty(_aRastro) 
	MsgInfo('Itens do motor não localizado !','Vazio')
	Return
EndIF

DEFINE MSDIALOG _oRast TITLE OemToAnsi("RASTRO MOTOR DE PROCESSO") FROM 000,000 TO 015,050
	@ 001,001 LISTBOX _oLRast FIELDS HEADER "ORIGEM","FILIAL","CHAVE","MOTOR",;
					COLSIZES 040,040,040,040;
					SIZE 200,110 OF _oRast PIXEL
	
	_oLRast:SetArray(_aLRastro)
	_oLRast:bLine := { || { _aLRastro[_oLRast:nAt,01] ,;
							_aLRastro[_oLRast:nAt,02] ,;
							_aLRastro[_oLRast:nAt,03] ,;
							_aLRastro[_oLRast:nAt,04] }}				                        	
ACTIVATE DIALOG _oRast CENTER

Return

*----------------------------------*
Static Function xExiProc(cAlias,aParam)
*----------------------------------*
	Local lRet := .F.
	Local cSql := ""
	
	If cALias == "SC5"
		cSql := " SELECT R_E_C_N_O_ RECC5 "
		cSql += " FROM "+RetSqlName(cALias)
		cSql += " WHERE C5_FILIAL = '"+xFIlial("SC5")+"' AND "
		cSql += " C5_CLIENTE = '"+aParam[1]+"' AND "
		cSql += " C5_LOJACLI = '"+aParam[2]+"' AND "
		cSql += " C5_XMOTOR = '"+aParam[3]+"' AND "
		cSql += " C5_XMOTOID = '"+aParam[4]+"' AND "
		cSql += " D_E_L_E_T_ = ' ' "
		
		If Select("_VLD") > 0
			_VLD->(DbCloseArea())
		EndIf       	 
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"_VLD",.F.,.T.)
		
		If !_VLD->(EoF())
			SC5->(DbGoTo(_VLD->RECC5))
			lRet := .T.
		Else
			lRet := .F.
		Endif
	EndIf
	
Return(lRet)
