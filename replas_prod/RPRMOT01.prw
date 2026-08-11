#INCLUDE "rwmake.ch"

#DEFINE  ENTER CHR(13)+CHR(10)   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ RPRMOT01  º Autor ³ Totvs/Gustavo     º Data ³  11/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Remessa e Retorno de Mercadoria               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ REPLAS                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*--------------------*
User Function RPRMOT01
*--------------------*
Private cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := "de acordo com os parametros informados pelo usuario."
Private cDesc3         := "Movimentaçao de Mercadoria - Motor de Processo"
Private cPict          := ""
Private titulo       := ""
Private nLin         := 80
Private Cabec1       := "            TIPO            EMISSAO      N.FISCAL   SER. QUANTID.   VL.TOTAL   CUSTO       ARMZ   TES    DESCRICAO"
//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                              10        20        30        40        50        60        70        80        90       100       110       120
Private Cabec2       := ""
Private imprime      := .T.
Private aOrd         := {}     

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "RPRMOT01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RPRMOT01" // Coloque aqui o nome do arquivo usado para impressao em disco
Private _cPerg       := "PRMOTR01" 

Private cString := "SA1"

//---> REMOVIDO compatibilização para versão 12.1.25.
/*PutSx1(_cPerg,"01","Produto De ?          ","Maquina De ?          ","Maquina De?           ","mv_ch1","C",15,00,00,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","",{'Produto Inicial'})
PutSx1(_cPerg,"02","Produto Até?          ","Maquina Até?          ","Maquina Até?          ","mv_ch2","C",15,00,00,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","",{'Produto Final'})
PutSx1(_cPerg,"03","N.Fiscal De ?         ","N.Fiscal De ?         ","N.Fiscal De?          ","mv_ch3","C",09,00,00,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","",{'Nota Inicial'})
PutSx1(_cPerg,"04","N.Fiscal Até?         ","N.Fiscal Até?         ","N.Fiscal Até?         ","mv_ch4","C",09,00,00,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{'Nota Final'})
PutSx1(_cPerg,"05","Serie De ?            ","Serie De ?            ","Serie De ?            ","mv_ch5","C",03,00,00,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{'Serie Inicial'})
PutSx1(_cPerg,"06","Serie Ate ?           ","Serie Ate ?           ","Serie Ate ?           ","mv_ch6","C",03,00,00,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{'Serie Final'})
PutSx1(_cPerg,"07","Data de Emissao De ?  ","Data de Emissao De ?  ","Data de Emissao De ?  ","mv_ch7","D",08,00,00,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{'Data inicial'})
PutSx1(_cPerg,"08","Data de Emissao Ate ? ","Data de Emissao Ate ? ","Data de Emissao Ate ? ","mv_ch8","D",08,00,00,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{'Data final'})
PutSx1(_cPerg,"09","Cliente Remessa ?     ","Cliente Remessa ?     ","Cliente Remessa ?     ","mv_ch9","C",08,00,00,"G","","SA1","","","mv_par09","","","","","","","","","","","","","","","","",{'Cliente Inicial'})
PutSx1(_cPerg,"10","Loja Remessa ?        ","Loja Remessa ?        ","Loja Remessa ?        ","mv_chA","C",04,00,00,"G","",""   ,"","","mv_par10","","","","","","","","","","","","","","","","",{'Loja Inicial'})
PutSx1(_cPerg,"11","TES De ?              ","TES De ?              ","TES De?               ","mv_chB","C",03,00,00,"G","","SF4","","","mv_par11","","","","","","","","","","","","","","","","",{'TES Inicial'})
PutSx1(_cPerg,"12","TES Até?              ","TES Até?              ","TES Até?              ","mv_chC","C",03,00,00,"G","","SF4","","","mv_par12","","","","","","","","","","","","","","","","",{'TES Final'})
PutSx1(_cPerg,"13","Tipo de Movimentacao? ","Tipo de Movimentacao? ","Tipo de Movimentacao? ","mv_chD","N",01,00,00,"C","","   ","","","mv_par13","Normal","Normal","Normal","","Beneficiamento","Beneficiamento","Beneficiamento","Ambos","Ambos","Ambos","","","","","","",{'Normal, Beneficiamento ou Ambos'})   
PutSx1(_cPerg,"14","Imprime Parametros  ? ","Imprime Parametros  ? ","Imprime Parametros  ? ","mv_chE","N",01,00,00,"C","","   ","","","mv_par14","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{''})*/

Private _cProdDe  := MV_PAR01
Private _cProdAte := MV_PAR02

Private _cNotaDe  := MV_PAR03
Private _cNotaAte := MV_PAR04
Private _cSeriDe  := MV_PAR05
Private _cSeriAte := MV_PAR06

Private _cEmisDe  := MV_PAR07
Private _cEmisAte := MV_PAR08

Private _cClieDe  := MV_PAR09
Private _cLojaDe  := MV_PAR10
Private _cClieAte := _cClieDe
Private _cLojaAte := _cLojaDe

Private _cTESDe   := MV_PAR12
Private _cTESAte  := MV_PAR13

Private _cTipoNF  := MV_PAR14  

Private _aProds := {}  

Private ARR_PROD := 2
Private ARR_TIPO := 2 
Private ARR_DADOS := 2

//³ Monta a interface padrao com o usuario... 
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

//³ Processamento. RPTSTATUS monta janela com a regua de processamento.
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ RPRMOT01  º Autor ³ Totvs/Gustavo     º Data ³  11/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Remessa e Retorno de Mercadoria               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ REPLAS                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*--------------------------------------------------*
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
*--------------------------------------------------*
Local nOrdem, _nP

Private _cProdDe  := MV_PAR01
Private _cProdAte := MV_PAR02

Private _cNotaDe  := MV_PAR03
Private _cNotaAte := MV_PAR04
Private _cSeriDe  := MV_PAR05
Private _cSeriAte := MV_PAR06

Private _cEmisDe  := MV_PAR07
Private _cEmisAte := MV_PAR08

Private _cClieDe  := MV_PAR09
Private _cLojaDe  := MV_PAR10
Private _cClieAte := _cClieDe
Private _cLojaAte := _cLojaDe

Private _cTESDe   := MV_PAR11
Private _cTESAte  := MV_PAR12

Private _cTipoNF  := MV_PAR13

Private _lImpParam  := MV_PAR14 == 2

_cQryRMT := " SELECT AAA.*, B2_CM1 CUSTO, LTRIM(RTRIM(X5_DESCRI)) CFOP, AAA.TES, F4_TEXTO DESC_TES "+ENTER
_cQryRMT += " FROM ( "+ENTER
_cQryRMT += "       SELECT '1REMESSA' TIPOREL, D2_EMISSAO EMISSAO,  "+ENTER
_cQryRMT += "       		CASE WHEN D2_TIPO='B' THEN A2_CGC               ELSE A1_CGC               END CGC_CLIFOR,		 "+ENTER
_cQryRMT += "       		CASE WHEN D2_TIPO='B' THEN 'BENEFICIAMENTO'     ELSE 'NORMAL'             END TIPO, 	 "+ENTER
_cQryRMT += " 	         	D2_DOC NOTA, D2_SERIE SERIE, D2_ITEM ITEM, D2_COD PRODUTO, D2_CF CODFIS, D2_QUANT QUANT, D2_TOTAL TOTAL, D2_LOCAL ARMAZEM, D2_TES TES "+ENTER
_cQryRMT += "         FROM "+RetSqlName('SD2')+" SD2 (NOLOCK) "+ENTER
_cQryRMT += "         LEFT JOIN "+RetSqlName('SA1')+" SA1 ON SA1.D_E_L_E_T_='' AND A1_FILIAL='"+xFilial('SA1')+"' AND A1_COD=D2_CLIENTE AND A1_LOJA=D2_LOJA "+ENTER
_cQryRMT += "         LEFT JOIN "+RetSqlName('SA2')+" SA2 ON SA2.D_E_L_E_T_='' AND A2_FILIAL='"+xFilial('SA2')+"' AND A2_COD=D2_CLIENTE AND A2_LOJA=D2_LOJA "+ENTER
_cQryRMT += "            WHERE SD2.D_E_L_E_T_='' AND D2_FILIAL = '"+xFilial('SD2')+"' "+ENTER
IF _cTipoNF == 1
	_cQryRMT += "              AND D2_TIPO    IN ('N') "+ENTER
ELSEIF _cTipoNF == 2
	_cQryRMT += "              AND D2_TIPO    IN ('B') "+ENTER
ELSE 
	_cQryRMT += "              AND D2_TIPO    IN ('B','N') "+ENTER
ENDIF
_cQryRMT += "              AND D2_DOC     BETWEEN '"+_cNotaDe+"' AND '"+_cNotaAte+"' "+ENTER 
_cQryRMT += "              AND D2_SERIE   BETWEEN '"+_cSeriDe+"' AND '"+_cSeriAte+"'  "+ENTER
_cQryRMT += "              AND D2_EMISSAO BETWEEN '"+DtoS(_cEmisDe)+"' AND '"+DtoS(_cEmisAte)+"'  "+ENTER
_cQryRMT += "              AND D2_TES     BETWEEN '"+_cTESDe+"' AND '"+_cTESAte+"'  "+ENTER
_cQryRMT += "              AND CASE WHEN D2_TIPO='B' THEN A2_CGC  ELSE A1_CGC END IN (SELECT DISTINCT A1_CGC CNPJ  "+ENTER
_cQryRMT += " 													              			FROM "+RetSqlName('SA1')+" CGC  "+ENTER
_cQryRMT += " 																              WHERE CGC.D_E_L_E_T_='' "+ENTER 
_cQryRMT += " 																	            AND CGC.A1_FILIAL='"+xFilial('SA1')+"'  "+ENTER
_cQryRMT += " 																	            AND CGC.A1_COD  BETWEEN '"+_cClieDe+"' AND '"+_cClieAte+"'  "+ENTER
_cQryRMT += " 																	            AND CGC.A1_LOJA BETWEEN '"+_cLojaDe+"' AND '"+_cLojaAte+"'  "+ENTER
_cQryRMT += " 															 ) "+ENTER
_cQryRMT += "              AND D2_COD     BETWEEN '"+_cProdDe+"' AND '"+_cProdAte+"' "+ENTER
_cQryRMT += "  "+ENTER
_cQryRMT += " UNION ALL "+ENTER
_cQryRMT += "  "+ENTER
_cQryRMT += "      SELECT '2RETORNO' TIPOREL, D1_EMISSAO EMISSAO,  "+ENTER
_cQryRMT += " 		      CASE WHEN D1_TIPO='B' THEN A1_CGC ELSE A2_CGC END CGC_CLIFOR, "+ENTER
_cQryRMT += " 		      CASE WHEN D1_TIPO='B' THEN 'BENEFICIAMENTO' ELSE 'NORMAL' END TIPO,	 "+ENTER
_cQryRMT += " 		      D1_DOC NOTA, D1_SERIE SERIE, D1_ITEM ITEM ,D1_COD PRODUTO, D1_CF CODFIS, D1_QUANT QUANT, D1_TOTAL TOTAL, D1_LOCAL ARMAZEM, D1_TES TES "+ENTER
_cQryRMT += "        FROM "+RetSqlName('SD1')+" SD1 (NOLOCK)  "+ENTER
_cQryRMT += "        LEFT JOIN "+RetSqlName('SA1')+" SA1 ON SA1.D_E_L_E_T_='' AND A1_FILIAL='"+xFilial('SA1')+"' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA "+ENTER
_cQryRMT += "        LEFT JOIN "+RetSqlName('SA2')+" SA2 ON SA2.D_E_L_E_T_='' AND A2_FILIAL='"+xFilial('SA2')+"' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA "+ENTER
_cQryRMT += "          WHERE SD1.D_E_L_E_T_='' AND D1_FILIAL='"+xFilial('SD1')+"' "+ENTER
IF _cTipoNF == 1
	_cQryRMT += "              AND D1_TIPO    IN ('N') "+ENTER
ELSEIF _cTipoNF == 2
	_cQryRMT += "              AND D1_TIPO    IN ('B') "+ENTER
ELSE 
	_cQryRMT += "              AND D1_TIPO    IN ('B','N') "+ENTER
ENDIF
_cQryRMT += "            AND D1_DOC     BETWEEN '"+_cNotaDe+"' AND '"+_cNotaAte+"' "+ENTER 
_cQryRMT += "            AND D1_SERIE   BETWEEN '"+_cSeriDe+"' AND '"+_cSeriAte+"'  "+ENTER
_cQryRMT += "            AND D1_EMISSAO BETWEEN '"+DtoS(_cEmisDe)+"' AND '"+DtoS(_cEmisAte)+"'  "+ENTER
_cQryRMT += "            AND D1_TES     BETWEEN '"+_cTESDe+"' AND '"+_cTESAte+"'  "+ENTER
_cQryRMT += "            AND CASE WHEN D1_TIPO='B' THEN A1_CGC ELSE A2_CGC END  IN (SELECT DISTINCT A1_CGC CNPJ  "+ENTER
_cQryRMT += " 																          FROM "+RetSqlName('SA1')+" CGC  "+ENTER
_cQryRMT += " 																            WHERE CGC.D_E_L_E_T_=''  "+ENTER
_cQryRMT += " 																	          AND CGC.A1_FILIAL='"+xFilial('SA1')+"'  "+ENTER
_cQryRMT += " 																	          AND CGC.A1_COD  BETWEEN '"+_cClieDe+"' AND '"+_cClieAte+"'  "+ENTER
_cQryRMT += " 																	          AND CGC.A1_LOJA BETWEEN '"+_cLojaDe+"' AND '"+_cLojaAte+"'  "+ENTER
_cQryRMT += " 															 ) "+ENTER
_cQryRMT += "            AND D1_COD     BETWEEN '"+_cProdDe+"' AND '"+_cProdAte+"' "+ENTER
_cQryRMT += " ) AAA "+ENTER
_cQryRMT += "   INNER JOIN "+RetSqlName('SB2')+" SB2 ON SB2.D_E_L_E_T_='' AND B2_FILIAL='"+xFilial('SB2')+"' AND B2_COD=AAA.PRODUTO AND B2_LOCAL=AAA.ARMAZEM "+ENTER
_cQryRMT += "   LEFT  JOIN "+RetSqlName('SX5')+" SX5 ON SX5.D_E_L_E_T_='' AND X5_TABELA='13' AND X5_CHAVE = AAA.CODFIS "+ENTER
_cQryRMT += "   INNER JOIN "+RetSqlName('SF4')+" SF4 ON SF4.D_E_L_E_T_='' AND F4_FILIAL='"+xFilial('SF4')+"' AND F4_CODIGO = AAA.TES "+ENTER
_cQryRMT += " ORDER BY 3,8,1,2,5,6,7 "+ENTER

IF Select('_TRB') > 0
	_TRB->(DbCloseArea())
ENDIF
DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQryRMT), "_TRB", .F., .T.)    
DbSelectArea('_TRB');_TRB->(DBGoTop())
_nMax := Contar('_TRB',"!Eof()"); _TRB->(DbGoTop())

SetRegua(_nMax)

While _TRB->(!Eof())
	IncRegua()

	_aNewProd := {{'REMESSA',{}},{'RETORNO',{}}}	
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   IF (_nPosCGC := Ascan(_aProds,{|S| S[1]==_TRB->CGC_CLIFOR})) == 0
	   aADD(_aProds,{_TRB->CGC_CLIFOR,{_TRB->PRODUTO+'|0|0', _aNewProd}})
	   _nPosCGC   := len(_aProds)
   ENDIF   
   _aTempPROD := aClone({_aProds[_nPosCGC][ARR_PROD]})

   IF ( _nPosPROD := Ascan(_aTempPROD,{|S| AllTrim(_TRB->PRODUTO) $ AllTrim(S[1]) })) == 0
	   aADD(_aTempPROD,{_TRB->PRODUTO+'|0|0', _aNewProd})
	   _nPosPROD := len(_aProds)
   ENDIF
   
   _aArrType := aClone(_aTempPROD[_nPosPROD][ARR_TIPO])
   IF (_nPosTIPO := aScan(_aArrType,{|P| P[1] $ AllTrim(_TRB->TIPOREL)  })) > 0
	   AAdd( _aProds[_nPosCGC][ARR_PROD][ARR_TIPO][_nPosTIPO][ARR_DADOS], {_TRB->TIPO, _TRB->EMISSAO, _TRB->NOTA, _TRB->SERIE, _TRB->QUANT, _TRB->TOTAL, _TRB->CUSTO, _TRB->ARMAZEM, _TRB->TES, _TRB->DESC_TES})   

	   //CARREGA DADOS DE TOTAIS - PRODUTO
	   _nPPrdArr := 1 //posicao fixa do produto no array
	   //_aSepVAL := Separa(_aProds[_nPosCGC][ARR_PROD][_nPosPROD],'|')
	   _aSepVAL := Separa(_aProds[_nPosCGC][ARR_PROD][_nPPrdArr],'|')
	   _nTRem := VAl(_aSepVAL[2]) + iIF('REMES'$_TRB->TIPOREL,_TRB->QUANT,0)
	   _nTRet := VAl(_aSepVAL[3]) + iIF('RETOR'$_TRB->TIPOREL,_TRB->QUANT,0)
	   _aProds[_nPosCGC][ARR_PROD][_nPosPROD] := _aSepVAL[1]+'|'+cValToChar(_nTRem)+'|'+cValToChar(_nTRet)
   Else 
   		_cErr += 'Tipo nao localizado: '+_TRB->TIPOREL+ENTER
   ENDIF
     
   _aTempPROD:= {}; _aArrType:={}
        
	_TRB->(DbSkip())
EndDo             

IF LEN(_aProds) > 0
	Processa({|| IMPMT01(@_aProds,@nLin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) },'[ Movimentaçao de Mercadorias ]')
ENDIF

//³ Finaliza a execucao do relatorio...                                 
SET DEVICE TO SCREEN

//³ Se impressao em disco, chama o gerenciador de impressao...         
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return                          
*------------------------------*
Static Function IMPMT01(_aProds,nLin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
*------------------------------*
Local _nQtdReg := 0 
Local _nP, _nA, _nB, _nC, _nD, _nY
ProcRegua(Len(_aProds))

IF _lImpParam
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif	
	
	@ nLin,000 Psay __PrtThinLine()
	nLin++	                       
	//---> REMOVIDO compatibilização para versão 12.1.25.
	/*@ nLin,000 Psay 'IMPRESSÃO DOS PARAMETROS DO RELATÓRIO'
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

For _nY:=1 To Len(_aProds)
	_nQtdReg++

   	If nLin > 55
      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      	nLin := 8
   	Endif	
          
	//[QUADRO 001]_________________________________________DADOS DE IMPRESAO DO CLIENTE 
	_aDDsCLI := _aProds[_nY]
	DbSelectArea('SA1');SA1->(DbSetOrder(3));SA1->(DbGoTop());DbSelectArea('SA2');SA2->(DbSetOrder(3));SA2->(DbGoTop())

	SA1->(DbSeek(xFilial('SA1')+_aDDsCLI[1]))
	IncProc('['+StrZero(_nQtdReg,5)+'] Saving... '+SA1->A1_NOME)
	
	@ nLin,000 Psay __PrtThinLine()
	nLin++
	@ nLin,000 Psay 'CLIENTE / FORNECEDOR...: '+SA1->A1_NOME
	nLin++
	@ nLin,000 Psay __PrtThinLine()
	nLin++
	
	For _nA:=1 To Len(_aDDsCLI[ARR_PROD])

	   	If nLin > 55
	      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      	nLin := 8
	   	Endif	
	   	
		IF _nA == 1 
			//[QUADRO 002]_________________________________________DADOS DE IMPRESAO DO CLIENTE
			DbSelectArea('SB1');SB1->(DbSetOrder(1));SB1->(DbGoTop())
			_aSepCLI := Separa(_aDDsCLI[ARR_PROD][1],'|')
			SB1->(DbSeek(xFilial('SB1')+_aDDsCLI[ARR_PROD][1]))					
			@ nLin,005 Psay 'PRODUTO: '+SB1->B1_COD +' - '+SB1->B1_DESC
			@ nLin,075 Psay 'REMESSA:'+TransForm(Val(_aSepCLI[2]),'@e 9,999,999')
			@ nLin,095 Psay 'RETORNO:'+TransForm(Val(_aSepCLI[3]),'@e 9,999,999')
			@ nLin,115 Psay 'SALDO:'+TransForm(Val(_aSepCLI[2])-Val(_aSepCLI[3]),'@e 9,999,999')		
			nLin++
			//@ nLin,010 Psay __PrtThinLine()
			@ nLin,005 Psay Replicate('- ',63)
			nLin++
		ELSE                                         
			//[QUADRO 003]_________________________________________TIPO DE NOTA
			_aArrType := _aDDsCLI[ARR_PROD][ARR_TIPO]
			For _nB:=1 To Len(_aArrType)
				           
				//[QUADRO 004]_________________________________________LISTA REMESSA E RETORNO
				_aRemRet := aClone(_aArrType[_nB])
				For _nD:=1 To Len(_aRemRet)
					IF _nD == 1
						@ nLin,008 Psay _aRemRet[_nD]
						nLin++
					Else
						//[QUADRO 004]_________________________________________IMPRESSAO DOS DADOS
						_aDados := _aRemRet[ARR_DADOS]
						For _nC:=1 To Len(_aDados)

						   	If nLin > 55
						      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						      	nLin := 8
						   	Endif
   							
							IF Len(_aDados[_nC]) > 5
								@ nLin,012 Psay _aDados[_nC][1]	
								@ nLin,028 Psay DtoC(StoD(_aDados[_nC][2]))
								@ nLin,041 Psay _aDados[_nC][3]	
								@ nLin,052 Psay _aDados[_nC][4]	
								@ nLin,057 Psay TransForm(_aDados[_nC][5],'@e 9,999,999.99')	
								@ nLin,070 Psay TransForm(_aDados[_nC][6],'@e 9,999,999.99')
								@ nLin,083 Psay TransForm(_aDados[_nC][7],'@e 9,999,999.99')
								@ nLin,095 Psay _aDados[_nC][8]
								@ nLin,103 Psay _aDados[_nC][9]	
								@ nLin,109 Psay PadR(_aDados[_nC][10],25)							
								nLin++	
							ENDIF
						Next _nC				
					ENDIF 
				Next _nD			
			Next _nB
		ENDIF
	Next 
	
   nLin++
Next _nY
Return      
