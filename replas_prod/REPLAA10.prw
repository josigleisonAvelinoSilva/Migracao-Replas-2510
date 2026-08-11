#include "fileio.ch"
#include "rwmake.ch"
#include "totvs.ch"

//*********************************S*************************//
//Autor: Fernando Brito Muta                                 //
//Data: 23/05/2022                                           //
//Objetivo: Manutencao na tabela para envio de queryies      //
//***********************************************************//
User Function replaa10()
Local _aCores     := {}
Private aRotina   := MenuDef()
Private cCadastro := "Monitoramento Diario"

AADD(_aCores,{"Z9D_ATIVO=='S'","BR_VERDE"    ,"Sim"})
AADD(_aCores,{"Z9D_ATIVO=='N'","BR_VERMELHO" ,"Não"})

mBrowse(6,1,22,75, "Z9D",,,,,,_aCores)

Return


//*********************************S**************//
//Autor: Fernando Brito Muta                     //
//Data: 06/03/2021                               //
//Objetivo: Menu para gestÃ£o dos fontes          //
//***********************************************//
Static Function menuDef()

Local aRotina := {}

aAdd(aRotina , {"Pesquisar"			, "AxPesqui"         , 0 , 1 ,,.F.} )
aAdd(aRotina , {"Visualizar"        , "AxVisual"        , 0 , 2 ,,   } )
aAdd(aRotina , {"Incluir   "        , "AxInclui"        , 0 , 3 ,,   } )
aAdd(aRotina , {"Alterar"           , "AxAltera"        , 0 , 4 ,,   } )
aAdd(aRotina , {"Excluir"           , "AxExclui"        , 0 , 5 ,,   } )
aAdd(aRotina , {"Env.Email"         , "U_RP95MAIL()"    , 0 , 4 ,,   } )

Return aRotina

User Function RP95MAIL()
local  nOpc := Aviso("Copia","Enviar e-mail",{"Somente para mim","Para todos","Cancelar"},2,"Escolha uma das Opções")

If nOpc <> 3
    U_REPLAA14(nOpc)
EndIf

Return    
