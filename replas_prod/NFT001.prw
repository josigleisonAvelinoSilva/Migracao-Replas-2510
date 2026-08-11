#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 

/*
=========================================================================================================
Programa.................: GFEA044 - Documento de Carga
Autor:...................: Leandro Dentello
Data.....................: 17/11/2017
Descrição / Objetivo.....: Integrar o Trecho do Documento de Carga como "Não Pago" para veículos próprios.
Doc. Origem..............: GAP
Solicitante..............: Cliente
Uso......................: 
Obs......................: Ponto de entrada executado no momento da integração com o SIGAGFE.
=========================================================================================================
*/  

User Function GFEA044()
Local xRet       := .T.
Local aParam  		:= PARAMIXB 
Local aAreas    	:= { /*SM0->(GetArea())*/, GetArea() }
Local oModelMaster  := Nil
Local oModelGrid	:= Nil
Local nX			:= 0
Local aSM0 := {}
Local nI := 0

If (aParam <> NIL) 
	oModelMaster    := aParam[1]
   cIdPonto   		:= aParam[2]
   cIdModel   		:= aParam[3]

	If oModelMaster <> Nil .And. cIdPonto == 'MODELPOS'
		oModelGrid := oModelMaster:GetModel( 'GFEA044_GWU' )
		If oModelGrid <> Nil
		
			aSM0 := FwLoadSM0( .T.,.F. )
			
			For nX := 1 To oModelGrid:Length()
				oModelGrid:GoLine( nX )
				If !oModelGrid:IsDeleted() .And. oModelGrid:CanSetValue('GWU_PAGAR')
					lTemSM0 := .F.
					//---> REMOVIDO compatibilização para versão 12.1.25.
					/*SM0->(DbGotop())
					While !SM0->(EOF())
						If AllTrim(SM0->M0_CGC) == AllTrim(oModelGrid:GetValue("GWU_CDTRP"))
							lTemSM0 := .T.
							Exit
						EndIf
						SM0->(DbSkip())
					EndDo
					SM0->(RestArea(aAreas[1]))
					RestArea(aAreas[2])*/
					
					For nI := 1 To Len( aSM0 )
						If aSM0[ nI, 18 ] == AllTrim(oModelGrid:GetValue("GWU_CDTRP"))
							lTemSM0 := .T.
							Exit
						Endif
					Next nI
					
					If lTemSM0
						oModelGrid:SetValue('GWU_PAGAR' , '2')
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	//SM0->(RestArea(aAreas[1]))
	RestArea(aAreas[2])
EndIf

Return xRet
