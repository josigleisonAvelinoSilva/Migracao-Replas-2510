User Function FT210OPC()
    Local cFONT := '<b><font size="5" color="blue"><b>'
    Local cNOFONT := '</b></font></u></b>'
    Local nOpc := 2
    If MsgYesNo( cFONT + 'Confirma a operação de liberação por regra do pedido de vendas ['+SC5->C5_FILIAL+'-'+SC5->C5_NUM+']?' + cNOFONT, 'FT120PC-01' )
        nOpc := 1
        U_R920Begin()
    Endif
Return( nOpc )
