User Function FA630APV()
    Local lTeste := .F., lTeste1 := .F., lTeste2 := .F., lTeste3 := .F., lTeste4 := .F.
    Local lFound := .F.
    Local cE6_FILORIG := SE6->E6_FILORIG
    Local aArea := GetArea()

	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	lFound := SE1->(DBSEEK(cE6_FILORIG + SE6->E6_PREFIXO + SE6->E6_NUM + SE6->E6_PARCELA + SE6->E6_TIPO ) )

	lTeste := AllTrim(SE1->E1_ORIGEM) $ "MATA460" .And. (lExcSX5 .Or. ExistBlock("CHGX5FIL")) .And. GetMV("MV_TPNRNFS") == "1" .And.;
					AllTrim(SuperGetMV("MV_1DUPREF")) == "SF2->F2_SERIE"

	lTeste1 := AllTrim(SE1->E1_ORIGEM) $ "MATA460"
	lTeste2 := (lExcSX5 .Or. ExistBlock("CHGX5FIL"))
	lTeste3 := GetMV("MV_TPNRNFS") == "1"
	lTeste4 := AllTrim(SuperGetMV("MV_1DUPREF")) == "SF2->F2_SERIE"

    RestArea( aArea )
Return( .T. )
