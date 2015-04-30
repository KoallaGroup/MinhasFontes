#Include 'Protheus.ch'

User Function Resumcx()
	
	Local aCF := {}
	Local aNF := {}
	Local dDtDe  := dDatabase
	Local dDtAte := dDatabase
	
	Private aCX := ListCx()
	Private oBrowCX
	Private oBrowCF
	Private oBrowNF
		
	Private oOk := LoadBitmap(GetResources(), "LBOK")
	Private oNo := LoadBitmap(GetResources(), "LBNO")
	
	DEFINE MSDIALOG oDlg TITLE "Resumo de caixa" FROM 000,000 TO 450,560 PIXEL  //Style 128
	
	@ 010,010 Say "Data de:" 	SIZE 55,07 OF oDlg Pixel
	@ 010,100 Say "Data ate:" 	SIZE 55,07 OF oDlg Pixel
	@ 010,040 Get dDtDe 		 	SIZE 55,07 OF oDlg Pixel
	@ 010,130 Get dDtAte 		SIZE 55,07 OF oDlg Pixel
	
	@ 030, 010 LISTBOX oBrowCX Fields HEADER "?", "Caixa" SIZE 110,130 OF oDlg PIXEL ColSizes 15,80
	
	RfrshBw()
	
	aCF := TotalCF(dDtDe,dDtAte) // dDTde , dDTATE , filial,
	aNF := TotalNF(dDtDe,dDtAte) // dDTde , dDTATE , filial,
	
	oBrowCF := TListBox():New(030,130,,aCF,060,100,,oDlg,,,,.T.)
	oBrowNF := TListBox():New(030,210,,aNF,060,100,,oDlg,,,,.T.)

/*	
	@ 030, 130 LISTBOX oBrowCF Fields HEADER "Tipo","Valor" SIZE 190,075 OF oDlg PIXEL ColSizes 80,30
	@ 115, 130 LISTBOX oBrowNF Fields HEADER "Tipo","Valor" SIZE 190,075 OF oDlg PIXEL ColSizes 80,30
*/
	ACTIVATE DIALOG oDlg CENTERED
	
Return

Static Function TotalCF(dDtDe,dDtAte)
	
	Local aCF := {}
	
	cQuery := "SELECT L4_FORMA AS FORMA , SUM(L4_VALOR) AS TOTAL "
	cQuery += "FROM "
	cQuery += RetSqlName("SL4") + " SL4 "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND L4_DATA BETWEEN '" + dDtDe + "' AND '" + dDtDe + "'"
	cQuery += " AND SubString(L4_FILIAL,1,2) IN
	cQuery += " AND  IN
	cQuery += " GROUP BY L4_FORMA"
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYSL4") > 0
		QRYSL4->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSL4", .F.,.F.)
	dbSelectArea("QRYSL4")
	dbGoTop()

	WHILE !EOF()

		AADD(aCF,(AllTrim(QRYSL4->FORMA) + Replicate(" + ",1) +  AllTrim(cValToChar(QRYSL4->TOTAL))))
		dbSkip()
	Enddo
	
Return (aCF)

Static Function TotalNF()
	
	Local aNF 		:= {}
	Local cFil		:= '01'
	Local dDtDe 	:= "20140503"
	Local dDtAte 	:= "20140510"
	
	cQuery := "SELECT E1_TIPO AS TIPO , SUM(E1_VALOR) AS VALOR"
	cQuery += "FROM "
	cQuery += RetSqlName("SE1") + " SE1 "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND E1_FILIAL = '" + cFil + "'"
	cQuery += " AND E1_EMISSAO BETWEEN '" + dDtDe + "'"
	cQuery += " AND '"  +  dDtAte + "'"
	cQuery += " GROUP BY E1_TIPO"
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYSE1") > 0
		QRYSE1->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSE1", .F.,.F.)
	dbSelectArea("QRYSE1")
	dbGoTop()
	
	WHILE !EOF()
		AADD(aNF,(AllTrim(QRYSE1->TIPO) + Replicate(" + ",1) +  AllTrim(cValToChar(QRYSE1->VALOR))))
		dbSkip()
	Enddo
Return (aNF)


Static Function ListCx()
	
	Local aCX := {}
	
	cQuery := "SELECT A6_FILIAL AS FILIAL, A6_COD AS CAIXA, A6_NREDUZ AS NOME"
	cQuery += " FROM"
	cQuery += RetSqlName("SA6") + " SA6 "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND A6_CXGERLJ != ''"
	cQuery += " ORDER BY A6_FILIAL, A6_COD"
	
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYSA6") > 0
		QRYSA6->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSA6", .F.,.F.)
	dbSelectArea("QRYSA6")
	dbGoTop()
	WHILE !EOF()
		AADD(aCX,{.F.,AllTrim(QRYSA6->CAIXA) + Replicate(" - ",1) +  AllTrim(QRYSA6->NOME), Alltrim(QRYSA6->FILIAL)})
		dbSkip()
	Enddo
	
Return (aCX)

Static Function RfrshBw()
	
	oBrowCX:SetArray(aCX)
	oBrowCX:bLine := {|| {;
		If(aCX[oBrowCX:nAT,1],oOk,oNo),;
		aCX[oBrowCX:nAt,2],;
		}}
	oBrowCX:bLDblClick := {|| aCX[oBrowCX:nAt,1] := !aCX[oBrowCX:nAt,1],;
		oBrowCX:DrawSelect()}

Return Nil