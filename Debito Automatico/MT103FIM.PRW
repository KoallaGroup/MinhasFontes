#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
Ponto de Entrada na rotina MATA103
O ponto de entrada MT103FIM encontra-se no final da fun��o A103NFISCAL.
Ap�s o destravamento de todas as tabelas envolvidas na grava��o do documento de entrada,
depois de fechar a opera��o realizada neste, � utilizado para realizar alguma opera��o ap�s a grava��o da NFE.
Utilizado para liberar o arquivo de exportacao gerado para a pasta de SAIDA.

@author	   Cl�udio Luiz da Silva
@since		   19/04/2010
@version	   FSWPD00044_PL_10-COFERMETA
@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
11/01/2011 Claudio Silva   Nao executa processo para conhecimento de frete
/*/
//-------------------------------------------------------------------

User Function MT103FIM()

	Local aAreAtu 	:= {SF1->(GetArea()),SD1->(GetArea()),GetArea()} //Salva todas as areas num array
	Local nOpcao 		:= PARAMIXB[1]   // Op��o Escolhida pelo usuario no aRotina
	Local nConfirma	:= PARAMIXB[2]   // Se o usuario confirmou a opera��o de grava��o da NFE
	Local lExclui  	:= (nOpcao==5)
	Local lGerArq		:= .T.
	Local cCond 		:= GetMv( "MV_DEBCOND" , , ) // Parametro com condi��o de pagamento para Debito automatico.
	Local lAchou		:= .F.
	Local nTempo		:= 0
	Local nProg		:= 3
	Local cMsgLog		:= ""
	
	Private cPath  	:= GetSrvProfString("Startpath","")
	Private aErros 	:= {}
	Private lMsErroAuto := .F.
	Private nOpc		:= 3
	Private cBco  	:= PADR(GetMv( "MV_DEBBCO" , , ),3) // Numero do banco
	Private cAg   	:= PADR(GetMv( "MV_DEBAG" , ,  ),5) // Numero Agencia
	Private cConta	:= PADR(GetMv( "MV_DEBCONT" , ,),10)// Numero conta
	
	Private cNomArqErro := ""
		
	//Efetua disponibilizacao do arquivo de exportacao gerado na pasta de SAIDA
	If (nConfirma<>0) .And. !U_FSNFEAUT() //Avalia se rotina esta sendo executada via SIGAAUTO
		U_FSMovEnt(lExclui,lGerArq)
	EndIf
	
	aEval(aAreAtu, {|x| RestArea(x) }) //Restaura todas as areas dentro do array.
	

	//�����������������������������������������������������������������������������Ŀ
	//�Incluido para realizar a baixa automatica do titulo quando a condicao de 	�
	//� pagamento for igual ao cadastro MV_DEBCOND									�
	//�������������������������������������������������������������������������������
	
	If cCONDICAO == cCond
		
		Processa({||U_Espera(3)},"Baixando T�tulo","Processando aguarde...", .F.)
		
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1)) //
		SE2->(dbGoTop())
		lAchou := SE2->(dbSeek(xFilial("SE2") + cSerie  + cNfiscal + SPACE(TAMSX3("E2_PARCELA")[1]);
			+ "NF " + CA100FOR + CLOJA))
		
		While !lAchou .And. nTempo <= 3
			nTempo++
			Processa({||U_Espera(5)},"Baixando T�tulo","Processando aguarde...", .F.)
			lAchou := SE2->(dbSeek(xFilial("SE2") + cSerie  + cNfiscal + SPACE(TAMSX3("E2_PARCELA")[1]);
				+ "NF " + CA100FOR + CLOJA))
		End
		
		If lAchou
			cHistBaixa := "DEBITO AUTO"
			//Monta array com os dados da baixa a pagar do t�tulo
			aBaixa := {}
			AADD(aBaixa, {"E2_FILIAL" 	, SE2->E2_FILIAL 	, Nil})
			AADD(aBaixa, {"E2_PREFIXO" 	, SE2->E2_PREFIXO	, Nil})
			AADD(aBaixa, {"E2_NUM" 		, SE2->E2_NUM  	, Nil})
			AADD(aBaixa, {"E2_PARCELA" 	, SE2->E2_PARCELA	, Nil})
			AADD(aBaixa, {"E2_TIPO" 		, SE2->E2_TIPO 	, Nil})
			AADD(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE	, Nil})
			AADD(aBaixa, {"E2_LOJA" 		, SE2->E2_LOJA 	, Nil})
			AADD(aBaixa, {"AUTMOTBX" 	, "DEB"     	 	, Nil})
			AADD(aBaixa, {"AUTBANCO" 	, cBco 		 	, Nil})
			AADD(aBaixa, {"AUTAGENCIA" 	, cAg 		 		, Nil})
			AADD(aBaixa, {"AUTCONTA" 	, cConta	 	 	, Nil})
			AADD(aBaixa, {"AUTDTBAIXA" 	, dDataBase      	, Nil})
			AADD(aBaixa, {"AUTDTCREDITO", SE2->E2_VENCREA	, Nil})
			AADD(aBaixa, {"AUTDTDEB"    , SE2->E2_VENCREA	, Nil})
			AADD(aBaixa, {"AUTHIST" 		, cHistBaixa 	 	, Nil})
			AADD(aBaixa, {"AUTVLRPG" 	, SE2->E2_SALDO  	, Nil})
					
			If SE2->E2_VENCREA >= dDataBase
				
				If SE2->E2_SALDO > 0
					
					ACESSAPERG("FIN080", .F.)
					
					MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, nOpc)
					
					If !lMsErroAuto
						cMsgLog := "BAIXADO OK "  + CHR(13)+CHR(10)
						cMsgLog += "   ooo FILIAL: " + SE2->E2_FILIAL + " - PREFIXO: " +  SE2->E2_PREFIXO + " - NUMERO: ";
							+ SE2->E2_NUM + " - PARCELA: " + SE2->E2_PARCELA + " - TIPO: " +  SE2->E2_TIPO + " - FORNECEDOR: " +;
							SE2->E2_FORNECE + " - LOJA: " + SE2->E2_LOJA + "." + CHR(13)+CHR(10)
						GeraLog(cMsgLog)
					EndIf
					
					If lMsErroAuto
						cNomArqErro := "MsautoLog.LOG"
						MostraErro(cPath, cNomArqErro)
						cMsgLog := MemoRead(cPath + cNomArqErro) //     carrega o log gravado.
						GeraLog(cMsgLog) // Chama fun��o de log.
						AADD(aErros, MemoRead(cPath + cNomArqErro))
						MsErase(cNomArqErro)
					EndIf
				EndIf
			Else
				APMSGINFO("Favor verificar data de vencimento informada. Baixa automatica n�o realizada.")
				cMsgLog := "Erro - Data base maior que data de vencimento."  + CHR(13)+CHR(10)
				cMsgLog += "   ### FILIAL: " + SE2->E2_FILIAL + " - PREFIXO: " +  SE2->E2_PREFIXO + " - NUMERO: ";
					+ SE2->E2_NUM + " - PARCELA: " + SE2->E2_PARCELA + " - TIPO: " +  SE2->E2_TIPO + " - FORNECEDOR: " +;
					SE2->E2_FORNECE + " - LOJA: " + SE2->E2_LOJA + "." + CHR(13)+CHR(10)
				GeraLog(cMsgLog)
			Endif
		Else
			Alert("Titulo nao encontrado!!")
			cMsgLog := "Erro - Titulo n�o encotrado." + CHR(13)+CHR(10)
			cMsgLog += "   *** FILIAL: " + xFilial("SE2") + " - Serie: " + cSerie + " - Nota Fiscal: " + cNfiscal
			+ " - Parcela: " + SPACE(TAMSX3("E2_PARCELA")[1]) + " - Fornecedor: " + CA100FOR + " - Loja: " + CLOJA + "." ;
				+ CHR(13)+CHR(10)
			GeraLog(cMsgLog)
		Endif
	EndIf
		
Return Nil

// Fun��o temporaria para analise de erro.

Static Function GeraLog(cLog)

	Local cArqTxt := "LogDbAuto.TXT"
	Local nCodArq := fOpen(cArqTxt,2)
	Local cEOL    := "CHR(13)+CHR(10)"

 //caso n�o consiga abrir o arquivo...
	If nCodArq == -1
      //tenta cria-lo
		nCodArq := fCreate(cArqTxt,2)
      //se tamb�m der erro
		If nCodArq == -1
			Return
		EndIf
	Else
      //vai para o fim do arquivo
		fSeek(nCodArq,0,2)
	Endif

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	cLog := "*##* " + DtoC(Date()) + " - " + Time() + " - " + "DataBase (" + DtoC(dDataBase) +  ") - ";
		+ "User: " + cUserName + " - " + cLog + cEOL

	fWrite(nCodArq,cLog,Len(cLog)) != Len(cLog)

	fClose(nCodArq)

Return Nil
 
User Function Espera(nProg)
		
	ProcRegua(nProg)

	For i:= 1 to nProg
		IncProc()
		SLEEP(1000)
	Next
Return Nil