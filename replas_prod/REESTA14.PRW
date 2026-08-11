#include "totvs.ch"


/*/{Protheus.doc} REESTA14
Rotina que contem o historico das etiquetas lidas no recebimento da innova
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 21/02/2024
/*/
User Function REESTA14()
    Local aAreaAnt := GetArea()
    Local cTabela  := "SZD"

    Private cCadastro := "Historico Recebimento - Filmes Replas"
    Private aRotina   := {}

    //-- Array aRotina
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
    aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})

    //-- Tabela
    dbSelectArea(cTabela)
    (cTabela)->(dbSetOrder(1))

    //-- Montagem do Browse
    mBrowse(6, 1, 22, 75, cTabela)
     
    //-- Encerra rotina
    (cTabela)->(dbCloseArea())
    RestArea(aAreaAnt)

Return
