#Include "protheus.ch"                       
#Include "topconn.ch" 
#Define  _CRLF  CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSIMPP05
Importacao de Pedido de Venda.

@author	   Cláudio Luiz da Silva
@since	   05/04/2010 
@version	   FSWPD00044_PL_05-COFERMETA
@obs	      
Executa somente para empresa corrente.

FSIMPP05 - Execucao Manual
FSIMPW05 - Execucao Automatica
FSIMPP05.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
25/05/2010 Claudio Silva   Adaptacao da rotina de acordo com FSWPD00066_PL03 (Transferencia entre Filiais)
17/06/2010 Claudio Silva   Alteracao nomenclatura arquivo. VDS-Pedido de Venda  VDT-Transferencia
22/06/2010 Claudio Silva   Inclusao tratamento para localizar cliente a partir do CNPJ/CPF para devolucao de cupom fiscal
07/10/2010 Claudio Silva   Alterado tratamento em caso de inconsistencia na importacao, para mover o arquivo para 
                           pasta BACKUP/ENTRADA em vez da pasta ENTRADA.
/*/
//-------------------------------------------------------------------

User Function FSIMPP05()

Local 		nOpca 		:= 0			 // Flag de confirmacao para OK ou CANCELA
Local 		aSays		:= {} 		 // Array com as mensagens explicativas da rotina
Local 		aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local 		cCadastro:= "Importação de Pedido de Venda"

Local		bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
Local   	bBlock, bErro //Tratamento de erro
Local 		lManual 	:= .T.
Local 		cMensAux	:= ""

Private  	cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
Private 	cNomRot		:= "FSIMPP05" //Define o nome da rotina principal para controle
Private  	lErrArq		:= .F.
Private 	nHdlLog		:= 0
Private 	cMensLog	:= ""                                                  
Private 	cMensErr	:= ""  //Tratamento de erro
Private		cFileLog	:= ""
Private 	oProcess
Private  	cMasArq		:= "*VD?.txt"  //Mascara de filtro arquivo
Private  	cTipoLeg	:= ""  // -- Davis 21/09/2011


AADD(aSays, "Este programa tem como objetivo efetuar Importação de Pedido de Venda.")
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

		//U_FSGrvLog("Empresa: "+SM0->M0_CODIGO)
		U_FSGrvLog("Empresa: "+FWCodEmp())

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
		U_FSEnvMai(Nil,cFileLog,Nil,"FSIMPP05-Importacao de Pedido de Venda",Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)

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
/*/{Protheus.doc} FSIMPW05
Importacao de Pedido de Venda (JOB)

@author	   Cláudio Luiz da Silva
@since	   05/04/2010
@version	   FSWPD00044_PL_05-COFERMETA
@obs	      
Executa para todas as empresas.

FSIMPP05 - Execucao Manual
FSIMPW05 - Execucao Automatica
FSIMPP05.LAY - Arquivo de Layout da rotina

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function FSIMPW05()

Local 		aRecnoSM0	:= {}
Local 		aEmpFil		:= {}

Local 		lContinua	:= .T.
Local 		nI			:= 0

Local		bFileLog	:= {|X| DTOS(DATE())+LEFT(TIME(),2) +SUBSTR(TIME(),4,2)+ RIGHT(TIME(),2)}
Local   	bBlock, bErro //Tratamento de erro
Local 		lManual 	:= .F.
Local 		cMensAux	:= ""

Private  	cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD
Private 	cNomRot		:= "FSIMPP05" //Define o nome da rotina principal para controle
Private  	lErrArq		:= .F.
Private 	nHdlLog  	:= 0
Private 	cMensLog 	:= ""
Private 	cMensErr	:= ""  //Tratamento de erro
Private		cFileLog	:= ""
Private 	oProcess
Private  	cMasArq		:= "*VD?.txt"  //Mascara de filtro arquivo
Private  	cTipoLeg	:= ""

ConOut("******************************************************************************")
ConOut("* INICIANDO PROCESSO FSIMPP05                        " + DtoC(Date()) + " as " + Time() + "Hrs *") 
ConOut("* Importacao de Pedido de Venda                                              *")
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
	U_FSEnvMai(Nil,cFileLog,aEmpFil,"FSIMPP05-Importacao de Pedido de Venda",Nil) //FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)
	
	//Move todos os arquivos da pasta TEMP\ENTRADA para pasta de ENTRADA
	aEval(Directory(cDirInt+cDirTmp+cDirImp+"\"+cMasArq), { |aArquivos| U_FSMovArq(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[1], cDirInt+cDirImp+"\"+aArquivos[1]) })
Else
	//Apaga arquivo de log
	//Arquivo de log nao podera ser apagado em caso de erro devido ao delay de envio do arquivo como anexo
	U_FSGrvLog(,,.T.) //Apaga arquivo de log
EndIf

ConOut("******************************************************************************")
ConOut("* FINALIZANDO PROCESSO FSIMPP05                      " + DtoC(Date()) + " as " + Time() + "Hrs *")
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

Local	aDados  	:= {}
Local   aArrLay   	:= {}
Local   cArqLay 	:= ""
Local   nHandle 	:= 0
Local   lProcessa	:= .T.
Local	aLayAux		:= {} 
Local   nPosLay   	:= 0
Local	aDadAux		:= {}
Local   nPosDad   	:= 0
Local   nPosAux   	:= 0
Local   aCabec		:= {}
Local   aItens		:= {}
Local   aItDes		:= {} //Cofermeta/Crepaldi - 06/12/2012 = customização da Danfe Cofermeta
Local   nXi			:= 0
Local   nYi			:= 0
Local   nRegLid   	:= 0
Local   cMensAux  	:= ""
Local   cTipArq		:= "PEDVENDA" 	//Define o nome da rotina no arquivo para validacao
Local   cFilOld		:= cFilAnt		//Salva filial anterior
Local   aArquivos	:= {}
Local   nHdlLock  	:= -1
Local   cTipOper	:= ""
Local   cTipDad		:= ""
Local   aPagto		:= {}     
Local   nAcresc		:= 0

Private  lErrReg	:= .F.
Private  cCNPJCPF	:= ""
Private	cZVendedo	:= ""
Private cCCVended	:= ""
Private cZCodCli	:= ""
Private cZLojCli	:= ""
Private nPosCli		:= ""
Private nPosLoj		:= ""


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
aArquivos	:= Directory(cDirInt+cDirTmp+cDirImp+"\"+FWCodEmp()+cMasArq)
aArquivos 	:= aSort(aArquivos,,,{|x,y|  x[4] < y[4]})

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
	if File(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1])
		U_TrcChrEsp(cDirInt+cDirTmp+cDirImp+"\"+aArquivos[nXi,1])
	Endif	
	
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

		aDados  := {}
		aCabec	:= {}
		aItens	:= {}
		aItDes	:= {} //Cofermeta/Crepaldi - 06/12/2012 = customização da Danfe Cofermeta
		aPagto	:= {}

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
					nPosLay		:= aScan(aArrLay,{|x| Alltrim(x[1][1]) == cTipDad})
					aLayAux		:= aArrLay[nPosLay]
					
					//Monta array
					If cTipDad == "H"
						cCNPJCPF:= ""
						
						//Busca o tipo de operacao
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "OPERACAO"})) <> 0
							cTipOper:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
						EndIf
						// Davis - 21/09/2011 - Verifica o Tipo Legado.
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_TIPLEG"})) <> 0
							cTipoLeg:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
						EndIf
						
						// Pega o vendedor para definir o Centro de Custo - Marcio Felipe 11/08/2014
						/* COMENTADO conforme solicitação do Marcelo - Marcio Felipe - 06/01/2015
						DbSelectArea("SA3")
						DbGoTop()
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_VEND1"})) <> 0
							cZVendedo := Alltrim(aDadAux[Len(aDadAux),nPosAux])
					    		cCCVended := Posicione("SA3",1,xFilial("SA3")+cZVendedo,"A3_CCUSTO")
							If AllTrim(Posicione("CTT",3,xFilial("CTT")+cCCVended,"CTT_CUSTO")) <> ""
								cCCVended := Posicione("CTT",3,xFilial("CTT")+cCCVended,"CTT_CUSTO") // INCLUIDO DIA 05/01/2015 PARA RESOLVER PROBLEMAS DE CC CONFORME SOLICITACAO DA CONTABILIDADE
							EndIf
						EndIf
					    */
					    
						//Verifica se foi passado o CNPJ/CPF
						//Caso tenha sido passado localiza o cliente/fornecedor pelo CNPJ/CPF
						If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "CNPJCPF"})) <> 0
							cCNPJCPF:= Alltrim(aDadAux[Len(aDadAux),nPosAux])

							If !Empty(cCNPJCPF)
								If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_TIPO"})) <> 0
									cTipNF:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
								EndIf

								aCliFor:= U_FSCliFor(Iif(cTipNF$"BD","F","C"),cCNPJCPF)
											
								If !Empty(aCliFor[1]) .And. !Empty(aCliFor[1])
									If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_CLIENTE"})) <> 0
										aDadAux[Len(aDadAux),nPosAux]:= aCliFor[1]
									EndIf
	
									If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_LOJACLI"})) <> 0
										aDadAux[Len(aDadAux),nPosAux]:= aCliFor[2]
									EndIf
								EndIf
							Else // INICIO otimização da validação de cliente - Marcio Felipe - 25/08/2014
									
									If (nPosAux:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_TIPO"})) <> 0
										cTipNF:= Alltrim(aDadAux[Len(aDadAux),nPosAux])
									EndIf
									
									If (nPosCli:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_CLIENTE"})) <> 0
										cZCodCli := aDadAux[Len(aDadAux),nPosCli]
									EndIf
	
									If (nPosLoj:= aScan(aLayAux,{|x| Alltrim(x[2]) == "C5_LOJACLI"})) <> 0
										cZLojCli := aDadAux[Len(aDadAux),nPosLoj]
									EndIf
						
									If !cTipNF$"BD" // bonificação e devolução 
										DbSelectArea("SA1")
										If !ExistCpo("SA1", cZCodCli + cZLojCli)//verificar no cadastro de clientes
									    	aDadAux[Len(aDadAux),nPosCli] := "       "
									    	aDadAux[Len(aDadAux),nPosLoj] := "  "
									    EndIf
									Else
										DbSelectArea("SA2")
										If !ExistCpo("SA2", cZCodCli + cZLojCli)//verificar no cadastro de fornecedores
									    	aDadAux[Len(aDadAux),nPosCli] := "       "
									    	aDadAux[Len(aDadAux),nPosLoj] := "  "
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
						
					ElseIf cTipDad == "X" //Cofermeta/Crepaldi - 06/12/2012 = customização da Danfe Cofermeta
						//Carrega dados no item
						U_FSMntArr(@aItDes, aLayAux, aDadAux2, .T.)

					ElseIf cTipDad == "P"
						//Carrega dados de detalhamento de pagamento
						U_FSMntArr(@aPagto, aLayAux, aDadAux2, .T.)
						
					EndIf

				Next nZi

			Next nYi
            
			//Cofermeta/Marcio Felipe - 03/04/2013 
			//alteração para ajustar data do registro de OP - para evitar data de vencimento menor que data de emissao
			If Len(aPagto) > 0
				For nX1:= 1 To Len(aPagto)
					nPosiForm	:= aScan(aPagto[nX1] ,{|x| Alltrim(x[1]) == 'P01_FORMA'})	
					If allTrim(aPagto[nX1][nPosiForm][2]) == "OP"
						nPosiData := aScan(aPagto[nX1] ,{|x| Alltrim(x[1]) == 'P01_DATA'})
						If aPagto[nX1][nPosiData][2] < Date()
							aPagto[nX1][nPosiData][2] := Date()		
						EndIf
					EndIf		   
			   Next nX1
			Endif

			//Cofermeta/Crepaldi - 06/12/2012 = customização da Danfe Cofermeta
			//alteração para customizar as tags <INFADPROD>, <XPED>, <NITEMPED>
			If Len(aItDes) > 0
			   For nX1:= 1 To Len(aItens)
				   IF (Alltrim(aItens[nX1,1,1]) == "C6_ITEM")
					  For nX2:= 1 To Len(aItDes)
				          IF (Alltrim(aItDes[nX2,1,1]) == "C6_ITEM" .And. Alltrim(aItDes[nX2,1,2]) == Alltrim(aItens[nX1,1,2]))
			                 Aadd(aItens[nX1], {"C6_DESCNFE", Alltrim(aItDes[nX2,2,2]), Nil })
			                 Aadd(aItens[nX1], {"C6_FCICOD", Alltrim(aItDes[nX2,3,2]), Nil })
			              Endif
				      Next nX2
				   EndIf
			   Next nX1
			Endif // fim Len(aItDes) > 0
			

			//Coloca array na ordem do SX3
			aCabec:= U_FSAceArr(aCabec, "SC5")
			aItens:= U_FSAceIte(aItens, "SC6")  
			                                                                                                 
			// Alterado Alex T. Souza 27/11/2013
			//acerta campos do C5_PARC? E C5_DATA? de acordo com os dados da linha P do arquivo matriz aPagto
			For nX1 := 1 to len(aPagto)
				if nX1 <= 26
					if nX1 <= 9
						cCmpParc := "C5_PARC"+StrZero(nX1,1)
						cCmpData := "C5_DATA"+StrZero(nX1,1)
					Else
						cCmpParc := "C5_PARC"+Chr(nX1+55) //depois do C5_PARC9 passa a utilizar letra C5_PARCA, C5_PARCB	
						cCmpData := "C5_DATA"+Chr(nX1+55)	
				    Endif
				    
				    nNumDec := TamSX3(cCmpParc)[2]
					If (nPosAux:= aScan(aCabec,{|x| Alltrim(x[1]) == cCmpParc })) <> 0
						aCabec[nPosAux,2]:= Round(aPagto[nX1,3,2],nNumDec)
					EndIf
					If (nPosAux:= aScan(aCabec,{|x| Alltrim(x[1]) == cCmpData })) <> 0
						aCabec[nPosAux,2]:= aPagto[nX1,2,2]
					EndIf
				Endif		
			Next                                            
			
			// Alteracao Alex Teixeira de Souza - Ajuste no valor dos campos C5_PARC de acordo com valor dos itens dom pedido
			nTotParc := 0
			For nX1 := 1 to len(aCabec)
				if Substr(Alltrim(aCabec[nX1,1]),1,7) == "C5_PARC"
					nTotParc += aCabec[nX1,2]
				Endif                                             				
			Next

			nTotItens := 0			
			For nX1 := 1 to len(aItens)		
				If (nPosQtd := aScan(aItens[nX1],{|x| Alltrim(x[1]) == 'C6_QTDVEN'})) <> 0 .and. ;
				   (nPosVlr := aScan(aItens[nX1],{|x| Alltrim(x[1]) == 'C6_PRCVEN'})) <> 0 
				   	nVlrDsc := 0
				    if (nPosDsc := aScan(aItens[nX1],{|x| Alltrim(x[1]) == 'C6_VALDESC'})) <> 0
				    	nVlrDsc := aItens[nX1,nPosDsc,2]
				    Endif	                                                          
				    aadd(aItens[nX1],{"C6_VALOR",(aItens[nX1,nPosQtd,2]*aItens[nX1,nPosVlr,2])-nVlrDsc, NIL})
					nTotItens += (aItens[nX1,nPosQtd,2]*aItens[nX1,nPosVlr,2])-nVlrDsc
				Endif
			Next
			                
			// Adiciona valor do frete ao total de itens
		    if (nPosFrt := aScan(aCabec,{|x| Alltrim(x[1]) == "C5_FRETE"})) <> 0
		    	//aCabec[nPosFrt,2] := 0  // Alterado Alex T. Souza 11/12/13 - Retirar depois
		    	nTotItens += aCabec[nPosFrt,2]
		    Endif  
		    
			// Adiciona valor do frete ao total de itens
		    if (nPosDsp := aScan(aCabec,{|x| Alltrim(x[1]) == "C5_DESPESA"})) <> 0
		    	//aCabec[nPosDsp,2] := 0  // Alterado Alex T. Souza 11/12/13 - Retirar depois
		    	nTotItens += aCabec[nPosDsp,2]
		    Endif		    
			
			nPrcAjust := 0
			if nTotParc <> nTotItens
				nPrcAjust := nTotItens/nTotParc
				For nX1 := 1 to len(aCabec)
					if Substr(Alltrim(aCabec[nX1,1]),1,7) == "C5_PARC"
						nNumDec := TamSX3( Alltrim(aCabec[nX1,1]) )[2]
						aCabec[nX1,2] := Round(aCabec[nX1,2]*nPrcAjust,nNumDec)
					Endif
				Next				
			Endif	
			
			//Executa rotina de inclusao automatica
			If Len(aCabec) <> 0 .And. Len(aItens) <> 0
				//Tratamento de erro para o registro
				lErrReg:= .F.
				cChave:= ""

				Begin Transaction 
					lRet:= FSIncAut(aCabec, aItens, nRegLid, aArquivos[nXi,1], cTipOper, lManual, @cChave, aPagto)
				End Transaction
				
				//SC5 e SF2 tem que estar posicionado
				If lRet .And. Empty(cMensErr)
					If (SC5->C5_CONDPAG $ GetNewPar("FS_CONDPAG","888")) .And. !Empty(aPagto)
						Begin Transaction 
							lErrReg:= FGerLiq(nRegLid, cChave, aArquivos[nXi,1])
							If lErrReg
								DisarmTransaction()
							EndIf
						End Transaction
					EndIf				
				EndIf
            
				//Em caso de errolog. O tratamento de erro redireciona para apos o End Transaction e/ou End
				If !Empty(cMensErr)
					MsUnlockAll()
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
@author	   Claudio Luiz da Silva
@since	   05/04/2010

@param		aCabPre		Array cabecalho
@param		aItemPre		Array item
@param		nRegLid		Posicao do registro corrente
@param		cFile       Nome do arquivo
@param		cTipOper		Tipo de Operacao
@param		lManual 		Identificador se rotina executada manual ou via job
/*/
//-------------------------------------------------------------------
Static Function FSIncAut(aCabPre, aItemPre, nRegLid, cFile, cTipOper, lManual, cChave, aPagto)

Local cZOpc			:= Substr(cFile,len(cFile)-6,3) // Valor ->("VDS" ou "VDT") - incluido por Marcio Felipe 20-11-12 para tratar transferência
Local aChave		:= {}
Local cChave2		:= ""
Local nPos			:= 0
Local cTipOpe		:= 0
Local lExiste		:= .T.
Local lContinua		:= .T.
Local cMensAux		:= ""
Local cGrvErr		:= ""
Local lPed			:= .F.
Local cFlag			:= .T.
Local FlagComple	:= .F. //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local aItensComp	       //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local cTipoComp		:= ""  //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local nValor		:= 0   //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local cCfo			:= ""  //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local cSeqCfo		:= ""  //Rodolfo. 20110929 - Validando nota de complemento para clonar aItens adicionando campo C6_VALOR
Local aPagtoAux:= {}
Local aPagPar	:= {}
Local nZi		:= 0

cChave		:= xFilial("SC5")

// Incluido para tratar transferencia entre filiais que não validava filial de destino e, portanto, 
//impedia a inclusão do pedido que possuia o mesmo C5_PEDLEG - Marcio Felipe 20-11-2012
If cZOpc == "VDS"
	aChave := {"C5_PEDLEG","C5_TIPLEG"}
ElseIf cZOpc == "VDT"
	aChave := {"C5_ZFILDES","C5_PEDLEG","C5_TIPLEG"}
EndIf

Private lMsHelpAuto	:= .T.
Private lMsErroAuto	:= .F.
Private	aGrv		:={}

//Carrega chave de pesquisa
For nXi:= 1 To Len(aChave)
	If (nPos:= aScan(aCabPre ,{|x| Alltrim(x[1]) == aChave[nXi]})) <> 0
		cChave += aCabPre[nPos,2]
	EndIf
Next nXi

// Incluido para tratar transferencia entre filiais que não validava filial de destino e, portanto, 
//impedia a inclusão do pedido que possuia o mesmo C5_PEDLEG - Marcio Felipe 20-11-2012
DbSelectArea("SC5")
If cZOpc == "VDT"
	dbOrderNickName("FSSC5IND02") //C5_FILIAL+C5_ZFILDES+C5_PEDLEG+C5_TIPLEG
Else
	dbOrderNickName("FSSC5IND01") //C5_FILIAL+C5_PEDLEG+C5_TIPLEG
EndIf
lExiste := DbSeek(cChave)

//Insere no array o numero do pedido de venda
If lExiste
	Aadd(aCabPre, {"C5_NUM", SC5->C5_NUM, Nil })
	aCabec:= U_FSAceArr(aCabPre, "SC5")

   If (!Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ))
		cMensAux:= "Pedido de venda Protheus "+SC5->C5_NUM + " Legado "+SC5->C5_PEDLEG+" ja faturado!" + _CRLF
		lContinua:= .F.
	EndIf
EndIf
    //Rodolfo. 20110929 validando nota de complemento
	If (nPosAux:= aScan(aCabPre,{|x| Alltrim(x[1]) == "C5_TIPO"})) <> 0
		cTipoComp:= Alltrim(aCabPre[nPosAux][2])
	EndIf

//Avalia tipo de operacao
If cTipOper=="A"
	cTipOpe:= Iif(!lExiste, 3, 4) //3 Inclusao 4 Alteracao 
ElseIf cTipOper=="X" .And. lExiste
	cTipOpe:= 5 //Exclusao
Else
	lContinua:=.F.	
EndIf

If lContinua
	
	//Davidson 24/08/2011 validacao de nota fiscal de origem.		//(nPosNf:= aScan(aItemPre,{|x| Alltrim(x[1]) == 'C6_ITEMORI'})) <> 0
	For i:=1 To Len(aItemPre)
		For y:=1 To Len(aItemPre[1])
			If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_NFORI'})) <> 0
				If ! Empty(aItemPre [i][y][2])
					lPed:=.T.
				EndIf
			EndIf	
            
   			If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_CCUSTO'})) <> 0				// INCLUIDO DIA 06/01/2015 PARA RESOLVER
				If AllTrim(aItemPre[i][y][2]) <> "" .AND. AllTrim(Posicione("CTT",3,xFilial("CTT")+aItemPre[i][y][2],"CTT_CUSTO")) <> ""   // PROBLEMAS DE CC CONFORME SOLICITACAO DA CONTABILIDADE
					aItemPre[i][y][2] := Posicione("CTT",3,xFilial("CTT")+aItemPre[i][y][2],"CTT_CUSTO")   	// Marcio Felipe
				EndIf 
			EndIf
            
		Next y
	Next i	

	If lPed
	/**********************************************************************************************
	* Caso exista nota fiscal de origem buscaremos o pedido+produto+item para depois gravar na SC6
	/********************************************************************************/		 
			For i:=1 To Len(aItemPre)
			  Aadd(aGrv,{Space(2),Space(15),Space(9),Space(3),Space(4)})
				For y:=1 To Len(aItemPre[1])
					 
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_ITEM'})) <> 0
						If aItemPre [i][y][1] == 'C6_ITEM'
						//	Aadd(aGrv,{aItemPre[i][y][2]})
					   		aGrv[i][1]:=aItemPre[i][y][2]
						EndIf
					EndIf
					
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_PRODUTO'})) <> 0
						If aItemPre [i][y][1] == 'C6_PRODUTO'
						//	Aadd(aGrv,{aItemPre[i][y][2]})
							aGrv[i][2]:=aItemPre[i][y][2]
						EndIf
					EndIf									
					
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_NFORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_NFORI'
					   	//	Aadd(aGrv,{aItemPre[i][y][2]})
						aGrv[i][3]:=aItemPre[i][y][2]
						EndIf
					EndIf
					
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_SERIORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_SERIORI'
					 	//	Aadd(aGrv,{aItemPre[i][y][2]})
					   	aGrv[i][4]:=aItemPre[i][y][2]
						EndIf
					EndIf   					
					
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_ITEMORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_ITEMORI'
						//	Aadd(aGrv,{aItemPre[i][y][2]})  
							aGrv[i][5]:=aItemPre[i][y][2]
						EndIf
					EndIf
					
				Next Y
			Next i	
						
		   /***********************************************************************
		   * Passando o numero de NfOri e Serieori para array e apagando o itemorig
		   /***********************************************************************/
			For i:=1 To Len(aItemPre)
				For y:=1 To Len(aItemPre[1])
				    
					//Apagar o conteudo do C6_NFORI
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_NFORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_NFORI'					    
						     If cTipoLeg <> "065" // Davis
							    aItemPre[i][y][2]:="123456"
						     EndIf
						EndIf
					EndIf 
	                 
					//Apagar o conteudo do C6_SERIEORI
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_SERIORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_SERIORI'
						     If cTipoLeg <> "065" // Davis
							   aItemPre[i][y][2]:="1"  
						    EndIf
						EndIf
					EndIf			
				
					//Apagar o conteudo do C6_ITEMORI
					If (nPosNf:= aScan(aItemPre,{|x| Alltrim(x[y][1]) == 'C6_ITEMORI'})) <> 0
						If aItemPre [i][y][1] == 'C6_ITEMORI'
						     If cTipoLeg <> "065" // Davis
							   aItemPre[i][y][2]:=" "
						    EndIF
						EndIf
					EndIf
				Next
			Next i
	EndIf

	//Rodolfo. 20110929. Clonar array de itens para adicionar campo valor total para notas de complemento de ICMS
	IF cTipoComp == "I"
		
		aItensComp := ARRAY(Len(aItemPre))
		
		For nXy := 1 to len(aItemPre)
			aItensComp[nXy] := {}		    	
			For nXz := 1 to len(aItemPre[nXy])
			
				If aItemPre[nXy][nXz][1] == "C6_PRCVEN"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					AADD(aItensComp[nXy],{"C6_VALOR",aItemPre[nXy][nXz][2],Nil})
					nValor := aItemPre[nXy][nXz][2]
				ElseIf aItemPre[nXy][nXz][1] == "C6_CFO"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					cCfo := aItemPre[nXy][nXz][2]
				ElseIf aItemPre[nXy][nXz][1] == "C6_CFOSEQ"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					cCfoSeq := aItemPre[nXy][nXz][2]					
				ElseIf aItemPre[nXy][nXz][1] == "C6_ZDESCSE" .And. (cCfo == "6403" .Or. cCfo == "5405") .And. (cCfoSeq == "0002")
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					AADD(aItensComp[nXy],{"C6_ICMSRET",nValor,Nil})				
				Else
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
				EndIf
			
			Next nXz
		
		Next nXy
		FlagComple := .T.
	ElseIf cTipoComp == "C"
		
		aItensComp := ARRAY(Len(aItemPre))
		
		For nXy := 1 to len(aItemPre)
			aItensComp[nXy] := {}		    	
			For nXz := 1 to len(aItemPre[nXy])
			
				If aItemPre[nXy][nXz][1] == "C6_PRCVEN"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					AADD(aItensComp[nXy],{"C6_VALOR",aItemPre[nXy][nXz][2],Nil})
					nValor := aItemPre[nXy][nXz][2]
				ElseIf aItemPre[nXy][nXz][1] == "C6_CFO"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					cCfo := aItemPre[nXy][nXz][2]
				ElseIf aItemPre[nXy][nXz][1] == "C6_CFOSEQ"
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					cCfoSeq := aItemPre[nXy][nXz][2]					
				ElseIf aItemPre[nXy][nXz][1] == "C6_ZDESCSE" .And. (cCfo == "6403" .Or. cCfo == "5405") .And. (cCfoSeq == "0002")
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
					AADD(aItensComp[nXy],{"C6_ICMSRET",nValor,Nil})				
				Else
					AADD(aItensComp[nXy],{aItemPre[nXy][nXz][1],aItemPre[nXy][nXz][2],aItemPre[nXy][nXz][3]})
				EndIf
			
			Next nXz
		
		Next nXy
		FlagComple := .T.
	EndIF


	//Avalia se existem itens liberados
	If lExiste .And. U_FSLibPdV(SC5->C5_NUM,1)[1]
		lErrArq:= .T.
		lErrReg:= .T.
		
		cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
		cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
		cGrvErr+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
		cGrvErr+= "Nao foi gerado a nota fiscal do pedido Legado <"+SC5->C5_PEDLEG+"> Protheus<"+SC5->C5_NUM+">" + _CRLF
		cGrvErr+= "Pedido de venda ja possui itens liberados para faturamento." + _CRLF
		cGrvErr+= "EFETUE A GERACAO DA NOTA MANUALMENTE E RETIRE O ARQUIVO "+cFile+" DA PASTA DE ENTRADA." + _CRLF
		U_FSGrvLog(cGrvErr)
		
		//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
		U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
	Else            	
		dbSelectArea("SA1")
		dbSetOrder(1)    	
	
		//Efetua inclusao e/ou alteracao
 		If FlagComple //Rodolfo. 20110929. Validando tipo do pedido apara substituir o array com campo valor para complemento de icms
			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPre,aItensComp,cTipOpe)
		Else                     
			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPre,aItemPre,cTipOpe)
		EndIf
		//	FreeUsedCodes(.T.)
		
		If lMsErroAuto .Or. !Empty(cMensErr)    
		
			//MostraErro()
		
			DisarmTransaction()
			
			lErrArq:= .T.
			lErrReg:= .T.
			
			cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
			cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
			cGrvErr+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
			If Empty(cMensErr)
				cGrvErr+= MemoRead(NomeAutoLog()) + _CRLF
			Else
				cGrvErr+= cMensErr + _CRLF
			EndIf
			U_FSGrvLog(cGrvErr)
			
			//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
			U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
			
			//Apaga o arquivo de erro apos gravar no log da importacao, devido ser acumulado erros no arquivo
			If Empty(cMensErr)
				Ferase(NomeAutoLog())
			Else
				cMensErr:=""
			EndIf
			
		Else	
		
			//Atualiza campos de controle
			dbSelectArea("SC5")
			If Reclock("SC5",.F.)
				C5_ARQIMP	:= cFile
				C5_DTIMP	:= Date()
				MsUnlock()
			EndIf
		
			/**************************************************************************************
		   * Gravando na tabela SC6 a nota fiscal de origem e serie de origem do arquivo importado
		   /****************************************************************************************/
		    For l:=1 To Len(aGrv)  
		    		If cTipoLeg <> "065"   			   			   
					   dbSelectArea("SC6")
					   dbSetOrder(1)            //+ Pedido   item        Produto        
					   If dbSeek(xFilial("SC6")+SC5->C5_NUM+aGrv[l][1]+aGrv[l][2])					   										
					     	If Reclock("SC6",.F.)
						    	Replace	C6_NFORI   With  aGrv[l][3]							
						    	Replace	C6_SERIORI With  aGrv[l][4]
			   			    	Replace	C6_ITEMORI With  aGrv[l][5]
					   	    	MsUnlock()
	    				    EndIf
					   EndIf
					EndIf 
			Next l
			            
            // Davis - 20/09/2011 - 18:57 - Criado para Remessa para Troca. // Complemento de ICMS.
            // Cofermeta/Crepaldi - 17/11/2012 = De acordo com e-mail do Marcelo em 14/11/2012, foi 
            // interrompido o procsso de geração automatica de NF quando C5_TIPLEG == "054" (Devolucao de Compra/Fornecedor)
            // Marcio Felipe - 27/03/2013 - Alterado para remessa conserto não gerar NF automaticamente.
            
            If SC5->C5_TIPLEG == "044" .Or. SC5->C5_TIPLEG == "054" .Or. SC5->C5_TIPLEG == "022" .Or. SC5->C5_TIPLEG == "066" // Troca / Devolucao de Compra/Fornecedor / Garantia
               lPed := .T.          // nao gera nota                             
            ElseIf SC5->C5_TIPLEG == "065" //Complemento ICMS
               lPed := .F.
            EndIf

			
			//Efetua liberacao do pedido
			U_FSLibPdV(SC5->C5_NUM,2)
			
			//Se existir itens bloqueados forca desbloqueio
			If !U_FSLibPdV(SC5->C5_NUM,1)[2]
				U_FSLibBlq(SC5->C5_NUM)
			EndIf
			
			If !lPed
				//Avalia se existem itens a faturar e se
				//nao existem itens bloqueados do pedido
				If U_FSLibPdV(SC5->C5_NUM,1)[1] .And. U_FSLibPdV(SC5->C5_NUM,1)[2]
					//Gera nota fiscal de saida
					If !Empty(U_FSGerNFS(SC5->C5_NUM,SC5->C5_ZTIPPED))

						//Exclui P01
						If (cTipOpe==4) .Or. (cTipOpe==5)
						   U_FSDelP01(SC5->C5_NUM)
						EndIf
						
						If (cTipOpe==3) .Or. (cTipOpe==4)						
							//Adiciona o numero do pedido de venda ao array
							If !Empty(aPagto)
								For nZi:= 1 To Len(aPagto)
									aPagPar:= aPagto[nZi]
									Aadd(aPagPar,{"P01_FILIAL", SC5->C5_FILIAL, Nil})
									Aadd(aPagPar,{"P01_PEDIDO", SC5->C5_NUM, Nil})
									Aadd(aPagtoAux, aClone(aPagPar))
								Next nZi
								aPagto:= aClone(aPagtoAux)
								
								U_FSGrvP01(aPagto)
							EndIf
						EndIf
						
						//Avalia se pedido de venda é de transferencia
						If SC5->C5_ZTRANSF=="S"
							//Gera Pre-Nota de Saida baseado no pedido de venda
							U_FSGerPNE(SC5->C5_NUM,@cGrvErr,lManual,cFile)     // Inlcuido Davis a Clausula cFile - 24/10/2011
							
							If !Empty(cGrvErr)
								cMensAux:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
								cMensAux+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
								cMensAux+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
								
								cGrvErr:= cMensAux+cGrvErr
								
								U_FSGrvLog(cGrvErr)
								
								//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
								U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
							EndIf
						EndIf
					EndIf
					
				Else
					lErrArq:= .T.
					lErrReg:= .T.
					
					cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
					cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
					cGrvErr+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
					cGrvErr+= "Nao foi gerado a nota fiscal do pedido Legado <"+SC5->C5_PEDLEG+"> Protheus<"+SC5->C5_NUM+">" + _CRLF
					cGrvErr+= "Devido a inexistencia de itens liberados ou a existencia de itens bloqueados." + _CRLF
					cGrvErr+= "EM CASO DE ITENS JA LIBERADOS: EFETUE A GERACAO DA NOTA TAMBEM MANUALMENTE." + _CRLF
					cGrvErr+= "EM CASO DE BLOQUEIO: EFETUE O DESBLOQUEIO MANUALMENTE E A GERACAO DA NOTA TAMBEM MANUALMENTE." + _CRLF
					cGrvErr+= "APOS O PROCESSO, RETIRE O ARQUIVO "+cFile+" DA PASTA DE ENTRADA." + _CRLF
					U_FSGrvLog(cGrvErr)
					
					//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
					U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	lErrReg:= .T.
	
	cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
	cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
	cGrvErr+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
	
	If !Empty(cMensAux)
		cGrvErr+= cMensAux
	Else
		cGrvErr+= "Operacao invalida para o registro." + _CRLF
	EndIf
	
	U_FSGrvLog(cGrvErr)
	
	//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
	U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
EndIf

Return(lContinua)



//-------------------------------------------------------------------
/*/{Protheus.doc} FGerLiq
Gera liquidacao

@protected
@author	   Claudio Luiz da Silva
@since	   14/12/2012
/*/
//-------------------------------------------------------------------
Static Function FGerLiq(nRegLid, cChave, cFile)
Local cMensAux		:= ""
Local cGrvErr		:= ""
Local lRet			:= .F.

//Efetua Liquidacao de acordo com P01
If !U_FSProLiq("SF2",SF2->(Recno()),,@cGrvErr)
	cMensAux:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
	cMensAux+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
	cMensAux+= "REGISTRO ===> " + cChave  + Space(05) + cCNPJCPF + _CRLF
	cMensAux+= "Nao foi efetuado a liquidacao do pagamento. Verifique." + _CRLF
		
	cGrvErr:= cMensAux+cGrvErr
	
	U_FSGrvLog(cGrvErr)
	
	//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
	U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
	lRet:= .T.
EndIf

Return(lRet)