#include "totvs.ch"

/*/{Protheus.doc} M461TRV
Ponto de entrada que tem a finalidade de desativar o LOCK de registros da tabela 
"SB2 - Saldos Físico e Financeiro" no momento da geração do Documento de Saída
@type function 
@author dener.lemos@dothink.com.br
@since 24/03/2026
@return logical, Retorno do tipo lógico, sendo:.T. - Trava os registros, .F. - Desativa a trava dos registros
/*/
User Function M461TRV()
Return .F.
