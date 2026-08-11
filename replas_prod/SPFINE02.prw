#Include "Protheus.ch"

/*/
±±ºDescricao ³ Retorna informações do cliente para o CNAB Safra        º±±
±±º          ³                                                         º±±
±±º Autor    ³ Marcel Robinson Grosselli				               º±±
±±º Data     ³ 30/07/2015								               º±±
/*/

user function SPFINE02(posicao)

  cConteudo :=""

    	Do Case

        case posicao = 1
		If Empty(SA1->A1_ENDCOB) .Or. "MESMO" $ SA1->A1_ENDCOB
            		cConteudo := substr(SA1->A1_END,1,40)  
		else    
			cConteudo := substr(SA1->A1_ENDCOB,1,40)  
		endif   
                
	case posicao = 2
		If Empty(SA1->A1_MUNC) .Or. "MESMO" $ SA1->A1_MUNC
            		cConteudo := substr(SA1->A1_MUN,1,15)  
		else    
			cConteudo := substr(SA1->A1_MUNC,1,15)  
		endif  
                               
	case posicao = 3
		If Empty(SA1->A1_ESTC) 
            		cConteudo := AllTrim(SA1->A1_EST )  
		else    
			cConteudo := AllTrim(SA1->A1_ESTC )  
		endif 
          
         case posicao = 4
		If Empty(SA1->A1_CEPC) 
            		cConteudo := substr(SA1->A1_CEP,1,8)  
		else    
			cConteudo := substr(SA1->A1_CEPC,1,8)  
		endif  
                               
	case posicao = 5
		If Empty(SA1->A1_BAIRROC) .Or. "MESMO" $ SA1->A1_BAIRROC
            		cConteudo := substr(SA1->A1_BAIRRO,1,12 )  
		else    
			cConteudo := substr(SA1->A1_BAIRROC,1,12)  
		endif 
	Endcase 

RETURN cConteudo
