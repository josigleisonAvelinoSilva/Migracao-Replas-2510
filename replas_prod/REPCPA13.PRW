#include "Protheus.ch"

User Function REPCPA13()
    Local aCores      :={}
	Private aRotina   :=MenuDef()
	Private cCadastro :="Registro de Inventário"
	Private aParam    :={}
	Private aRet      :={}                  
	Private nOpc      :=0

    AADD(aCores,{"SZ7->Z7_STATUS = '1' ","BR_VERMELHO"  ,"Não Processado"})
    AADD(aCores,{"SZ7->Z7_STATUS = '2' ","BR_VERDE"     ,"Processado"})	

	DbSelectArea("SZ7")
	DbSetOrder(1)

	oMBrowse := mBrowse( 6, 1,22,75     ,"SZ7",,,,,,aCores)


Return()

Static Function MenuDef()
Local aRotina :={	{"Pesquisar                ","AxPesqui"	,0 , 1},;
 					{"Grv.Lts/Sub - Individual ","U_XGRVSZ7"	,0 , 6},;
 					{"Grv.Lts/Sub - Todos      ","U_XGRVTDS"	,0 , 6},;
  					{"Grv.B1_Rastro p/MP       ","U_XGRVSB1"	,0 , 6},;					
 					{"Legenda"                 ,"U_LEGSA13"	,0 , 6},;
 					{"Visualizar"              ,"AxVisual"	,0 , 2}}

// 					{"Grv.SB2 - Teste          ","U_XGRVSB2"	,0 , 6},;

Return( aRotina )

User Function LEGSA13()

	Local _aLegenda := {}

	AADD(_aLegenda, {"BR_VERMELHO","Não Processado"})
	AADD(_aLegenda, {"BR_VERDE","Processado"})

	BrwLegenda(cCadastro,'Legenda',_aLegenda)

Return()



User Function XGRVTDS()
	local aArea    := GetArea()
	local aAreaSB8 := SB8->( GetArea()	)
	SB8->( dbSetOrder(3)) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	SB1->( dbSetOrder(1)) 

	If FWAlertYesNo("Confirma a Gravação de Todos os Registros ?", "Carga Lotes")
		nRecno := SZ7->( Recno() )
	    SZ7->( dbGotop() )
		nQtdRegs := SZ7->(LastRec())
		Processa( { || xGrvInve( nQtdRegs ) } , "Gravando Inventario..." )		
		SZ7->( dbGoto( nQtdRegs ))
	Endif

    RestArea( aAreaSB8 )
    RestArea( aArea )
Return()

Static Function xGrvInve( nQtdRegs )
    local aArea    := GetArea()
    local aAreaSB2 := SB2->(GetArea())	
    local aAreaSZ7 := SZ7->(GetArea())		
	local nQtdProc := 0
	local lGrvSZ7  := .T.
	local cMsg     := ""
    local lotes    := {}	
    local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )

	cFilAnt := cFilOrig

	ProcRegua(nQtdRegs)

	cDocto := CriaVar("D3_DOC")
	If Empty(cDocto)
		cDocto := NextNumero("SD3", 2, "D3_DOC", .T.)
	EndIf

	SB2->( dbSetOrder(1))

	While SZ7->( !Eof())
		IncProc("Gravando Produto : " + Alltrim(SZ7->Z7_COD) + " - Lote : " + Alltrim(SZ7->Z7_LOTECTL) + " - Sub-Lote : " + Alltrim(SZ7->Z7_NUMLOTE)  )	
		nQtdProc++
        lGrvSZ7 := .T.
		cMsg := ""

   		If SZ7->Z7_STATUS == "2"
   	       SZ7->( dbSkip() )
		   Loop
    	Endif

		//If lGrvSZ7 .AND. SB8->( dbSeek( SZ7->Z7_FILIAL + SZ7->Z7_COD  +  SZ7->Z7_LOCAL + SZ7->Z7_LOTECTL +  SZ7->Z7_NUMLOTE  )) 
        If lGrvSZ7 .AND. SB8->( dbSeek( cFilOrig + SZ7->Z7_COD  +  SZ7->Z7_LOCAL + SZ7->Z7_LOTECTL +  SZ7->Z7_NUMLOTE  )) 		
           cMsg :="Produto : " + SZ7->Z7_COD + " - Lote : " + SZ7->Z7_LOTECTL + " - Sub-Lote : " + SZ7->Z7_NUMLOTE + " já existe , Favor Verificar !!!!" 		
           lGrvSZ7 := .F.			   
    	Endif

        //--Valida Código do Produto
	    If lGrvSZ7 .AND. !SB1->( dbSeek( xFilial("SB1") + SZ7->Z7_COD ) )
		    cMsg :="Produto : " + SZ7->Z7_COD + " não Localizado, Favor Verificar !!!!"
			lGrvSZ7 := .F.  
		Else 
			If lGrvSZ7 .AND. SB1->B1_RASTRO != "S" 
			    cMsg :="Produto : " + SZ7->Z7_COD + " não esta com o Controle de Sub-Lote, Favor Verificar !!!!"
				lGrvSZ7 := .F.
			Endif
		Endif
		//-- Valida Demais Campos
		If lGrvSZ7 .AND. ( Empty(SZ7->Z7_LOCAL) .OR.;
			Empty(SZ7->Z7_LOTECTL) .OR.;
			Empty(SZ7->Z7_NUMLOTE) .OR.;			   			
			Empty(SZ7->Z7_DTVALID) .OR.;
			SZ7->Z7_QTDORI <= 0 )
			cMsg :="Existe(m) Registro(s) não valido(s) para Inclusão, Favor Verificar !!!!"
			lGrvSZ7 := .F.
		Endif

		If lGrvSZ7 

			If !SB2->(DbSeek( cFilAnt + SZ7->Z7_COD + SZ7->Z7_LOCAL ))
				CriaSB2( SZ7->Z7_COD, SZ7->Z7_LOCAL , cFilAnt )	
			EndIf
            //-- Ação necessária para possível gravação dos Lotes de Inventário - Base TesteAmbiente de Homologação
			//-- Analisar necessidade de efetivar essa ação em Base de Produção.
            /*
			If SB2->( dbSeek( cFilAnt + SZ7->Z7_COD + SZ7->Z7_LOCAL  ))
			   SB2->( RecLock( "SB2" , .F. ))
			   SB2->B2_QEMP    := 0 
			   SB2->B2_RESERVA := 0
			   SB2->B2_SALPEDI := 0
			   SB2->( MsUnLock() )
			Endif
			*/

			lotes := {}	
			//aadd( lotes, {"D5_FILIAL"  , SZ7->Z7_FILIAL  , nil})
			//aadd( lotes, {"D5_FILIAL"  , SZ7->Z7_FILIAL  , nil})
			//aadd( lotes, {"D5_FILIAL"  , cFilOrig        , nil})
			aadd( lotes, {"D5_FILIAL"  , cFilAnt         , nil})
			aadd( lotes, {"D5_PRODUTO" , SZ7->Z7_COD , nil})
			aadd( lotes, {"D5_LOCAL"   , SZ7->Z7_LOCAL   , nil})
			aadd( lotes, {"D5_LOTECTL" , SZ7->Z7_LOTECTL , nil})
			aadd( lotes, {"D5_NUMLOTE" , SZ7->Z7_NUMLOTE , nil})
			aadd( lotes, {"D5_DTVALID" , SZ7->Z7_DTVALID , nil})
			aadd( lotes, {"D5_DATA"    , Date()          , nil})		
			aadd( lotes, {"D5_QUANT"   , SZ7->Z7_QTDORI	 , nil})
			aadd( lotes, {"D5_DOC"     , cDocto	         , nil})			

			lmserroauto := .f.
			msexecauto({|x,y| MATA390(x,y)}, lotes ,3)
			If lmserroauto
				//mostraerro()
				cFileLog := NomeAutoLog()
            	cMsg     := MemoRead( cFileLog )
				//-- Grava Controle de Gravação - Tabela SZZ
				SZ7->( RecLock( "SZ7",.F.) )
				SZ7->Z7_OBS      := cMsg
				SZ7->( MsUnLock() )
			else
				//-- Grava Data de Fabricação - Tabela SB8
				cChvSD5 := SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_LOCAL + SD5->D5_LOTECTL + SD5->D5_NUMLOTE + DTOS(SD5->D5_DTVALID)
				If SB8->( dbSeek( cChvSD5 )) 
					If SB8->( RecLock("SB8",.F. ))
						SB8->B8_DFABRIC := SZ7->Z7_DFABRIC
						SB8->( MsUnLock() )
					Endif
				Endif
				//-- Grava Controle de Gravação - Tabela SZZ
				SZ7->( RecLock( "SZ7",.F.) )
				SZ7->Z7_STATUS   := "2"
				SZ7->Z7_OBS      := ""
				SZ7->( MsUnLock() )
			Endif
		Else 	
			//-- Grava Controle de Gravação - Tabela SZZ
			SZ7->( RecLock( "SZ7",.F.) )
			SZ7->Z7_OBS     := cMsg
			SZ7->( MsUnLock() )
		Endif   

	    SZ7->( dbSkip() )
	Enddo

	FWAlertInfo("Foram Processados " + Alltrim( str(nQtdProc) ) + " registros.","INFO")
	 			
	RestArea( aAreaSZ7 ) 
    RestArea( aAreaSB2 )
    RestArea( aArea )
Return


User Function XGRVSZ7()
	local aArea    := GetArea()
	local aAreaSB8 := SB8->( GetArea()	)
    local lotes    := {}
	local lGrvSZ7  := .T.
	local cMsg     := ""
    local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )

	SB8->( dbSetOrder(3)) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	SB1->( dbSetOrder(1)) 

	If FWAlertYesNo("Confirma a Gravação do Registro ?", "Carga Lotes")
		cDocto := CriaVar("D3_DOC")
   		If SZ7->Z7_STATUS == "2"
		   cMsg := "Produto : " + SZ7->Z7_COD + " - Lote : " + SZ7->Z7_LOTECTL + " - Sub-Lote : " + SZ7->Z7_NUMLOTE + " já Gravado, Favor Verificar !!!!"
		   FWAlertWarning( cMsg) 
           lGrvSZ7 := .F.			   
    	Endif

		//If lGrvSZ7 .AND. SB8->( dbSeek( SZ7->Z7_FILIAL + SZ7->Z7_COD  +  SZ7->Z7_LOCAL + SZ7->Z7_LOTECTL +  SZ7->Z7_NUMLOTE  )) 
		If lGrvSZ7 .AND. SB8->( dbSeek( cFilOrig + SZ7->Z7_COD  +  SZ7->Z7_LOCAL + SZ7->Z7_LOTECTL +  SZ7->Z7_NUMLOTE  )) 
           cMsg :="Produto : " + SZ7->Z7_COD + " - Lote : " + SZ7->Z7_LOTECTL + " - Sub-Lote : " + SZ7->Z7_NUMLOTE + " já existe , Favor Verificar !!!!" 		
		   FWAlertWarning( cMsg) 
           lGrvSZ7 := .F.			   
    	Endif

        //--Valida Código do Produto
	    If lGrvSZ7 .AND. !SB1->( dbSeek( xFilial("SB1") + SZ7->Z7_COD ) )
		    cMsg :="Produto : " + SZ7->Z7_COD + " não Localizado, Favor Verificar !!!!"
		    FWAlertWarning( cMsg) 
			lGrvSZ7 := .F.  
		Else 
			If lGrvSZ7 .AND. SB1->B1_RASTRO != "S" 
			    cMsg :="Produto : " + SZ7->Z7_COD + " não esta com o Controle de Sub-Lote, Favor Verificar !!!!"
		        FWAlertWarning( cMsg) 				
				lGrvSZ7 := .F.
			Endif
		Endif
		//-- Valida Demais Campos
		If lGrvSZ7 .AND. ( Empty(SZ7->Z7_LOCAL) .OR.;
			Empty(SZ7->Z7_LOTECTL) .OR.;
			Empty(SZ7->Z7_NUMLOTE) .OR.;			   			
			Empty(SZ7->Z7_DTVALID) .OR.;
			SZ7->Z7_QTDORI <= 0 )
			cMsg :="Existe(m) Registro(s) não valido(s) para Inclusão, Favor Verificar !!!!"
	        FWAlertWarning( cMsg)
			lGrvSZ7 := .F.
		Endif

		If lGrvSZ7 
			lotes := {}	
			If Empty(cDocto)
				cDocto := NextNumero("SD3", 2, "D3_DOC", .T.)
			EndIf
			cFilAnt := cFilOrig
			//aadd( lotes, {"D5_FILIAL"  , SZ7->Z7_FILIAL  , nil})
			//aadd( lotes, {"D5_FILIAL"  , cFilOrig        , nil})
			aadd( lotes, {"D5_FILIAL"  , cFilAnt         , nil})
			aadd( lotes, {"D5_PRODUTO" , SZ7->Z7_COD     , nil})
			aadd( lotes, {"D5_LOCAL"   , SZ7->Z7_LOCAL   , nil})
			aadd( lotes, {"D5_LOTECTL" , SZ7->Z7_LOTECTL , nil})
			aadd( lotes, {"D5_NUMLOTE" , SZ7->Z7_NUMLOTE , nil})
			aadd( lotes, {"D5_DTVALID" , SZ7->Z7_DTVALID , nil})
			aadd( lotes, {"D5_DATA"    , Date()          , nil})		
			aadd( lotes, {"D5_QUANT"   , SZ7->Z7_QTDORI	 , nil})
			aadd( lotes, {"D5_DOC"     , cDocto	         , nil})

			lmserroauto := .f.
			msexecauto({|x,y| MATA390(x,y)}, lotes ,3)
			If lmserroauto
				//mostraerro()
				//Limpar Registro Anterior
				cMsg :=""
				SZ7->( RecLock( "SZ7",.F.) )
				SZ7->Z7_OBS      := cMsg
				SZ7->( MsUnLock() )

				cFileLog := NomeAutoLog()
            	cMsg     := MemoRead( cFileLog )
				//-- Grava Controle de Gravação - Tabela SZZ
				SZ7->( RecLock( "SZ7",.F.) )
				SZ7->Z7_OBS      := cMsg
				SZ7->( MsUnLock() )
				FWAlertError( cMsg, "Grava Lote/Sub-Lote!" )				
			else
				//-- Grava Data de Fabricação - Tabela SB8
				cChvSD5 := SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_LOCAL + SD5->D5_LOTECTL + SD5->D5_NUMLOTE + DTOS(SD5->D5_DTVALID)
				If SB8->( dbSeek( cChvSD5 )) 
					If SB8->( RecLock("SB8",.F. ))
						SB8->B8_DFABRIC := SZ7->Z7_DFABRIC
						SB8->( MsUnLock() )
					Endif
				Endif
				//-- Grava Controle de Gravação - Tabela SZZ
				SZ7->( RecLock( "SZ7",.F.) )
				SZ7->Z7_STATUS   := "2"
				SZ7->Z7_OBS      := ""
				SZ7->( MsUnLock() )

			    FWAlertInfo("Registro Gravado.","INFO")				
			Endif
		Else 	
			//-- Grava Controle de Gravação - Tabela SZZ
			SZ7->( RecLock( "SZ7",.F.) )
			SZ7->Z7_OBS     := cMsg
			SZ7->( MsUnLock() )
		Endif   
	Endif

    RestArea( aAreaSB8 )
    RestArea( aArea )
Return()


User Function XGRVSB2()
	local aArea    := GetArea()
	local aAreaSB2 := SB2->( GetArea() )
	local cQuery   := ""	
    local cFilOrig := GetMV( "RE_FILORIG", .F., "0302" )
	local nQtd	   := 0

	If FWAlertYesNo("Grava Saldo no SB2 de Acordo com Inventario (SZ7) ?", "SB2")	

		SB2->( dbSetOrder(1))  // B2_FILIAL+B2_COD+B2_LOCAL

		cQuery := " SELECT Z7_COD,Z7_LOCAL,Z7_QUANT,B2_QATU " + CRLF 
		cQuery += " FROM " + CRLF 
		cQuery += "  ( " + CRLF 
		cQuery += "  SELECT Z7_COD,Z7_LOCAL,SUM(Z7_QUANT) Z7_QUANT " + CRLF 
		cQuery += "  FROM SZ7010 Z7 " + CRLF
		cQuery += "  WHERE Z7.D_E_L_E_T_ = ' ' " + CRLF 
		cQuery += "  GROUP BY Z7_COD,Z7_LOCAL " + CRLF
		cQuery += "  ) XX " + CRLF

		cQuery += "  JOIN SB1010 B1 " + CRLF
		cQuery += "    ON B1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "   AND B1.B1_COD = XX.Z7_COD " + CRLF 
		cQuery += "   AND B1.B1_TIPO = 'MP' " + CRLF

		cQuery += "  LEFT JOIN SB2010 B2 " + CRLF
		cQuery += "    ON B2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "   AND B2.B2_FILIAL = '" + cFilOrig + "' " + CRLF
		cQuery += "   AND B2.B2_COD = XX.Z7_COD " + CRLF
		cQuery += "   AND B2.B2_LOCAL = XX.Z7_LOCAL " + CRLF

		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "XSZ7", .F., .T.)

		If XSZ7->( !EOF())
			While XSZ7->( !EOF())

				If !SB2->(DbSeek( cFilOrig + XSZ7->Z7_COD + XSZ7->Z7_LOCAL ))
					CriaSB2( XSZ7->Z7_COD, XSZ7->Z7_LOCAL , cFilOrig)	
				EndIf

				IF SB2->( dbSeek( cFilOrig + XSZ7->Z7_COD + XSZ7->Z7_LOCAL  ))
			        nQtd++				
					SB2->( RecLock( "SB2", .F. ))
					SB2->B2_QATU := XSZ7->Z7_QUANT
					SB2->( MsUnLock() )			   
				Endif

				XSZ7->( dbSkip() )	      
			Enddo
			FWAlertInfo("Foram Processados " + Alltrim( str(nQtd) ) + " registros.","INFO")
        Else
			FWAlertInfo("Foram Processados " + Alltrim( str(nQtd) ) + " registros.","INFO")							
		Endif

		XSZ7->( dbCloseArea() )

	Endif


RestArea( aAreaSB2 )
RestArea( aArea )
Return

User Function XGRVSB1()
	local aArea    := GetArea()
	local aAreaSB1 := SB1->(GetArea())	
	local nQtd	   := 0

	If FWAlertYesNo("Grava Rastro p/MP (SB1) ?", "SB1")		
		SB1->( dbSetOrder(1 ))
		SB1->( dbGotop() )
		While SB1->( !Eof() ) 
			If Alltrim( SB1->B1_TIPO ) == "MP"
			    nQtd++			
				SB1->( RecLock( "SB1", .F. ))
				SB1->B1_RASTRO := "S"
				SB1->( MsUnLock() )			   
			Endif
			SB1->( dbSkip() )
		Enddo 
		FWAlertInfo("Foram Processados " + Alltrim( str(nQtd) ) + " registros.","INFO")			
	Endif

	RestArea( aAreaSB1 )
	RestArea( aArea )
Return
