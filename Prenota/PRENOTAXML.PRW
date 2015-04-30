//*********************************************************************
// Arquivo     : PRENOTAXML.PRW
// Utilizacao  : leitura e importacao arquivo xml para gerar pre-nota
// Autor       : DIN - Cofermeta / Eduardo Crepaldi
// Data        : 05/04/2012
// Observacao  : Baseado em fonte disponivel no portal supeerp.com
//*********************************************************************
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#Define  _CRLF  CHR(13)+CHR(10)

//**********************
User Function PreNotaXML
//**********************
Do While .T.
	Private cArquivoXML := Space(100)
	Private lProcChkXML := .T.
	Private lNCMIgual	:= .T.
	Private lOriIgual	:= .T.
		
	// verificar tabela SZ7 para pegar a divisão
	/*
	Z7_FILIAL Z7_FILCOF Z7_VALDIV Z7_DIVISAO Z7_FORNECE Z7_LOJA D_E_L_E_T_ R_E_C_N_O_
	--------- --------- --------- ---------- ---------- ------- ---------- -----------
	01        S         FE         0000162    00                 2
	02        S         FE         0000159    00                 3
	03        S         FE         0006425    00                 4
	04        S         HI         0000160    00                 5
	07        S         RO         0000163    00                 6
	08        S         FE         0000158    00                 7
	12        S         FE         0007148    00                 8
	14        S         FE         0007560    00                 9
	15        S         FE         0012369    00                 1
	
	Z7_FILIAL Z7_FILCOF Z7_VALDIV Z7_DIVISAO Z7_FORNECE Z7_LOJA D_E_L_E_T_ R_E_C_N_O_
	--------- --------- --------- ---------- ---------- ------- ---------- -----------
	09        N                                                  1
	*/
	cDivisao := ""
	Do Case
		//Case AllTrim(SM0->M0_CODFIL) $ "01/02/03/08/12/14/15"
		Case AllTrim(right(cFilAnt,2)) $ "01/02/03/08/12/14/15"
			cDivisao := "FE"
			//Case AllTrim(SM0->M0_CODFIL) $ "04"
		Case AllTrim(right(cFilAnt,2)) $ "04"
			cDivisao := "HI"
			//Case AllTrim(SM0->M0_CODFIL) $ "07"
		Case AllTrim(right(cFilAnt,2)) $ "07"
			cDivisao := "RO"
			//Case AllTrim(SM0->M0_CODFIL) $ "09"
		Case AllTrim(right(cFilAnt,2)) $ "09"
			cDivisao := "AL"
	EndCase
	
	// montagem da tela principal
	DEFINE MSDIALOG oDlgArquivoXML FROM  50, 050 TO 400,500 TITLE OemToAnsi('Processa arquivo XML de Notas Fiscais de Entrada') PIXEL
	
	@ 040,005 Say OemToAnsi("Este programa tem como objetivo efetuar a importação do arquivo XML de Notas")
	@ 050,005 Say OemToAnsi("Fiscais de (ENTRADA).")
	@ 060,005 Say OemToAnsi("ATENÇÃO: SERÃO IMPORTADOS SOMENTE OS DADOS DA EMPRESA CORRENTE.")
	
	@ 100,005 Say OemToAnsi("Selecione um arquivo para processamento:")
	
	@ 135,060 Button OemToAnsi("Arquivo") Size 036,016 Action (BuscaArquivoXML(@cArquivoXML),oDlgArquivoXML:End())
	@ 135,160 Button OemToAnsi("Sair") Size 036,016 Action Fecha_MSDIALOG()
	
	Activate Dialog oDlgArquivoXML CENTERED
	
	cArquivoXML := Upper(Alltrim(cArquivoXML))
	
	// abre arquivo XML sem compartilhamento e somente leitura
	Private nHandleArqXML := fOpen(cArquivoXML,0)
	If nHandleArqXML == -1
		If !Empty(cArquivoXML)
			MsgAlert("O arquivo: ("+cArquivoXML+") nao pode ser aberto, verifique o arquivo selecionado.")
		Endif
		Return
	Endif
	
	// verifica tamanho do arquivo
	Private nTamArqXML := fSeek(nHandleArqXML,0,2)
	If nTamArqXML <= 0
		MsgAlert("O arquivo: ("+cArquivoXML+") nao possui dados, verifique o arquivo selecionado.")
		Return
	Endif
	
	// possiciona o ponteiro no inicio do arquivo
	fSeek(nHandleArqXML,0,0)
	
	// define variavel para a linha do registro de leitura
	Private cBufferArqXML := Space(nTamArqXML)
	
	// leitura do arquivo XML
	Private nBytesLidos := fRead(nHandleArqXML,@cBufferArqXML,nTamArqXML)
	
	// fecha arquivo XML
	fClose(nHandleArqXML)
	
	Private cAviso := ""
	Private cErro := ""
	oNfe := XmlParser(cBufferArqXML,"_",@cAviso,@cErro)
	If !empty(cErro)
		MsgAlert("Erro na validacao do arquivo: ("+cArquivoXML+"), verifique o arquivo selecionado.")
		Return
	Endif
	
	Private oNF
	
	If Type("oNFe:_NfeProc")<> "U"
		oNF := oNFe:_NFeProc:_NFe
	ElseIf Type("oNFe:_EnviNFE")<> "U"
		oNF := oNFe:_EnviNFE:_NFe
	Else
		oNF := oNFe:_NFe
	Endif
	Private oEmitente  := oNF:_InfNfe:_Emit
	Private oIdent     := oNF:_InfNfe:_IDE
	Private oDestino   := oNF:_InfNfe:_Dest
	Private oTotal     := oNF:_InfNfe:_Total
	Private oTransp    := oNF:_InfNfe:_Transp
	Private oDet       := oNF:_InfNfe:_Det
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
	If Type("oNF:_InfNfe:_ICMS")<> "U"
		Private oICM := oNF:_InfNfe:_ICMS
	Else
		Private oICM := nil
	Endif
	
	//Private oFatura := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
	
	Private oDestinatario := oNF:_InfNfe:_Dest
	
	//Chave da NFE
	If Type("oNFe:_NFeProc:_protNFe:_infProt") == "U"
		MsgAlert("Chave de acesso nao encontrada no arquivo, verifique o arquivo selecionado.")
		Return
	Endif
	Private oChNFe := oNFe:_NFeProc:_protNFe:_infProt
	Private cChNFe := AllTrim(oChNFe:_chNFe:TEXT)
	
	// valor frete da NFE
	Private oFrete := oNF:_InfNfe:_Total:_ICMSTot
	Private cFrete := IIf(Type("oFrete:_vFrete:TEXT")=="U",Nil,AllTrim(oFrete:_vFrete:TEXT))
	
	// tipo frete da NFE
	Private oModFrete := oTransp
	Private cModFrete := IIf(Type("oModFrete:_modFrete:TEXT")=="U",Nil,AllTrim(oModFrete:_modFrete:TEXT))
	
	// volumes da NFE
	If (Type("oTransp:_vol")<>"U")
		Private oVol := oTransp:_vol
		Private cVol := IIf(Type("oVol:_qVol:TEXT")=="U","0",AllTrim(oVol:_qVol:TEXT))
		Private cEsp := IIf(Type("oVol:_esp:TEXT")=="U","",AllTrim(oVol:_esp:TEXT))
		Private cPesoL := IIf(Type("oVol:_pesoL:TEXT")=="U","0",AllTrim(oVol:_pesoL:TEXT))
		Private cPesoB := IIf(Type("oVol:_pesoB:TEXT")=="U","0",AllTrim(oVol:_pesoB:TEXT))
	Else
		Private cVol := "0"
		Private cEsp := ""
		Private cPesoL := "0"
		Private cPesoB := "0"
	Endif
	
	// CPF ou CGC do destinatario da nota fiscal de entrada / XML
	cCgcDestXML := AllTrim(IIf(Type("oDestinatario:_CPF")=="U",oDestinatario:_CNPJ:TEXT,oDestinatario:_CPF:TEXT))
	
	// CGC da filial atual do usuario logado
	Private cCGCLocal := AllTrim(SM0->M0_CGC)
	
	// CGC ou CPF do EMITENTE
	cCgc := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	
	// verifica se fornecedor existe
	If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2")+cCgc))
		MsgAlert("CNPJ do fornecedor: (" + Transform(cCgc,"@r 99.999.999/9999-99") + ") nao cadastrado," + chr(13)+chr(10) + "nao e possivel processar a importacao desta NFE.")
		Return
	Endif
	
	// verifica se CNPJ do DESTINATARIO da NFE/XML e igual ao da filial atual
	If (cCGCLocal <> cCgcDestXML)
		MsgAlert("O CNPJ: (" + Transform(cCgcDestXML,"@r 99.999.999/9999-99") + ") da Nota Fiscal atual diferente do" + chr(13)+chr(10) + "CNPJ: (" + Transform(cCGCLocal,"@r 99.999.999/9999-99") + ") da filial atual." + chr(13)+chr(10) + "Nao e possivel processar a importacao desta NFE.")
		Return
	Endif
	
	// verifica se nota fiscal existe
	If SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+SA2->A2_LOJA))
		MsgAlert("Nota fiscal numero: (" + Alltrim(OIdent:_nNF:TEXT) + "/" + OIdent:_serie:TEXT + ") do fornecedor: (" + SA2->A2_COD + ") ja existe." + chr(13)+chr(10) + "Nao e possivel processar a importacao desta NFE.")
		Return
	EndIf
	
	// declara arrays que serao utilizados no processamento da MSExecAuto
	Private aCabec := {}
	Private aItens := {}
	
	// carrega array do cabecalho da nota
	aadd(aCabec,{"F1_TIPO"   ,"N",Nil,Nil})
	aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
	aadd(aCabec,{"F1_DOC"    ,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9),Nil,Nil})
	aadd(aCabec,{"F1_SERIE"  ,OIdent:_serie:TEXT,Nil,Nil})
	
	If Type("OIdent:_dEmi") <> "U"
		cData := Alltrim(OIdent:_dEmi:TEXT)
	Else
		cData := Left(Alltrim(OIdent:_dhEmi:TEXT),10) // Tratamento Marcio Felipe XML 3.10	
	EndIf
	
	dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
	aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
	aadd(aCabec,{"F1_FORNECE",SA2->A2_COD,Nil,Nil})
	aadd(aCabec,{"F1_LOJA"   ,SA2->A2_LOJA,Nil,Nil})
	aadd(aCabec,{"F1_ESPECIE","NFE",Nil,Nil})
	
	Private cEdit1
	Private cDescProd
	Private cCodForn
	Private lFlag
	Private nQtdProd
	Private aItConsPC := {} // matriz com itens para verificar se existe o pedido de compra - | COD PROD | QTD ENTRADA | QTD DISPONÍVEL|
	Private cMsgInfo	:= ""
	
	// Inicio - Marcio Felipe - Valores a serem atualizados na Prenota após sua inclusão via ExecAuto - 03/12/2014
	Private nXMLBcIPI	:= 0 
	Private nXMLAlIPI	:= 0
	Private nXMLVlIPI	:= 0
	
	Private nXMLBcST	:= 0
	Private nXMLVlST	:= 0
	
	Private nXMLBcICM	:= 0
	Private nXMLAlICM	:= 0
	Private nXMLVlICM	:= 0 	
	// Fim - Marcio Felipe - Valores a serem atualizados na Prenota após sua inclusão via ExecAuto - 03/12/2014	
	
	lFlag := .F.
	
	For nItChk := 1 To Len(oDet)
		cProduto:=Upper(AllTrim(oDet[nItChk]:_Prod:_cProd:TEXT))
		
		cAliasSB1a := GetNextAlias()
		BeginSql Alias cAliasSB1a
			SELECT COUNT(*) as nQtdProd
			FROM %Table:SB1% SB1
			WHERE SB1.B1_CODFOR =%Exp:cProduto%
			AND SUBSTRING(SB1.B1_COD,1,2) =%Exp:cDivisao%
		EndSql
		nQtdProd := (cAliasSB1a)->nQtdProd
		(cAliasSB1a)->(DbCloseArea())
		
		If nQtdProd == 0
			MsgAlert("Codigo Fornecedor: (" + cProduto + ") nao encontrado no cadastro de produtos," + chr(13)+chr(10) + "favor efetuar o cadastramento do produto no NovoSist e exportar p/o Protheus.")
			lProcChkXML := .F.
		Endif
		
	Next nItChk
	
	If ! lProcChkXML
		MSGALERT("Pre Nota numero: (" + Alltrim(aCabec[3,2]) + '/' + Alltrim(aCabec[4,2]) + ") nao processada," + chr(13)+chr(10) + "efetue a importacao da NFE novamente.")
		Return
	Endif
	
	Private cB1_COD
	
	Private aCodFCI	:= {} // Item, Cod Prod, FCI - Marcio Felipe 26/03/2014
	Private aInfIPI	:= {} // Item, Cod Prod, Base IPI, Aliq IPI, Valor IPI 		- Marcio Felipe 03/12/2014
	Private aInfICM	:= {} // Item, Cod Prod, Base ICMS, Aliq ICMS, Valor ICMS 	- Marcio Felipe 03/12/2014
	Private aInfST	:= {} // Item, Cod Prod, Base ST, Valor ST 					- Marcio Felipe 03/12/2014
	For nItens := 1 To Len(oDet)
		aAux := {}
		cProduto:=Upper(AllTrim(oDet[nItens]:_Prod:_cProd:TEXT))
		
		cAliasSB1b := GetNextAlias()
		BeginSql Alias cAliasSB1b
			SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_ORIGEM, SB1.B1_ZFCICOD
			FROM %Table:SB1% SB1
			WHERE SB1.B1_CODFOR =%Exp:cProduto%
			AND SUBSTRING(SB1.B1_COD,1,2) =%Exp:cDivisao%
		EndSql
		
		If (cAliasSB1b)->(!Eof()) .And. substr(alltrim((cAliasSB1b)->B1_COD),1,2) == cDivisao
			
			Private nQtdCod
			cAliasSB1c := GetNextAlias()
			BeginSql Alias cAliasSB1c
				SELECT COUNT(*) as nQtdCod
				FROM %Table:SB1% SB1
				WHERE SB1.B1_CODFOR =%Exp:cProduto%
				AND SUBSTRING(SB1.B1_COD,1,2) =%Exp:cDivisao%
				AND SB1.D_E_L_E_T_ <> '*'
			EndSql
			nQtdCod := (cAliasSB1c)->nQtdCod
			(cAliasSB1c)->(DbCloseArea())
			
			If nQtdCod > 1
				
				If MsgYesNo ("Codigo Fornecedor: ("+cProduto+") cadastrado mais de uma vez, seleciona o codigo correto?")
					
					cEdit1 := Space(15)
					cDescProd := Space(55)
					cCodForn := Space(25)
					
					DEFINE MSDIALOG oDlgSelecCod TITLE "Seleciona Codigo" FROM 177,192 TO 509,659 PIXEL
					@ 002,003 TO 071,186 LABEL "Seleciona Codigo" PIXEL OF oDlgSelecCod
					
					@ 012,027 Say "Codigo Fornecedor: " + cProduto Size 150,008 PIXEL OF oDlgSelecCod
					@ 020,027 Say "Descricao: " + oDet[nItens]:_Prod:_xProd:TEXT Size 150,008 PIXEL OF oDlgSelecCod
					@ 028,070 MsGet oEdit1 Var cEdit1 F3 "SB1" Valid(ValProd()) Size 060,009 PIXEL OF oDlgSelecCod
					@ 040,027 Say "Produto selecionado: " + cEdit1 Size 150,008 PIXEL OF oDlgSelecCod
					@ 048,027 Say "Descricao: " + cDescProd Size 150,008 PIXEL OF oDlgSelecCod
					@ 056,027 Say "Codigo Fornecedor: " + cCodForn Size 150,008 PIXEL OF oDlgSelecCod
					
					@ 004,194 Button "Confirmar" Size 037,012 PIXEL OF oDlgSelecCod Action(TrocaVal())
					@ 025,194 Button "Cancelar" Size 037,012 PIXEL OF oDlgSelecCod Action(oDlgSelecCod:End(),lFlag:=.T.)
					oEdit1:SetFocus()
					
					ACTIVATE MSDIALOG oDlgSelecCod CENTERED
					
					if lFlag
						return
					endif
				Else
					return
				Endif
				
				cAliasSB1b := GetNextAlias()
				BeginSql Alias cAliasSB1b
					SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_ORIGEM, SB1.B1_ZFCICOD
					FROM %Table:SB1% SB1
					WHERE SB1.B1_COD =%Exp:cEdit1%
					AND SUBSTRING(SB1.B1_COD,1,2) =%Exp:cDivisao%
					AND SB1.%NotDel%
				EndSql
				
			Endif
			
		Endif
		cB1_COD := (cAliasSB1b)->B1_COD
		Private cB1Descri := (cAliasSB1b)->B1_DESC
		Private cZOriSB1  := (cAliasSB1b)->B1_ORIGEM
		// INICIO tratamento do codigo FCI - Marcio Felipe 26/03/2014
		Private cCodFCI := ""
		
		If (Type("oDet[nItens]:_Prod:_nFCI") <> "U")
			cCodFCI := AllTrim(oDet[nItens]:_Prod:_nFCI:TEXT)
			aAdd(aCodFCI, {cB1_COD,allTrim(strzero(nItens,4)), cCodFCI})  // D1_COD, D1_ITEM, D1_FCICOD para tratamento do FCI
		Else
			If allTrim((cAliasSB1b)->B1_ZFCICOD) <> ""
				cCodFCI := (cAliasSB1b)->B1_ZFCICOD
				aAdd(aCodFCI, {cB1_COD,allTrim(strzero(nItens,4)), cCodFCI})  // D1_COD, D1_ITEM, D1_FCICOD para tratamento do FCI
			EndIf	 
		EndIf
		// FIM tratamento do codigo FCI - Marcio Felipe 26/03/2014
		
		// Teste para verificar se o NCM é diferente ao cadastrado no Protheus -  Marcio Felipe - 10/09/2013
		If AllTrim(oDet[nItens]:_Prod:_NCM:TEXT) <> AllTrim((cAliasSB1b)->B1_POSIPI)
			APMsgInfo("NCM do item: ("+StrZero(nItens,3)+") no XML("+AllTrim(oDet[nItens]:_Prod:_NCM:TEXT)+") não coincide com o cadastrado no Protheus("+AllTrim((cAliasSB1b)->B1_POSIPI)+"). Favor atualizar o cadastro. ")
			lNCMIgual := .F.
		EndIf
		// -- Fim Marcio Felipe - 10/09/2013
		
		(cAliasSB1b)->(DbCloseArea())
		
		aadd(aAux,{"D1_COD",cB1_COD,Nil,Nil})
		aadd(aAux,{"D1_DESCRI",cB1Descri,Nil,Nil}) // Incluido por marcio felipe
		
		If Val(oDet[nItens]:_Prod:_qTrib:TEXT) != 0
			aadd(aAux,{"D1_QTSEGUM",Val(oDet[nItens]:_Prod:_qTrib:TEXT),Nil,Nil})
			aadd(aAux,{"D1_VUNIT",Round(Val(oDet[nItens]:_Prod:_vProd:TEXT)/Val(oDet[nItens]:_Prod:_qTrib:TEXT),6),Nil,Nil})
			aAdd(aItConsPC,{cB1_COD,Val(oDet[nItens]:_Prod:_qTrib:TEXT),0})
		Else
			aadd(aAux,{"D1_QTSEGUM",Val(oDet[nItens]:_Prod:_qCom:TEXT),Nil,Nil})
			aadd(aAux,{"D1_VUNIT",Round(Val(oDet[nItens]:_Prod:_vProd:TEXT)/Val(oDet[nItens]:_Prod:_qCom:TEXT),6),Nil,Nil})
			aAdd(aItConsPC,{cB1_COD,Val(oDet[nItens]:_Prod:_qCom:TEXT),0})
		Endif
		aadd(aAux,{"D1_TOTAL",Val(oDet[nItens]:_Prod:_vProd:TEXT),Nil,Nil})
		_cfop:=oDet[nItens]:_Prod:_CFOP:TEXT
		If Left(Alltrim(_cfop),1)="5"
			_cfop:=Stuff(_cfop,1,1,"1")
		Else
			_cfop:=Stuff(_cfop,1,1,"2")
		Endif
		If Type("oDet[nItens]:_Prod:_vDesc")<> "U"
			aadd(aAux,{"D1_VALDESC",Val(oDet[nItens]:_Prod:_vDesc:TEXT),Nil,Nil})
		Endif
		Do Case
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS00")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS00
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS10")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS10
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS20")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS20
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS30")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS30
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS40")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS40
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS51")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS51
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS60")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS60
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS70")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS70
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMS90")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMS90
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN101")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN101	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN102")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN102	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN103")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN103	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN201")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN201	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN202")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN202	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN203")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN203	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN300")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN300	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN400")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN400	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN500")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN500	
			Case Type("oDet[nItens]:_Imposto:_ICMS:_ICMSSN900")<> "U"
				oICM:=oDet[nItens]:_Imposto:_ICMS:_ICMSSN900	
		EndCase
		Private cZOriXml := ""
       // Inicio teste para validar origem do produto - Marcio Felipe 16/05/2014
		If Type("oICM") <> "U"
			cZOriXml := Alltrim(oICM:_orig:TEXT)
			If cZOriXml == "1"
				cZOriXml := "2"	
			ElseIf cZOriXml == "6"
				cZOriXml := "7"
			EndIf
			If cZOriXml <> allTrim(cZOriSB1)
				APMsgInfo("Origem do item: ("+StrZero(nItens,3)+") no XML("+cZOriXml+") não coincide com o cadastrado no Protheus("+allTrim(cZOriSB1)+"). Favor atualizar o cadastro. ")
				lOriIgual := .F.
			EndIf	
        EndIf
		// Fim validação origem do produto - Marcio Felipe 16/05/2014
		
			// INICIO tratamento para chapar Impostos do XML conforme solicitado pela Ivana/Henrique - Marcio Felipe 03/12/2014
			
			// IPI
			nXMLBcIPI	:= 0 
			nXMLAlIPI	:= 0
			nXMLVlIPI	:= 0
			
			If Type("oDet[nItens]:_Imposto:_IPI:_IPITrib:_vBC") <> "U"
				nXMLBcIPI := VAL(oDet[nItens]:_Imposto:_IPI:_IPITrib:_vBC:TEXT)
			EndIf
			If Type("oDet[nItens]:_Imposto:_IPI:_IPITrib:_pIPI") <> "U"
				nXMLAlIPI	:= VAL(oDet[nItens]:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
			EndIf
			If Type("oDet[nItens]:_Imposto:_IPI:_IPITrib:_vIPI") <> "U"
				nXMLVlIPI	:= VAL(oDet[nItens]:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
			EndIf
			
			If	nXMLBcIPI <> 0 .AND. nXMLAlIPI <> 0 .AND. nXMLVlIPI <> 0
				aAdd(aInfIPI, {cB1_COD,allTrim(strzero(nItens,4)), nXMLBcIPI, nXMLAlIPI, nXMLVlIPI})  // Cod Prod, Item, Base IPI, Aliq IPI, Valor IPI - Marcio Felipe 03/12/2014
			EndIf			
						
			// ICMS PROPRIO
			nXMLBcICM	:= 0
			nXMLAlICM	:= 0
			nXMLVlICM	:= 0 	
				
			If Type("oICM:_vBC") <> "U"
				nXMLBcICM := VAL(oICM:_vBC:TEXT) // Base calculo ICMS Proprio
			EndIf	
			If Type("oICM:_pICMS") <> "U"
				nXMLAlICM := VAL(oICM:_pICMS:TEXT) // Aliq ICMS Proprio
			EndIf	
			If Type("oICM:_vICMS") <> "U"
				nXMLVlICM := VAL(oICM:_vICMS:TEXT) // Valor ICMS Proprio
			EndIf
			
			If	nXMLBcICM <> 0 .AND. nXMLAlICM <> 0 .AND. nXMLVlICM <> 0
				aAdd(aInfICM, {cB1_COD,allTrim(strzero(nItens,4)), nXMLBcICM, nXMLAlICM, nXMLVlICM})  // Cod Prod, Item, Base ICMS, Aliq ICMS, Valor ICMS 	- Marcio Felipe 03/12/2014
			EndIf			
			
			// ST
			nXMLBcST	:= 0
			nXMLVlST	:= 0
				
			If Type("oICM:_BCSTRet") <> "U"
				nXMLBcST := VAL(oICM:_BCSTRet:TEXT) // Base calculo ICMS Proprio
			EndIf	
			If Type("oICM:_ICMSRet") <> "U"
				nXMLVlST := VAL(oICM:_ICMSRet:TEXT) // Aliq ICMS Proprio
			EndIf		
			
			If	nXMLBcST <> 0 .AND. nXMLVlST <> 0 
				aAdd(aInfST, {cB1_COD,allTrim(strzero(nItens,4)), nXMLBcST, nXMLVlST})  // Cod Prod, Item, Base ICMS, Aliq ICMS, Valor ICMS 	- Marcio Felipe 03/12/2014
			EndIf			
			
		// FIM tratamento para chapar Impostos do XML conforme solicitado pela Ivana/Henrique - Marcio Felipe 03/12/2014
				
		If Type("oNF:_InfNfe:_ICMS")<> "U"
			CST_Aux := Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)
			aadd(aAux,{"D1_CLASFIS",CST_Aux,Nil,Nil})
		Endif
				
		aadd(aItens,aAux)
		
	Next nItens
	
	If !lNCMIgual .OR. !lOriIgual // Se a correspondencia do NCM ou Origem do produto (entre XML e Protheus) não estiver correta, abandona a inclusão da Pre-nota
		MSGALERT("Pre Nota numero: (" + Alltrim(aCabec[3,2]) + '/' + Alltrim(aCabec[4,2]) + ") nao processada," + chr(13)+chr(10) + "efetue a importacao da NFE novamente.")
		Return
	EndIf
	
	/*// Add por Marcio Felipe para validar se existe(m) pedido(s) de compra para o(s) produto(s) desta NF.
	If !U_fConsulPC(@aItConsPC,@cMsgInfo)
		cMsgInfo += _CRLF + "Pre Nota não processada. Corrija e efetue a importação novamente."
		MSGALERT(cMsgInfo)
		Return
	EndIf
	*/
	If Len(aItens) > 0
		Private lMsErroAuto := .F.
		Private lMsHelpAuto := .T.
		
		SB1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))
		
		MSExecAuto({|x,y,z| Mata140(x,y,z)},aCabec,aItens,3)
		
		IF lMsErroAuto
			cArqAux := STRTRAN(cArquivoXML,"XMLNFE\", "XMLNFE\ERRO\")
			COPY FILE &cArquivoXML TO &cArqAux
			FErase(cArquivoXML)
			MSGALERT("Erro no processamento da Pre Nota, efetue a importacao da NFE novamente.")
			MostraErro()
		Else
			If SF1->F1_DOC == Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
				cArqAux := STRTRAN(cArquivoXML,"XMLNFE\", "XMLNFE\PROC\")
				COPY FILE &cArquivoXML TO &cArqAux
				FErase(cArquivoXML)
				MSGALERT("Pre Nota numero: (" + Alltrim(aCabec[3,2])+'/'+Alltrim(aCabec[4,2])+") gerada com sucesso," + chr(13)+chr(10) + "efetue a classificacao da Pre Nota.")
				
				If SF1->F1_PLUSER <> __cUserId
					If Reclock("SF1",.F.)
						SF1->F1_PLUSER := __cUserId // ID do usuario que esta logado
						SF1->F1_CHVNFE := cChNFe
						SF1->F1_FRETE := Val(cFrete)
						SF1->F1_ESPECI1 := cEsp
						SF1->F1_VOLUME1 := Val(cVol)
						SF1->F1_PLIQUI := Val(cPesoL)
						SF1->F1_PBRUTO := Val(cPesoB)
						SF1->F1_ESPECIE := "SPED"
						SF1->F1_TPFRETE := cModFrete
					EndIf
				EndIf

				DbSelectArea("SD1")
				cZChaveD1 := SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
				
				// INICIO tratamento do codigo FCI - Marcio Felipe 26/03/2014
				If Len(aCodFCI) > 0
					
					Private nZContFCI := 0 // contador para atualização dos itens com FCI
					
					// Atualizando SD1
					For nZContFCI := 1 To Len(aCodFCI)
						DbGoTop()
						If DbSeek(cZChaveD1 + aCodFCI[nZContFCI][1] + aCodFCI[nZContFCI][2])
							If Reclock("SD1",.F.)
								Replace D1_FCICOD   With aCodFCI[nZContFCI][3]
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
				// FIM tratamento do codigo FCI - Marcio Felipe 26/03/2014
                
				// INICIO tratamento para chapar o valor dos impostos conforme XML
				
				// IPI
				If Len(aInfIPI) > 0
					Private nZContIPI := 0 // contador para atualização dos itens com IPI
					// Atualizando SD1
					For nZContIPI := 1 To Len(aInfIPI)
						DbGoTop()
						If DbSeek(cZChaveD1 + aInfIPI[nZContIPI][1] + aInfIPI[nZContIPI][2])
							If Reclock("SD1",.F.)
								Replace D1_BASEIPI  With aInfIPI[nZContIPI][3]
								Replace D1_IPI   	With aInfIPI[nZContIPI][4]
								Replace D1_VALIPI   With aInfIPI[nZContIPI][5]
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
				
				// ICMS
				If Len(aInfICM) > 0
					Private nZContICM := 0 // contador para atualização dos itens com IPI
					// Atualizando SD1
					For nZContICM := 1 To Len(aInfICM)
						DbGoTop()
						If DbSeek(cZChaveD1 + aInfICM[nZContICM][1] + aInfICM[nZContICM][2])
							If Reclock("SD1",.F.)
								Replace D1_BASEICM  With aInfICM[nZContICM][3]
								Replace D1_PICM   	With aInfICM[nZContICM][4]
								Replace D1_VALICM   With aInfICM[nZContICM][5]
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf

				// ST
				If Len(aInfST) > 0
					Private nZContST := 0 // contador para atualização dos itens com IPI
					// Atualizando SD1
					For nZContST := 1 To Len(aInfST)
						DbGoTop()
						If DbSeek(cZChaveD1 + aInfST[nZContST][1] + aInfST[nZContST][2])
							If Reclock("SD1",.F.)
								Replace D1_BRICMS  	With aInfST[nZContST][3]
								Replace D1_ICMSRET	With aInfST[nZContST][4]
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
				
				// FIM tratamento para chapar o valor dos impostos conforme XML - Marcio Felipe 03/12/2014

			Else
				MSGALERT("Pre Nota numero: (" + Alltrim(aCabec[3,2]) + '/' + Alltrim(aCabec[4,2]) + ") nao processada," + chr(13)+chr(10) + "efetue a importacao da NFE novamente.")
			EndIf
		EndIf
	Else
		MSGALERT("Pre Nota numero: (" + Alltrim(aCabec[3,2]) + '/' + Alltrim(aCabec[4,2]) + ") nao processada," + chr(13)+chr(10) + "efetue a importacao da NFE novamente.")
	Endif
Enddo // fim Do While .T.
Return // fim User Function PreNotaXML

//******************************************
Static Function BuscaArquivoXML(cArquivoXML)
//******************************************
// Substituido linha abaixo para mostrar unidades de rede no cGetFile – Luiz Flávio
// cArquivoXML := cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,'C:\XMLNFE',.F., )
cArquivoXML := cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,'C:\XMLNFE',.F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE ),.T., .T. )
Return cArquivoXML

//******************************
Static Function Fecha_MSDIALOG()
//******************************
Close(oDlgArquivoXML)
Return

//***********************
Static Function ValProd()
//***********************
if !empty(cEdit1)
	cDescProd = Alltrim(GetAdvFVal("SB1","B1_DESC",XFilial("SB1")+cEdit1,1,""))
	cCodForn = Alltrim(GetAdvFVal("SB1","B1_CODFOR",XFilial("SB1")+cEdit1,1,""))
endif
Return ExistCpo("SB1")

//************************
Static Function TrocaVal()
//************************
if !empty(cCodForn)
	cProduto := cCodForn
endif
oDlgSelecCod:End()
Return
