#Include 'Protheus.ch'
#Include "FwBrowse.ch"

STATIC D9USUARIO  := 'NUMERO_RESERVADO_NAO_USAR'
STATIC D9MOTIVO   := 'RESERVADO_PARA_CONTROLE_INTERNO'
STATIC INUT_MOTIV := 'NUMERO_INUTILIZADO_NO_SEFAZ'

 /*/{Protheus.doc} REPLA970
     Rotina para fazer reserva de números de Nota Fiscal.
     @type  User Function
     @author Robson Gonçalves - RLEG
     @since 21/09/2021
     @Há 3 situações: 1. registro utilizado pelo sistema (preto)
                      2. registro reservado pelo usuário (vermelho)
                      3. registro disponível (verde)
     /*/
User Function REPLA970()
    Local aCoors := {}
    Local aReserv := {}
    Local oBrowse
    Local oColumn
    Local oDlg

    Private cTitulo := "Reservar Nº de NF"
    Private aD9_RECNO := {}
    
    DbSelectArea('SD9')
    SD9->(DbOrderNickName('SERIEDOC'))
    SD9->(DbGoTop())

    aCoors := FWGetDialogSize(oMainWnd)
    DEFINE MSDIALOG oDlg TITLE "" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
        oDlg:lEscClose := .F.

        DEFINE FWFORMBROWSE oBrowse;
            DATA TABLE ALIAS "SD9";
            FILTER;
            FILTER FILTERTOPBOT "D9_FILIAL",xFilial("SD9"),xFilial("SD9");
            DOUBLECLICK {|oBrowse| Iif((Empty(SD9->D9_DTUSO).AND.Empty(SD9->D9_HORA).AND.Empty(SD9->D9_USUARIO)).OR.(SD9->D9_USUARIO==D9USUARIO),A970Mrk(),;
                                   FwAlertWarning("Documento indisponível, selecione outro documento.",cTitulo)) };
            DESCRIPTION cTitulo;
            NO CONFIG;
            /*NO REPORT*/;
            NO DETAILS OF oDlg

            ADD LEGEND DATA 'Empty(SD9->D9_USUARIO).AND.Empty(SD9->D9_DTUSO).AND.Empty(SD9->D9_HORA)';
                COLOR "GREEN";
                TITLE "Disponível" OF oBrowse

            ADD LEGEND DATA 'RTrim(SD9->D9_USUARIO)=="'+D9USUARIO+'".AND.RTrim(SD9->D9_MOTIVO)=="'+D9MOTIVO+'".AND..NOT.Empty(SD9->D9_DTUSO).AND..NOT.Empty(SD9->D9_HORA)';
                 COLOR "RED";
                 TITLE "Reservado" OF oBrowse

            ADD LEGEND DATA 'RTrim(SD9->D9_MOTIVO)=="'+INUT_MOTIV+'".AND..NOT.Empty(SD9->D9_DTUSO).AND..NOT.Empty(SD9->D9_HORA).AND.RTrim(SD9->D9_USUARIO)<>"'+D9USUARIO+'"';
                COLOR "PINK";
                TITLE "Inutilizado" OF oBrowse

            ADD LEGEND DATA 'RTrim(SD9->D9_USUARIO)<>"'+D9USUARIO+'".AND..NOT.Empty(SD9->D9_USUARIO).AND.RTrim(SD9->D9_MOTIVO)<>"'+D9MOTIVO+'"';
                COLOR "BLACK";
                TITLE "Indisponível" OF oBrowse
            
            ADD COLUMN oColumn DATA {|| SD9->D9_FILIAL}  TITLE "Filial"    SIZE  4 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_SERIE}   TITLE "Série"     SIZE  3 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_DOC}     TITLE "Documento" SIZE 10 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_DTUSO}   TITLE "Data"      SIZE 10 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_HORA}    TITLE "Hora"      SIZE  4 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_USUARIO} TITLE "Usuário"   SIZE 40 OF oBrowse
            ADD COLUMN oColumn DATA {|| SD9->D9_MOTIVO}  TITLE "Motivo"    SIZE 40 OF oBrowse

            ADD BUTTON oButton TITLE "Sair"  ACTION {|| Iif(FWAlertYesNo('Deseja realmente sair da rotina?',cTitulo),(oDlg:End()),NIl) } OF oBrowse
            //ADD BUTTON oButton TITLE "Inutilizar Nº" ACTION {|| A970Inut(), oBrowse:Refresh()} OF oBrowse
        ACTIVATE FWBROWSE oBrowse
    ACTIVATE MSDIALOG oDlg CENTERED

    If Len(aD9_RECNO)>0
        aSort(aD9_RECNO,,,{|a,b| a<b})
        AAdd(aReserv,{'SEQ','FILIAL','SÉRIE','DOCUMENTO','DATA','HORA','USUÁRIO','RECNO'})
        For i := 1 To Len(aD9_RECNO)
            SD9->(dbGoTo(aD9_RECNO[i]))
            AAdd(aReserv,{LTrim(Str(i)),SD9->D9_FILIAL,SD9->D9_SERIE,SD9->D9_DOC,Dtoc(SD9->D9_DTUSO),Stuff(SD9->D9_HORA,3,0,':'),RTrim(cUserName),LTrim(Str(SD9->(RecNo())))})
        Next i
        
        FWMsgRun(,{|| DlgToExcel({{"ARRAY","",{'LOG DE RESERVA ['+Dtoc(MsDate())+']'},aReserv}},NIL)},,'Gerando planilha com os números reservados...')
    Endif
Return

/*/{Protheus.doc} A970Mrk()
    Rotina para reservar ou retirar a reserva do registro.
    @type  Function
    @author Robson Gonçalves - RLEG
    @since 21/09/2021
    /*/
Static Function A970Mrk()
    Local p := 0
    Local cTime := StrTran(Substr(Time(),1,5),':','')
    Local nRecNo := 0

    nRecNo := SD9->(RecNo())

    If SD9->D9_USUARIO==D9USUARIO .AND. RTrim(SD9->D9_MOTIVO)==D9MOTIVO
        SD9->(RecLock("SD9",.F.))
            SD9->D9_DTUSO   := Ctod("  /  /  ")
            SD9->D9_HORA    := ""
            SD9->D9_USUARIO := ""
            SD9->D9_MOTIVO  := ""
        SD9->(MsUnLock())

        p := AScan(aD9_RECNO,SD9->(RecNo()))
        If p > 0
            aDEL(aD9_RECNO,p)
            aSize(aD9_RECNO,Len(aD9_RECNO)-1)
        Endif
    Elseif Empty(SD9->D9_DTUSO) .AND. Empty(SD9->D9_HORA) .AND. Empty(SD9->D9_USUARIO)
        SD9->(RecLock("SD9",.F.))
            SD9->D9_DTUSO   := MsDate()
            SD9->D9_HORA    := cTime
            SD9->D9_USUARIO := D9USUARIO
            SD9->D9_MOTIVO  := D9MOTIVO
        SD9->(MsUnLock())

        AAdd(aD9_RECNO,SD9->(RecNo()))
    Else
        FwAlertWarning("Registro indisponível, selecione outro registro.",cTitulo)
    Endif

    SD9->(DbOrderNickName('SERIEDOC'))
    SD9->(dbGoTo(nRecNo))
Return

/*
Static Function A970Inut()
    Local lAtivar := .F.
    Local lInutil := .F.
    Local nRecNo := 0

    nRecNo := SD9->(RecNo())

    If RetCodUsr() $ GetNewPar("MV_A970INU","000000","000004","000091")
        lInutil := Empty(SD9->D9_DTUSO) .AND. Empty(SD9->D9_HORA) .AND. Empty(SD9->D9_USUARIO) .AND. Empty(SD9->D9_MOTIVO)
        lAtivar := .NOT. Empty(SD9->D9_DTUSO) .AND. .NOT. Empty(SD9->D9_HORA) .AND. .NOT. Empty(SD9->D9_USUARIO) .AND. RTrim(SD9->D9_MOTIVO)==INUT_MOTIV

        If lInutil .AND. .NOT. lAtivar
            If FWAlertYesNo('Tem certeza que deseja inutilizar o número de nota fiscal em questão?',cTitulo)
                SD9->(RecLock("SD9",.F.))
                    SD9->D9_DTUSO   := MsDate()
                    SD9->D9_HORA    := StrTran(Substr(Time(),1,5),':','')
                    SD9->D9_USUARIO := cUserName
                    SD9->D9_MOTIVO  := INUT_MOTIV
                SD9->(MsUnLock())
            Endif
        Elseif .NOT. lInutil .AND. lAtivar
            If RTrim(SD9->D9_USUARIO)==RTrim(cUserName)
                If FWAlertYesNo('Tem certeza que deseja disponibilizar o número de nota fiscal que foi inutilizado no SEFAZ?',cTitulo)
                    SD9->(RecLock("SD9",.F.))
                        SD9->D9_DTUSO   := Ctod('  /  /  ')
                        SD9->D9_HORA    := ''
                        SD9->D9_USUARIO := ''
                        SD9->D9_MOTIVO  := ''
                    SD9->(MsUnLock())
                Endif
            Else
                FwAlertWarning('Somente o usuário que inutilizou o nº de nota fiscal é quem poderá reativá-lo.',cTitulo)
            Endif
        Else
            FwAlertWarning('Opção diferente para inutilizar ou reativar o nº de nota fiscal.',cTitulo)
        Endif
    Else
        FwAlertWarning('Usuário sem permissão para a operação de inutilizar ou reativar o nº de nota fiscal.',cTitulo)
    Endif
    SD9->(DbOrderNickName('SERIEDOC'))
    SD9->(dbGoTo(nRecNo))
Return
*/

//#################################################################################################
//# A ROTINA ABAIXO É OBSOLETA.
//#################################################################################################

STATIC oMrk       := LoadBitmap(,'NGCHECKOK.PNG')
STATIC oNoMrk     := LoadBitmap(,'NGCHECKNO.PNG')
STATIC RESERVADO  := LoadBitmap(,'DISABLE')
STATIC NAORESERV  := LoadBitmap(,'ENABLE')

User Function REPLA971()
	Local aButton := {}
	Local aSay := {}
	
	Local nOpcao := 0
	
	Private cCadastro := 'Reservar Nº de NF'
	
	AAdd( aSay, 'Esta programa tem como objetivo reservar números de notas fiscais ou retirar a')
	AAdd( aSay, 'reserva.')
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, '' )
	AAdd( aSay, 'Clique em OK para prosseguir...' )
		
	AAdd( aButton, { 01, .T., { || nOpcao := 1, FechaBatch() } } )
	AAdd( aButton, { 22, .T., { || FechaBatch() } } )
	
    FormBatch( cCadastro, aSay, aButton )
	
	If nOpcao == 1
        If GetMV("MV_TPNRNFS") == "3"
		    R971Param()
        Else
            FwAlertWarning('Parâmetro MV_TPNRNFS não configurado para esta opção.',cCadastro)
        Endif
	Endif
Return

Static Function R971Param()
    Local aPar := {}
    Local aRet := {}

    AAdd(aPar,{3,"Selecione o procedimento",1,{"Reservar","Retirar a reserva"},90,"",.T.})
    AAdd(aPar,{1,'Série da NF' ,Space(Len(SF2->F2_SERIE)) ,'','','','',30,.T.})

    If ParamBox( aPar, 'Parâmetros', @aRet )
        dbSelectArea('SD9')
        SD9->(dbSetOrder(1))

        If aRet[1]==1
            R971Reservar(aRet[2])
        Elseif aRet[1]==2
            cCadastro := 'Retirar a reserva da NF' 
            R971RetirarReserva(aRet[2])
        Endif
    Endif
Return

Static Function R971Reservar(cSerieNF)
    Local aDados := {}

    Local cSQL := ''
    Local cTRB := ''

    Local oBar
    Local oDlg
    Local oLbx
    Local oPnl1
    Local oPnl2
    Local oThb1
    
    Private aReserv := {}

    cSQL := "SELECT TOP 30 D9_FILIAL, D9_DOC, D9_SERIE, D9_DTUSO, D9_HORA, D9_USUARIO, SD9.R_E_C_N_O_ AS D9_RECNO "
    cSQL += "  FROM "+RetSqlName("SD9")+" SD9 "
    cSQL += " WHERE D9_FILIAL = "+ValToSql(xFilial("SD9"))+" "
    cSQL += "       AND D9_SERIE = "+ValToSql(cSerieNF)+" "
    cSQL += "       AND D9_DTUSO = ' ' "
    cSQL += "       AND D9_HORA = ' ' "
    cSQL += "       AND D9_USUARIO = ' ' "
    cSQL += "       AND D9_MOTIVO = ' ' "
    cSQL += "       AND SD9.D_E_L_E_T_ = ' ' "
    cSQL += " ORDER BY D9_FILIAL, D9_SERIE, D9_DOC "

    cSQL := ChangeQuery( cSQL )

    cTRB := GetNextAlias()
    dbUseArea( .T., 'TOPCONN', TCGenQry(,,cSQL), cTRB, .T., .T. )
    If (cTRB)->(.NOT. BOF()) .AND. (cTRB)->(.NOT. EOF())
        While (cTRB)->( .NOT. EOF() )
            
            AAdd(aDados,{.F.,;
                         Iif(Empty((cTRB)->D9_DTUSO).AND.Empty((cTRB)->D9_HORA).AND.Empty((cTRB)->D9_USUARIO),0,1),;
                         (cTRB)->D9_FILIAL,;
                         (cTRB)->D9_SERIE,;
                         (cTRB)->D9_DOC,;
                         (cTRB)->D9_RECNO,;
                         ''})
            (cTRB)->( dbSkip() )
        End

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 500,600 PIXEL STYLE DS_MODALFRAME STATUS
            oDlg:lEscClose := .F.

            oPnl1:= TPanel():New(2,2,,oDlg,,,,,,60,26)
            oPnl1:Align := CONTROL_ALIGN_ALLCLIENT
            
            oPnl2:= TPanel():New(2,2,,oPnl1,,,,,RGB(100,100,100),1,13)
            oPnl2:Align := CONTROL_ALIGN_BOTTOM
        
            oBar := TBar():New( oPnl2, 10, 9, .T.,'BOTTOM')
            oThb1 := THButton():New(1,1, 'Sair'  , oBar,{|| Iif(FWAlertYesNo('Deseja realmente sair da rotina?',cCadastro),;
            (Iif(Len(aReserv)>1,(DlgToExcel({{"ARRAY","",{'LOG DE RESERVA ['+Dtoc(MsDate())+']'},aReserv}},NIL),oDlg:End()),oDlg:End())),NIL)}, 25, 9 )
            oThb1:Align := CONTROL_ALIGN_RIGHT

            oLbx := TwBrowse():New(0,0,0,0,,{'','','Filial','Série','Documento','RecNo',''},,oPnl1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oLbx:Align := CONTROL_ALIGN_ALLCLIENT
            oLbx:SetArray( aDados )
            oLbx:bLine := {|| {Iif(aDados[oLbx:nAt,1],oMrk,oNoMrk),;
                               Iif(aDados[oLbx:nAt,2]==0,NAORESERV,RESERVADO),;
                               aDados[oLbx:nAt,3],;
                               aDados[oLbx:nAt,4],;
                               aDados[oLbx:nAt,5],;
                               aDados[oLbx:nAt,6],;
                               aDados[oLbx:nAt,7]}}
            oLbx:bLDblClick := {|| A971Mark(oLbx) }

        ACTIVATE MSDIALOG oDlg CENTER
    Else
        FwAlertWarning('Dados não localizados para processar.',cCadastro)
    Endif
    (cTRB)->(dbCloseArea())
Return

Static Function A971Mark(oLbx)
    Local cTime := StrTran(Substr(Time(),1,5),':','')
    Local dD9_DTUSO := MsDate()
    Local nI := 0
    Local nL := 0
    Local p := 0

    SD9->(dbGoTo(oLbx:aArray[oLbx:nAt,6]))
    If SD9->(RecNo())==oLbx:aArray[oLbx:nAt,6]
        If .NOT. oLbx:aArray[oLbx:nAt,1]
            If Empty(SD9->D9_DTUSO) .AND. Empty(SD9->D9_HORA) .AND. Empty(SD9->D9_USUARIO)
                SD9->(RecLock('SD9',.F.))
                    SD9->D9_DTUSO   := dD9_DTUSO
                    SD9->D9_HORA    := cTime
                    SD9->D9_USUARIO := D9USUARIO
                    SD9->D9_MOTIVO  := D9MOTIVO
                SD9->(MsUnLock())
                oLbx:aArray[oLbx:nAt,1] := .T.
                oLbx:aArray[oLbx:nAt,2] := 1
                nL := Len(aReserv)
                If nL==0
                    nL++
                    AAdd(aReserv,{'SEQ','FILIAL','SÉRIE','DOCUMENTO','DATA','HORA','USUÁRIO','RECNO'})
                Endif
                AAdd(aReserv,{LTrim(Str(nL)),SD9->D9_FILIAL,SD9->D9_SERIE,SD9->D9_DOC,Dtoc(dD9_DTUSO),Stuff(cTime,3,0,':'),RTrim(cUserName),LTrim(Str(SD9->(RecNo())))})
            Else
                FwAlertWarning('Este número foi utilizado, selecione outro.',cCadastro)
            Endif
        Else
            If SD9->D9_USUARIO==D9USUARIO .AND. RTrim(SD9->D9_MOTIVO)==D9MOTIVO
                SD9->(RecLock('SD9',.F.))
                    SD9->D9_DTUSO   := Ctod('  /  /  ')
                    SD9->D9_HORA    := ""
                    SD9->D9_USUARIO := ""
                    SD9->D9_MOTIVO  := ""
                SD9->(MsUnLock())
                oLbx:aArray[oLbx:nAt,1] := .F.
                oLbx:aArray[oLbx:nAt,2] := 0
                p := AScan(aReserv,{|e| e[2]==SD9->D9_FILIAL .AND. e[3]==SD9->D9_SERIE .AND. e[4]==SD9->D9_DOC})
                If p > 0
                    aDEL(aReserv,p)
                    aSize(aReserv,Len(aReserv)-1)
                    For nL := 2 To Len(aReserv)
                        aReserv[nL,1] := LTrim(Str(++nI))
                    Next nL
                Endif
            Else
                FwAlertWarning('Este número não corresponde a registro reservado.',cCadastro)
            Endif
        Endif
    Else
        FwAlertWarning('Registro não localizado para reservar.',cCadastro)
    Endif
Return

Static Function R971RetirarReserva(cSerieNF)
    Local aDados := {}

    Local cSQL := ''
    Local cTRB := ''

    Local oBar
    Local oDlg
    Local oLbx
    Local oPnl1
    Local oPnl2
    Local oThb1
    Local oThb2

    cSQL := "SELECT TOP 30 D9_FILIAL, D9_DOC, D9_SERIE, SD9.R_E_C_N_O_ AS D9_RECNO "
    cSQL += "  FROM "+RetSqlName("SD9")+" SD9 "
    cSQL += " WHERE D9_FILIAL = "+ValToSql(xFilial("SD9"))+" "
    cSQL += "       AND D9_SERIE = "+ValToSql(cSerieNF)+" "
    cSQL += "       AND D9_DTUSO <> ' ' "
    cSQL += "       AND D9_HORA <> ' ' "
    cSQL += "       AND D9_USUARIO = "+ValToSql(D9USUARIO)+" "
    cSQL += "       AND D9_MOTIVO = "+ValToSql(D9MOTIVO)+" "
    cSQL += "       AND SD9.D_E_L_E_T_ = ' ' "
    cSQL += " ORDER BY D9_FILIAL, D9_SERIE, D9_DOC "

    cSQL := ChangeQuery( cSQL )

    cTRB := GetNextAlias()
    dbUseArea( .T., 'TOPCONN', TCGenQry(,,cSQL), cTRB, .T., .T. )
    If (cTRB)->(.NOT. BOF()) .AND. (cTRB)->(.NOT. EOF())
        While (cTRB)->( .NOT. EOF() )
            AAdd(aDados,{.F.,(cTRB)->D9_FILIAL,(cTRB)->D9_SERIE,(cTRB)->D9_DOC,(cTRB)->D9_RECNO,''})
            (cTRB)->( dbSkip() )
        End

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 500,600 PIXEL
            oPnl1:= TPanel():New(2,2,,oDlg,,,,,,60,26)
            oPnl1:Align := CONTROL_ALIGN_ALLCLIENT
            
            oPnl2:= TPanel():New(2,2,,oPnl1,,,,,RGB(100,100,100),1,13)
            oPnl2:Align := CONTROL_ALIGN_BOTTOM
        
            oBar := TBar():New( oPnl2, 10, 9, .T.,'BOTTOM')
            oThb2 := THButton():New(1,1, 'Sair'  , oBar,{|| oDlg:End()}, 25, 9 )
            
            oThb1 := THButton():New(1,1, 'Retirar a reservar', oBar,{|| nP:=Ascan(oLbx:aArray,{|e|e[1]==.T.}),;
            Iif(nP>0,(MsAguarde({|| R971DoRetirarReserv(oLbx)},'Retirando a reserva','Início do processo, aguarde...',.F.),;
            oDlg:End()),(MsgAlert('Selecione o(s) documento(s)',cCadastro),NIL))}, 50, 9 )
            
            oThb2:Align := CONTROL_ALIGN_RIGHT
            oThb1:Align := CONTROL_ALIGN_RIGHT
            
            oLbx := TwBrowse():New(0,0,0,0,,{' x','Filial','Série','Documento','RecNo',''},,oPnl1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oLbx:Align := CONTROL_ALIGN_ALLCLIENT
            oLbx:SetArray( aDados )
            oLbx:bLine := {|| {Iif(aDados[oLbx:nAt,1],oMrk,oNoMrk),aDados[oLbx:nAt,2],aDados[oLbx:nAt,3],aDados[oLbx:nAt,4],aDados[oLbx:nAt,5],aDados[oLbx:nAt,6]}}
            oLbx:bLDblClick := {|| aDados[ oLbx:nAt, 1 ] := .NOT. aDados[ oLbx:nAt, 1 ] }
        ACTIVATE MSDIALOG oDlg CENTER
    Else
        FwAlertWarning('Dados não localizados para processar.',cCadastro)
    Endif
    (cTRB)->(dbCloseArea())
Return

Static Function R971DoRetirarReserv(oLbx)
    Local i := 0
    For i := 1 To Len(oLbx:aArray)
        If oLbx:aArray[i,1]
            SD9->(dbGoTo(oLbx:aArray[i,5]))
            If SD9->(RecNo())==oLbx:aArray[i,5]
                SD9->(RecLock('SD9',.F.))
                SD9->D9_DTUSO   := Ctod('  /  /  ')
                SD9->D9_HORA    := ''
                SD9->D9_USUARIO := ''
                SD9->D9_MOTIVO  := ''
                SD9->(MsUnLock())
            Endif
        Endif
    Next i
Return

//#################################################################################################
//# A ROTINA ACIMA É OBSOLETA
//#################################################################################################

User Function A970SD9()
    If FWIsAdmin(RetCodUsr())
        If FWAlertYesNo('Esta rotina irá corrigir os registro do SD9 que foram reservados para nota fiscal complementar de ICMS. Continuar?','Ajustar SD9 reservado')
            GoSD9()
        Endif
    Else
        FwAlertWarning('Rotina permitida ser executada por usuários Administradores.','Corrigir SD9')
    Endif
Return

Static Function GoSD9()
    Local cD9_HORA := ''
    Local cD9_USUARIO := ''
    Local cQry := ''
    Local cSQL := ''
    Local cTab := ''
    Local cTRB := GetNextAlias()

    dbSelectArea('SF1')
    SF1->(dbSetOrder(1))

    dbSelectArea('SD9')
    SD9->(dbSetOrder(1))

    cSQL := "SELECT SD9.R_E_C_N_O_ AS D9_RECNO "
    cSQL += "  FROM SD9010 SD9 "
    cSQL += " WHERE D9_DTUSO <> ' ' AND D9_HORA <> ' ' AND SD9.D_E_L_E_T_ =  ' ' AND (D9_USUARIO = 'RESERVADO' OR D9_USUARIO = 'RESERVA')"

    cSQL := ChangeQuery(cSQL)
    cTRB := GetNextAlias()
    dbUseArea( .T., 'TOPCONN', TCGenQry(,,cSQL), cTRB, .T., .T. )
    If (cTRB)->(.NOT. BOF()) .AND. (cTRB)->(.NOT. EOF())
         While (cTRB)->( .NOT. EOF() )
            
            SD9->(dbGoTo((cTRB)->D9_RECNO))

            cQry := "SELECT F1_EMISSAO, F1_HORA, F1_USERLGI "
            cQry += "  FROM SF1010 SF1 "
            cQry += " WHERE F1_FILIAL = "+ValToSql(SD9->D9_FILIAL)+" "
            cQry += "       AND F1_DOC = "+ValToSql(SD9->D9_DOC)+" "
            cQry += "       AND F1_SERIE = "+ValToSql(SD9->D9_SERIE)+" "
            cQry += "       AND F1_FORMUL = 'S' "
            cQry += "       AND D_E_L_E_T_ = ' ' "

            cQry := ChangeQuery(cQry)
            cTab := GetNextAlias()
            dbUseArea( .T., 'TOPCONN', TCGenQry(,,cQry), cTab, .T., .T. )
            If (cTab)->(.NOT. BOF()) .AND. (cTab)->(.NOT. EOF())
                cD9_HORA := SubStr(StrTran((cTab)->F1_HORA,':',''),1,4)
                cD9_USUARIO := RTrim(FwLeUserLg(cTab+'->F1_USERLGI'))

                SD9->(RecLock('SD9',.F.))
                SD9->D9_DTUSO := Stod((cTab)->F1_EMISSAO)
                SD9->D9_HORA := cD9_HORA
                SD9->D9_USUARIO := cD9_USUARIO
                SD9->D9_MOTIVO := '#@#@'
                SD9->(MsUnLock())
            Endif
            (cTab)->(dbCloseArea())

            (cTRB)->( dbSkip() )
         End
    Else
        FwAlertWarning('Dados não localizados para processar.','Ajustar SD9 reservado')
    Endif
    (cTRB)->(dbCloseArea())
Return
