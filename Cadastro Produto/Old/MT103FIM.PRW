#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
Ponto de Entrada na rotina MATA103
O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada,
depois de fechar a operação realizada neste, é utilizado para realizar alguma operação após a gravação da NFE.
Utilizado para liberar o arquivo de exportacao gerado para a pasta de SAIDA.

@author	   Cláudio Luiz da Silva
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
	Local nOpcao 		:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local nConfirma	:= PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
	Local lExclui  	:= (nOpcao==5)
	Local lGerArq		:= .T.
	Local cCond 		:= GetMv( "MV_DEBCOND" , , ) // Parametro com condição de pagamento para Debito automatico.

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
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incluido para realizar a baixa automatica do titulo quando a condicao de 	³
	//³ pagamento for igual ao cadastro MV_DEBCOND									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If cCONDICAO == cCond
		
		SLEEP(5000)// Marcio Felipe - 27-08-2014 - Colocado pois foi reclamado que alguns titulos não estão sendo baixados automaticamente
		
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1)) //
		SE2->(dbGoTop())
		If SE2->(dbSeek(xFilial("SE2") + cSerie  + cNfiscal + SPACE(TAMSX3("E2_PARCELA")[1]) + "NF " + CA100FOR + CLOJA))
			If SE2->E2_VENCREA >= dDataBase
				If SE2->E2_SALDO > 0
					cHistBaixa := "DEBITO AUTO"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Monta array com os dados da baixa a pagar do título³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					aBaixa := {}
					AADD(aBaixa, {"E2_FILIAL" 	, SE2->E2_FILIAL , Nil})
					AADD(aBaixa, {"E2_PREFIXO" 	, SE2->E2_PREFIXO, Nil})
					AADD(aBaixa, {"E2_NUM" 		, SE2->E2_NUM  	 , Nil})
					AADD(aBaixa, {"E2_PARCELA" 	, SE2->E2_PARCELA, Nil})
					AADD(aBaixa, {"E2_TIPO" 		, SE2->E2_TIPO 	 , Nil})
					AADD(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE, Nil})
					AADD(aBaixa, {"E2_LOJA" 		, SE2->E2_LOJA 	 , Nil})
					AADD(aBaixa, {"AUTMOTBX" 	, "DEB"     	 , Nil})
					AADD(aBaixa, {"AUTBANCO" 	, cBco 		 	 , Nil})
					AADD(aBaixa, {"AUTAGENCIA" 	, cAg 		 	 , Nil})
					AADD(aBaixa, {"AUTCONTA" 	, cConta	 	 , Nil})
					AADD(aBaixa, {"AUTDTBAIXA" 	, dDataBase      , Nil})
					AADD(aBaixa, {"AUTDTCREDITO", SE2->E2_VENCREA, Nil})
					AADD(aBaixa, {"AUTDTDEB"    , SE2->E2_VENCREA, Nil})
					AADD(aBaixa, {"AUTHIST" 		, cHistBaixa 	 , Nil})
					AADD(aBaixa, {"AUTVLRPG" 	, SE2->E2_SALDO  , Nil})
					
					ACESSAPERG("FIN080", .F.)
					
					MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, nOpc)
					
					If lMsErroAuto
						cNomArqErro := "MsautoLog.LOG"
						MostraErro(cPath, cNomArqErro)
						cMsgLog := MemoRead(cPath + cNomArqErro)      //     carrega o log gravado.
						C201LOG(cMsgLog) // Chama função de log.
						AADD(aErros, MemoRead(cPath + cNomArqErro))
						MsErase(cNomArqErro)
						Return .F.
					EndIf
				EndIf
			Else
				APMSGINFO("Favor verificar data de vencimento informada. Baixa automatica nao realizada.")
			Endif
		Else
			Alert("Titulo nao encontrado!!")
		Endif
	EndIf
		
Return

// Função temporaria para analise de erro.

Static Function C201Log(_cMsg)

	Local cArqTxt := "GeraProva.TXT"
	Local nHdlog := fOpen(cArqTxt,2)
	Local cEOL    := "CHR(13)+CHR(10)"

 //caso não consiga abrir o arquivo...
	If nHdlog == -1
      //tenta cria-lo
		nHdlog := fCreate(cArqTxt,2)
      //se também der erro
		If nHdlog == -1
			Return
		EndIf
	Else
      //vai para o fim do arquivo
		fSeek(nHdlog,0,2)
	Endif

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	_cMsg := DtoC(dDataBase) + " - " + Time() + " - " + _cMsg + cEOL

	fWrite(nHdlog,_cMsg,Len(_cMsg)) != Len(_cMsg)

	fClose(nHdlog)

 Return Nil