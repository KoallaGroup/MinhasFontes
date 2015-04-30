#Include 'Protheus.ch'
#Include "topconn.ch"
#INCLUDE "TBICONN.CH"
#Define  _CRLF  CHR(13)+CHR(10)

// ****************************************************************************
// Funcao que exclui os cupons
// *********************
User Function FEXCLCUP()
//---------------------

Local _lCancel	:= .F.
Local aZCupons	:= {}
Local nZContCup	:= 0

Local cQuery 	:= ""

Local cZF2Fil := ""
Local cZF2Ser := ""
Local cZF2Doc := ""
Local cZF2Cli := ""
Local cZL1Num := ""

Local aListNCC:= {}
Local nZCntNCC:= 0

AjustaSX1()

If !Pergunte("FEXCLCUP",.T.)
	_lCancel := .T.
	APMSGInfo("O processo foi abortado.")
	Return
EndIf

aZCupons := fBuscaCup()

// Percorre resultados da busca na SF2
For nZContCup := 1 To Len(aZCupons)
	
	DbSelectArea("SF2")
	DbGoTo(aZCupons[nZContCup])
	
	If !Eof()
		
		cZF2Fil := SF2->F2_FILIAL
		cZF2Ser := SF2->F2_SERIE
		cZF2Doc := SF2->F2_DOC
		cZF2Cli	:= SF2->F2_CLIENTE
		
		aListNCC := fBuscaNCC(cZF2Fil,cZF2Ser,cZF2Doc)
		
		// INICIO tratamento das NCCs 
		If Len(aListNCC) > 0
			
			For nZCntNCC := 1 To Len(aListNCC)
				
				// Posiciona no E5 da NCC
				DbSelectArea("SE5")
				DbGoTo(aListNCC[nZCntNCC][1])
				
				// Posiciona no E1 da NCC
				DbSelectArea("SE1")
				DbGoTo(aListNCC[nZCntNCC][2])
				
				nSaldAtu	:= E1_SALDO + SE5->E5_VALOR
				nValiqAtu	:= E1_VALLIQ - SE5->E5_VALOR
				
				If RecLock("SE1",.F.)
					Replace E1_SALDO 	With IIf(nSaldAtu  > E1_VALOR, E1_VALOR,nSaldAtu)
					Replace E1_VALLIQ 	With IIf(nValiqAtu < 0, 0,nValiqAtu)
					If E1_SALDO == E1_VALOR
						Replace E1_BAIXA 	With STOD('')
						Replace E1_STATUS 	With 'A'
					Else
						CONOUT("O saldo da NCC " + E1_NUM + " ficou: "+cValToChar(E1_SALDO))
					EndIf
					MsUnlock()
					
					// Apaga o movimento de compensação da NCC com a DV
					DbSelectArea("SE5")
					If RecLock("SE5",.F.)
						DBDelete()
						MsUnlock()
					EndIf
				EndIf
								
			Next nZCntNCC
			
		EndIf
		// FIM tratamento das NCCs 
		
		DbSelectArea("SL1")
		DbSetOrder(2) // L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		If DbSeek(SF2->F2_FILIAL + SF2->F2_SERIE + SF2->F2_DOC)
			
			cZL1Num := SL1->L1_NUM
			
			cQuery := "UPDATE "+RetSqlName("SF2") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE F2_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "F2_DOC = '"+cZF2Doc+"' AND "
			cQuery += "F2_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SD2") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE D2_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "D2_DOC = '"+cZF2Doc+"' AND "
			cQuery += "D2_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SF3") + " "
			cQuery += "SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE F3_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "F3_NFISCAL = '"+cZF2Doc+"' AND "
			cQuery += "F3_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "F3_CLIEFOR = '"+cZF2Cli+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SFT") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE FT_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "FT_NFISCAL = '"+cZF2Doc+"' AND "
			cQuery += "FT_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "FT_CLIEFOR = '"+cZF2Cli+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SE1") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE E1_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "E1_NUM = '"+cZF2Doc+"' AND "
			cQuery += "E1_PREFIXO = '"+cZF2Ser+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SE5") + " "
			cQuery += "SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE E5_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "E5_NUMERO = '"+cZF2Doc+"' AND "
			cQuery += "E5_PREFIXO = '"+cZF2Ser+"' AND "
			cQuery += "E5_CLIFOR = '"+cZF2Cli+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			// TABELAS LOJA
			cQuery := "UPDATE "+RetSqlName("SL1") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE L1_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "L1_DOC = '"+cZF2Doc+"' AND "
			cQuery += "L1_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SL2") + " "
			cQuery += "SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
			cQuery += "WHERE L2_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "L2_DOC = '"+cZF2Doc+"' AND "
			cQuery += "L2_SERIE = '"+cZF2Ser+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
			cQuery := "UPDATE "+RetSqlName("SL4") + " "
			cQuery += "SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE L4_FILIAL = '"+cZF2Fil+"' AND "
			cQuery += "L4_NUM = '"+cZL1Num+"' AND "
			cQuery += "D_E_L_E_T_ <> '*'"
			TCSqlExec(cQuery)
			
		EndIf
	EndIf
	
Next nZContCup


Return


//*******************************************************************************************
// Funcao que retorna a lista de cupons a serem deletados conforme preenchido nos parametros
// ************************
Static Function fBuscaCup()
//-------------------------

Local cQuery := ""
Local aZDados:= {}

cQuery := "SELECT SF2.R_E_C_N_O_ F2_R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SF2")+" AS SF2 "
cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'
cQuery += " AND SF2.F2_ESPECIE = 'CF'"
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '" + MV_PAR02 + "'"
cQuery += " AND SF2.F2_DOC BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 + "'"
cQuery += " AND SF2.F2_SERIE BETWEEN '"+ MV_PAR05 + "' AND '" + MV_PAR06 + "'"
cQuery += " AND SF2.F2_EMISSAO BETWEEN '"+ DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "'"
cQcQueryuery := ChangeQuery(cQuery)

//Garante que a area TRB nao esta em uso
If Select( "TRB" ) > 0
	TRB->( dbCloseArea() )
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)

While ! TRB->(EOF())
	aAdd(aZDados,TRB->F2_R_E_C_N_O_)
	TRB->(dbSkip())
End Do

Return aZDados

//*******************************************************************************************
// Funcao que retorna a lista NCCs compensadas com o cupom atual
// ************************
Static Function fBuscaNCC(cZF2Fil,cZF2Ser,cZF2Doc)
//-------------------------

Local cQuery := ""
Local aZDados:= {}

cQuery := "SELECT SE5.R_E_C_N_O_ E5_R_E_C_N_O_, SE1.R_E_C_N_O_ E1_R_E_C_N_O_ "
cQuery += " FROM "+RetSqlName("SE5")+" SE5 "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SE1")+" SE1 ON E5_FILIAL = E1_FILIAL AND E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM AND E5_PARCELA = E1_PARCELA AND E5_TIPO = E1_TIPO "
cQuery += " WHERE SUBSTRING(SE5.E5_DOCUMEN,1,12) = '" + cZF2Ser + cZF2Doc + "'"
cQuery += " AND SE1.E1_FILIAL = '" + cZF2Fil + "'"
cQuery += " AND SE1.D_E_L_E_T_ <> '*'"
cQuery += " AND SE5.D_E_L_E_T_ <> '*'"

cQcQueryuery := ChangeQuery(cQuery)

//Garante que a area TRB nao esta em uso
If Select( "TRB" ) > 0
	TRB->( dbCloseArea() )
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)

While ! TRB->(EOF())
	aAdd(aZDados,{TRB->E5_R_E_C_N_O_,TRB->E1_R_E_C_N_O_})
	TRB->(dbSkip())
End Do

Return aZDados



//*****************************************************************************
// Funcao para criar as perguntas
// ************************
Static Function AjustaSX1()
//-------------------------

PutSx1("FEXCLCUP","01","Filial de       	?","Filial de       	  ?","Filial de       	 ?","mv_ch1","C",06,00,01,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a filial inicial")}, {}, {} )
PutSx1("FEXCLCUP","02","Filial Ate         ?","Filial Ate         ?","Filial Ate         ?","mv_ch2","C",06,00,01,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a filial final")}  , {}, {} )
PutSx1("FEXCLCUP","03","Numero De          ?","Numero De          ?","Numero De          ?","mv_ch3","C",09,00,01,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","",{ OemToAnsi("Define o numero do documento inicial")}  , {}, {} )
PutSx1("FEXCLCUP","04","Numero Ate         ?","Numero Ate         ?","Numero Ate         ?","mv_ch4","C",09,00,01,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{ OemToAnsi("Define o numero do documento final")}  , {}, {} )
PutSx1("FEXCLCUP","05","Serie de           ?","Serie de           ?","Serie de           ?","mv_ch5","C",03,00,01,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a serie inicial")}  , {}, {} )
PutSx1("FEXCLCUP","06","Serie ate          ?","Serie ate          ?","Serie ate          ?","mv_ch6","C",03,00,01,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a serie final")}  , {}, {} )
PutSx1("FEXCLCUP","07","Data inicial       ?","Data inicial       ?","Data inicial       ?","mv_ch7","D",08,00,01,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a data inicial do período")}  , {}, {} )
PutSx1("FEXCLCUP","08","Data final         ?","Data final         ?","Data final         ?","mv_ch8","D",08,00,01,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{ OemToAnsi("Define a data final do período")}  , {}, {} )

Return
