#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*/{Protheus.doc} REESTA10
Efetua a gravação do Recebimento de Bobinas da INNOVA
@type function
@version 1.0
@author Marcos P.Aversa - Dothink
@since 06/2023
@return variant, nil
/*/
User Function REESTA10()
    local aArea       := GetArea()
    local aAreaSZB    := SZB->( GetArea() )
    local aAreaSZD    := SZD->( GetArea() )
    local cINNOVA     := GetMV("RE_FINNOVA", .F.,  "042297610001")         
    local cFilOrig    := GetMV("RE_FILORIG", .F., "0302")    

    Private cDoc      := Space( TamSX3("ZD_DOC")[1] )
    Private cSerie    := Space( TamSX3("ZD_SERIE")[1] )
    Private cCodBarra := Space( TamSX3("ZD_CODBAR")[1] )

    Private cTipo       := "1" //--Grava Registro

    Private cForIN    := ""     //--Cod.Fornecedor Innova 
    Private cLjIN     := ""     //--Loja Forneceor Innova

	If cFilAnt # cFilOrig
        VtBeep(2)
        VtAlert( "Somente e permitido realizar o Recebimento na Filial  : " + cFilOrig, "ATENCAO", .T., 3000 )
		Return
	EndIf

    cForIN := LEFT( cINNOVA, 8 )
    cLjIN  := RIGHT( cINNOVA, 4 )

    SZD->( dbSetOrder( 1 ))  //--ZD_FILIAL + ZD_DOC + ZD_SERIE + ZD_CODBAR
    SZB->( dbSetOrder( 1 ))  //--ZB_FILIAL + ZB_DOC + ZB_SERIE + ZB_FORNEC + ZB_LOJA
  
    While .T.
        cDoc   := Space( TamSX3("ZD_DOC")[1] )
        cSerie := Space( TamSX3("ZD_SERIE")[1] )
        VtClear()
        @ 0,0 VtSay Padc("RECEBIMENTO INNOVA", VTMaxCol())
        @ 1,0 VtSay Padc("----------- ------", VTMaxCol()) 
        @ 3,0 VtSay "N U M E R O    D A    N O T A" 
        @ 4,0 VtGet cDoc  Pict "@!"  
        @ 5,0 VtSay "S E R I E"
        @ 6,0 VtGet cSerie Pict "@!" Valid vldDoc( cDoc, cSerie ) 
        VTRead     
     
        If VtLastKey() == 27
            If VtYesNo( "Deseja Sair do Recebimento?", "ATENCAO" )
                Exit 
            EndIf
        EndIf

        If SZD->( dbSeek( xFilial("SZB") + cDoc + cSerie ) ) .AND. !Empty( SZD->ZD_DFIM )
            If VtYesNo( "Recebimento do Documento " + cDoc + cSerie +", foi Finalizado !!!. Deseja Reabrir ?", "ATENCAO" ) 
                While SZD->( !Eof() ) .AND.;
                    xFilial("SZD") + cDoc + cSerie == SZD->ZD_FILIAL + SZD->ZD_DOC + SZD->ZD_SERIE 
                    SZD->( RecLock( "SZD", .F.))
                    SZD->ZD_DFIM   := CTOD("  /  /  ")                 
                    SZD->( dbUnLock() )                
                    SZD->( dbSkip() )                           
                Enddo
            Else
               loop
            Endif
        Endif

        While .T.

            VtClear()    

            VTSetKey(12,{|| VDocSZD( cDoc, cSerie )},"Documento")      //CTRL L    

            cTipo := "1"
            cCodBarra := Space( TamSX3("ZD_CODBAR")[1] )
            cLoteFor  := Space( TamSX3("ZD_LOTE")[1] )
            cCodFor   := Space( TamSX3("ZD_CODINN")[1] )  
        
            @ 0,0 VtSay Padc("LEIA ETIQUETA INNOVA", VTMaxCol())
            @ 1,0 VtSay Padc("--------------------", VTMaxCol())
            @ 2,0 VtSay Padc("Documento : " + Alltrim(cDoc) + "/" +Alltrim(cSerie)  , VTMaxCol())
            @ 4,0 VtGet cCodBarra  Pict "@!"  Valid vldCodBarra( cCodBarra )
            VTRead
 
            If VtLastKey() == 27
                If VtYesNo( "Deseja Finalizar o Recebimento ?", "ATENCAO" )
                   cTipo := "2"
                Else 
                   Exit
                EndIf
            EndIf

            nPesoFor  := Val( Substring( cCodBarra,21,3 )+"."+Substring( cCodBarra,24,2 ) )
            cxLoteFor := Substring( cCodBarra,1,10 )
            cxCodFor  := Substring( cCodBarra, 32, iif( len( Alltrim( cCodBarra) ) == 37,6,5 ) ) + ;
                         Substring( cCodBarra, 11, 4 ) 

            cLoteFor := Padr( cxLoteFor, Len( cLoteFor) )
            cCodFor  := Padr( cxCodFor, Len( cCodFor ) )

            //--Grv. Registros
            If cTipo == "1"
                fGrvSZD( cDoc, cSerie, cForIN, cLjIN, cLoteFor, nPesoFor, cCodFor  )
            Elseif cTipo == "2"
                fGrvFinRec(  cDoc, cSerie )
                Exit
            Endif

        Enddo
    Enddo

    RestArea( aAreaSZD )
    RestArea( aAreaSZB )
    RestArea( aArea )

Return


Static Function vldDoc( cDoc, cSerie )
If SZB->( dbSeek( xFilial("SZB") + cDoc + cSerie + cForIN + cLjIN ))
    VtBeep(2)
    VtAlert( "Ja Existe Registro na Base para Geracao da Pre-Nota para o Documento " + cDoc + cSerie + cForIN + cLjIN +".", "ATENCAO", .T., 3000 )
    VTKeyboard(chr(20))        
    Return .F. 
Endif
Return .T.


Static Function VldCodBarra( cCodBarra )
    local aArea := GetArea()
    local aAreaSZD := SZD->( GetArea() )    
    local nTamCod  := Len(Alltrim( cCodBarra))
    local cLoteFor := Space( TamSX3("ZD_LOTE")[1] )
    local cCodFor  := Space( TamSX3("ZD_CODINN")[1] )  

    cLoteFor := Padr( Substring( cCodBarra,1,10 ), Len( cLoteFor) )
    cCodFor  := Padr(  Substring( cCodBarra, 31, iif( len( Alltrim( cCodBarra) ) == 37,7,6 ) ), Len( cCodFor ) )

    SZD->( dbSetOrder( 4 )) //--ZD_FILIAL +   ZD_CODINN +   ZD_LOTE

    If !( nTamCod == 37 .OR. nTamCod == 36 )
        VtBeep(2)
        VtAlert( "Codigo de Barras Invalido !!!, < Numero de Caracteres >  !!!", "ATENCAO", .T., 5000 )
		VTKeyboard(chr(20))
        RestArea( aAreaSZD ) 
        RestArea( aArea )        
        Return .F. 
    Endif 

    If SZD->( dbSeek( xFilial("SZD")  + cCodFor + cLoteFor ))
        VtBeep(2)
        VtAlert( "Ja existe este Codigo/Lote " + Alltrim(cCodFor)+ "/"+ Alltrim(cLoteFor)+ " para NF/Serie : " + Alltrim(SZD->ZD_DOC) + "/" + Alltrim(SZD->ZD_SERIE) , "ATENCAO", .T., 5000 )
        /*
        VtBeep(2)        
        If VtYesNo( "Deseja excluir o Recebimento do Documento : " +  cDoc + "/" + cSerie + " - Lote : " +  cLoteFor , "ATENCAO" )
            SZD->( RecLock( "SZD", .F.))
            SZD->( dbDelete() )
            SZD->( dbUnLock() ) 
        Endif                      
        */
		VTKeyboard(chr(20))
        RestArea( aAreaSZD ) 
        RestArea( aArea )      
        Return .F. 
     Endif

    RestArea( aAreaSZD )
    RestArea( aArea )

Return .T.


Static Function VDocSZD( cDoc, cSerie )
    Local ckey12  := VTDescKey(12)
    Local bkey12  := VTSetKey(12)
    Local aCab,aSize
    Local aSave   := VTSAVE()
    Local aTemp   := {}

    //-- Desabilita tecla de atalho (Volume)
    VTSetKey(12,Nil)

    VTClear()

    If SZD->( dbSeek( xFilial( "SZD") + cDoc + cSerie ) )
       While SZD->(!Eof() ) .AND. SZD->ZD_FILIAL + SZD->ZD_DOC + SZD->ZD_SERIE ==   xFilial( "SZD") + cDoc + cSerie
            aadd(aTemp,{  SZD->ZD_LOTE, SZD->ZD_CODINN, SZD->ZD_COD, Transform( SZD->ZD_QTD,"@E 99999.99")  })       
            SZD->( dbSkip() )       
       EndDo 
    Else
        aadd(aTemp,{ "","", "","" })          
    Endif

    aCab  := {"Lote","Cod.Forn.","Cod.Repl","Quant."} 
    aSize := {10,15,20,10}
    VTaBrowse(,,,,aCab,aTemp,aSize)
    VtRestore(,,,,aSave)
    //-- Restaura Teclas
    VTSetKey(12,bKey12, cKey12)

Return

Static Function fGrvFinRec(  cDoc, cSerie  )
    local aArea    := GetArea()
    local aAreaSZD := SZD->( GetArea() )

    SZD->( dbSetOrder( 1 ) )
 
    SZD->( dbSeek( xFilial("SZD") + cDoc + cSerie )) 
    If SZD->( Eof() )
  		VtBeep(2)
    	VtAlert( "Documento : " + cDoc +"/"+ cSerie +", nao localizado !!!", "ATENCAO", .T., 3000 )    
    Else
        If !Empty( SZD->ZD_DFIM )
            VtBeep(2)
            VtAlert( "Documento : " + cDoc +"/"+ cSerie +", ja Finalizado Anteriormente !!!", "ATENCAO", .T., 3000 )    
        Else
            While SZD->( !Eof() ) .AND.;
                xFilial("SZD") + cDoc + cSerie == SZD->ZD_FILIAL + SZD->ZD_DOC + SZD->ZD_SERIE 
                SZD->( RecLock( "SZD", .F.))
                SZD->ZD_DFIM   := dDataBase                 
                SZD->( dbUnLock() )                
                SZD->( dbSkip() )                           
            Enddo
            VtBeep(2)
            VtAlert( "Documento : " + cDoc +"/"+ cSerie +", Finalizado com Sucesso !!!", "ATENCAO", .T., 3000 )    
       Endif
    Endif

    RestArea( aAreaSZD )
    RestArea( aArea )

Return

Static Function fGrvSZD( cDoc, cSerie, cForIN, cLjIN, cLoteFor, nPesoFor, cCodFor )
    local aArea := GetArea()
    local aAreaSZD := SZD->( GetArea() )
    local aAreaSZ5 := SZ5->( GetArea() ) 
    local cCodProd := Space( TamSX3("B1_COD")[1] )   

    SZ5->( dbSetOrder(1 ) ) //-- Z5_FILIAL+Z5_CODFOR  
    If SZ5->( !dbSeek( xFilial( "SZ5") + cCodFor ) )
       //-- Alerta de Mensagem, mas deixa Prosseguir
        VtBeep(2)
        VtAlert( "Codigo : <" + cCodFor + "> do Fornecedor *** Sem correspondente Cadastrado ***, Favor verificar !!!", "ATENCAO", .T., 3000 )  
    Else
        cCodProd := SZ5->Z5_CODPRD
    Endif

    dbSelectArea("SZD")

    SZD->( dbSetOrder( 2 )) //-- ZD_FILIAL + ZD_DOC + ZD_SERIE + ZD_CODINN + ZD_LOTE

    If SZD->( dbSeek( xFilial("SZD") + cDoc + cSerie + cCodFor + cLoteFor  ))
        VtBeep(2)
        VtAlert( "Codigo : " + cCodFor + " - Lote : " + cLoteFor +" ja incluido, Favor verificar !!!", "ATENCAO", .T., 3000 )
        If VtYesNo( "Deseja excluir o Recebimento do Documento : " +  cDoc + "/" + cSerie + " - Lote : " +  cLoteFor , "ATENCAO" )
            SZD->( RecLock( "SZD", .F.))
            SZD->( dbDelete() )
            SZD->( dbUnLock() )                       
        Endif        
    Else 
        SZD->( RecLock( "SZD", .T.))    
        SZD->ZD_FILIAL  := xFilial("SZD")
        SZD->ZD_DOC     := cDoc
        SZD->ZD_SERIE   := cSerie
        SZD->ZD_FORNECE := cForIN
        SZD->ZD_LOJA    := cLjIN
        SZD->ZD_COD     := cCodProd
        SZD->ZD_CODBAR  := cCodBarra
        SZD->ZD_CODINN  := cCodFor
        SZD->ZD_LOTE    := cLoteFor
        SZD->ZD_VALID   := Ctod("  /  /  ")
        SZD->ZD_QTD     := nPesoFor
        SZD->ZD_DCONF   := dDataBase
        SZD->ZD_HCONF   := Left( Time(), 5 ) 
        SZD->ZD_USER    := __CUSERID
        
        SZD->( dbUnLock() )
    Endif

    RestArea( aAreaSZ5 )
    RestArea( aAreaSZD )
    RestArea( aArea )

Return
