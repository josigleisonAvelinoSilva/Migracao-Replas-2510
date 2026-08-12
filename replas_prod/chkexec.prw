#include 'protheus.ch'

/*/{Protheus.doc} ChkExec
PE framework interfaces Protheus, disparado ao executar uma rotina no menu
@type function
@version 2
@author luiz.favareto
@since 13/09/2023
@history 14/09/2023, luiz.favareto, versao 2, somente executa para usuarios pre-definidos neste fonte
@return logical, permite ou nao prosseguir com a rotina
/*/
User Function ChkExec()
    Local aAreaAnt     := GetArea()
    Private nAmbReplas := 0
    If u_GetAmbiente() > 1
        ChkDev()
    Else    
        U_MCFGA005(ParamIxb)
    EndIf

    If aScan({'silvio',;
            'feige',;
            'gabriel.goncalves',;
            'luiz.favareto',;
            'erike.yury',;
            'fernando.muta',;
            'marcos.aversa',;
            'dothink'},;
            Alltrim(Lower(cUserName)))>0
        Processa({||ValidaDic()},'Aguarda, verificando ambiente ...')
    Endif

    SX2->(dbSetOrder(1))
    If SX2->(dbSeek("PBJ"))
        If SX2->(dbSeek("PBK"))
            audit()
        EndIf	
    EndIf

    RestArea(aAreaAnt)

Return .T.


/*/{Protheus.doc} ValidaDic
Valida dicionarios customizados
@type function
@version 1
@author luiz.favareto
@since 13/09/2023
@return logical, lRet, OK dicionario customizado valido
/*/
Static Function ValidaDic()
Local xAux
Local aDirectory
Local lRun      := .F.
Local lRet      := .T.
Local nVrfType  := 1
Local nVrfKey   := 2
Local nVrfCheck := 3
Local aVerify   := {;
                    {'X2_UNICO','NNT','NNT_FILIAL+NNT_COD+NNT_FILORI+NNT_PROD+NNT_LOCAL+NNT_LOCALI+NNT_NSERIE+NNT_LOTECT+NNT_NUMLOT+NNT_FILDES+NNT_PRODD+NNT_LOCLD+NNT_LOCDES+NNT_LOTED+NNT_TS+NNT_TE'},;
                    {'X3_TAMANHO','BM_TIPGRU ',6};
                   }
Local cPath     := '\checkdic\'
Local cFile     := 'chkexec.tmp'
Local cFullPath := cPath+cFile
Local nLoop
Local lX2unico
Local lX3tamanho
If IsSrvUnix()
    // para ambientes Unix ou Linux
    cPath     := STRTRAN(cPath,'\','/')
    cFullPath := STRTRAN(cFullPath,'\','/')
Endif
If !ExistDir(cPath)
    // criar diretorio de trabalho, visando velocidade por somente conter o arquivo de controle
    MakeDir(cPath)
Endif
lRun       := .T.
// verifica se existe arquivo para execucao ou nao das validacoes
aDirectory := Directory(cFullPath)
If Len(aDirectory)>0
    // verifica se arquivo esta com data e hora de agora
    If Dtos(aDirectory[1][3])+Left(aDirectory[1][4],2)==Left(FwTimeStamp(1),10)
        lRun := .F.
    Endif
Endif
If lRun
    For nLoop := 1 To Len(aVerify)
        lX2unico   := aVerify[nLoop][nVrfType]=='X2_UNICO'
        lX3tamanho := aVerify[nLoop][nVrfType]=='X3_TAMANHO'
        If lX2unico
            xAux := FwSX2Util():GetSX2data('NNT',{aVerify[nLoop][nVrfType]})
        Elseif lX3tamanho
            xAux := FWSX3Util():GetFieldStruct(aVerify[nLoop][nVrfKey])
        Endif
        If Len(xAux)>0
            If (lX2unico.And.!Alltrim(xAux[1][2])==Alltrim(aVerify[nLoop][nVrfCheck]));
                .Or.(lX3tamanho.And.!Str(xAux[3],3)==Str(aVerify[nLoop][nVrfCheck],3))
                MSGALERT('Alerta ! Detectado '+aVerify[nLoop][nVrfType]+' incorreto, chave '+aVerify[nLoop][nVrfKey]+', favor informar administrador do sistema imediatamente !!','ATENCAO')
                lRet := .F.
            Endif
        Endif
    Next
    MEMOWRITE(cFullPath,FwTimeStamp(1))
Endif
Return lRet


/*/{Protheus.doc} Audit
Rotina que grava informacoes do usuario ao acessar um rotina pelo menu do sistema
@type function
@version 1.0  
@author DO THINK - FERNANDO B. MUTA
@since 24/10/2024
/*/
static Function Audit()
    Local _aInfo  

	PBJ->(DbSetOrder(1))
	_lNew := !PBJ->(DbSeek(xFilial()+RetCodUsr()))
	RecLock("PBJ",_lNew)
	If _lNew
		PBJ->PBJ_IDUSER := RetCodUsr()
        PBJ->PBJ_LOGIN  := cUserName
		PBJ->PBJ_DTINC  := Date()
		PBJ->PBJ_FILTRO := "P"
	EndIf    
	PBJ->PBJ_IP     := GetClientIP()
	PBJ->PBJ_COMPUT := GetComputerName()
	PBJ->PBJ_ACESSO := Date()
	PBJ->PBJ_ENV    := GetEnvServer()
	PBJ->PBJ_HRACES := SubStr(Time(),1,5)
	PBJ->PBJ_EMP    := FWCodEmp()
	PBJ->PBJ_FIL    := FWCodFil()
	PBJ->PBJ_ESTAT  := PBJ->PBJ_ESTAT + 1
	PBJ->PBJ_VRPO   := U_VRPO()
	If !IsTelNet()
		_aInfo  := GetRmtInfo()
		PBJ->PBJ_SO     := _aInfo[2]
		PBJ->PBJ_MEM    := _aInfo[4]
		PBJ->PBJ_CPU    := _aInfo[5]
		PBJ->PBJ_MHZ    := _aInfo[6]
		PBJ->PBJ_CPUDET := _aInfo[7]
		PBJ->PBJ_ARQUIT := _aInfo[11]
		PBJ->PBJ_SMART  := _aInfo[13]
	Else
		PBJ->PBJ_SO     := "TELNET"
	EndIf

	PBJ->(MsUnlock())

	RecLock("PBK",.T.)
	PBK->PBK_IDUSER := RetCodUsr()
	PBK->PBK_LOGIN  := cUserName
	PBK->PBK_IP     := GetClientIP()
	PBK->PBK_COMPUT := GetComputerName()
	PBK->PBK_DATA   := Date()
	PBK->PBK_DTBASE := DDATABASE
	PBK->PBK_ENV    := GetEnvServer()
	PBK->PBK_HRACES := SubStr(Time(),1,5)
	PBK->PBK_FUNCAO := STRTRAN(ParamIXB,"()","")
	PBK->PBK_EMP    := FWCodEmp()
	PBK->PBK_FIL    := FWCodFil()
	PBK->PBK_VRPO   := U_VRPO()
	If !IsTelNet()
		PBK->PBK_SO     := _aInfo[2]
		PBK->PBK_MEM    := _aInfo[4]
		PBK->PBK_CPU    := _aInfo[5]
		PBK->PBK_MHZ    := _aInfo[6]
		PBK->PBK_CPUDET := _aInfo[7]
		PBK->PBK_ARQUIT := _aInfo[11]
		PBK->PBK_SMART  := _aInfo[13]
	Else
		PBK->PBK_SO     := "TELNET"
	EndIf

	PBK->(MsUnlock())

Return


/*/{Protheus.doc} AtuPbj
Rotina que atualiza tabela dos usuarios cadastrados
@type function
@version 1.0  
@author DO THINK - FERNANDO B. MUTA
@since 24/10/2024
/*/
User Function AtuPbj()
    Local _i

    WFPREPENV("01","10")
    _aUsers := AllUsers()
    DbSelectArea("PBJ")
    DbSetOrder(1)

    For _i:=1 to len(_aUsers)
        _lNew := !PBJ->(DbSeek(xFilial()+_aUsers[_i][1][1]))
        RecLock("PBJ",_lNew)
        If _lNew
            PBJ->PBJ_IDUSER := _aUsers[_i][1][1]
            PBJ->PBJ_DTINC := _aUsers[_i][1][24]
            PBJ->PBJ_FILTRO := "P"
        EndIF
        PBJ->PBJ_LOGIN := _aUsers[_i][1][2]
        PBJ->PBJ_NOME  := _aUsers[_i][1][4]     
        PBJ->PBJ_EMAIL := _aUsers[_i][1][14]
        PBJ->PBJ_STATUS:= IIF(_aUsers[_i][1][17],"B","L")
        PBJ->PBJ_LIMITE:= _aUsers[_i][1][15]
        PBJ->PBJ_DTATU := Date()
        PBJ->(MsUnlock())        
    Next

Return

/*/{Protheus.doc} GetAmbiente
Retorna o codigo do ambiente
@type function
@version 1.0  
@author DO THINK - FERNANDO B. MUTA
@since 09/01/2025
/*/
User Function GetAmbiente()
local _cDbAlias := ""
_cDbAlias := GetPvProfString( 'DBACCESS', 'Alias'	 , 'ERROR', GetADV97() )
If Empty(_cDbAlias) .OR. _cDbAlias == "ERROR"
    _cDbAlias := GetSrvProfString( 'DbAlias'   , _cDbAlias)
EndIf
If "HOM" $ GetEnvServer() .OR. ;
   "HML" $ GetEnvServer() .OR. ;
   "HML" $ _cDbAlias .OR. ;
   "HOM" $ _cDbAlias 
    nAmbReplas := 2 // Homologacao
ElseIf "DEV" $ GetEnvServer() .OR. ;
       "DES" $ GetEnvServer() .OR. ;
       "DEV" $ _cDbAlias .OR. ;
       "DES" $ _cDbAlias 
    nAmbReplas := 3 //Desenvolvimento
EndIf    

Return nAmbReplas

/*/{Protheus.doc} ChkDev
Update nos campos para ambientes não produtivos
@type function
@version 1.0  
@author DO THINK - FERNANDO B. MUTA
@since 09/01/2025
/*/
Static Function ChkDev()
Local cUpdUrl   := ""
Local cAmbiente := ""
If nAmbReplas > 1
    If nAmbReplas == 2
        cUpdUrl := "http://192.168.20.25:27101/"
        cAmbiente := "HOMOLOG"
    ElseIf nAmbReplas == 3
        cUpdUrl := "http://192.168.20.24:37101/"
        cAmbiente := "DESENV"
    EndIf
    cUpdate := " UPDATE " + RetSqlName("SX6") + " SET X6_CONTEUD = '"+cUpdUrl+"', X6_CONTENG = '"+cUpdUrl+"', X6_CONTSPA = '"+cUpdUrl+"' "
    cUpdate += " WHERE X6_VAR = 'MV_SPEDURL' "
    cUpdate += " AND   X6_CONTEUD <> '" + cUpdUrl + "' "
    If tcsqlexec(cUpdate)
        alert(tcsqlerror())
    EndIf

    cUpdate := " UPDATE XX1 SET XX1_ENV = '"+ cAmbiente +"' WHERE D_E_L_E_T_ = ' ' "
    If tcsqlexec(cUpdate)
        alert(tcsqlerror())
    EndIf

    cUpdate := " UPDATE XX0 SET XX0_PORTA = XX0_PORTA-10000+("+ strzero(nAmbReplas,1) + "*10000), XX0_ENV = '"+cAmbiente+"' WHERE D_E_L_E_T_ = ' ' "
    If tcsqlexec(cUpdate)
        alert(tcsqlerror())
    EndIf


EndIf
Return
