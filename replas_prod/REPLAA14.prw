#INCLUDE "fileio.ch"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#include "totvs.ch"
#include "topconn.ch"

//*********************************S**************//
//Funcao: dt01094                               //
//Autor: Fernando Brito Muta                     //
//Data: 01/05/2024                               //
//Objetivo: Monitoramento de Jobs               //
//***********************************************//

User Function replaa14(aParam)
local cQry := ""
local _cAssunto  := "Monitoramento de processos - " + GetEnvServer()
local _cFileHtm  := "replasfiles\tmp\"+"Monit.htm"
local _cHtm      := ""
Private _cEol    := Chr(13)+Chr(10)
Private _aAnexos := {}
Private _nTotNot := 0
Default nOpc     := 99
If IsBlind()
    wfprepenv(aParam[1],aParam[2])
EndIf    

_aDest  := {}

ferase(_cFileHtm)

cQry := " SELECT Z9E_GRUPO, Z9E_DESCRI "
cQry += " FROM "+RetSqlName("Z9E")+" Z9E "
cQry += " WHERE Z9E.D_E_L_E_T_ = ' ' "
cQry += " ORDER BY Z9E_GRUPO "
If Select("TRBMON")>0
    TRBMON->(DbCloseArea())
EndIf    
TcQuery cQry New Alias "TRBMON"

TRBMON->(DbGotop())
While !TRBMON->(Eof())
     _nTotNot := 0
    Processa({|| _cHtm  := RetHtm(TRBMON->Z9E_GRUPO) })

    //memowrit(_cFileHtm,_cHtm )

    //AADD(_aAnexos,_cFileHtm)
    _cAssunto := "Monitoramento REPLAS - " + TRBMON->Z9E_DESCRI
    If "DES"$GetEnvServer() .OR. "HOM"$GetEnvServer()
        _aDest := {"fernando.muta@dothink.com.br"}
    Else
        _aDest := GetEmail(TRBMON->Z9E_GRUPO)
    EndIf    
    If  _nTotNot > 0 .OR. SubStr(Time(),1,2) == "08"
        U_REPLAA15( _aDest , _cAssunto , _cHtm , _aAnexos,"Monitoramento de processos" )
    EndIf    
    _aAnexos :={}
    TRBMON->(DBSkip())
End

Return

Static Function GetEmail(cGrupo)
local aRet := {}
local cQry := ""
cQry := "SELECT Z9G_EMAIL From " + RetSqlName("Z9G")
cQry += " WHERE Z9G_FILIAL = '" +xFilial("Z9G")+ "' "
cQry += " AND   Z9G_GRUPO  = '" +cGrupo+"' "
cQry += " AND   D_E_L_E_T_ = ' ' "
If Select("TRMAIL")>0
    TRMAIL->(DbCloseArea())
EndIf    
TCQUERY cQry New Alias "TRMAIL"
aadd(aRet,"naoresponda@replas.com.br")
While !TRMAIL->(Eof())
    AADD(aRet,TRMAIL->Z9G_EMAIL)
    TRMAIL->(dbSkip())
end
Return aRet


Static Function RetHtm(cGrupo)
local _cHtm := ""
local _cEol := Chr(13)+Chr(10)
local i     :=0
local cQuery:=0

cQry := " SELECT Z9E_GRUPO, Z9E_DESCRI, Z9F_MONIT, Z9D.R_E_C_N_O_ RECZ9D "
cQry += " FROM "+RetSqlName("Z9F")+" Z9F "
cQry += " INNER JOIN "+RetSqlName("Z9D")+" Z9D ON Z9F_MONIT = Z9D_ID AND Z9D.D_E_L_E_T_ = ' ' "
cQry += " INNER JOIN "+RetSqlName("Z9E")+" Z9E ON Z9F_GRUPO=Z9E_GRUPO AND  Z9E.D_E_L_E_T_ = ' ' "
cQry += " WHERE Z9F.D_E_L_E_T_ = ' ' "
cQry += " AND   Z9E_GRUPO = '"+cGrupo+"' "
cQry += " ORDER BY Z9E_GRUPO,Z9D_SEQ "
If Select("TRBMONC")>0
    TRBMONC->(DbCloseArea())
EndIf
TcQuery cQry New Alias "TRBMONC"

DbSelectArea("Z9D")
DbGotop()
ProcRegua(RecCount())
While !TRBMONC->(Eof())
    IncProc(Z9D->Z9D_TITULO)
    Z9D->(DbGoto(TRBMONC->(RECZ9D)))
    _cHrIni := Time()
    If Z9D->Z9D_ATIVO == 'N'
        TRBMONC->(DbSkip())
        Loop
    EndIf 
    cQuery := Alltrim(Z9D->Z9D_QUERY)
    If "SELECT" $ UPPER(cQuery) .AND. "FROM" $ UPPER(cQuery)
        cQuery := Z9D->Z9D_QUERY

        TCQUERY cQuery new Alias "TRBZ9" 
        DbSelectArea("TRBZ9")
        TRBZ9->(DbGotop())
        nCnt := 0
        DbEval( {|| nCnt++ }) 
        TRBZ9->(DbGotop())

        _cHtmAux := '    <head> ' + _cEol
        _cHtmAux += '       <title>HTML Table Background</title> ' + _cEol
        _cHtmAux += '    </head> ' + _cEol
        _cHtmAux += '       <table border = "1" bordercolor = "green"> ' + _cEol
        _cHtmAux += '    <b>' +Z9D->Z9D_TITULO+ '</b><br>'
        _cHtmAux += '          <tr> ' + _cEol
        _cHtmAux += '             <th>Item</th> ' + _cEol
        for i:=1 to TRBZ9->(Fcount())
            _cHtmAux += '             <th>'+Capital(TRBZ9->(FieldName(i)))+'</th> ' + _cEol
        next
        _cHtmAux += '          </tr> ' + _cEol
        nCont := 1
        While !TRBZ9->(Eof())
            _cHtmAux += "<tr>" + _cEol
            _cHtmAux += '             <td>'+strzero(nCont,4)+'</td> ' + _cEol
            for i:=1 to TRBZ9->(Fcount())
                xValue := TRBZ9->(FieldGet(i))
                If  Valtype(xValue) = "N"
                    xValue := Transform(xValue,"@E 99,999,999.99")
                ElseIf   Valtype(xValue) = "D"
                    xValue := DTOC(xValue)
                EndIf    
                _cHtmAux += '             <td>'+xValue+'</td> ' + _cEol
                _nTotNot++
            next
            nCont++
            _cHtmAux += "</tr>"
            TRBZ9->(DbSkip())
        End
        _cHtmAux += " </table> " + _cEol
        If nCnt <= 15
            _cHtm +=  _cHtmAux
        Else    
            _cHtm +=  '    <b>' +Z9D->Z9D_TITULO+ ' <br> 
            _cHtm +=  '    *** VER ANEXO '+transform(nCnt,"@E 9,999,999")+' linhas *** </b><br>'
            _cFileHtm := Alltrim(Z9D->Z9D_TITULO)
            _cCarac := " ,.;/<>:?!@#$%'&*()+=\|"
            for i:=1 to len(_cCarac)
                _cFileHtm := strtran(_cFileHtm,substr(_cCarac,i,1),"")
            Next
            _cFileHtm := _cFileHtm + ".htm"
            ferase(_cFileHtm)
            MemoWrit("replasfiles\tmp\"+_cFileHtm,_cHtmAux)
            aadd(_aAnexos,"replasfiles\tmp\"+_cFileHtm)
        EndIf                       
        //_cHtm += " </body> " + _cEol
        _cHtm += "<br><br>"
        TRBZ9->(DbCloseArea())
    ElseIf "\" $ Z9D->Z9D_QUERY
        nLinhas := SubStr(Z9D->Z9D_QUERY,1,2)
        cDirect := Alltrim(SubStr(Z9D->Z9D_QUERY,3,300))
        _cHtm += RetHtm3(Z9D->Z9D_TITULO,cDirect,nLinhas)
        _cHtm += "<br><br>"
    EndIf
    RecLock("Z9D",.F.)
    Z9D->Z9D_TEMPO := ELAPTIME(_cHrIni,Time())
    Z9D->(MsUnlock())
    TRBMONC->(DbSkip())
End

Return _cHtm 



/*
Funcao: RetHtm3
Data  : 2305/2022
Nome  : Fernando Brito Muta
Descri: Retorna html gerado conforme tabela Z9D com leitura de pastas
*/
Static Function RetHtm3(cTitulo,cDir,nLinhas)
local i := 0
local aFiles := Directory(cDir)
local _cHtm  := ""
aSort(aFiles, , , {|x, y| x[3] > y[3]}) 
If nLinhas > "00" .AND. nLinhas <= "99"
    nLinhas := Val(nLinhas)
Else
    Return ("")
EndIf    

_cHtm += '    <head> ' + _cEol
_cHtm += '       <title>HTML Table Background</title> ' + _cEol
_cHtm += '    </head> ' + _cEol
_cHtm += '       <table border = "1" bordercolor = "green"> ' + _cEol
_cHtm += '    <b>'+Alltrim(cTitulo)+'</b>'
_cHtm += '          <tr> ' + _cEol
_cHtm += '          <th>Arquivo</th> ' + _cEol
_cHtm += '          <th>Data</th> ' + _cEol
_cHtm += '          <th>Hora</th> ' + _cEol
_cHtm += '          </tr>' + _cEol

For i:=1 to len(aFiles)
    If i > nLinhas
        Exit
    EndIf 
    _cHtm += '          <tr> ' + _cEol
    _cHtm += '          <th>'+aFiles[i][1]+'</th> ' + _cEol
    _cHtm += '          <th>'+dtoc(aFiles[i][3])+'</th> ' + _cEol
    _cHtm += '          <th>'+aFiles[i][4]+'</th> ' + _cEol
    _cHtm += '          </tr> ' + _cEol
 Next
_cHtm += " </table> "
return _cHtm
