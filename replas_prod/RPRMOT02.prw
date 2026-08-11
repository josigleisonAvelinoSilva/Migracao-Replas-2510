#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#INCLUDE "rwmake.ch"
#Include "Xmlxfun.ch"
#INCLUDE "ap5mail.ch"

#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  RPRMOT02   บ Autor ณ Totvs/Gustavo      บ Data ณ  23/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Motor de Processo                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Replas                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*--------------------*
User Function RPRMOT02
*--------------------*

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo       := ""
Local nLin         := 80

Local Cabec1       := "                                                                                [ MOTOR DE PROCESSO - REPLAS ]" 
	
Local Cabec2       := "          STATUS    I.D.   PROCESSO                                                  CHAVE          ORIGEM                        DESTINO                       ROTINA    OBSERVACAO" 
                     //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                     //         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180
                     
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "RPRMOT02" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RPRMOT02" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""
Private _cPerg := 'RPRMOT02'   

Private _cRecZZ := SZZ->(Recno())
Private _cRecZY := SZY->(Recno())

//---> REMOVIDO compatibiliza็ใo para versใo 12.1.25.
/*PutSx1(_cPerg,"01","Emissใo De       ","Emissใo De       ","Emissใo De       ","mv_ch01","D",08,00,00,"G","",""       ,"","","mv_par01","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"02","Emissใo Ate      ","Emissใo Ate      ","Emissใo Ate      ","mv_ch02","D",08,00,00,"G","",""       ,"","","mv_par02","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"03","Processo De:     ","Processo De:     ","Processo De      ","mv_ch03","C",06,00,00,"G","",,"","","mv_par03","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"04","Processo Ate:    ","Processo Ate:    ","Processo Ate     ","mv_ch04","C",06,00,00,"G","",,"","","mv_par04","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"05","Nota Fiscal De:  ","Nota Fiscal De:  ","Nota Fiscal De:  ","mv_ch05","C",09,00,00,"G","",,"","","mv_par05","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"06","Nota Fiscal Ate: ","Nota Fiscal Ate: ","Nota Fiscal Ate: ","mv_ch06","C",09,00,00,"G","",,"","","mv_par06","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"07","Serie De:        ","Serie De:        ","Serie De:        ","mv_ch07","C",03,00,00,"G","",,"","","mv_par07","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"08","Serie Ate:       ","Serie Ate:       ","Serie Ate:       ","mv_ch08","C",03,00,00,"G","",,"","","mv_par08","","","","","","","","","","","","","","","","")
PutSx1(_cPerg,"09","Imprime Parametros  ? ","Imprime Parametros  ? ","Imprime Parametros  ? ","mv_ch9","N",01,00,00,"C","","   ","","","mv_par09","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{''})*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(_cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,_cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private _cCodDe  := MV_PAR03
Private _cCodAte := MV_PAR04
Private _dDatDe  := MV_PAR01
Private _dDatAte := MV_PAR02

Private _cDocDe  := MV_PAR05
Private _cDocAte := MV_PAR06
Private _cSerDe  := MV_PAR07
Private _cSerAte := MV_PAR08  

Private _lImpParam  := MV_PAR09 == 2

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

DbSelectArea('SZZ'); SZZ->(DbGoTo(_cRecZZ))
DbSelectArea('SZY'); SZY->(DbGoTo(_cRecZY))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  23/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

_cQry := " SELECT ZZ_PROCESS, ZY_DESCOD ,ZZ_NOMEXEC, ZZ_DATA, "+ENTER
_cQry += "        ZZ_STATUS, ZZ_ID, ZZ_IDENT, ZZ_OCORREN, ZZ_CHAVE, ZZ_ORIGEM, ZZ_DESTINO, ZY_CODIGO, ZY_ROTINA, ZZ_OBS OBSERV, SZZ.R_E_C_N_O_ RECSZZ, SZY.R_E_C_N_O_ RECSZY "+ENTER
_cQry += " FROM "+RetSqlName('SZZ')+" SZZ  "+ENTER
_cQry += " INNER JOIN "+RetSqlName('SZY')+" SZY ON SZY.D_E_L_E_T_='' AND ZY_CODIGO = ZZ_CODEXEC AND ZY_SEQ=ZZ_ID "+ENTER
_cQry += " WHERE SZZ.D_E_L_E_T_='' AND ZZ_PROCESS BETWEEN '"+_cCodDe+"' AND '"+_cCodAte+"' AND ZZ_DATA BETWEEN '"+DtoS(_dDatDe)+"' AND '"+DtoS(_dDatAte)+"' "+ENTER
_cQry += "   AND ZZ_CHAVE BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"' "+ENTER
_cQry += "   AND ZY_SERIE BETWEEN '"+_cSerDe+"' AND '"+_cSerAte+"' "+ENTER
_cQry += " ORDER BY ZZ_PROCESS, ZZ_DATA "+ENTER
If Select("_STR") > 0	
	_STR->(DbCloseArea())
EndIf        
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"_STR",.F.,.T.)                        	
DbSelectArea("_STR")
_STR->(DBGOTOP())

_nRetG1 := Contar("_STR","!Eof()"); _STR->(DbGoTop())

SetRegua(_nRetG1)
_cPrcKey := ''

IF _lImpParam
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif	
	
	@ nLin,000 Psay __PrtThinLine()
	nLin++	                       
	//---> REMOVIDO compatibiliza็ใo para versใo 12.1.25.
	/*@ nLin,000 Psay 'IMPRESSรO DOS PARAMETROS DO RELATำRIO'
	nLin++	     
	@ nLin,000 Psay __PrtThinLine()
	nLin+=2
	DbSelectArea('SX1')
	IF SX1->(DbSeek(_cPerg, .T.))
		While SX1->(!Eof()) .And. AllTrim(SX1->X1_GRUPO) == _cPerg
			_cInfo := &('MV_PAR'+SX1->X1_ORDEM)
			
			@ nLin,010 Psay SX1->X1_PERGUNT
			
			IF SX1->X1_TIPO == 'N'
				_cInfo := cValToChar(_cInfo)
			elseif SX1->X1_TIPO == 'D'
				_cInfo := DtoC(_cInfo)		
			endif
			
			@ nLin,100 Psay _cInfo
					
			nLin++	     
			SX1->(DbSkip())
		ENDDo
	ENDIF*/
	nLin := 100
ENDIF
                     
While _STR->(!Eof())
	IncRegua()

	DbSelectarea('SZZ');SZZ->(DbGoTop());SZZ->(DbGoTo(_STR->RECSZZ))
	DbSelectarea('SZY');SZY->(DbGoTop());SZY->(DbGoTo(_STR->RECSZY))
	
   	If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   	Endif

   	//ณ Impressao do cabecalho do relatorio. . .                            
   	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   	Endif
   
	IF _cPrcKey <> _STR->ZZ_PROCESS
		nLin++
   		_cPrcKey := _STR->ZZ_PROCESS
   		nLin++
   		@nLin,000 PSay __PrtFatLine()
   		nLin++
   		@nLin,005 PSAY 'PROCESSO DE MOTOR: ' + _STR->ZZ_PROCESS
   		@nLin,050 PSAY 'TIPO PROCESSO: ' + _STR->ZY_DESCOD
   		@nLin,100 PSAY 'MATERIAL: ' + _STR->ZZ_NOMEXEC
   		@nLin,130 PSAY 'EMISSรO: ' + DtoC(StoD(_STR->ZZ_DATA))
   		
   		_aRetSTS := u_xScanRastro(_STR->ZZ_PROCESS)
   		@nLin,160 PSAY 'STATUS: ' + iif(!_aRetSTS[1],'MOTOR EXCLUIDO','ATIVO')
   		nLin++
   		@nLin,000 PSay __PrtFatLine()
   		nLin++
	EndIf    
	
   	@nLin,010 PSAY _STR->ZZ_STATUS
	@nLin,020 PSAY _STR->ZZ_ID
	@nLin,027 PSAY _STR->ZZ_IDENT
	//@nLin,038 PSAY _STR->ZZ_OCORREN
	@nLin,085 PSAY _STR->ZZ_CHAVE
	@nLin,100 PSAY _STR->ZZ_ORIGEM
	@nLin,130 PSAY _STR->ZZ_DESTINO
	@nLin,160 PSAY _STR->ZY_ROTINA

	nLinha:= MLCount(SZZ->ZZ_OBS,45)
	@nLin,170 PSAY MemoLine(SZZ->ZZ_OBS,45,1)

	nLin++    
	_STR->(DbSkip())	
EndDo                   	



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
