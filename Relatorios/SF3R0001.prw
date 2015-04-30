#Include 'Protheus.ch'

User Function SF3R0001()


	Local oReport
 	
	Local cPerg  := 'SF3R0001'
 	
	Local cAlias := getNextAlias()
	
	criaSx1(cPerg)
	Pergunte(cPerg, .F.)

	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()

Return
         
 //+-----------------------------------------------------------------------------------------------+
 //! Rotina para montagem dos dados do relat�rio.                                  !
 //+-----------------------------------------------------------------------------------------------+
 
Static Function ReportPrint(oReport,cAlias)
               
	Local oSecao1 := oReport:Section(1)
 	
	If MV_PAR04 = 1
 	
		oSecao1:BeginQuery()

		BeginSQL Alias cAlias

			SELECT F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_CFO, F3_CLIEFOR, F3_SERIE, F3_OBSERV, F3_DTCANC
			FROM %Table:SF3010% SF3
			WHERE
			F3_FILIAL = %Exp:xFilial("SF3")%
			AND	F3_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND F3_CFO in (SubString(%Exp:MV_PAR03%,1,4),SubString(%Exp:MV_PAR03%,6,4),;
				SubString(%Exp:MV_PAR03%,11,4),SubString(%Exp:MV_PAR03%,16,4))
			AND SF3.D_E_L_E_T_ <> '*'
			AND F3_SERIE = '1'
			AND F3_TIPO = 'D'
		EndSQL
	Else
		oSecao1:BeginQuery()

		BeginSQL Alias cAlias

			SELECT F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_CFO, F3_CLIEFOR, F3_SERIE, F3_OBSERV, F3_DTCANC
			FROM %Table:SF3010% SF3
			WHERE
			F3_FILIAL = %Exp:xFilial("SF3")%
			AND	F3_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND F3_CFO in (SubString(%Exp:MV_PAR03%,1,4),SubString(%Exp:MV_PAR03%,6,4),;
				SubString(%Exp:MV_PAR03%,11,4),SubString(%Exp:MV_PAR03%,16,4))
			AND SF3.D_E_L_E_T_ <> '*'
			AND F3_SERIE = '1'
			AND F3_TIPO = 'D'
			AND RIGHT(RTRIM(F3_OBSERV),2) != 'CF'
		EndSql
	EndIf
	
	oSecao1:EndQuery()
	oReport:SetMeter((cAlias)->(RecCount()))
	oSecao1:Print()

Return

 //+-----------------------------------------------------------------------------------------------+
 //! Fun��o para cria��o da estrutura do relat�rio.                                                !
 //+-----------------------------------------------------------------------------------------------+
 
Static Function ReportDef(cAlias,cPerg)

	Local cTitle  := "Relat�rio de Devolu��o de Notas Fiscais"
 
	Local cHelp   := "Permite gerar relat�rio de nostas fiscais devolvidas."
 
	Local oReport
 
	Local oSection1

	oReport := TReport():New('SF3R0001',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

 //Primeira se��o
	oSection1 := TRSection():New(oReport,"LRV FISCAL",{"SF3"})
	TRCell():New(oSection1,"F3_FILIAL" , "SF3", "FILIAL")
	TRCell():New(oSection1,"F3_ENTRADA", "SF3", "DT. ENTRADA")
	TRCell():New(oSection1,"F3_NFISCAL", "SF3", "NOTA FISCAL")
	TRCell():New(oSection1,"F3_CFO"    , "SF3", "CFOP")
	TRCell():New(oSection1,"F3_CLIEFOR", "SF3", "FORNECEDOR")
	TRCell():New(oSection1,"F3_SERIE"  , "SF3", "SERIE")
	TRCell():New(oSection1,"F3_OBSERV" , "SF3", "OBSERVA��O")
 
Return(oReport)

 //+-----------------------------------------------------------------------------------------------+
 //! Fun��o para cria��o das perguntas (se n�o existirem)                                          !
 //+-----------------------------------------------------------------------------------------------+
 
Static Function criaSX1(cPerg)

	PutSx1(cPerg,"01","Data De..?","","","mv_ch1","D",08,00,00,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",;
		{"Digite a Data Inicial"},{},{},"")
	PutSx1(cPerg,"02","Data ate.?","","","mv_ch2","D",08,00,00,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",;
		{"Digite a Data Final"},{},{},"")
	PutSx1(cPerg,"03","CFOs.....?","","","mv_ch3","C",19,00,00,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",;
		{"Digitar CFO separados por ' ; '"},{},{},"")
	PutSx1(cPerg,"04","Devolu��o de CFs...?","","","mv_ch4","C",1,00,00,"C","","","","","mv_par04","SIM","SIM","SIM","1","NAO","NAO","NAO","","","","","","","","","",;
		{"Sim - Mostra devolu��o de CF / N�o oculta devolu��o de cf."},{},{},"")
		
Return