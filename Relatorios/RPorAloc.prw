#Include 'Protheus.ch'

User Function RPorAloc()
	
	
	Local aDBF 	:= {}
	Local cCod 	:= ''
	Local cDesc 	:= ''
	Local cNcm		:= ''
	Local Tot     := 0
	Local cTexto 	:= ''
	Local cFile := "\TABPRO\arquivo.txt"
	Local nH
	
	nH := fCreate(cFile)
	If nH == -1
   		MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
   		Return
	Endif
	

// Abre arquivo dbf em tabela temporaria
	If Select("TABDBF") > 0
 		TABDBF->(dbCloseArea())
 	Endif
	
	DbUseArea(.T., "DBFCDX", "TABPRO\PLANILHA.DBF", "TABDBF", .T., .F.)
	DbSelectArea("TABDBF")
		
// Armazena estrutura do arquivo DBF
	aDBF := TABDBF->(DbStruct())
	
	TABDBF->(DbGotop())
	
	While !EOF()
	
		cCod  := AllTrim(TABDBF->PRODUTO)
		cDesc := AllTrim(TABDBF->DESCRICAO)
		cNcm  := AllTrim(TABDBF->NCM)
		
		DbSelectArea("SB1")
		
		SB1->(DbSetOrder(12))
		SB1->(DbGotop())
		If DbSeek(xFilial("SB1") + PadR(cCod,25))
			If SB1->B1_ORIGEM $"1|2|3|8"
				If cTexto == ''
					cTexto := (PadR(Alltrim("Codigo"),25) +  PadR(Alltrim("Codigo Fornecedor"),35) + PadR(Alltrim("Descrição"),50) + PadR(Alltrim("ORIGEM"),12) +  PadR(Alltrim("NCM"),20))
					fWrite(nH,cTexto + chr(13)+chr(10) )
				Endif
					cTexto := (PadR(Alltrim(SB1->B1_COD),25) +  PadR(Alltrim(SB1->B1_CODFOR),35) + PadR(Alltrim(SB1->B1_DESC),50) + PadR(Alltrim(SB1->B1_ORIGEM),12) +  PadR(Alltrim(SB1->B1_POSIPI),20))
					fWrite(nH,cTexto + chr(13)+chr(10) )
			EndIf
		EndIf
		
		DbSelectArea("TABDBF")
		TABDBF->(DbSkip())
		
	EndDo
	fClose(nH)
	Msginfo("Arquivo criado :" + cFile)
Return 

			