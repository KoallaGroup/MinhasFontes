#Include "protheus.ch"
#Include "topconn.ch"
#Define  _CRLF  CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSIMPP09
Importacao de Nota Fiscal de Entrada.

@author	   Jane Mariano Duval
@since	   31/05/2010
@version	   FSWPD00066_PL_02-COFERMETA
@obs	      
Executa somente para empresa corrente.

FSIMPP09 - Execucao Manual
FSIMPW09 - Execucao Automatica
FSIMPP09.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
22/06/2010 Claudio Silva   Inclusao tratamento para localizar cliente a partir do CNPJ/CPF para devolucao de cupom fiscal
29/06/2010 Claudio Silva   Tratamento para buscar o sequencial da serie quando formulario proprio igual a SIM
07/10/2010 Claudio Silva   Alterado tratamento em caso de inconsistencia na importacao, para mover o arquivo para 
                           pasta BACKUP/ENTRADA em vez da pasta ENTRADA.
30/12/2010 Claudio Silva   Tratamento para gravar campos F1_PEDLEG, F1_FILLEG e F1_TIPLEG
30/12/2010 Claudio Silva   Comentado em 20/12/2010 validacao de devolucao devido ser enviado somente numero da nota de devolucao.
                           Acordado com Marcelo devido a devolucoes parciais.
                           Foi deixado claro que caso o arquivo seja processado mais de uma vez sera efetuado a inclusao n vezes
30/12/2010 Claudio Silva   Criacao variavel cFSDocGer para guardar o nome do arquivo de exportacao tratado nos seguintes pontos de entrada:
							Inclusao/classificacao:
							   GQREENTR - Gera arquivo pasta TEMP/SAIDA
							   MT103FIM - Move para pasta SAIDA  
/*/
//-------------------------------------------------------------------

User Function FSIMPP09()

	Local 	nOpca 	    := 0		// Flag de confirmacao para OK ou CANCELA
	Local 	aSays		:= {} 		// Array com as mensagens explicativas da rotina
	Local 	aButtons	:= {}		// Array com as perguntas (parametros) da rotina
	Local 	cCadastro	:= "Importação de Nota Fiscal de Entrada"

	Local	bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
	Local   bBlock, bErro //Tratamento de erro
	Local 	lManual 	:= .T.
	Local 	cMensAux	:= ""

	Private cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
	Private cNomRot		:= "FSIMPP09" //Define o nome da rotina principal para controle
	Private lErrArq		:= .F.
	Private nHdlLog 	:= 0
	Private cMensLog	:= ""
	Private cMensErr	:= ""  //Tratamento de erro
	Private	cFileLog	:= ""
	Private oProcess
	Private  cMasArq	:= "*NFE.txt"  //Mascara de filtro arquivo
//Private  cMasArq	:= "*DCO.txt"  //Mascara de filtro arquivo 
	Private cFSDocGer	:= ""

	AADD(aSays, "Este programa tem como objetivo efetuar Importação de Nota Fiscal de Entrada.")
	AADD(aSays, "ATENÇÃO: NA EXECUCAO MANUAL É IMPORTADO SOMENTE OS DADOS")
	AADD(aSays, "DA EMPRESA CORRENTE.")

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

		cFileLog	:= cDirInt+cDirBkp+cDirLog+"\"+Eval(bFileLog)+cNomRot+".LOG"
	
	//Cria arquivo de log definido na variavel cFileLog	
		U_FSGrvLog()

		Begin Sequence
	
			cMensAux	:= "Log de Ocorrências - "+ cNomRot + _CRLF  //Mensagem a ser mostrada na tela
			cMensAux += "Iniciando processo de Importacao - " + DtoC(Date()) + " as " + Time() + "Hrs" + _CRLF
			cMensAux += Replicate("=",80) + _CRLF
			cMensLog	+= cMensAux
			U_FSGrvLog(cMensAux)

			U_FSGrvLog("Empresa: "+SM0->M0_CODIGO)

		//Avalia se existem arquivos a processar
		//If Len(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)) <> 0
			If Len(Directory(cDirInt+cDirImp+"\"+FWCodEmp()+cMasArq)) <> 0
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
			U_FSEnvMai(Nil,cFileLog,Nil,"FSIMPP09- Nota Fiscal de Entrada",Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)

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

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSIMPW09
Importacao de Nota Fiscal de Entrada (JOB)

@author	   Jane Mariano Duval
@since	   31/05/2010
@version	   FSWPD00066_PL_02-COFERMETA
@obs	      
Executa para todas as empresas.

FSIMPP09 - Execucao Manual
FSIMPW09 - Execucao Automatica
FSIMPP09.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function FSIMPW09()

	Local 	aRecnoSM0	:= {}
	Local 	aEmpFil		:= {}

	Local 	lContinua	:= .T.
	Local 	nI		  	:= 0

	Local	bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
	Local   bBlock, bErro //Tratamento de erro
	Local 	lManual 	:= .F.
	Local 	cMensAux	:= ""

	Private cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
	Private cNomRot		:= "FSIMPP09" //Define o nome da rotina principal para controle
	Private lErrArq 	:= .F.
	Private lErrReg 	:= .F.
	Private nHdlLog  	:= 0
	Private cMensLog 	:= ""
	Private cMensErr	:= ""  //Tratamento de erro
	Private	cFileLog	:= ""
	Private oProcess
//Private  cMasArq 		:= "*DCO.txt"  //Mascara de filtro arquivo
	Private  cMasArq	:= "*NFE.txt"  //Mascara de filtro arquivo

	Private cFSDocGer:= ""

	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSIMPP09                        " + DtoC(Date()) + " as " + Time() + "Hrs *")
	ConOut("* Importacao de Nota Fiscal de Entrada                                       *")
	ConOut("******************************************************************************")

//Tratamento de Erro
	bBlock:=ErrorBlock()
	bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})

	Begin Sequence

		cMensAux	:= "Log de Ocorrências - "+ cNomRot + _CRLF  //Mensagem a ser mostrada na tela
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
				//If Len(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)) <> 0
					If Len(Directory(cDirInt+cDirImp+"\"+FWCodEmp()+cMasArq)) <> 0
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
		U_FSEnvMai(Nil,cFileLog,aEmpFil,"FSIMPP09-Importacao de Nota Fiscal",Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)
	
	//Move todos os arquivos da pasta TEMP\ENTRADA para pasta de ENTRADA
		aEval(Directory(cDirInt+cDirTmp+cDirImp+"\"+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1], cDirInt+cDirImp+"\"+aArquivos[1]) })
	Else
	//Apaga arquivo de log
	//Arquivo de log nao podera ser apagado em caso de erro devido ao delay de envio do arquivo como anexo
		U_FSGrvLog(,,.T.) //Apaga arquivo de log
	EndIf

	ConOut("******************************************************************************")
	ConOut("* FINALIZANDO PROCESSO FSIMPP09                      " + DtoC(Date()) + " as " + Time() + "Hrs *")
	ConOut("******************************************************************************")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSProReg
Processa Registros

@protected
@author	   Jane Mariano Duval
@since	   31/05/2010
/*/
//-------------------------------------------------------------------
Static Function FSProReg(lManual)

	Local	aDados		:= {}
	Local   aArrLay   	:= {}
	Local   cArqLay   	:= ""
	Local   nHandle   	:= 0
	Local   lProcessa 	:= .T.
	Local	aLayAux 	:= {}
	Local   nPosLay   	:= 0
	Local	aDadAux		:= {}
	Local   nPosDad   	:= 0
	Local   nPosAux   	:= 0
	Local   aCabec	  	:= {}
	Local   aItens	  	:= {}
	Local   nXi		  	:= 0
	Local   nYi		  	:= 0
	Local   nRegLid   	:= 0
	Local   cMensAux  	:= ""
	Local   cTipArq		:= "NFE" 	//Define o nome da rotina no arquivo para validacao
	Local   cFilOld		:= cFilAnt  //Salva filial anterior
	Local   aArquivos	:= {}
	Local   nHdlLock  	:= -1
	Local   cTipOper	:= ""
	Local   cTipDad		:= ""

	Private  lErrReg	:= .F.

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
//aEval(Directory(cDirInt+cDirImp+"\"+SM0->M0_CODIGO+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirImp+"\"+aArquivos[1], cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1]) })
	aEval(Directory(cDirInt+cDirImp+"\"+FWCodEmp()+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirImp+"\"+aArquivos[1], cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1]) })

//Carrega todos os arquivos do diretorio de importacao temporario
//aArquivos:= Directory(cDirInt+cDirTmp+cDirImp+"\"+SM0->M0_CODIGO+cMasArq)
	aArquivos:= Directory(cDirInt+cDirTmp+cDirImp+"\"+FWCodEmp()+cMasArq)

	If lManual
		oProcess:SetRegua1(Len(aArquivos))
	EndIf

	For nXi:= 1 To Len(aArquivos)
   
	//Tratamento de Erro por Arquivo
		lErrReg	:= .F.

	//Considera filial do nome do arquivo
	//cFilAnt:= SubStr(aArquivos[nXi,1],3,2)
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
			U_FSVldAll(aArquivos[nXi,1],cNomRot,"P")

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

			aDados  	:= {}
			aCabec	:= {}
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
				nPosLay:= aScan(aArrLay,{|x| Alltrim(x[1][1]) == "F"})

			//Prepara arrays de trabalho
				aLayAux:= aArrLay[nPosLay]
				aDadAux:= aDados[nPosDad]

			//Informa no log a quantidade de registros informado no arquivo e a quantidade processada
				If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "QTDREG"})) <> 0
					cMensAux := "Quantidade de Registros=> Informado no arquivo: "+ Alltrim(Str(aDadAux[Len(aDadAux),nPosAux])) +". Lidos: " + Alltrim(Str(nRegLid)) + ""
					cMensLog += cMensAux + _CRLF
					U_FSGrvLog(cMensAux)
				EndIf

			//Nao continua lendo o arquivo apos o final do arquivo
				Exit

			Else  //Efetua tratamento para os demais tipos

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
						
						//Verifica se foi passado o CNPJ/CPF
						//Caso tenha sido passado localiza o cliente/fornecedor pelo CNPJ/CPF
							If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CNPJCPF"})) <> 0
								cCNPJCPF:= Alltrim(aDadAux[Len(aDadAux),nPosAux])

								If !Empty(cCNPJCPF)
									If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "F1_TIPO"})) <> 0
										cTipNF:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
									EndIf

									If Len(aCliFor:= U_FSCliFor(Iif(cTipNF$"BD","C","F"),cCNPJCPF)) <> 0
										If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "F1_FORNECE"})) <> 0
											aDadAux[Len(aDadAux),nPosAux]:= aCliFor[1]
										EndIf
	
										If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "F1_LOJA"})) <> 0
											aDadAux[Len(aDadAux),nPosAux]:= aCliFor[2]
										EndIf
									
									EndIf
								EndIf
	
							EndIf
						
						//Carrega dados no cabecalho
							U_FSMntArr(@aCabec, aLayAux, aDadAux2)

						ElseIf cTipDad == "M"
						//Carrega dados no cabecalho
							U_FSMntArr(@aCabec, aLayAux, aDadAux2)

						ElseIf cTipDad == "D"
						//Carrega dados no item
							U_FSMntArr(@aItens, aLayAux, aDadAux2, .T.)

						EndIf

					Next nZi

				Next nYi

			//Coloca array na ordem do SX3
				aCabec:= U_FSAceArr(aCabec, "SF1")
				aItens:= U_FSAceIte(aItens, "SD1")
			
			//Executa rotina de inclusao automatica
				If Len(aCabec) <> 0 .And. Len(aItens) <> 0
				//Tratamento de erro para o registro
					lErrReg:= .F.

					Begin Transaction
						FSIncAut(aCabec, aItens, nRegLid, aArquivos[nXi,1], cTipOper,lManual)
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
			U_FSVldAll(aArquivos[nXi,1],cNomRot,"P")

		//O arquivo sera movido para pasta BACKUP ENTRADA
			If U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1], cDirInt+cDirBkp+cDirImp+cDirAMD+"\"+aArquivos[nXi,1])
				cMensAux := "Movido para a pasta: "+ cDirInt+cDirBkp+cDirImp+cDirAMD + _CRLF
				cMensLog += cMensAux
				U_FSGrvLog(cMensAux)
			EndIf
	
		Else
		//Grava registro de processado para o arquivo
			U_GrvLogTb(cNomRot,aArquivos[nXi,1],"Importacao com SUCESSO!","",0,"")

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
@author	   Jane Mariano Duval
@since	   31/05/2010
/*/
//-------------------------------------------------------------------
Static Function FSIncAut(aCabPre, aItemPre, nRegLid, cFile, cTipOper,lManual)

	Local cTipOpe	:= 0
	Local lExiste	:= .T.
	Local lContinua	:= .T.
	Local cMensAux	:= ""
	Local cGrvErr	:= ""
	Local aChave	:= {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA"}
	Local cChave	:= xFilial("SF1")
	Local aChaveP	:= {"F1_PEDLEG"}
	Local cChaveP	:= xFilial("SF1")
	Local cSerieNF 	:= ""
	Local cNFiscal 	:= ""
	Local cFormulNF	:= ""
	Local cTpNrNfs 	:= SuperGetMV("MV_TPNRNFS") //Retorno o tipo de controle da numeracao da NF
	Local cTipoNf	:= "" //Rodolfo
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local cUFCli	:= ""
	Local cTipLeg	:= ""
	Local lExiteReg := .F.
//Local cMenNota	:= ""

	Private lMsHelpAuto:= .T.
	Private lMsErroAuto:= .F.

               
                    






//Carrega chave de pesquisa
	For nXi:= 1 To Len(aChave)
		If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == aChave[nXi]})) <> 0
			cChave += aCabPre[nPos,2]
		EndIf
	Next nXi
                                 




//Avalia tipo de operacao
	If cTipOper=="A"
		cTipOpe:= 3 //Iif(!lExiste, 3, 4) //3 Inclusao 4 Alteracao
	ElseIf cTipOper=="X" .And. lExiste
		cTipOpe:= 5 //Exclusao
	Else
		lContinua:=.F.
	EndIf


// Inicio Bloco - Carrega Chave de Pesquisa por Pedido LEgado.  -- Davis  12/12/2011

	If lContinua .And. cTipOpe <> 5
		For nXi:= 1 To Len(aChaveP)
			If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == aChaveP[nXi]})) <> 0
				cChaveP += aCabPre[nPos,2]
			EndIf
		Next nXi
                                                                          

		DbSelectArea("SF1")
		dbOrderNickName("FSSF1IND01") //F1_FILIAL+F1_PEDLEG
		lExiteReg := DbSeek(cChaveP)
   
		If lExiteReg
			lContinua := .F.
      
			cMensAux += "PEDIDO LEGADO: "+Substr(cChaveP,3,8)+" JA FOI IMPORTADO. "+ _CRLF
      
		EndIf
   
	EndIf
// -- Nao deixar de Criar o Indice com a Chave F1_FILIAL+F1_PEDLEG  - NickName = FSSF1IND01
// -- Fim Bloco de Codigo - Davis 12/12/2011

	If cTipOpe==3
		If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_FORMUL"})) <> 0
			cFormulNF:= aCabPre[nPos,2]
		EndIf

		If Alltrim(cFormulNF)=="S"
			If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_SERIE"})) <> 0
				cSerieNF:= aCabPre[nPos,2]
			EndIf
	
			If Empty(cSerieNF)
				cMensAux+= "Serie nao foi informado."
				lContinua:= .F.
			EndIf
		EndIf
	EndIf


//Valida devolucao
//Comentado em 20/12/2010 em comun acordo com Marcelo devido a devolucoes parciais
//Foi deixado claro que caso o arquivo seja processado mais de uma vez sera efetuado a inclusao n vezes
//If lContinua
//	If U_FSRetVal(aCabPre,"F1_TIPO")=="D"
//		lContinua:= FSVldDev(aCabPre,aItemPre,@cMensAux)
//	EndIf
//EndIf

	If lContinua

		If cTipOpe==3 .And. Alltrim(cFormulNF)=="S"

			cNFiscal:= NxtSX5Nota( cSerieNF,.T.,cTpNrNfs)
		
			If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_DOC"})) <> 0
				aCabPre[nPos,2]:= cNFiscal
			EndIf
		EndIf
		/*Rodolfo. Inicio em 20110927*/
		If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_TIPO"})) <> 0
			cTipoNf := aCabPre[nPos,2]
		EndIf
		If (nPos := aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_FORNECE"})) <> 0
			cCodCli := aCabPre[nPos,2]
		EndIf
		If (nPos := aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_LOJA"})) <> 0
			cLojCli := aCabPre[nPos,2]
		EndIf
		If (nPos := aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_TIPLEG"})) <> 0
			cTipLeg := aCabPre[nPos,2]
		EndIf

		cUFCli := POSICIONE("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_EST")

		If (cTipoNf == "D" .And. cUFCli == "MG"  .AND. cTipLeg <> "97" ) .OR. (cTipLeg == '03' .AND. cUFCli == 'PA' .AND. cTipoNf == "D")  //alterado dia 07/07/2014 conforme solicitação da Sra. Simone
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabPre,aItemPre,3)
		Else
			MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabPre,aItemPre,3)
		EndIf
	/*Rodolfo. Fim
	20110927 - Removi emissão de pré nota para Devoluções dentro de MG.
	
		//Efetua inclusao e/ou alteracao
		//MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabPre,aItemPre,3) 
	  
		Davidson 20110826 alteração do processo,para criação de pre-nota
	   	de entrada para todos os documentos de entrada.
	 	MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabPre,aItemPre,3) 
	*/

	
		If lMsErroAuto .Or. !Empty(cMensErr)
			DisarmTransaction()
	
			lErrReg:= .T.
	
			cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
			cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
			cGrvErr+= "REGISTRO ===> " + cChave  + _CRLF
			If Empty(cMensErr)
				cGrvErr+= MemoRead(NomeAutoLog()) + _CRLF
			Else
				cGrvErr+= cMensErr + _CRLF
			EndIf
			U_FSGrvLog(cGrvErr)

			U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
	
		//Apaga o arquivo de erro apos gravar no log da importacao, devido ser acumulado erros no arquivo
			If Empty(cMensErr)
				Ferase(NomeAutoLog())
			Else
				cMensErr:=""
			EndIf

		Else

//		If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == "F1_ZMENNOT"})) <> 0
//			cMenNota:= aCabPre[nPos,2]
//		EndIf

		//Atualiza campos de controle
			dbSelectArea("SF1")
			If Reclock("SF1",.F.)
				F1_ARQIMP	:= cFile
				F1_DTIMP	:= Date()
				F1_ZMENNOT	:= U_FSRetVal(aCabPre,"F1_ZMENNOT")
				F1_PEDLEG	:= U_FSRetVal(aCabPre,"F1_PEDLEG")
				F1_FILLEG   := U_FSRetVal(aCabPre,"F1_FILLEG")
				F1_TIPLEG   := U_FSRetVal(aCabPre,"F1_TIPLEG")
				MsUnlock()
			EndIf
		
		//Efetua exportacao da nota fiscal de entrada
//		FSExpNfe()

       // - Davis - 20/09/2011 - Inserir campo D1_TESACLA
       
			cFilSD1 := SF1->F1_FILIAL
			cDocSD1 := SF1->F1_DOC
			cSerSD1 := SF1->F1_SERIE
			cForSD1 := SF1->F1_FORNECE
			cLojSD1 := SF1->F1_LOJA
			dbSelectArea("SD1")
			dbSetOrder(1)
			If dbSeek(cFilSD1+cDocSD1+cSerSD1+cForSD1+cLojSD1) .And. ( !(cTipoNf == "D" .And. cUFCli == "MG") .Or. cTipLeg == "97")
       
				While ! SD1->( Eof() ) .And. SD1->D1_FILIAL == cFilSD1 .And. SD1->D1_DOC == cDocSD1 .And. SD1->D1_SERIE == cSerSD1 .And. ;
						SD1->D1_FORNECE == cForSD1 .And. SD1->D1_LOJA == cLojSD1
                  
					cTESACLA:= U_FSBusTES(SD1->D1_ZCFOENT,SD1->D1_ZSEQENT,SD1->D1_ZPARENT)[1]
					dbSelectArea("SD1")
					If RecLock("SD1",.F.)
						Replace D1_TESACLA With cTESACLA
						MsUnLock()
					EndIf
					dbSelectArea("SD1")
					SD1->(dbSkip())
				End
			EndIf

		EndIf
	Else
		lErrReg:= .T.

		cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
		cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
		cGrvErr+= "REGISTRO ===> " + cChave  + _CRLF

		If !Empty(cMensAux)
			cGrvErr+= cMensAux
		Else
			cGrvErr+= "Operacao invalida para o registro." + _CRLF
		EndIf

		U_FSGrvLog(cGrvErr)

		U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
	EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSVldDev
Valida nota de origem de devolucao

@protected
@author	   Cláudio Luiz da Silva
@since	   29/06/2010

@param 	   aCabPre     Array com dados do cabecalho
@param      aItemPre		Array com dados do item
@param      cMensAux		Mensagem a ser retornada ao usuario
@result		lRet			True se nota ainda nao devolvida
/*/
//-------------------------------------------------------------------
Static Function FSVldDev(aCabPre,aItemPre,cMensAux)

	Local 	lRet		:= .T.

	Local 	cAliasSD1	:= ""
	Local 	cFornece	:= cLoja:= cProduto:= cNFOrig:= ""

	Local	aItemAux 	:= {}

	Local 	nXi			:= 0
	Local 	nYi			:= 0
	Local	nPos		:= 0

//Carrega chave de pesquisa
	cFornece	:= U_FSRetVal(aCabPre,"F1_FORNECE")
	cLoja		:= U_FSRetVal(aCabPre,"F1_LOJA")

	For nYi:= 1 To Len(aItemPre)

		aItemAux := aClone(aItemPre[nYi])

	//Efetua validacao da nota de origem somente se for passado somente a nota
	//caso contrario sera efetuado validacao padrao
		If !( !Empty(U_FSRetVal(aItemAux,"D1_NFORI")) .And. Empty(U_FSRetVal(aItemAux,"D1_SERIORI")) .And. Empty(U_FSRetVal(aItemAux,"D1_ITEMORI")) )
			Loop
		EndIf

		cAliasSD1:= GetNextAlias()

		cProduto	:= U_FSRetVal(aItemAux,"D1_COD")
		cNFOrig		:= U_FSRetVal(aItemAux,"D1_NFORI")
	
		BeginSql Alias cAliasSD1
			SELECT SD1.R_E_C_N_O_ SD1RECNO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA,
			SD1.D1_ITEM, SD1.D1_NFORI, SD1.D1_SERIORI, SD1.D1_ITEMORI
			FROM %table:SD1% SD1
			WHERE SD1.%NotDel%
			AND SD1.D1_FILIAL  = %exp:cFilAnt%
			AND SD1.D1_FORNECE = %exp:cFornece%
			AND SD1.D1_LOJA    = %exp:cLoja%
			AND SD1.D1_COD     = %exp:cProduto%
			AND SD1.D1_NFORI   = %exp:cNFOrig%
			ORDER BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE
		EndSql

		lFirst:= .T.
	
		dbSelectArea(cAliasSD1)
		(cAliasSD1)->(dbGotop())
		While !(cAliasSD1)->(Eof())
			If lFirst
				lRet:= .F.
				cMensAux+= "Nota de devolucao ja importada para a(s) nota(s):" + _CRLF
				cMensAux+= "Nota      Ser Item      NF Origem Ser Item" + _CRLF
				lFirst:= .F.
			EndIf

			cMensAux+= D1_DOC+" "+D1_SERIE+" "+D1_ITEM+" "+Space(05)+D1_NFORI+" "+D1_SERIORI+" "+D1_ITEMORI + _CRLF

			dbSkip()
		EndDo
		
	//Fecha area temporaria
		(cAliasSD1)->(dbCloseArea())
	
	Next nYi

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSExpNfe
Efetua exportacao nota fiscal de entrada

@protected
@author	   Cláudio Luiz da Silva
@since	   30/12/2010
/*/
//-------------------------------------------------------------------
Static Function FSExpNfe()

//Efetua exportacao nota fiscal de entrada
	U_FSEXPP01("I")

	If !Empty(cFSDocGer)
	//Define diretorios utilizados pela rotina de exportacao e importacao
		U_FSDirInt()

	//Copia arquivo para \BACKUP\SAIDA
		U_FSCopArq(cDirInt+cDirTmp+cDirExp+"\"+cFSDocGer, cDirInt+cDirBkp+cDirExp+cDirAMD+"\"+cFSDocGer)

	//O arquivo sera movido para pasta \SAIDA
		U_FSMovArq(cDirInt+cDirTmp+cDirExp+"\"+cFSDocGer, cDirInt+cDirExp+"\"+cFSDocGer)

	//Atualiza flag de arquivo gerado
		dbSelectArea("SF1")
		If Reclock("SF1",.F.)
			F1_ARQEXP:= cFSDocGer
			F1_DTEXP	:= Date()
			MsUnlock()
		EndIf
	EndIf

Return
// teste teste teste teste teste
// retirar

User Function tetete(C123)
	Local cFil123 :="01FE02"
Return (cfil123)
