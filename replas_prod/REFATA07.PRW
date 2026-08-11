#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} REFATA07
Rotina de tranmissao de nota fiscal para o SEFAZ
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@param cNotaFeita, character, Numero da NF
@param cSerie, character, Serie da NF
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
User Function REFATA07(cNotaFeita, cSerie, cMsg)
    Local aParamSFZ := { cEmpAnt, cFilAnt, "5", "1", cSerie, cNotaFeita, cNotaFeita }
    Local lRetSefaz := .F.
	    Local aArea     := GetArea()
    Local aAreaSF2  := SF2->( GetArea() )
    Local nx        := 1
    SF2->( dbSetOrder(1))
    
    While nx <= 5
        Inkey(1)
        If SF2->( dbSeek( aParamSFZ[02] + aParamSFZ[06] + Padr(aParamSFZ[05], 3) ) )
            While !KillApp()
                AutoNfeEnv(aParamSFZ[01],;
                        aParamSFZ[02],;
                        aParamSFZ[03],;
                        aParamSFZ[04],;
                        Padr(aParamSFZ[05], 3),;
                        aParamSFZ[06],;
                        aParamSFZ[07])

                Sleep( 1000 * Val( aParamSFZ[3] ) )
                lRetSefaz := SpedNFe6Mnt( Padr( aParamSFZ[05], 3 ), aParamSFZ[06], aParamSFZ[07], , , "55", @cMsg )
                nx := 5
                Exit
            EndDo
        Endif
        nx++
    Enddo    

    RestArea( aAreaSF2 )
    RestArea( aArea )

Return lRetSefaz


/*/{Protheus.doc} SpedNFe6Mnt
Rotina que fica avaliando o retorno do SEFAZ por um determinado tempo
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@param cSerie, character, Serie da NF
@param cNotaIni, character, Nota inicial
@param cNotaFim, character, Nota final
@param lCTe, logical, Indica CTe
@param lMDFe, logical, Indica MDFe
@param cModel, character, Model
@param cMsg, character, Mensagem
@return logical, Retorno logico
/*/
Static Function SpedNFe6Mnt(cSerie, cNotaIni, cNotaFim, lCTe, lMDFe, cModel, cMsg)
    Local cIdEnt     := RetIdEnti() //-- Obtem o codigo da entidade
    local cUrl	     := Padr( GetNewPar( "MV_SPEDURL", "" ), 250 )
    Local aPerg      := {}
    Local aParam     := { Space( Len( SF2->F2_SERIE ) ), Space( Len( SF2->F2_DOC ) ), Space( Len( SF2->F2_DOC ) ) }
    Local aListBox   := {}
    Local cParNfeRem := ''
    Local nI, nJ     := 0
    Local nTentrf	 := GetMV( "CM_NTENTTF", .F., 50 )
    Local nEeWaitF   := GetMV( "CM_EEWAITF", .F., 3 )
    Local nPosStatus := 0

    Default cSerie   := ""
    Default cNotaIni := ""
    Default cNotaFim := ""
    Default lCTe     := .F.
    Default lMDFe    := .F.
    Default cModel	 := ""

    cParNfeRem := cEmpAnt + cFilAnt + "SPEDNFEREM"

    aAdd( aPerg, { 1, "Serie NFS"  , aParam[01], "", ".T.", "", ".T.", 30, .F. } ) //-- Serie da Nota Fiscal
    aAdd( aPerg, { 1, "NFS Inicial", aParam[02], "", ".T.", "", ".T.", 30, .T. } ) //-- Nota Fiscal Inicial
    aAdd( aPerg, { 1, "NFS Final"  , aParam[03], "", ".T.", "", ".T.", 30, .T. } ) //-- Nota Fiscal Final

    aParam[01] := ParamLoad( cParNfeRem, aPerg, 1, aParam[01] )
    aParam[02] := ParamLoad( cParNfeRem, aPerg, 2, aParam[02] )
    aParam[03] := ParamLoad( cParNfeRem, aPerg, 3, aParam[03] )

    If !Empty( cIdEnt )
        cSerie   := aParam[01] := cSerie
        cNotaIni := aParam[02] := cNotaIni
        cNotaFim :=	aParam[03] := cNotaFim	

        For nI := 1 To nTentrf                                                                                             
            For nJ := 1 To 5
                Sleep(1000)
            Next nJ

            aListBox := GetListBox( cIdEnt, cUrl, aParam, 1, cModel, lCte )
            
            If !Empty( aListBox )
                If !Empty( aListBox[1][9] )
                    nPosStatus := aScan( aListBox[1][9], {|x| x[9] == "100" } )

                    If nPosStatus > 0
                        cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                        cMsg += "Sucesso na transmissao para o SEFAZ. [" + cNotaIni + "]" + Chr(13) + Chr(10)
                        Return .T.
                    EndIf

                    If aListBox[1][9][1][9] == "103"
                        If nI == nTentrf                            
                            cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                            cMsg += "Erro 103 na transmissao para o SEFAZ. [" + cNotaIni + "]" + Chr(13) + Chr(10)
                            //cMsg += "Verifique a causa no monitor SEFAZ, realize os ajustes e transmita manualmente." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
                            Return .F.
                        EndIf
                    ElseIf aListBox[1][9][1][9] <> "100"
                        If !Empty(aListBox[1][9][1][9]) .Or. nI == nTentrf                            
                            cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                            cMsg += "Erro " + aListBox[1][9][1][9] + " na transmissao para o SEFAZ. [" + cNotaIni + "]" + Chr(13) + Chr(10)
                            //cMsg += "Verifique a causa no monitor SEFAZ, realize os ajustes e transmita manualmente." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
                            Return .F.
                        EndIf
                    EndIf
                Else
                    If nI == nTentrf
                        cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
                        cMsg += "Erro na transmissao para o SEFAZ. [" + cNotaIni + "]" + Chr(13) + Chr(10)
                        cMsg += "Excedeu o numero de tentativas no SEFAZ" + Chr(13) + Chr(10)
                        //cMsg += "Verifique a causa no monitor SEFAZ, realize os ajustes e transmita manualmente." + Chr(13) + Chr(10) + Chr(13) + Chr(10)      
                        Return .F.
                    EndIf		
                EndIf
            EndIf

            Sleep(1000 * nEeWaitF)
        Next nI			
    Else
        cMsg := "#" + DToC(Date()) + " - " + Time() + Chr(13) + Chr(10)
        cMsg += "SEFAZ nao configurado" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
    EndIf
      
Return .F.


/*/{Protheus.doc} GetListBox
Rotina que faz a verificacao no monitor do SEFAZ e 
passa um array com os dados da tranmissao
@type function
@version 1.0  
@author Dener Lemos - DOTHINK
@since 28/06/2022
@param cIdEnt, character, Id
@param cUrl, character, URL
@param aParam, array, Parametros
@param nTpMonitor, numeric, Tipo
@param cModelo, character, Modelo
@param lCte, logical, Indica CTe
@param lMsg, logical, Indica mensagem
@return array, Array com o resultado do monitor
/*/
Static Function GetListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg)
    Local aLote			 := {}
    Local aListBox		 := {}
    Local cId			 := ""
    Local cProtocolo	 := ""	
    Local cRetCodNfe	 := ""
    Local cAviso		 := ""
    Local nAmbiente		 := ""
    Local nModalidade	 := ""
    Local cRecomendacao	 := ""
    Local cTempoDeEspera := ""
    Local nTempomedioSef := ""
    Local nX			 := 0
    Local oOk			 := LoadBitMap( GetResources(), "ENABLE" )
    Local oNo			 := LoadBitMap( GetResources(), "DISABLE" )
            
    Default lMsg		 := .T.
    Default lCte		 := .F.
        
    //-- Processa Monitoramento
    aRetorno := procMonitorDoc( cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso )

    If Empty(cAviso)
        For nX := 1 To Len(aRetorno)				
            cId			   := aRetorno[nX][1]
            cProtocolo	   := aRetorno[nX][4]	
            cRetCodNfe	   := aRetorno[nX][5]
            nAmbiente	   := aRetorno[nX][7]
            nModalidade	   := aRetorno[nX][8]
            cRecomendacao  := aRetorno[nX][9]
            cTempoDeEspera := aRetorno[nX][10]
            nTempomedioSef := aRetorno[nX][11]
            aLote		   := aRetorno[nX][12]
                                    
            aAdd( aListBox, { IIF( Empty( cProtocolo ) .Or. cRetCodNfe $ RetCodDene(), oNo, oOk ),;
                              cId,;
                              IIF( nAmbiente == 1, "Produção", "Homologação" ),;
                              IIF( nModalidade == 1 .Or. nModalidade == 4 .Or. nModalidade == 6, "Normal", "Contingência" ),;
                              cProtocolo,;
                              cRecomendacao,;
                              cTempoDeEspera,;
                              nTempoMedioSef,;
                              aLote } )
        Next nX
    Else
        ConOut( "[Status Sefaz] - AVISO: " + cAviso )
    EndIf
        
Return aListBox 
