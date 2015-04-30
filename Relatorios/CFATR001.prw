#INCLUDE "PROTHEUS.CH"

USER FUNCTION CFATR001()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?efine Variaveis                                                        ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local Titulo  := "Transferencias entre filiais - Saidas"                             // Titulo do Relatorio
Local cDesc1  := "O relatorio ira imprimir as informacoes sobre as notas fiscais"   // Descricao 1
Local cDesc2  := "de transferencia entre filiais, imprimindo informacoes sobre as"  // Descricao 2
Local cDesc3  := "saidas e entradas de cada documento."                             // Descricao 3
Local cString := "SD2"  // Alias utilizado na Filtragem
Local lDic    := .F. // Habilita/Desabilita Dicionario
Local lComp   := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .T. // Habilita/Desabilita o Filtro
Local wnrel   := "CFATR001"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "CFATR001"  // nome do programa

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  //"Produto"###"Documento / Serie"###"Data de emissao"
Private cPerg   := "CFATR1"  // Pergunta do Relatorio
Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N?de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

PutSx1("CFATR1","01","Filial Origem de ?"    ,"Filial de ?"   		  ,"Filial de ?"   ,"mv_ch1","C",6,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","")
PutSx1("CFATR1","02","Filial Origem ate?"    ,"Filial ate?"   		  ,"Filial ate?"   ,"mv_ch2","C",6,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","")
PutSx1("CFATR1","03","Emissao de ?"  		 ,"Emissao de ?"  		  ,"Emissao de ?"  ,"mv_ch3","D",8,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","")
PutSx1("CFATR1","04","Emissao ate?"  		 ,"Emissao ate?"  		  ,"Emissao ate?"  ,"mv_ch4","D",8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","")
PutSx1("CFATR1","05","Doc saida de ?"		 ,"Doc saida de ?"		  ,"Doc saida de ?","mv_ch5","C",9,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","")
PutSx1("CFATR1","06","Doc saida ate?"		 ,"Doc saida ate?"		  ,"Doc saida ate?","mv_ch6","C",9,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","")
PutSx1("CFATR1","07","Ser saida de ?"		 ,"Ser saida de ?"		  ,"Ser saida de ?","mv_ch7","C",3,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","")
PutSx1("CFATR1","08","Ser saida ate?"		 ,"Ser saida ate?"		  ,"Ser saida ate?","mv_ch8","C",3,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","")
PutSx1("CFATR1","09","Lista NFs?"  		 	 ,"Lista NFs  ?"  		  ,"Lista NFs  ?"  ,"mv_ch9","N",1,0,1,"C","","","","","mv_par09","Em transito","Em transito","Em transito","","Ja recebidas","Ja recebidas","Ja recebidas","Nao Encontradas","Nao Encontradas","Nao Encontradas","Todas","Todas","Todas","","","")
PutSx1("CFATR1","10","Filial Destino de?"    ,"Filial de ?"   		  ,"Filial de ?"   ,"mv_cha","C",6,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","")
PutSx1("CFATR1","11","Filial Destino ate?"   ,"Filial ate?"   		  ,"Filial ate?"   ,"mv_chb","C",6,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","")
PutSx1("CFATR1","12","Filtra CFOP"		 	 ,"Filtra CFOP"		  	  ,"Filtra CFOP"   ,"mv_chc","C",4,0,0,"G","","","","","mv_par12","","","","","","","","","","","","","")
PutSx1("CFATR1","13","Dt.Digit. de?"  		 ,"Dt.Digit. de?"  		  ,"Dt.Digit. de?" ,"mv_chd","D",8,0,0,"G","","","","","mv_par13","","","","","","","","","","","","","")
PutSx1("CFATR1","14","Dt.Digit.ate?"  		 ,"Dt.Digit.ate?"  		  ,"Dt.Digit.ate?" ,"mv_che","D",8,0,0,"G","","","","","mv_par14","","","","","","","","","","","","","")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?erifica as Perguntas Seleciondas                                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Variaveis utilizadas para parametros                         ?
//?mv_par01          // Filial origem                           ?
//?mv_par02          // Data de emissao de                      ?
//?mv_par03          // Data de emissao ate                     ?
//?mv_par04          // Doc Saida de                            ?
//?mv_par05          // Doc Saida ate                           ?
//?mv_par06          // Ser Doc Saida de                        ?
//?mv_par07          // Ser Doc Saida ate                       ?
//?mv_par08          // Lista NFs Em transito/Ja recebidas/Todas?
//?mv_par09          // Totaliza quebras  Sim/Nao               ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte(cPerg,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?nvia para a SetPrinter                                                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
Return (.T.)


Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)
Local aFilsCalc :={}                 				// Array com dados das filiais
Local aAreaSM0  := SM0->(GetArea()) 				// Status original do arquivo SM0
Local cFilBack  := cFilAnt           		 		// Filial corrente original
Local aRetNf    := {}                				// Informacoes relacionadas a transferencia entre filiais
Local cSeek     := ""                				// Variavel utilizada na quebra
Local cWhile    := ""                				// Variavel utilizada na quebra
Local cTexto    := ""                				// Texto para totalizacao utilizada na quebra
// Texto para totalizacao geral
Local cTextoGer := "TOTAL DA FILIAL: "
Local aTotais   := {0,0,0}				  			// Array para totalizacao utilizada na quebra
Local aTotaisGer:= {0,0,0}				 			// Array para totalizacao geral
Local li        := 100               				// Contador de Linhas
Local cbCont    := 0                 				// Numero de Registros Processados
Local cbText    := ""                				// Mensagem do Rodape
Local cQuery    := ""  								// Query para filtragem
Local lQuery    := .F.								// Variavel que indica filtragem
Local cAliasSD2 := "SD2"							// Alias para processamento
Local nNumLRe	:= 55

//		          		  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21      22
//				01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local cCabec1:="ORIGEM             CFOP   DATA        NOTA/SERIE          VALOR BRUTO    DESTINO         SITUACAO                ENTRADA     DIAS P/ENTRADA"
Local cCabec2:=""
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Carrega filiais da empresa corrente                          ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SM0")
dbSeek(cEmpAnt)
Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
	// Adiciona filial
	Aadd(aFilsCalc,{SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_FILIAL})
	dbSkip()
Enddo

dbSelectArea("SD2")
SetRegua(LastRec())

cFilCorr:=""
nTot0Vlr:=0
nTot1Vlr:=0
aTotCfFil:={}
aTotCfGer:={}

dbSelectArea("SD2")
cAliasSD2 := GetNextAlias()
cQuery := "SELECT D2_FILIAL,D2_CF,D2_EMISSAO,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,SUM(D2_VALBRUT) AS D2_VALBRUT "
cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
cQuery += "WHERE SD2.D_E_L_E_T_<>'*' AND "
IF EMPTY(MV_PAR12)
	cQuery += "	SD2.D2_CF IN ('5409','5152','5209') AND "
Else
	if MV_PAR12 $ ("5152/5409/5209")
		cQuery += "	D2_CF IN ('"+MV_PAR12+"') AND "
	Else
		cQuery += "	SD2.D2_CF IN ('5409','5152','5209') AND "
	EndIf
Endif
cQuery += "	SD2.D2_CF IN ('5409','5152','5209') AND "
cQuery += "	SD2.D2_FILIAL between '"+mv_par01+"' AND  '"+mv_par02+"' AND "
cQuery += " SD2.D2_EMISSAO >= '"+DTOS(mv_par03)+"' AND SD2.D2_EMISSAO <= '"+DTOS(mv_par04)+"' AND "
cQuery += " SD2.D2_DOC >= '"+mv_par05+"' AND SD2.D2_DOC <= '"+mv_par06+"' AND "
cQuery += " SD2.D2_SERIE >= '"+mv_par07+"' AND SD2.D2_SERIE <= '"+mv_par08+"' "
cQuery += "GROUP BY D2_FILIAL,D2_CF,D2_EMISSAO,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO "
cQuery += "ORDER BY D2_FILIAL,D2_CF,D2_EMISSAO,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
aEval(SD2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasSD2,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasSD2)
Do While !Eof() .And. (cAliasSD2)->D2_FILIAL >= mv_par01 .AND. (cAliasSD2)->D2_FILIAL <= mv_par02
	lRegOk:=.F.
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//?Varre filiais da empresa corrente                            ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If AllTrim((cAliasSD2)->D2_FILIAL) <> AllTrim(cFilCorr)
		dbSelectArea("SM0")
		dbSeek(cEmpAnt)
		Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
			If AllTrim(SM0->M0_CODFIL) == AllTrim((cAliasSD2)->D2_FILIAL)
				If cFilCorr<>""
					For ix_:=1 to Len(aTotCfFil)
						@ li,000 PSAY "TOTAL POR CFOP: "+aTotCfFil[ix_,1]
						@ li,054 PSAY aTotCfFil[ix_,2] Picture PesqPict("SD2","D2_VALBRUT",15)
						li++
						cbCont++
					Next ix_
					If (nAchFil:=ASCAN(aFilsCalc,{|x| x[1] == cFilCorr})) > 0
						cNomFil:= aFilsCalc[nAchFil,3]
					Else
						cNomFil:= ""
					Endif
					@ li,000 PSAY cTextoGer+Substr(cFilAnt,1,2)+"/"+cNomFil
					@ li,054 PSAY nTot1Vlr Picture PesqPict("SD2","D2_VALBRUT",15)
					li++
					cbCont++
				Endif
				cFilAnt:=SM0->M0_CODFIL
				cFilCorr:= SM0->M0_CODFIL
				nTot1Vlr:=0
				aTotCfFil:={}
				li++
				cbCont++
				Exit
			EndIF
			dbSelectArea("SM0")
			dbSkip()
		Enddo
	EndIf	
		
	If lEnd
		@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	IncRegua()
	// Imprime linha
	If ( li > nNumLRe )
		li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,If(aReturn[4]==1,15,18))
		li++
	Endif
	//BUSCA INFORMACOES DA NOTA DE ENTRADA
	aRetNF := BuscaNF(aFilsCalc,cAliasSD2)
	If aRetNF[1]>=MV_PAR10 .AND. aRetNF[1]<=MV_PAR11
		//VALIDA SITUACAO DAS NOTAS FISCAIS DE ENTRADA
		If (mv_par09 == 4 ) .or. (mv_par09 == 1 .and. aRetNF[5] == 1) .or. (mv_par09 == 2 .and. aRetNF[5] == 2) .or. (mv_par09 == 3 .and. aRetNF[5] == 3)
			//VALIDA DATA DE DIGITACAO DAS NFS DE ENTRADA
			If mv_par09 == 2
				If !(aRetNF[4] >= mv_par13 .AND.aRetNF[4] <= mv_par14)
					dbSelectArea(cAliasSD2)
					dbSkip()
					Loop
				EndIf
			Endif
			@ li,000 PSAY Substr(cFilAnt,1,2)+"/"+SM0->M0_FILIAL
			@ li,019 PSAY (cAliasSD2)->D2_CF
			@ li,026 PSAY (cAliasSD2)->D2_EMISSAO
			@ li,038 PSAY (cAliasSD2)->D2_DOC+"/"+(cAliasSD2)->D2_SERIE
			@ li,054 PSAY (cAliasSD2)->D2_VALBRUT Picture PesqPict("SD2","D2_VALBRUT",15)
			nTot1Vlr+=(cAliasSD2)->D2_VALBRUT
			nTot0Vlr+=(cAliasSD2)->D2_VALBRUT
			//prepara array de totaliza豫o de cfop por filial
			If (nAchoCF:=ASCAN(aTotCfFil,{|x| x[1] == (cAliasSD2)->D2_CF})) > 0
				aTotCfFil[nAchoCF,2]+=(cAliasSD2)->D2_VALBRUT
			Else
				aadd(aTotCfFil,{(cAliasSD2)->D2_CF,(cAliasSD2)->D2_VALBRUT})
			Endif
			//prepara array de totaliza豫o de cfop geral
			If (nAchoCF:=ASCAN(aTotCfGer,{|x| x[1] == (cAliasSD2)->D2_CF})) > 0
				aTotCfGer[nAchoCF,2]+=(cAliasSD2)->D2_VALBRUT
			Else
				aadd(aTotCfGer,{(cAliasSD2)->D2_CF,(cAliasSD2)->D2_VALBRUT})
			Endif
			@ li,073 PSAY Substr(aRetNF[1],1,2)+"/"+ALLTRIM(aRetNF[2])
			If aRetNF[5] == 1 .or. aRetNF[5] == 2
				@ li,089 PSAY IIF(EMPTY(aRetNF[3]),"Em transito","Ja recebida")
				@ li,113 PSAY IIF(!EMPTY(aRetNF[3]),aRetNF[4],"")
				@ li,125 PSAY IIF(!EMPTY(aRetNF[3]),aRetNF[4]-(cAliasSD2)->D2_EMISSAO,"")
			ElseIf aRetNF[5] == 3
				@ li,089 PSAY "Nao Encontrada"
				@ li,113 PSAY ""
				@ li,125 PSAY ""
			Endif
			
			li++
			cbCont++
		EndIf
	EndIf
	dbSelectArea(cAliasSD2)
	dbSkip()
	If Eof()
		For ix_:=1 to Len(aTotCfFil)
			@ li,000 PSAY "TOTAL POR CFOP: "+aTotCfFil[ix_,1]
			@ li,054 PSAY aTotCfFil[ix_,2] Picture PesqPict("SD2","D2_VALBRUT",15)
			li++
			cbCont++
		Next ix_
		If (nAchFil:=ASCAN(aFilsCalc,{|x| x[1] == cFilCorr})) > 0
			cNomFil:= aFilsCalc[nAchFil,3]
		Else
			cNomFil:= ""
		Endif
		@ li,000 PSAY cTextoGer+Substr(cFilAnt,1,2)+"/"+cNomFil
		@ li,054 PSAY nTot1Vlr Picture PesqPict("SD2","D2_VALBRUT",15)
		li++
		cbCont++	
	EndIf
EndDo

//TOTALIZADORES DO RELATORIO
li++
@ li,000 PSAY "----> TOTAL GERAL DO RELATORIO <----"
li++
For ix_:=1 to Len(aTotCfGer)
	@ li,000 PSAY "CFOP: "+aTotCfGer[ix_,1]
	@ li,054 PSAY aTotCfGer[ix_,2] Picture PesqPict("SD1","D1_TOTAL",15)
	li++
	cbCont++
Next ix_
@ li,000 PSAY "TOTAL"
@ li,054 PSAY nTot0Vlr Picture PesqPict("SD1","D1_TOTAL",15)
li++
cbCont++	

// Restaura filial original
cFilAnt:=cFilBack
RestArea(aAreaSM0)

If cbCont > 0
	Roda(cbCont,cbText,Tamanho)
EndIf

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)

Static Function BuscaNF(aFilsCalc,cAliasSD2)
Local aRetNf    := {}
Local nAchoCGC  := 0
Local aArea     := GetArea()
Local cFilBack  := cFilAnt
Local cCGCOrig  := SM0->M0_CGC
Local cCGCDest  := ""

// Posiciona no fornecedor
dbSelectArea("SA2")
dbSetOrder(3)
If MsSeek(xFilial("SA2")+cCGCOrig)
	cCodFor:= SA2->A2_COD
	cLojFor:= SA2->A2_LOJA
EndIf

// Posiciona no cliente
cArqCliFor:="SA1"
dbSelectArea("SA1")
dbSetOrder(1)
If MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
	cCGCDest:=SA1->A1_CGC
EndIf

// Checa se cliente / fornecedor esta configurado como filial do sistema
If !Empty(cCGCDest) .And. ((nAchoCGC:=ASCAN(aFilsCalc,{|x| x[2] == cCGCDest})) > 0)
	// Pesquisa se nota fiscal ja foi registrada no destino
	cFilAnt := aFilsCalc[nAchoCGC,1]
	dbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(xFilial("SF1")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+cCodFor+cLojFor)
		While !Eof() .And. xFilial("SF1")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+cCodFor+cLojFor == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],SF1->F1_STATUS,SF1->F1_DTDIGIT,iif(EMPTY(SF1->F1_STATUS),1,2)}
			dbSelectArea("SF1")
			dbSkip()
		EndDo
	Else
		aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],"","",3}
	Endif
Else
	aRetNf:={"","","","",3}
EndIf
// Reposiciona area original
cFilAnt:=cFilBack
RestArea(aArea)
RETURN aRetNf