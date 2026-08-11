#INCLUDE "PROTHEUS.CH"


User Function REPCPA11()
    Local aCores      :={}
	Private aRotina   :=MenuDef()
	Private cCadastro :="Grv e Env.Transf.Fabrica"
	Private aParam    :={}
	Private aRet      :={}                  
	Private nOpc      :=0

    AADD(aCores,{"SZ9->Z9_STATUS = 'S' ","BR_VERMELHO"  ,"Transferido"})
    AADD(aCores,{"SZ9->Z9_STATUS <> 'S' ","BR_VERDE"    ,"Não Transferido"})	

	DbSelectArea("SZ9")
	DbSetOrder(1)

	oMBrowse := mBrowse( 6, 1,22,75     ,"SZ9",,,,,,aCores)

Return


Static Function MenuDef()
Local aRotina :={	{"Pesquisar      ","AxPesqui"	  ,0 , 1},;
 					{"Visualizar     ","AxVisual"	  ,0 , 2},;
 					{"Testa Cria SB8 ","U_TSTCRSB8",0 , 6},;					
 					{"Legenda"        ,"U_XREPCP11",0 , 6}}

Return( aRotina )

User Function XREPCP11()

	Local _aLegenda := {}

	AADD(_aLegenda, {"BR_VERMELHO","Transferido"})
	AADD(_aLegenda, {"BR_VERDE"   ,"Não Transferido"})

	BrwLegenda(cCadastro,'Legenda',_aLegenda)

Return()

User Function TSTCRSB8()
   /*
   local cFilOri  := '0201'
   local cProduto := SZ9->Z9_PRODORI
   local cLocal   := SZ9->Z9_LOCORI
   local cLoteCtl := SZ9->Z9_LOTORI
   local cNumLote := SZ9->Z9_SBLTORI
   local cFilDes  := "0302"
   U_CriaSB8( cFilOri, cProduto, cLocal, cLoteCtl, cNumLote, cFilDes )
   */
   local cQuery := ""
   If FWAlertYesNo("Confirma a Gravação do SB8 - Origem ?", "Lotes") 
		cQuery  := "   SELECT B8_FILIAL,B8.B8_PRODUTO,B8.B8_LOCAL,B8.B8_LOTECTL,B8.B8_NUMLOTE,'0302' B8_FILDES,B8.B8_QTDORI,B8.B8_SALDO "+ CRLF  
		cQuery  += "   FROM SB8010 B8 "+ CRLF  
		cQuery  += "   JOIN SB1010 B1 "+ CRLF  
		cQuery  += "      ON B1.D_E_L_E_T_ = ' ' "+ CRLF  
		cQuery  += "     AND B1.B1_COD = B8.B8_PRODUTO "+ CRLF  
		cQuery  += "     AND B1.B1_TIPO = 'MP' "+ CRLF  
		cQuery  += "     AND '0302'+B8.B8_PRODUTO+B8.B8_LOCAL+B8.B8_LOTECTL+B8.B8_NUMLOTE "+ CRLF  
		cQuery  += "     NOT IN ( SELECT B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE "+ CRLF  
		cQuery  += "              FROM SB8010 B80302 "+ CRLF  
		cQuery  += "              WHERE B80302.D_E_L_E_T_ = ' ' "+ CRLF  
		cQuery  += "            ) "+ CRLF    
		cQuery  += "    WHERE B8.D_E_L_E_T_ = ' ' "+ CRLF  
		cQuery  += "    AND B8.B8_SALDO != 0 "+ CRLF  
		cQuery  += "    ORDER BY B8_FILIAL,B8.B8_PRODUTO,B8.B8_LOCAL,B8.B8_LOTECTL,B8.B8_NUMLOTE "+ CRLF       
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "X084", .F., .T.)

		IF X084->( !EOF())
		   While X084->( !EOF())
		       U_CriaSB8( X084->B8_FILIAL, X084->B8_PRODUTO, X084->B8_LOCAL, X084->B8_LOTECTL, X084->B8_NUMLOTE, X084->B8_FILDES )
		       X084->( dbSkip() )
		   Enddo 
		Endif                     
		X084->( dbCloseArea() )
      
       
   Endif
    
Return


/*/{Protheus.doc} CriaSB8
Cria SB8 no Destino caso não exista
@type function
@version 1.0 
@author Marcos P.Aversa
@since 06/02/2023
@param cFilOri, character, Filial Origem
@param cProduto, character, Produto
@param cLocal, character, Local
@param cLoteCtl, character, Lote
@param cNumLote, character, Sub-Lote
@param cFilDes, character, Filial Destino
@return variant, Nil
/*/
User Function CriaSB8( cFilOri, cProduto, cLocal, cLoteCtl, cNumLote, cFilDes )
	local aArea := GetArea()
	local aAreaSB8 := SB8->( GetArea() )
		
	SB8->( dbSetOrder( 3 ) )
	
	If !Empty( cFilOri )  .And.;
	   !Empty( cProduto ) .And.;
	   !Empty( cLocal )   .And.;
	   !Empty( cLoteCtl ) .And.;
	   !Empty( cNumLote ) .And.; 	    
	   !Empty( cFilDes )  .And.;
	   SB8->( !dbSeek( cFilDes + cProduto + cLocal + cLoteCtl + cNumLote  )) .And.;
	   SB8->(  dbSeek( cFilOri + cProduto + cLocal + cLoteCtl + cNumLote  ))

	   dDataOri := SB8->B8_DATA
	   nQtdOri  := SB8->B8_QTDORI
	   dDataVal := SB8->B8_DTVALID
	   dDataFab := SB8->B8_DFABRIC

	   SB8->( RecLock( "SB8", .T. ))
	   SB8->B8_FILIAL  := cFilDes
	   SB8->B8_QTDORI  := nQtdOri
	   SB8->B8_PRODUTO := cProduto
	   SB8->B8_LOCAL   := cLocal
	   SB8->B8_DATA    := dDataOri
	   SB8->B8_DTVALID := dDataVal
	   SB8->B8_ORIGLAN := "TR"
	   SB8->B8_LOTECTL := cLoteCtl
	   SB8->B8_NUMLOTE := cNumLote
	   SB8->B8_DFABRIC := dDataFab

       SB8->( MsUnLock() )
	Endif
	  
	RestArea( aAreaSB8 )
	RestArea( aArea)
Return
