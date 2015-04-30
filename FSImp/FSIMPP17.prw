#Include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#Define  _CRLF  CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSIMPP17
Importação contas a receber.

@author	   Edmar Tinti
@since	   12/04/2012
@version	   FSWPD00044_PL_13-COFERMETA
@obs
Executa somente para empresa corrente.

FSIMPP17 - Execucao Manual
FSIMPW17 - Execucao Automatica
FSIMPP17.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo

/*/
//-------------------------------------------------------------------

User Function FSIMPP17()

Local 		nOpca 		:= 0			 // Flag de confirmacao para OK ou CANCELA
Local 		aSays		:= {} 		     // Array com as mensagens explicativas da rotina
Local 		aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local 		cCadastro	:= "Importação Contas a Receber"
Local		bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
Local   	bBlock, bErro //Tratamento de erro
Local 		lManual 	:= .T.
Local 		cMensAux	:= ""

Private  	cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
Private 	cNomRot		:= "FSIMPP17" //Define o nome da rotina principal para controle
Private  	lErrArq		:= .F.
Private 	nHdlLog  	:= 0
Private 	cMensLog 	:= ""
Private 	cMensErr	:= ""  //Tratamento de erro
Private	cFileLog	:= ""
Private 	oProcess
Private  	cMasArq		:= "*bol.txt"  //Mascara de filtro arquivo

AADD(aSays, "Este programa efetuara a Importação do Contas a Receber.")
AADD(aSays, "")
AADD(aSays, "ATENÇÃO: ESTA OPERAÇÃO, SERÁ IMPORTADO SOMENTE")
AADD(aSays, "OS DADOS DA EMPRESA CORRENTE.")
AADD(aButtons, { 1,.T.,{|o| nOpca := 1 , o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons )

//Se o usuario confirmou a operacao
If ( nOpcA == 1)
	
	//Tratamento de Erro
	bBlock:=ErrorBlock()
	bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})
	
	//Define diretorio para gravacao de logs de erro
	U_FSDirInt()
	
	cFileLog := cDirInt+cDirBkp+cDirLog+"\"+Eval(bFileLog)+cNomRot+".LOG"
	
	//Cria arquivo de log definido na variavel cFileLog
	U_FSGrvLog()
	
	Begin Sequence
	
	cMensAux := "Log de Ocorrências - "+ cNomRot + _CRLF  //Mensagem a ser mostrada na tela
	cMensAux += "Iniciando processo de Importacao - " + DtoC(Date()) + " as " + Time() + "Hrs" + _CRLF
	cMensAux += Replicate("=",80) + _CRLF
	cMensLog	+= cMensAux
	U_FSGrvLog(cMensAux)
	
	U_FSGrvLog("Empresa: "+SM0->M0_CODIGO)
	
	//Avalia se existem arquivos a processar
	If Len(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)) <> 0
		oProcess := MsNewProcess():New({|lEnd| FSProReg(lManual)},OemToAnsi("Processando"),OemToAnsi("Aguarde! Processando Importação..."),.F.)
		oProcess:Activate()
	Else
		cMensAux := "NÃO EXISTE ARQUIVOS A PROCESSAR! "+ _CRLF
		cMensLog	+= cMensAux
		U_FSGrvLog(cMensAux)
	EndIf
	
	End Sequence
	
	//Tratamento de Erro
	ErrorBlock(bBlock)
	
	If !Empty(cMensErr) .Or. lErrArq
		cMensAux	:= cMensErr + _CRLF
		cMensAux += "Processo finalizado com OCORRENCIAS." + _CRLF
		lErrArq:= .T.
	Else
		cMensAux := "Processo efetuado com SUCESSO." + _CRLF
	EndIf
	
	cMensAux += Replicate("=",80) + _CRLF
	cMensAux += "Finalizando processo de Importacao - " + DtoC(Date()) + " as " + Time() + "Hrs" + _CRLF
	cMensLog	+= cMensAux
	U_FSGrvLog(cMensAux)
	
	//Fecha arquivo de log
	U_FSGrvLog(,.T.)
	
	//Envia email ao responsavel em caso de ocorrencia de erro
	If lErrArq
		//Fecha arquivo
		FT_FUSE()
		
		//Envia email ao responsavel
		//U_FSEnvMai(Nil,cFileLog,Nil,cNomRot+"-"+cCadastro,Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)
		
		//Move todos os arquivos da pasta TEMP\ENTRADA para pasta de ENTRADA
		aEval(Directory(cDirInt+cDirTmp+cDirImp+"\"+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1], cDirInt+cDirImp+"\"+aArquivos[1]) })
	Else
		//Apaga arquivo de log
		//Arquivo de log nao podera ser apagado em caso de erro devido ao delay de envio do arquivo como anexo
		U_FSGrvLog(,,.T.) //Apaga arquivo de log
	EndIf
	
	If !Empty(cMensLog)
		//Janela com ocorrencias
		U_FSMosTxt(cMensLog)
	EndIf
	
Endif

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSIMPW05
Importacao de contas a receber

@author	   Edmar Tinti
@since	   12/04/2012
@version	   FSWPD00044_PL_13-COFERMETA
@obs
Executa para todas as empresas.

FSIMPP17 - Execucao Manual
FSIMPW17 - Execucao Automatica
FSIMPP17.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function FSIMPW17()

Local 		aRecnoSM0	:= {}
Local 		aEmpFil		:= {}
Local 		lContinua	:= .T.
Local 		nI			:= 0
Local		bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
Local   	bBlock, bErro //Tratamento de erro
Local 		lManual 	:= .F.
Local 		cMensAux	:= ""

Private  	cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
Private 	cNomRot		:= "FSIMPP17" //Define o nome da rotina principal para controle
Private  	lErrArq		:= .F.
Private 	nHdlLog  	:= 0
Private 	cMensLog 	:= ""
Private 	cMensErr	:= ""  //Tratamento de erro
Private	cFileLog	:= ""
Private 	oProcess
Private  	cMasArq		:= "*bol.txt"  //Mascara de filtro arquivo

ConOut("******************************************************************************")
ConOut("* INICIANDO PROCESSO FSIMPP17                        " + DtoC(Date()) + " as " + Time() + "Hrs *")
ConOut("* Importacao de Contas a Receber                                             *")
ConOut("******************************************************************************")

//Tratamento de Erro
bBlock:=ErrorBlock()
bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})

Begin Sequence

cMensAux := "Log de Ocorrências - "+ cNomRot + _CRLF  //Mensagem a ser mostrada na tela
cMensAux += "Iniciando processo de Importacao - " + DtoC(Date()) + " as " + Time() + "Hrs" + _CRLF
cMensAux += Replicate("=",80) + _CRLF

//Abertura do Sigamat e ambientes
If ( lOpen := U_FSAbrSM0() )
	
	//Busca somente as empresas
	aRecnoSM0:= U_FSEmpInt()
	SM0->(dbGoto(aRecnoSM0[1,1]))
	aEmpFil:= {SM0->M0_CODIGO, SM0->M0_CODFIL}
	
	If ( lOpen := U_FSAbrSM0() )
		
		For nI := 1 To Len(aRecnoSM0)
			
			//Abertura do Ambiente da Empresa
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			Conout("Abrindo Empresa "+SM0->M0_CODIGO+" para Importacao.")
			
			RpcSetType(3)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			nModulo := 05
			
			//Define diretorio para gravacao de logs de erro
			U_FSDirInt()
			
			//Avalia se existem arquivos a processar para rotina
			If Len(Directory(cDirInt+cDirImp+"\"+cMasArq)) == 0
				lContinua:=.F.
			EndIf
			
			//Avalia se existem arquivos a processar para a empresa
			If Len(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)) <> 0
				If Empty(cFileLog)
					cFileLog	:= cDirInt+cDirBkp+cDirLog+"\"+Eval(bFileLog)+cNomRot+".LOG"
				EndIf
				
				//Abre arquivo de trabalho
				U_FSGrvLog()
				
				If !Empty(cMensAux)
					U_FSGrvLog(cMensAux)
					cMensAux:= ""
				EndIf
				
				U_FSGrvLog("Empresa: "+SM0->M0_CODIGO)
				
				//Executa rotina de Importacao
				FSProReg(lManual)
			EndIf
			
			//Fecha ambiente atual
			RpcClearEnv()
			
			//Reabre tabela SM0
			If !lContinua .Or. !(lOpen := U_FSAbrSM0())
				Exit
			EndIf
			
		Next nI
		
	EndIf
	
EndIf

If !lOpen
	cMensErr+= "Erro na abertura do SIGAMAT.EMP."
EndIf

End Sequence

//Tratamento de Erro
ErrorBlock(bBlock)

If !Empty(cMensErr) .Or. lErrArq
	If !Empty(cMensErr)
		U_FSGrvLog(cMensErr + _CRLF)
	EndIf
	lErrArq:= .T.
Else
	U_FSGrvLog("Processo efetuado com SUCESSO." + _CRLF)
EndIf

U_FSGrvLog(Replicate("=",80) + _CRLF)
U_FSGrvLog("Finalizando processo de Importacao - " + DtoC(Date()) + " as " + Time() + "Hrs" + _CRLF)

//Fecha arquivo de log
U_FSGrvLog(,.T.)

//Envia email ao responsavel em caso de ocorrencia de erro
If lErrArq
	//Fecha arquivo
	FT_FUSE()
	
	//Envia email ao responsavel
	U_FSEnvMai(Nil,cFileLog,aEmpFil,"FSIMPP17-Importacao de Contas a Receber",Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)
	//U_FSEnvMai(Nil,cFileLog,Nil,"FSIMPP17-Importacao de Contas a Receber",Nil)
	//Move todos os arquivos da pasta TEMP\ENTRADA para pasta de ENTRADA
	aEval(Directory(cDirInt+cDirTmp+cDirImp+"\"+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1], cDirInt+cDirImp+"\"+aArquivos[1]) })
Else
	//Apaga arquivo de log
	//Arquivo de log nao podera ser apagado em caso de erro devido ao delay de envio do arquivo como anexo
	U_FSGrvLog(,,.T.) //Apaga arquivo de log
EndIf

ConOut("******************************************************************************")
ConOut("* FINALIZANDO PROCESSO FSIMPP17                      " + DtoC(Date()) + " as " + Time() + "Hrs *")
ConOut("******************************************************************************")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSProReg
Rotina de processamento dos registros

@protected
@author	   Claudio Luiz da Silva
@since	   05/04/2010

@return     lManual     Rotina executada manual ou via Job
/*/
//-------------------------------------------------------------------

Static Function FSProReg(lManual)

Local	 aDados  		:= {}
Local   aArrLay   	:= {}
Local   cArqLay 		:= ""
Local   nHandle 		:= 0
Local   lProcessa		:= .T.
Local	 aLayAux		:= {}
Local   nPosLay   	:= 0
Local	 aDadAux		:= {}
Local   nPosDad   	:= 0
Local   nPosAux   	:= 0
Local   nPosCGC   	:= 0
Local   aCabec		:= {}
Local   aItens		:= {}
Local   aItensAux		:= {}
Local   nXi			:= 0
Local   nYi			:= 0
Local   nRegLid   	:= 0
Local   cMensAux  	:= ""
Local   cTipArq		:= "CTARECEB" 	//Define o nome da rotina no arquivo para validacao
Local   cFilOld		:= cFilAnt		//Salva filial anterior
Local   aArquivos		:= {}
Local   nHdlLock 		:= -1
Local   cTipOper		:= ""
Local   cTipDad		:= ""
Local   cTipNF  		:= ""
Local 	 cTipExc
Local 	 cFilPed		:= ""
Local 	 cChaveE1		:= ""
Local	 cFilCTR		:= ""
Local	 cPrefCTR		:= ""
Local	 cNumCTR		:= ""
Local	 cParcCTR		:= ""
Local	 cTipoCTR		:= ""
Local 	 cClieImp		:= ""
Local	 cLojaCli		:= ""
Local 	 aDadBorde		:= {}
Local	 aDadBaixa		:= {}
Local	 dDtBaix
Local 	 cHistBaix		:= ""
Local 	 nValTit
Local 	 nSalTit
Local 	 cSituAtu		:= ""
Local 	 cCGC			:= ""

Private  lErrReg		:= .F.
Private  cCNPJCPF		:= ""

Private  CBCOAUTO    := ""
Private  CAGEAUTO    := ""
Private  CCTAAUTO    := ""

//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
If U_FSTraExe(@nHdlLock, cNomRot, .T., lManual)
	Return(Nil)
EndIf

//Le arquivo de layout
cArqLay 	:= "\"+cNomRot+".LAY"
If !U_FSCarLay(cDirLay+cArqLay, @aArrLay)
	cMensAux := "=> Arquivo de layout inexistente: "+ cDirLay+cArqLay + "!"
	cMensLog += cMensAux + _CRLF
	U_FSGrvLog(cMensAux)
	lErrArq:= .T.
	Return
EndIf

//Move todos os arquivos da pasta ENTRADA para pasta de TEMP\ENTRADA
aEval(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirImp+"\"+aArquivos[1], cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1]) })

//Carrega todos os arquivos do diretorio de importacao temporario
aArquivos:= Directory(cDirInt+cDirTmp+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)

If lManual
	oProcess:SetRegua1(Len(aArquivos))
EndIf

For nXi:= 1 To Len(aArquivos)
	
	//Tratamento de Erro por Arquivo
	lErrReg	:= .F.
	
	//Considera filial do nome do arquivo
	cFilAnt:= U_fGetFil(SubStr(aArquivos[nXi,1],3,2))
	
	// Verifica se ja tem LOGS pra esse arquivo e limpa
	U_FSVerif(aArquivos[nXi,1],cNomRot)
	
	//Altera status como em PROCESSAMENTO
	U_FSVldAll(aArquivos[nXi,1],cNomRot,"P")
	
	cMensAux := "=> Lendo o arquivo: "+ aArquivos[nXi,1]
	
	If lManual
		oProcess:IncRegua1(cMensAux)
	EndIf
	
	cMensLog += cMensAux + _CRLF
	U_FSGrvLog(cMensAux)
	
	nRegLid   := 0
	
	lProcessa:= .T.
	
	//Valida se abertura com sucesso
	If (nHandle := FT_FUse(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1]))== -1
		cMensAux := "Erro de abertura do arquivo "+ cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1]
		cMensLog += cMensAux + _CRLF
		U_FSGrvLog(cMensAux)
		lErrArq:= .T.
		
		//Altera status como importado PENDENTE
		//U_FSVldAll(aArquivos[nXi,1],cNomRot,"P")
		
		//O arquivo sera movido para pasta ENTRADA
		If U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1], cDirInt+cDirImp+"\"+aArquivos[nXi,1])
			cMensAux := "Movido para a pasta: "+ cDirInt+cDirImp + _CRLF
			cMensLog += cMensAux
			U_FSGrvLog(cMensAux)
		EndIf
		
		//Busca proximo arquivo
		Loop
	EndIf
	
	If lManual
		oProcess:SetRegua2(FT_FLastRec())
	EndIf
	
	//Posiciona no inicio do arquivo
	FT_fGoTop()
	
	While !FT_fEOF() .And. lProcessa
		
		If lManual
			oProcess:IncRegua2(OemToAnsi('Importando registros...'))
		EndIf
		
		aDados  := {}
		aCabec	:= {}
		aItensAux	:= {}
		aItens	:= {}
		//Le dados carregando na estrutura definida no layout
		If U_FSImpTab(aArrLay, @aDados, @nRegLid)
			FT_fSkip()           // Salta e le prox. registro
			Exit
		EndIf
		
		If (nPosDad:= aScan(aDados ,{|x| Alltrim(x[1][1]) == 'I'})) <> 0 //Verifica se a linha eh de Identificacao
			
			If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "TIPOARQ"})) <> 0
				If Alltrim(Str(aDadAux[Len(aDadAux),nPosAux])) <> cTipArq
					cMensAux := "Arquivo nao é da rotina "+cNomRot+" ("+cTipArq+"). Verifique => "+ Alltrim(Str(aDadAux[Len(aDadAux),nPosAux]))
					cMensLog += cMensAux + _CRLF
					U_FSGrvLog(cMensAux)
					lErrReg:= .T.
					Exit
				EndIf
			EndIf
			
			
		ElseIf (nPosDad:= aScan(aDados ,{|x| Alltrim(x[1][1]) == 'F'})) <> 0 //Verifica se a linha eh de Finalizacao
			
			//Localiza a posicao do tipo na estrutura
			nPosLay := aScan(aArrLay,{|x| Alltrim(x[1][1]) == "F"})
			
			//Prepara arrays de trabalho
			aLayAux := aArrLay[nPosLay]
			aDadAux := aDados[nPosDad]
			
			//Informa no log a quantidade de registros informado no arquivo e a quantidade processada
			If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "QTDREG"})) <> 0
				cMensAux := "Quantidade de Registros=> Informado no arquivo: "+ Alltrim(Str(aDadAux[Len(aDadAux),nPosAux])) +". Lidos: " + Alltrim(Str(nRegLid)) + ""
				cMensLog += cMensAux + _CRLF
				U_FSGrvLog(cMensAux)
			EndIf
			
			//Nao continua lendo o arquivo apos o final do arquivo
			Exit
		Else
			
			//Monta array do SigaAuto
			For nYi:= 1 To Len(aDados)
				aDadAux:= aDados[nYi]
				
				For nZi:= 1 To Len(aDadAux)
					
					aDadAux2	:= aDadAux[nZi]
					cTipDad 	:= aDadAux2[1]
					nPosLay	:= aScan(aArrLay,{|x| Alltrim(x[1][1]) == cTipDad})
					aLayAux	:= aArrLay[nPosLay]
					
					//Monta array
					If cTipDad == "H"
						//Busca o tipo de operacao
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "OPERACAO"})) <> 0
							cTipOper:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
						EndIf
					ElseIf cTipDad == "D"
						
						aDadBaixa := {}
						
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_PREFIXO"})) <> 0
							cPrefCTR:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_NUM"})) <> 0
							cNumCTR:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_PARCELA"})) <> 0
							cParcCTR:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_TIPO"})) <> 0
							cTipoCTR:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_CLIENTE"})) <> 0
							cClieImp:= (aDadAux[Len(aDadAux),nPosAux])
							If Empty(cClieImp)
								DbSelectArea("SA1")
								If (nPosCGC:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CGC"})) <> 0
									cCGC:= (aDadAux[Len(aDadAux),nPosCGC])
									cClieImp := Posicione("SA1",3,xFilial("SA1")+cCGC,"A1_COD")
									aDadAux[Len(aDadAux),nPosAux] := cClieImp
								EndIf
							EndIf
						EndIf
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "E1_LOJA"})) <> 0
							cLojaCli:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CBCOAUTO"})) <> 0
							CBCOAUTO:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CAGEAUTO"})) <> 0
							CAGEAUTO:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CCTAAUTO"})) <> 0
							CCTAAUTO:= (aDadAux[Len(aDadAux),nPosAux])
						EndIf
						
						
						cChaveE1 := cFilAnt+cPrefCTR+cNumCTR+cParcCTR+cTipoCTR+cClieImp+cLojaCli
						
						U_FSMntArr(@aCabec, aLayAux, aDadAux2)
						
					EndIf
					
				Next nZi
				
			Next nYi
			
			//Executa rotina de inclusao automatica
			If Len(aCabec) <> 0
				//Tratamento de erro para o registro
				lErrReg:= .F.
				
				Begin Transaction
				FSIncAut(aCabec, cTipOper, nRegLid, aArquivos[nXi,1],cChaveE1,aDadBorde,aDadBaixa,cSituAtu)
				End Transaction
				
				//Em caso de errolog. O tratamento de erro redireciona para apos o End Transaction e/ou End
				If !Empty(cMensErr)
					Break
				EndIf
			Else
				cMensAux := "Ocorreu falta de informacao no cabecalho ou item, verifique o layout de importacao!"
				U_FSGrvLog(cMensAux)
				lErrReg:= .T.
			EndIf
			
		EndIf
		
		//Avalia se nao teve erros
		If lErrReg
			//Seta que ocorreu um erro	em um dos arquivos
			lErrArq:= .T.
		EndIf
		
	EndDo
	//Fecha arquivo
	FT_FUSE()
	
	If !lProcessa
		cMensAux := "Nao Processado. Verifique Log."
		cMensLog += cMensAux + _CRLF
		U_FSGrvLog(cMensAux)
	EndIf
	
	//Avalia se nao teve erros
	If lErrReg
		//Seta que ocorreu um erro	em um dos arquivos
		lErrArq:= .T.
	EndIf
	
	//Avalia se nao teve erros
	If lErrArq
		
		//Altera status como importado PENDENTE
		U_FSVldAll(aArquivos[nXi,1],cNomRot, "P")
		
		//O arquivo sera movido para pasta BACKUP ENTRADA
		If U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1], cDirInt+cDirBkp+cDirImp+cDirAMD+"\"+aArquivos[nXi,1])
			cMensAux := "Movido para a pasta: "+ cDirInt+cDirBkp+cDirImp+cDirAMD + _CRLF
			cMensLog += cMensAux
			U_FSGrvLog(cMensAux)
		EndIf
		
	Else
		//Altera status como importado com sucesso
		U_FSVldAll(aArquivos[nXi,1],cNomRot)
		
		//O arquivo sera movido para pasta BACKUP ENTRADA
		If U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1], cDirInt+cDirBkp+cDirImp+cDirAMD+"\"+aArquivos[nXi,1])
			cMensAux := "Movido para a pasta: "+ cDirInt+cDirBkp+cDirImp+cDirAMD + _CRLF
			cMensLog += cMensAux
			U_FSGrvLog(cMensAux)
		EndIf
	EndIf
	
Next nXi

//Restaura filial de origem
cFilAnt:= cFilOld

//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSIncAut
Rotina de Inclusao Automatica

@protected
@author	   Edmar Tinti
@since	   12/04/2012

@param		aCabPre		Array cabecalho
@param		aItemPre		Array item
@param		nRegLid		Posicao do registro corrente
@param		cFile       Nome do arquivo
@param		cTipOper		Tipo de Operacao
@param		cTipExc		Tipo de Exclusão (Pedido ou item)
@param		lManual 		Identificador se rotina executada manual ou via job

/*/
//-------------------------------------------------------------------

Static Function FSIncAut(aCabPre, cTipOper, nRegLid, cFile,cChaveE1,aDadBorde,aDadBaixa,cSituAtu)

Local aArea 	:= GetArea()
Local cChave	:= ""
Local nPos		:= 0
Local nTipOpe	:= 0
Local lExiste	:= .T.
Local lContinua	:= .T.
Local cMensAux	:= ""
Local cGrvErr	:= ""
Local cNumero  	:= ""
Local cNumAux	:= ""
Local nI 		:= 0
Local nZ 		:= 0
Local aCab 		:= {}
Local ddata		:= ""
Local cCond 	:= ""
Local cCont 	:= ""
Local cFilEntre := ""
Local cMoeda 	:= 0
Local nTxMoeda 	:= 0
Local cItem 	:= ""
Local cNomArqErro := ""
Local cQuery	:= ""
Local lNewSeq	:= .T.

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.


//Verifica se o codigo original ja existe
DbSelectArea("SE1")
SE1->(DbSetOrder(1))
lExiste := SE1->(DbSeek(cChaveE1))

//Ordem do SX3
aCab:= U_FSAceArr(aCabPre, "SE1")

//Cofermeta / Eduardo - Alterado a pedido do Marcelo 19/09/2012 permite somente inclusão do que NAO existe
/*
//Avalia tipo de operacao
If cTipOper=="A"
nTipOpe:= iif(!lExiste, 3, 4) //3 Inclusao 4 Alteracao
ElseIf cTipOper=="X" .And. lExiste
nTipOpe:= 5 //Exclusao
Else
lContinua:=.F.
EndIf
*/

//Avalia tipo de operacao
If (cTipOper=="A" .And. !lExiste)
	nTipOpe:= 3 // Inclusao
Else
	lContinua:=.F.
EndIf

If lContinua
	
	MSExecAuto({|x,y| Fina040(x,y)}, aCabPre, nTipOpe)
	
	If lMsErroAuto .Or. !Empty(cMensErr)
		
		DisarmTransaction()
		
		lErrArq:= .T.
		lErrReg:= .T.
		cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
		cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
		cGrvErr+= "REGISTRO ===> " + cChaveE1  + Space(05) + cCNPJCPF + _CRLF
		If Empty(cMensErr)
			cGrvErr+= "Erro ExecAuto:" + MemoRead(NomeAutoLog()) + _CRLF ////MemoRead(NomeAutoLog()) + _CRLF //
		Else
			cGrvErr+= cMensErr + _CRLF
		EndIf
		U_FSGrvLog(cGrvErr)
		
		U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChaveE1)
		
		//Apaga o arquivo de erro apos gravar no log da importacao, devido ser acumulado erros no arquivo
		If Empty(cMensErr)
			Ferase(NomeAutoLog())
		Else
			cMensErr := ""
		EndIf
	Endif
	
Else
	
	lErrReg:= .T.
	cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
	cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
	cGrvErr+= "REGISTRO ===> " + cChaveE1  + Space(05) + cCNPJCPF + _CRLF
	If !Empty(cMensAux)
		cGrvErr+= cMensAux
	Else
		cGrvErr+= "Operacao invalida para o registro." + _CRLF
	EndIf
	U_FSGrvLog(cGrvErr)
	
EndIf

RestArea(aArea)

Return