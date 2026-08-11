#Include 'Protheus.ch'
                 
//+---------------------------------------------------------------------------+
//|  Funcao   |GAT01  | Autor | Leandro Dentello - TOTVS SM | Data|22/08/2017 |
//+---------------------------------------------------------------------------+
//|  Descricao|Chamada no Gatilho do campo D1_CPD para alertar sobre Segunda UM.|
//+---------------------------------------------------------------------------+
//|   Uso     |Especifico COOP                                                |
//+---------------------------------------------------------------------------+

//***********************************************************************************

User Function GAT2UM()

//***********************************************************************************

local cProd := ''
local nVal := 0

//  cCod = Código do Produto
//  DbSelectArea("SB1")
//  DbSetOrder(1)
//  DbSeek(xFilial("SB1")+M->C6_PRODUTO)
       If SB1->B1_CONV != 0 .and. SB1->B1_CONV != 1
       		cProd := SB1->B1_COD
       		MsgAlert('O PRODUTO  '+cProd+' POSSUI SEGUNDA UNIDADE DE MEDIDA, PORTANTO DEVE SER INFORMADA ESTA UNIDADE PRIMEIRO!', 'ATENÇÃO PARA SEGUNDA UNIDADE DE MEDIDA!' )
       endif     
return(nVal)