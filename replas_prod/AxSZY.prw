#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "rwmake.ch"

#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ AxSZ5   ºAutor  ³Meliora/Gustavo Oliveira ºData³ 19/04/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao SOP...                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Viskase                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*------------------*
User Function AxSZY
*------------------*
PRIVATE cCadastro := OemToAnsi("Parametros MOTOR DE PROCESSO") 
Private _cFilQry  := " ZY_FILIAL = '"+ xFilial("SZY") +"' And Left(ZY_SEQ,2) = '01' "
Private _cFilSZM  := ''

PRIVATE aCores 	:= {	{'SZY->ZY_MSBLQL == "2"', 'ENABLE'  },;
				 		{'SZY->ZY_MSBLQL == "1"', 'DISABLE' },;
				 		{'SZY->ZY_MSBLQL == "2" .AND. SZY->ZY_EXTAUTO == "E" ', 'BR_AMARELO'   } }

PRIVATE aRotina := { 	{OemToAnsi("Pesquisar") 	,"AxPesqui"  	,00,1	},;
						{OemToAnsi("Visual")		,"AxVisual"		,00,2	},;
						{OemToAnsi("Incluir")		,"u_AxZyExec(3)",00,3	},;
						{OemToAnsi("Alterar")		,"u_AxZyExec(4)",00,4	},;
						{OemToAnsi("Excluir")  		,"u_AxZyExec(5)",00,5	},;						
						{OemToAnsi("Legenda")   	,"u_xSZYLegen" 	,00,1	},;
						{OemToAnsi("@ Prod.Servico"),"u_xSZYCdServ"	,00,1	} }

Public _cGrupo := ''

//IF !xFilSBM(@_cFilSZY,@_cGrupo)
//	Return
//ENDIF

DbSelectArea('SZY'); SZY->(DbSetOrder(3)); SZY->(DbGoTop())

//SET FILTER TO &(_cFilSZM)      

SetKey( VK_F10, {|| XSCANDIR() })

mBrowse(06,01,22,75,"SZY",,,,,,aCores)
//mBrowse(06,01,22,75,"SZ3",,,,,,_aCores,,,,,,,,_cFilQry)

Return 

*-------------------------*
User Function AxZyExec(_nOpc)
*-------------------------*

Local _aInc        := {}
Local _aFlxProcess := Array(2,'')

Private _cIdOK    := AllTrim(GetMV('RP_CFGMOTO',.F.,'000000'))

IF !(__cUserID $ _cIdOK)
	MsgInfo('Usuário sem permissao na rotina!','Atenção')
	Return
ENDIF

IF _nOpc == 3
	IF xIncSZY(@_aInc,@_aFlxProcess)
		PUBLIC _AAXINC := Array(14,'') 
		_AAXINC[1] := _aInc[4]
		_AAXINC[2] := _aInc[5]
		_AAXINC[3] := _aInc[1]
		_AAXINC[4] := _aInc[2]
		_AAXINC[5] := _aInc[3]
		_AAXINC[6] := _aInc[9]
		_AAXINC[7] := _aInc[6]
		_AAXINC[8] := _aInc[7]
		_AAXINC[9] := _aInc[8]
		_AAXINC[10] := _aInc[10]
		_AAXINC[11] := _aInc[11]
		_AAXINC[12] := _aInc[12] 
		_AAXINC[13] := _aInc[13]		
		_AAXINC[14] := _aInc[14]
		AxInclui('SZY',SZY->(Recno()),3)
	ENDIF
ElseIF _nOpc == 4
	AxAltera('SZY',SZY->(Recno()),4)
ElseIF _nOpc == 5
	AxDeleta('SZY',SZY->(Recno()),5)
ENDIF


u_XSZYBLOQ()

Return

*----------------------*
User Function xSZYLegen
*----------------------*        
//BrwLegenda(OemToAnsi("MOTOR DE PROCESSO")  ,;
//						"LEGENDA", { {"ENABLE"  ,"Habiliado"},;
//									 {"DISABLE" ,"Bloqueado" }})									 									 									 
Return                 

*----------------------------*
Static Function xIncSZY(_aInc,_aFlxProcess)
*----------------------------*
Local _aInc         := Array(14,'')
Local _lInc    		:= .F.
Local _aRet    		:= {}  
Local _aParamBox 	:= {}
Local _aEmpresa		:= xLisSM0()
Local _aChkEmp		:= _aEmpresa[2]
Local _aTpMotor		:= {"BOPP","RESINA NASC","RESINA IMP"} 
Local _aRotina 		:= {'Doc. Entrada','Pedido de Venda'}  
Local _aTpDoc       := {'N=Normal','D=Devolução','B=Beneficiamento'}
Local _aDDsRot 		:= {	{'MATA103','SF1|SD1','Documento Entrada'},;
					  		{'MATA410','SC5|SC6','Pedido de Venda'}  }
Local _aRotExecAut := {{'1','MATA103'},{'2','MATA650'},{'3','MATA250'},{'4','MATA460'}}

Private _cCadastro := "Inclusao Cadastro de Motor"

xScamFluxo(@_aFlxProcess)

IF Empty(_aFlxProcess[1])
	Return
ENDIF

aAdd(_aParamBox,{9,"MOTOR DE PROCESSO - "+_aFlxProcess[1]+' '+_aFlxProcess[2],150,7,.T.})

aAdd(_aParamBox,{2,"EMPRESA",1,_aEmpresa[1],50,"",.T.})

aAdd(_aParamBox,{2,"Motor de Processo",1,_aTpMotor,50,".F.",.T.})
aAdd(_aParamBox,{2,"Processamento",1,_aRotina,50,"",.T.}) 
aAdd(_aParamBox,{2,"Tipo Documento",1,_aTpDoc,50,"",.T.}) 

aAdd(_aParamBox,{2,"DESTINO",1,_aEmpresa[1],50,"",.T.})

If ParamBox(_aParamBox,"Configuração",@_aRet)
	_lInc := .T.
	xIncAjust(@_aRet,_aEmpresa[1],_aTpMotor,_aRotina,_aTpDoc)
	
	_aInc[1] := Upper(_aChkEmp[_aRet[2]][2])
	_aInc[2] := Upper(_aChkEmp[_aRet[2]][3])
	_aInc[3] := Upper(_aChkEmp[_aRet[2]][4])
	
	_aInc[4] := _aFlxProcess[1]+cValToChar(_aRet[3]) //STRZERO(_aRet[3],6)
	_aInc[5] := Upper(_aTpMotor[_aRet[3]])
    
	_aInc[6] := Upper(AllTrim(_aDDsRot[_aRet[4]][1]))
	_aInc[7] := Upper(AllTrim(_aDDsRot[_aRet[4]][2]))
	_aInc[8] := Upper(AllTrim(_aDDsRot[_aRet[4]][3]))

	_aInc[10] := Upper(_aChkEmp[_aRet[6]][2])
	_aInc[11] := Upper(_aChkEmp[_aRet[6]][3])
	_aInc[12] := Upper(_aChkEmp[_aRet[6]][4])

	_aInc[13] := SubStr(Upper(_aTpDoc[_aRet[5]]),1,1)
			                             
	_aInc[9] := xSeqSZY({_aInc[1],_aInc[2],_aInc[4],_aInc[5]})	
	
	IF _aInc[9] == '010' //ALTERACAO DO NOME DA FUNCAO PARA SEQUENCIA 010, PORQUE É A ORIGEM DO PROCESSO
		IF (_nEx := aScan(_aRotExecAut,{|s| s[1]==Right(_aInc[4],1)}) ) > 0 //_aInc[4]
			_aInc[6] := _aRotExecAut[_nEx][2]	
		ENDIF
	ENDIF
	
	_aInc[14] := UPPER(_aFlxProcess[2])
Endif

Return(_lInc)

*---------------------*
Static Function xSeqSZY(_aTemp)
*---------------------*
Local _cSeq := '01'
//_cQry := "SELECT MAX(Left(ZY_SEQ,2)) MAXSEQ FROM "+RetSqlName('SZY')+" SZY WHERE SZY.D_E_L_E_T_= '' AND ZY_FILIAL = '"+xFilial('SZY')+"' AND ZY_EMPRESA = '"+_aTemp[1]+"' AND ZY_MFILIAL = '"+_aTemp[2]+"' AND ZY_CODIGO = '"+_aTemp[3]+"' "
//_cQry := "SELECT MAX(Left(ZY_SEQ,2)) MAXSEQ FROM "+RetSqlName('SZY')+" SZY WHERE SZY.D_E_L_E_T_= '' AND ZY_FILIAL = '"+xFilial('SZY')+"' AND ZY_EMPRESA = '"+cEmpAnt+"' AND ZY_MFILIAL = '"+cFilAnt+"' AND ZY_CODIGO = '"+_aTemp[3]+"' " 
_cQry := "SELECT MAX(Left(ZY_SEQ,2)) MAXSEQ FROM "+RetSqlName('SZY')+" SZY WHERE SZY.D_E_L_E_T_= '' AND ZY_FILIAL = '"+xFilial('SZY')+"' AND ZY_CODIGO = '"+_aTemp[3]+"' AND ZY_DESCRI = '"+_aTemp[4]+"' "
If Select("_WST") > 0
	_WST->(DbCloseArea())
EndIf
_cQry := ChangeQuery(_cQry)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_WST",.F.,.T.)
DbSelectArea("_WST")
IF !Empty(_WST->MAXSEQ)
	_cSeq := SOMA1(AllTrim(_WST->MAXSEQ))
ENDIF
	
Return(_cSeq+'0')

*----------------------*
Static Function xLisSM0
*----------------------*
Local _aLsM0   := {}
Local _aDDsEm0 := {}
//Local _nRecSmo := SM0->(Recno())

//---> REMOVIDO compatibilização para versão 12.1.25.
/*dbSelectArea("SM0")
SM0->(DbGotop())
While SM0->(!Eof()) 
	Aadd(_aLsM0,{Recno(),SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL})
	aADD(_aDDsEm0,SM0->M0_FILIAL)
	SM0->(dbSkip())
EndDo	
dbSelectArea("SM0")
SM0->(DbGoTo(_nRecSmo))*/

//Capturar o grupo de empresas --> FWGrpCompany()
//Capturar todas as filiais    --> FwAllFilial()
//Capturar o nome das filiais  --> FwFilialName()
cCompany := FWGrpCompany()
aFil := FwAllFilial(,,cCompany)
For nI := 1 To Len( aFil )
	AAdd( _aLsM0, { nI, cCompany, aFil[ nI ], FwFilialName( cCompany, aFil[ nI ], 1 ) } )
	AAdd( _aDDsEm0, aFil[ nI ] )
Next nI

Return({_aDDsEm0,_aLsM0})

*-----------------------*
User Function zSZYDLFOR
*-----------------------* 
Local _aRet  := {}
Local _lClFt := .T.
Local _cAls  := M->ZY_TIPOCF
Local _aParam:= {}

M->ZY_CLIFOR := CriaVar('ZY_CLIFOR')
M->ZY_LOJA   := CriaVar('ZY_LOJA')
M->ZY_NOME   := CriaVar('ZY_NOME')

aAdd(_aParam,{1,iIF(_cAls=='SA1','CLIENTE','FORNECEDOR'),Space(08),"","",_cAls,"",0,.T.}) // Tipo caractere

If ParamBox(_aParam,"Configuração",@_aRet)
	_lClFt := .T.
	M->ZY_CLIFOR := (_cAls)->&(RIGHT(_cAls,2)+'_COD')
	M->ZY_LOJA   := (_cAls)->&(RIGHT(_cAls,2)+'_LOJA')
	M->ZY_NOME   := (_cAls)->&(RIGHT(_cAls,2)+'_NOME')
ENDIF

Return(_lClFt)

*--------------------*
User Function XSZYBLOQ
*--------------------*
Local _nRecSZY := SZY->(Recno())
Local _cCodMt  := SZY->ZY_CODIGO + SZY->ZY_EMPRESA + SZY->ZY_MFILIAL
Local _cSeqSts := SZY->ZY_MSBLQL

IF Left(SZY->ZY_SEQ,2) == '01'
/*
	IF SZY->ZY_MSBLQL == '1'
		MsgInfo('O bloqueio da sequencia 01 desabilita todos os processos!',"Acesso a Rotina","INFO")
	ENDIF
	
	DbSelectArea('SZY');SZY->(DbSetOrder(1));SZY->(DbGoTo(_nRecSZY))
	IF SZY->(DbSeek(xFilial('SZY')+_cCodMt))
		WHILE SZY->(!EOF()) .And. xFilial('SZY')+SZY->ZY_CODIGO + SZY->ZY_EMPRESA + SZY->ZY_MFILIAL == xFilial('SZY')+_cCodMt     
			IF RecLock('SZY',.F.)
				Replace SZY->ZY_MSBLQL With _cSeqSts
			ENDIF
			SZY->(DbSkip())
		EndDo
	ENDIF
*/	
ENDIF

DbSelectArea('SZY');SZY->(DbGoTo(_nRecSZY))

Return  
*--------------------------------------------------------------*
Static Function xIncAjust(_aRet,_aTEMP1,_aTEMP2,_aTEMP3,_aTEMP4) // (@_aRet,_aEmpresa[1],_aTpMotor,_aRotina)
*--------------------------------------------------------------*
Local _nj
Local _aArr := {}

For _nJ:=2 To Len(_aRet)
	IF ValType(_aRet[_nJ]) == 'C'
		IF _nJ == 2 .Or. _nJ == 6
			_aArr := aClone(_aTEMP1)	 
		ElseIF _nJ == 3 
	   		_aArr := aClone(_aTEMP2)
		ElseIF _nJ == 4 
			_aArr := aClone(_aTEMP3)					
		ElseIF _nJ == 5 
			_aArr := aClone(_aTEMP4)
		endif
		_aRet[_nJ] := aScan(_aArr,_aRet[_nJ])
	ENDIF
Next _nJ

Return

*--------------------*
User Function xSZYNext
*--------------------*
Local _lRetNxt := .T. 
_cQry := " SELECT DISTINCT ZY_PROXIMO EXTSEQ, ZY_DESCUSR DESCUSR, ZY_SEQ SEQ "+ENTER
_cQry += "  FROM "+RetSqlName('SZY')+" SZY (nolock)      "+ENTER
_cQry += "   WHERE SZY.D_E_L_E_T_= ''                    "+ENTER
_cQry += "     AND ZY_FILIAL     = '"+xFilial('SZY') +"' "+ENTER
_cQry += "     AND ZY_DESCRI     = '"+M->ZY_DESCRI   +"' "+ENTER
_cQry += "     AND ZY_CODIGO     = '"+M->ZY_CODIGO   +"' "+ENTER
_cQry += "     AND ZY_EMPRESA    = '"+cEmpAnt        +"' "+ENTER
_cQry += "     AND ZY_MFILIAL    = '"+cFilAnt        +"' "+ENTER
_cQry += "     AND ZY_PROXIMO    = '"+M->ZY_PROXIMO  +"' "+ENTER
If Select("_TMY") > 0
	_TMY->(DbCloseArea())
EndIf       	 
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_TMY",.F.,.T.) 
DbSelectArea("_TMY");_TMY->(dbGoTop())
_lRetNxt := Empty(_TMY->EXTSEQ)   

IF !_lRetNxt
	MsgInfo('Processo já utilizado:'+ENTER+ENTER+'Sequencia: '+_TMY->SEQ+' - '+aLLtRIM(_TMY->DESCUSR),'Atenção')	
ENDIF

Return(_lRetNxt)

*--------------------------------------*
Static Function xScamFluxo(_aFlxProcess) 
*--------------------------------------*
Local _aPFlux   := {} 
Local _aRetFlux := {}
Local _aTpFluxo	:= {"Remessa Material","Gera Ordem Prod","Produção da OP","Faturamento"} 
aAdd(_aPFlux,{9,"MOTOR DE PROCESSO",150,7,.T.})

aAdd(_aPFlux,{9,"Fluxo de Processamento Integrado",150,7,.T.})

aAdd(_aPFlux,{2,"Motor de Processo",,_aTpFluxo,50,"",.T.})

If !ParamBox(_aPFlux,"Configuração",@_aRetFlux)   
  	Return
ENDIF 
_aFlxProcess[1] := cValToChar(aScan(_aTpFluxo,_aRetFlux[3]))+Replicate('0',4)//StrZero(aScan(_aTpFluxo,_aRetFlux[3]),6)
_aFlxProcess[2] := _aRetFlux[3]
Return

*-----------------------*
User Function xSZYCdServ
*-----------------------*
Local _cPerg      := 'xSZYCdServ'                                                     
local _aParamSX6 := {{'RP_CODSERV','C','Produto de Servico (Faturamento)','SRVCSE80E'}}//AllTrim(GetMV('RP_CODSERV',.F.'SRVCSER80E'))
Local _nF

//---> REMOVIDO compatibilização para versão 12.1.25.
//xCriaX6(@_aParamSX6)

//---> REMOVIDO compatibilização para versão 12.1.25.
//PutSx1(_cPerg,"01","Produto de Serviço (fatura)","Produto de Serviço (fatura)","Produto de Serviço (fatura)","mv_ch1","C",15,00,00,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","",{'Produto Fatura como Serviço'})
Pergunte(_cPerg,.F.)

//---> REMOVIDO compatibilização para versão 12.1.25.
//xCriaX1(@_aParamSX6,_cPerg)
	
IF Pergunte(_cPerg,.T.)
	For _nF:= 1 To Len(_aParamSX6)
		PutMV(_aParamSX6[_nF][1], AllTrim(MV_PAR01))
	Next _nF
	MsgInfo('Parametros alterados com sucesso!','Atencao')
ENDIF

Return                             

*---------------------------------*
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function xCriaX6(_aParamSX6) 
*---------------------------------*
Local _nF  

For _nF:=1 To Len(_aParamSX6)
	DbSelectArea("SX6");SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(xFilial("SX6")+_aParamSX6[_nF][1]))
		IF 	RecLock("SX6",.T.)
				Replace SX6->X6_FIL     With xFilial("SX6")
				Replace SX6->X6_VAR     With _aParamSX6[_nF][1]
				Replace SX6->X6_TIPO    With _aParamSX6[_nF][2]
				Replace SX6->X6_DESCRIC With _aParamSX6[_nF][3]
				Replace SX6->X6_DSCSPA  With SX6->X6_DESCRIC
				Replace SX6->X6_DSCENG  With SX6->X6_DESCRIC
				Replace SX6->X6_DESC1   With _aParamSX6[_nF][3]
				Replace SX6->X6_DSCSPA1 With SX6->X6_DESC1
				Replace SX6->X6_DSCENG1 With SX6->X6_DESC1
				Replace SX6->X6_DESC2   With _aParamSX6[_nF][3]
				Replace SX6->X6_DSCSPA2 With SX6->X6_DESC2
				Replace SX6->X6_DSCENG2 With SX6->X6_DESC2
				Replace SX6->X6_CONTEUD With _aParamSX6[_nF][4]
				Replace SX6->X6_CONTSPA With SX6->X6_CONTEUD
				Replace SX6->X6_CONTENG With SX6->X6_CONTEUD
				Replace SX6->X6_PROPRI  With "U"
				Replace SX6->X6_PYME    With ""
			SX6->(MsUnLock())
		EndIF
	EndIf
Next _nF

Return*/

*---------------------------------*
//---> REMOVIDO compatibilização para versão 12.1.25.
/*Static Function xCriaX1(_aParamSX6,_cPerg) 
*---------------------------------*
Local _nF  
For _nF:=1 To Len(_aParamSX6)
	DbSelectArea("SX1");SX1->(DbSetOrder(1))
	If 	SX1->(DbSeek(_cPerg+StrZero(_nF,2)))
		IF 	RecLock("SX1", .F.)  
	   			Replace SX1->X1_CNT01 With GetMV(_aParamSX6[_nF][1],.F.,_aParamSX6[_nF][4])
	   		SX1->(MsUnlock())
		EndIf
	EndIf
Next _nF
Return*/

*----------------------*
Static Function XSCANDIR
*----------------------*
Local cIniFile  := GetADV97()                                                      
Local _cNameDir := AllTrim(GetMV('CN_SQLDIRT',.F.,'SQL_QRY'))+iIF(Right(_cNameDir,1)<>'\','\','')
Local _cDirArq  := GetPvProfString(GetEnvServer(), "StartPath","ERROR", cIniFile )+_cNameDir
Local _cFile    := ''
Local _aPBox    := {}
Local _aRRox    := {}
Local cFileTXT  := ''
Local nHandle   := 0 

MakeDir(_cDirArq)
	
           

IF Empty(cFileTXT)
	//_cPath := cGetFile( "Diretório Importação XML: | ",OemToAnsi("Selecione Diretorio"), ,"" ,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)
	aADD(_aPBox,{6,'Diretório Arquivo Texto:', Space(50),"","","",50,.F.,"Arquivos TXT |*.TXT"})
	If !ParamBox( _aPBox, "Parâmetros" ,@_aRRox )  			
		Return
	ENDIF
	cFileTXT := AllTrim(_aRRox[1])
	
	_aTemp  := Separa(_cLocal,"\",.T.)
ENDIF

IF !Empty(cFileTXT)
	
	nhandle := ft_fuse( cFileTXT )
	If nhandle >= 0                         
		ft_fuse()
		IF FILE(cFileTXT)
			_cFile := cFileTXT	
			_cFile := _aTemp[Len(_aTemp)]	
			CpyT2S(cFileTXT,_cDirArq,.F.)
			fERASE(cFileTXT)
		ENDIF
	Else
		Alert("Falha ao abrir o arquivo!!")
	Endif
endif 

ReadDir(_cFile)

return nil

*---------------------*
Static Function ReadDir(_cFile)
*---------------------* 
Local _cQryTXT  := ''
Local cIniFile  := GetADV97()                                                      
Local _cNameDir := AllTrim(GetMV('CN_SQLDIRT',.F.,'SQL_QRY'))+iIF(Right(_cNameDir,1)<>'\','\','')
Local _cDirArq  := GetPvProfString(GetEnvServer(), "StartPath","ERROR", cIniFile )+_cNameDir

//_cQryTXT := MemoRead(_cDirArq+_cFile)
If (nHandle:= FT_FUse( _cFile )) == -1 
	MsgInfo('Arquivo nao pode aberto!'+Chr(13)+Chr(10)+_cFile,'Atencao')
Else	
	//conta os registros
	ProcRegua( FT_FLASTREC() ) 
	IncProc("Levantando Informações")
		
	FT_FGotop()
	While ! FT_FEof()             
		_cQryTXT += UPPER(FT_FReadLN())   		                               
		FT_FSkip()
	Enddo
EndIF

Alert(_cQryTXT)

Return			
