#INCLUDE "PROTHEUS.CH"


User Function A310LIBR
Local aParam := PARAMIXB
Local lRet   := .T.

If Alltrim(ReadVar()) == "M->C5_CLIENT" .And. (IsInCallStack("CRMA310") .Or. IsInCallStack("CRMA290"))
   lRet := .F.
EndIf

Return lRet