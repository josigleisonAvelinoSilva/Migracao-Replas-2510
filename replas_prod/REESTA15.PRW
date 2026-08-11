#include "totvs.ch"


/*/{Protheus.doc} REESTA15
Rotina que contem o historico das bobina retornadas
@type function
@version 1.0
@author DO THINK - DENER LEMOS
@since 26/05/2024
/*/
User Function REESTA15()
    Local aAreaAnt := GetArea()
    Local cTabela  := "SZ9"

    Private cCadastro := "Historico Bobinas Retornadas"
    Private aRotina   := {}

    //-- Array aRotina
    aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
    aAdd(aRotina, {"Alterar", "AxAltera", 0, 4})
    aAdd(aRotina, {"Excluir", "AxDeleta", 0, 5})

    //-- Tabela
    dbSelectArea(cTabela)
    (cTabela)->(dbSetOrder(1))

    //-- Montagem do Browse
    mBrowse(6, 1, 22, 75, cTabela)
     
    //-- Encerra rotina
    (cTabela)->(dbCloseArea())
    RestArea(aAreaAnt)

Return
