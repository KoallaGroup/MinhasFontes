#INCLUDE "Protheus.CH"
#INCLUDE "Topconn.CH"

/*
+-----------------------------------------------------------------------------+
| Programa       |AGPER01    | Desenvolvedor | Marcio Felipe    |  18/10/2011 |
|-----------------------------------------------------------------------------|
| Descricao     | Relatório de Funcionários - Excel                           |
|-----------------------------------------------------------------------------|
| Uso           | Agromaratá |                                                |
|-----------------------------------------------------------------------------|
|                  Modificacoes desde a construcao inicial                    |
|-----------------------------------------------------------------------------|
| Responsavel  | Data      | Motivo                                           |
|-----------------------------------------------------------------------------|
|              |           |                                                  |
+--------------+-----------+--------------------------------------------------+
*/

User Function SB1R0002()

	Local oReport
	Private cForn := ""
	Private lAtu := .F.
	Private cAtual := 1
//Interface de impressao
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()
*******************************************************************************

	Local cTitle   := " "

	AjustaSX1()
	Pergunte("SB2R002",.T.)

	cForn :=  "" // mv_par01
	cAtual:=  mv_par02


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport:= TReport():New("SB2R002",cTitle,"SB2R002", {|oReport| ReportPrint(oReport)},"Relatorio de TesXProdutos")
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideFooter()
	oReport:SetTotalInLine(.F.)

	oSection1:= TRSection():New(oReport,"Relatorio ",{"SD1"},/*aOrdem*/)
	oSection1:SetReadOnly()
	oSection1:SetCellBorder("ALL",,,.T.)
	oSection1:SetCellBorder("RIGHT")
	oSection1:SetCellBorder("LEFT")
	oSection1:SetCellBorder("BOTTOM")

	TRCell():New(oSection1,"CODIGO"      ,"","CODIGO"     ,/*Picture*/,27,/*lPixel*/,{|| cCodigo }	,"LEFT",,"CENTER")
	TRCell():New(oSection1,"TES_1"       ,"","TES_1"      ,/*Picture*/,27,/*lPixel*/,{|| cTes01 }	,"LEFT",,"CENTER")
	TRCell():New(oSection1,"TES_2"       ,"","TES_2"      ,/*Picture*/,27,/*lPixel*/,{|| cTes02 }	,"LEFT",,"CENTER")
	TRCell():New(oSection1,"TES_3"  	  ,"","TES_3"      ,/*Picture*/,27,/*lPixel*/,{|| cTes03 }	,"LEFT",,"CENTER")
	TRCell():New(oSection1,"FORNECEDOR"  ,"","FORNECEDOR" ,/*Picture*/,27,/*lPixel*/,{|| cFornece} ,"LEFT",,"CENTER")
	
Return(oReport)

Static Function ReportPrint(oReport)
******************************************************************************** 
// Fluxo principal do relatorio
********************************************************************************
	Local   cQuery 	:= ""
	Private nTotReg	:= 0

	Private oSection1   := oReport:Section(1)
	Private oSection2   := oReport:Section(1):Section(1)
	Private oFont1      := TFont():New( "Arial",,16,,.T.,,,,.F.,.F. )
	Private oFont2      := TFont():New( "Arial",,14,,.T.,,,,.F.,.F. )

	Private cQuery := ""
	Private nLin   := 50

	Private aAreaSM0 := SM0->(GetArea())

	Private nZCont := 1
	Private nZCont1:= 1
	Private aCod	 := {}
	Private aFor	 := {}

	oSection1:Init()

	nLin := oReport:Row()
	oReport:SkipLine()
	oReport:SkipLine()


	dbSelectArea("SA2")
	SA2->(dbGoTop())
	While !EOF()
		aAdd(aFor,SA2->A2_COD)
		DbSkip()
	EndDo
		
//	For nZCont1 := 1 to Len(aFor)
	
//		cForn := aFor[nZCont1]
		
//		conout ("Fornecedor " + cForn)
		 
	cQuery := "SELECT DISTINCT(D1_COD) CODIGO "
	cQuery += "FROM"
	cQuery += RetSqlName("SD1") + " SD1 "
	cQuery += "WHERE D_E_L_E_T_ != '*' "
		//cQuery += " AND D1_FORNECE = '" + cForn + "'"
	cQuery += " AND D1_CF IN ('1102', '2102', '1403', '2403', '1652', '2652') "
		//cQuery += " AND D1_EMISSAO >= '20140801' "
	cQuery += " ORDER BY D1_COD"

	cQuery := ChangeQuery( cQuery )

//Garante que a area QRYEXP nao esta em uso
	If Select( "TRBAGE" ) > 0
		TRBAGE->( dbCloseArea() )
	EndIf

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TRBAGE", .F., .F. )

	DbSelectArea("TRBAGE")
	Count to nTotReg
	oReport:SetMeter(nTotReg)
	dbGoTop()

	While !Eof()
		aAdd(aCod,TRBAGE->CODIGO)
		dbSelectArea("TRBAGE")
		DbSkip()
	EndDo

	For nZCont := 1  To Len(aCod)

		cCodigo:= aCod[nZCont]
		lAtu := .F.
		conout ("Produto " + aCod[nZCont])
			
		cQuery := " SELECT  DISTINCT TOP 3 D1_COD, D1_TES, D1_DOC, D1_DTDIGIT, D1_FORNECE "
		cQuery += " FROM "
		cQuery += RetSqlName ("SD1") + " SD1 "
		cQuery += " WHERE D1_COD = '" + cCodigo + "'"
			//cQuery += " AND D1_FORNECE = '" + cForn + "'"
		cQuery += " AND D1_CF IN ('1102', '2102', '1403', '2403', '1652', '2652') "
		cQuery += " AND D_E_L_E_T_ != '*' "
		cQuery += " ORDER BY D1_DTDIGIT DESC "

		cQuery := ChangeQuery( cQuery )

//Garante que a area QRYEXP nao esta em uso
		If Select( "TRBAGE" ) > 0
			TRBAGE->( dbCloseArea() )
		EndIf

		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TRBAGE", .F., .F. )

		DbSelectArea("TRBAGE")
		dbGoTop()
	
		cTes01 := ""
		cTes02 := ""
		cTes03 := ""
		cFornece := ""
	
		While !Eof()
		
			If cTes01 == ""
				cTes01	:= TRBAGE->D1_TES
			ElseIf cTes02 == ""
				cTes02	:= TRBAGE->D1_TES
			ElseIf cTes03 == ""
				cTes03	:= TRBAGE->D1_TES
			EndIf
			cFornece := TRBAGE->D1_FORNECE
		
			DbSelectArea("TRBAGE")
			DbSkip()
		EndDo
    	
    	
		If cTes02 == ""
			lAtu := .T.
		Elseif (cTes01 == cTes02 .and. cTes03 == "")
			lAtu := .T.
		Elseif (cTes03 == cTes01 .and. cTes01 == cTes02)
			lAtu := .T.
		EndIf
    	
		oReport:IncMeter()

		
		If lAtu == .T.
			
			If cAtual == 1
	
				dbSelectArea("SB1")
				dbSetOrder(13)
				dbGoTop()
		
				If dbSeek(cCodigo)
					Reclock("SB1",.F.)
					Replace SB1->B1_TE with Alltrim(cTes01)
					MsUnlock()
				EndIf
			Endif			
				//oSection1:PrintLine() // Mostra os atualizado
		Else
			oSection1:PrintLine()
		EndIf
	
Next nZCont

oSection1:Finish()

dbSelectArea("TRBAGE")
dbCloseArea()
	
//	Next nZcont1
Return
		

Static Function AjustaSX1()
*******************************************************************************

	PutSx1("SB2R002","01","Fornecedor       ?","Fornecedor       ?","Fornecedor       ?","mv_ch1","C",07,00,01,"G","","SA2","","","mv_par01","","","","","","","","","","","","","","","","",{ OemToAnsi("Define Fronecedor inicial")}, {}, {} )
	PutSx1("SB2R002","02","Atualiza Produtos?","Atualiza Produtos?","Atualiza Produtos?","mv_ch2","N",01,00,01,"C","",   "","","","mv_par02","SIM","SIM","SIM","","NÃO","NÃO","NÃO","","","","","","","","","",{ OemToAnsi("Atualiza Cad. Produtos")}  , {}, {} )
	
Return