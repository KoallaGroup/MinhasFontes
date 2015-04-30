#Include "Protheus.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#Define  _CRLF  CHR(13)+CHR(10)

/*
Programa .: FSLIBGER
Funçao ...: Rotinas Genericas
Autor.....: Claudio Silva
Data .....: 19/03/2010

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo
*/

//-------------------------------------------------------------------
/* /{Protheus.doc} FSAbrSM0
Efetua a abertura do Sigamat(SM0)

@author	   Cláudio Luiz da Silva
@since	   

@param 		lSM0Comp   Define se sera aberto compartilhado

@return		lOpen      T. ou .F. - SM0 aberto ou fechado
/*/
//-------------------------------------------------------------------
User Function FSAbrSM0(lSM0Comp)

	Local lOpen := .F.
	Local nLoop := 0

	Default lSM0Comp:= .T.

	For nLoop := 1 To 20

		If Select("SM0")>0
			dbSelecTArea("SM0")
			dbCloseArea()
		EndIf
		dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", lSM0Comp, .F. )
		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex("SIGAMAT.IND")
			Exit
		EndIf
		Sleep( 500 )

	Next nLoop

Return( lOpen )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSEmpInt
Carrega array somente com as empresas, desconsiderando as filiais.

@author	   Cláudio Luiz da Silva
@since	   

@return		aRecnoSM0  		array com as empresas
/*/
//-------------------------------------------------------------------
User Function FSEmpInt()

	Local aRecnoSM0	:= {}

	dbSelectArea("SM0")
	SM0->(dbGoTop())
	Do While !SM0->(Eof())
		If Ascan(aRecnoSM0,{ |x| x[2] == SM0->M0_CODIGO + SubStr(SM0->M0_CODFIL,01,02)}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO + SubStr(SM0->M0_CODFIL,01,02)})
		EndIf
	
		dbSelectArea("SM0")
		SM0->(dbSkip())
	EndDo

Return(aRecnoSM0)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSChkBug
Tratamento de erro especifico para capturar o erro e armazenar em variavel.

@author	   Cláudio Luiz da Silva
@since	   

@param 		e         Objeto do erro
@param 		lManual   Define se a rotina esta sendo executada manualmente

@obs	      
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
08/10/2010 Claudio Silva   Adequacao rotina devido a estouro de variavel string, caso a string ultrapasse 1Mb sera gravado o log
/*/
//-------------------------------------------------------------------
User Function FSChkBug(e, lManual)

	Local	cDescErr:= cDetaErr:= ""

	Default lManual:= .F.

	IF e:gencode > 0
		If lManual
			HELP(" ",1,"ERR_MSG",,e:Description,2,1)
		EndIf

		cDescErr:= "Erro.....: "+ e:Description	+ _CRLF
		cDetaErr:= "Descricao: "+ e:ErrorStack 	+ _CRLF

		If Len(cMensErr)+Len(cDescErr)+Len(cDetaErr) >= (1024*1024) //Limite string 1Mb

			U_FSGrvLog(cMensErr + _CRLF)
			U_FSGrvLog(cDescErr)
			U_FSGrvLog(cDetaErr)

		//Variavel tem que ser carregada com valor devido tratamento nas rotinas
			cMensErr := "."
		Else
			cMensErr	+= cDescErr
			cMensErr	+= cDetaErr
		EndIf

	Endif

	Break


//-------------------------------------------------------------------
/*/{Protheus.doc} FSTraExe
Controle para travar e destravar rotina para ser executada somente 1 vez

@author	   Cláudio Luiz da Silva
@since	   

@param      nHdlLock  Identificador interno para o arquivo de trava
@param      cNomArq   Nome Arquivo a ser gerado com extensao .L01 onde 01 empresa
@param      lTrava    Avalia se a rotina sera para travar ou destravar
@param      lManual   Avalia se a rotina esta sendo executada Manualmente ou Automatico

@return     lRet .T. ou .F. - Avalida se a rotina podera ser executada ou nao
/*/
//-------------------------------------------------------------------
User Function FSTraExe(nHdlLock, cNomArq, lTrava, lManual)

	Local lRet:= .F.
	Local cNomUsu:= Iif(Type("cUserName")<>"U", cUserName, "Workflow")

	lTrava:= Iif(lTrava==NIL, .F., lTrava)

	If lTrava

	// Nao permite o acesso simultaneo … rotina por mais de 1 usuario.
		IF ( nHdlLock := MSFCREATE(cNomArq+".L"+cEmpAnt)) < 0
			If lManual
				MsgAlert("A rotina esta sendo utilizada por outro usuário."+_CRLF+;
					"Por questões de integridade de dados, não é permitida"+_CRLF+;
					"a utilização desta rotina por mais de um usuário simultaneamente."+_CRLF+;
					"Tente novamente mais tarde.","::Atenção::")
			else
				ConOut("** A rotina esta sendo utilizada por outro usuário **" + DtoC(Date()) + " as " + Time() + "Hrs")
			EndIf
			lRet:= .T.
		Endif
	
	//Grava no sem foro informações sobre quem está utilizando
		FWrite(nHdlLock,"Operador: "+cNomUsu+_CRLF+;
			"Empresa.: "+cEmpAnt+_CRLF+;
			"Filial..: "+cFilAnt+_CRLF)

	else

		If nHdlLock > -1
			fclose(nHdlLock)
			Ferase(cNomArq+".L"+cEmpAnt)
		Endif
	
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSAceArr
Coloca o array para sigaauto na mesma ordem do SX3

@author	   Cláudio Luiz da Silva
@since	   

@param      aArrPar   Array tipo cabecalho
@param      cAliasSX3 Alias da tabela a ser pesquisada

@return     aArrAux   Array ordenado
/*/
//-------------------------------------------------------------------
User Function FSAceArr(aArrPar, cAliasSX3)

	Local nPos		:= 0
	Local nXi		:= 0
	Local aArrAux	:= {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasSX3,.T.)
	While !Eof() .And. (X3_ARQUIVO==cAliasSX3)

	//Acerta array com somente uma linha
		If (nPos:= aScan(aArrPar,{|x| Alltrim(x[1]) == Alltrim(X3_CAMPO) })) <> 0
			aadd(aArrAux,aClone(aArrPar[nPos]))
		EndIf

		DbSkip()

	EndDo

Return(aArrAux)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSAceIte
Coloca o array para sigaauto na mesma ordem do SX3, utilizado para array de itens

@author	   Cláudio Luiz da Silva
@since	   

@param      aArrPar   Array tipo item
@param      cAliasSX3 Alias da tabela a ser pesquisada

@return     aArrAux   Array ordenado
/*/
//-------------------------------------------------------------------
User Function FSAceIte(aArrPar, cAliasSX3)

	Local aArrAux	:= {}
	Local aArrAux2	:= {}
	Local nPos		:= 0
	Local nXi		:= 0

//Acerta array com varias linhas
	For nXi:= 1 To Len(aArrPar)

		aArrAux2:= aArrPar[nXi]
		aArrAux2:= U_FSAceArr(aArrAux2, cAliasSX3)

		If Len(aArrAux2) <> 0
			aadd(aArrAux,aClone(aArrAux2))
		EndIf

	Next nXi

Return(aArrAux)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGrvLog
Cria e grava arquivo de log

@author	   Cláudio Luiz da Silva
@since	   

@param      cMensagem	Mensagem a ser gravada
@param      lFecha   	Informa se o arquivo sera fechado
@param      lApaga	  	Apaga arquivo de log

@return     lRet 			.T. ou .F. - Avalia se a rotina foi executada sem erro
/*/
//-------------------------------------------------------------------
User Function FSGrvLog(cMensagem, lFecha, lApaga)

	Local lRet:= .T.
	Local nRet:= 0

	Default lFecha:= .F.
	Default lApaga:= .F.

	If !lApaga
		If !lFecha

			If !File(cFileLog)
			//Criacao de novo arquivo
				IF (nHdlLog:= MSFCREATE(cFileLog,0)) > 0
					lRet:= .T.
					FCLOSE(nHdlLog)
				Endif
			Else
				If !Empty(cMensagem)
				//Abre de novo o arquivo de log
					nHdlLog:= FOPEN(cFileLog,2)
					If nHdlLog > 0
					//Posiciona no fim do arquivo
						FSeek(nHdlLog, 0, FS_END)
		   		//Grava a mensagem
						nRet:= FWrite(nHdlLog, cMensagem + _CRLF)
					//Fecha o arquivo
						FCLOSE(nHdlLog)
					EndIf
				EndIf
			EndIf
		Else
		//Fecho o arquivo	
			If nHdlLog > -1
				FCLOSE(nHdlLog)
			Endif
		EndIf
	Else
	//Apago o arquivo
		If File(cFileLog)
			FErase(cFileLog)
		EndIf
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMntQry
Monta area de acordo com parametros.

@author	   Cláudio Luiz da Silva
@since	   

@param      cAlias  alias a ser criado
@param      cQuery  query a ser utilizada para geracao arq. temporario
@param      aStru   array com alias para verificacao estruturas para conversao TCSETFIELD
/*/
//-------------------------------------------------------------------
User Function FSMntQry(cAlias, cQuery, aAliStru)

	Local lStruct:= Iif(aAliStru == NIL, .F., .T.)

	cQuery := ChangeQuery(cQuery)

//Monta Query
	If Select(cAlias) <> 0
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	If lStruct
		For nx:= 1 To Len(aAliStru)
			aStru:= (aAliStru[nx])->(dbStruct())
			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C'
					TCSetField(cAlias, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
		Next
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSZerEsq
Tira zero a esquerda de uma variavel string

@author	   Cláudio Luiz da Silva
@since	   

@param      cValor 		string a ser convertida

@return     cRetorno 	string convertida
/*/
//-------------------------------------------------------------------
User Function FSZerEsq(cValor)

	Local nPos		:= 1
	Local cRetorno	:= ""

//Verifica a posicao do primeiro caractere diferente de zero
	While SubStr(cValor,nPos,1) == "0"
		nPos++
	EndDo

	cRetorno:= SubStr(cValor,nPos,Len(cValor))

Return(cRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSEnvMai
Rotina de Envio de email para o Administrador do Sistema utilizando WF.

@author	   Cláudio Luiz da Silva
@since	   

@param      cMensLog   Mensagem a ser enviada no corpo do email
@param      cAttach    Nome do arquivo a ser enviado
@param      aEmpFil    Array com Empresa e Filial para abertura de ambiente caso necessario
@param      cSubject   Assunto do email
@param      cDestino   Destino do email
/*/
//-------------------------------------------------------------------
User Function FSEnvMai(cMensLog,cAttach,aEmpFil,cSubject,cDestino)

	Local oHTML, oProcess
	Local aFiles

	Default cSubject	:= "Email Automatico - Log de Erro - "+Dtoc(Date()) + " " + Time()
	Default cAttach	:= ""
	Default cMensLog	:= ""

	If aEmpFil <> Nil
		RpcSetType(3)
		RpcSetEnv(aEmpFil[1], aEmpFil[2])
		nModulo := 05
	EndIf

//Cofermeta/Crepaldi - 29/03/2012 = PERMITE DEFINIR UM DESTINATARIO SEM SOBREPOSICAO DO PARAMETRO "MV_WFADMIN"
	If cDestino == Nil
		Default cDestino := GetMv("MV_WFADMIN")
	EndIf

	oProcess:= TWFProcess():New("LOGERRO", "Log Erro")
	oProcess:NewTask("LOGERRO", "\WORKFLOW\LOGERRO.htm")
	oProcess:cTo:= cDestino
	oProcess:cSubject:= cSubject

//Envio de arquivo em anexo
	If !Empty(cAttach)
	//Busca atributos do arquivo a ser anexado
		aFiles:= Directory(cAttach)

	//Se anexo maior que 5M nao envia por email
		If aFiles[1,2] > (1024*1024*5)
			If !Empty(cMensLog)
				cMensLog+= "<br><br>"
			EndIf
			cMensLog+= "Arquivo de log possui mais de 5Mb.<br>"
			cMensLog+= "Favor verificar o arquivo no caminho "+cAttach+ "."
		Else
			If Empty(cMensLog)
				cMensLog	:= "Segue arquivo descritivo do erro em anexo."
			EndIf
			oProcess:AttachFile(cAttach)
		EndIf
	Else
		If Empty(cMensLog)
			cMensLog	:= "Segue arquivo descritivo do erro em anexo."
		EndIf
	EndIf

	oProcess:cBody:= cMensLog

	oHTML:= oProcess:oHTML

	oHtml:ValByName("Mensagem"	,cMensLog)

	oProcess:Start()
	oProcess:Finish()

	If aEmpFil <> Nil
	//Fecha ambiente atual
		RpcClearEnv()
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCriDir
Verifica a existencia do diretorio e cria se nao existir.

@author	   Cláudio Luiz da Silva
@since	   

@param      cPath       Caminho a ser verificado/criado diretorio
@param      lDrive      Flag para controlar a digitacao da unid. drive 
								.T. -> tera que informar a unidade de drive
								.F. -> Nao controla a unidade de drive

@return     lRet       .T. Sucesso  .F. Erro de gravacao
/*/
//-------------------------------------------------------------------
User Function FSCriDir( cPath, lDrive )

	Local aDir
	Local lRet:=.T.

	If Empty(cPath)
		Return lRet
	EndIf

	lDrive := If(lDrive == Nil, .T., lDrive)
	cPath := Alltrim(cPath)

	If Subst(cPath,2,2) <> ":\" .AND. lDrive
		lRet:=.F.
	Else
		cPath := If(Right(cPath,1) == "\", Left(cPath,Len(cPath)-1), cPath)
		aDir  := Directory(cPath,"D")
		If Len(aDir) = 0
			If MakeDir(cPath) <> 0
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSValQry
Verifica quantos registros existem na tabela com o codigo passado em parametro

@author	   Cláudio Luiz da Silva
@since	   

@param 		cTabela    alias da tabela. Exemplo: "SB1"
@param 		aFiltro    array com campo e valor: Exemplo: "B1_LOCAL","01"

@return     lRet       .T. se foi localizado registros
/*/
//-------------------------------------------------------------------
User Function FSValQry(cTabela, aFiltro)

	Local aArea  := GetArea()
	Local cTipo  := Iif(Left(cTabela,1)=="S",SubStr(cTabela,2),cTabela)
	Local lRet   := .T.
	Local cQuery := ""

	cQuery := "SELECT COUNT(*) NRECS FROM " + RetSqlName(cTabela) + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
	cQuery += cTipo+"_FILIAL = '"+ xFilial(cTabela)+"' AND "

	For nXi:= 1 To Len(aFiltro)
		If Type(aFiltro[nXi,2])=="C"
			cQuery += Alltrim(aFiltro[nXi,1])+ " = '"+ Alltrim(aFiltro[nXi,2]) + "' "
		ElseIf Type(aFiltro[nXi,2])=="N"
			cQuery += Alltrim(aFiltro[nXi,1])+ " =  "+ Alltrim(Str(aFiltro[nXi,2])) + " "
		EndIf

	//Se tiver mais de um filtro e nao for o ultimo filtro, adiciona o "AND"
		If (Len(aFiltro)>1) .And. (Len(aFiltro)<>nXi)
			cQuery+= " AND "
		EndIf
	Next nXi
	
	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBQRY",.F.,.T.)

	If TRBQRY->NRECS > 0
		Help(" ",1,"NAOPODE",,"Registro esta relacionado na tabela "+cTabela+"!",2)
		lRet:= .F.
	Endif

	dbCloseArea()

	RestArea(aArea)

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMosTxt
Mostra texto em janela.

@author	   Cláudio Luiz da Silva
@since	   

@param 		cTexto    Texto a ser apresentada
/*/
//-------------------------------------------------------------------
User Function FSMosTxt(cTexto)

	Local oDlg, oMemo, oButton

	DEFINE MSDIALOG oDlg FROM 3,0 to 340,720 PIXEL TITLE ".: Ocorrências :."

	oMemo:= tMultiget():New(05,05,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oDlg,350,145,,,,,,.T.,,,,,,.T.)

	oButton:=tButton():New(153,285,'&Fechar',oDlg,{||oDlg:End()},70,15,,,,.T.)

	oMemo:EnableVScroll(.T.)
	oMemo:EnableHScroll(.T.)
	oMemo:lWordWrap:= .T.

	ACTIVATE MSDIALOG oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCliFor
Localiza cliente/fornecedor pelo CPF/CNPJ.

@author	   Cláudio Luiz da Silva
@since	   

@param 		cTipo      Tipo de Pesquisa C-Cliente F-Fornecedor
@param 		cCGC       CPF/CNPJ para localizar cliente/fornecedor

@return     aRet       Vetor contendo na primeira posicao o codigo e na segunda a loja
/*/
//-------------------------------------------------------------------
User Function FSCliFor(cTipo,cCGC,lCupom)

	Local cCliFor	:= ""
	Local cLoja		:= ""
	Local cSeek		:= ""

	Default lCupom:= .F.

	If (cTipo == "C")
	//Cliente
		dbSelectArea("SA1")
		dbSetOrder(3) //A1_FILIAL+A1_CGC
		dbSeek(cSeek:= xFilial("SA1")+cCGC)
		While !Eof() .And. Alltrim(cSeek)==Alltrim(A1_FILIAL+A1_CGC)
			cCliFor	:= A1_COD
			cLoja		:= A1_LOJA
			If (A1_MSBLQL<>"1") //1=Sim;2=Não
			//Caso nao seja cupom e o cliente for balcao, continua pesquisando
				If !lCupom .And. (A1_BALCAO=="1")  //1=Sim;2=Não
					dbSkip()
					Loop
				Else
					Exit
				EndIf
			EndIf
		
			dbSkip()
		EndDo
	ElseIf (cTipo == "F")
	//Fornecedor
		dbSelectArea("SA2")
		dbSetOrder(3) //A2_FILIAL+A2_CGC
		dbSeek(cSeek:= xFilial("SA2")+cCGC)
		While !Eof() .And. Alltrim(cSeek)==Alltrim(A2_FILIAL+A2_CGC)
			cCliFor	:= A2_COD
			cLoja		:= A2_LOJA

			If (A2_MSBLQL<>"1") //1=Sim;2=Não
				Exit
			EndIf
		
			dbSkip()
		EndDo
	EndIf
 
Return({cCliFor,cLoja})


//-------------------------------------------------------------------
/*/{Protheus.doc} FSBusTES
Funcao para localizar a TES correspondente ao CFO/SEQ do sistema Legado.

@author	   Cláudio Luiz da Silva
@since	   10/04/2010

@param 		cCFO       CFO do sistema legado
@param 		cCFOSEQ    SEQ do sistema legado
@param 		cCFOPAR    PAR do sistema legado

@return		aTES       Array com TES e CF correspondente

@obs
Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo
Claudio Silva   31/05/2010 Inclusao tratamento campo parametro
/*/
//-------------------------------------------------------------------
User Function FSBusTES(cCFO,cCFOSEQ,cCFOPAR)

	Local aAreaOld:= GetArea()

	Local aTES	:= {"",""}

	Default cCFOPAR:= Space(04)

	dbSelectArea("SZ1")
	dbSetOrder(1) //Z1_FILIAL+Z1_CFO+Z1_SEQ+Z1_PAR
	If dbSeek(xFilial("SZ1")+cCFO+cCFOSEQ+cCFOPAR)
		aTES:= {SZ1->Z1_TES, POSICIONE("SF4",1,XFILIAL("SF4")+SZ1->Z1_TES,"SF4->F4_CF")}
	EndIf

	RestArea(aAreaOld)

Return(aTES)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSBUSCFO
Funcao para localizar o CFO/SEQ correspondente a TES utilizada.

@author	   Cláudio Luiz da Silva
@since	   19/04/2010

@param 		cTES       TES a ser pesquisada

@return		aCfoSeq    CFO e SEQ do sistema legado
/*/
//-------------------------------------------------------------------
User Function FSBusCFO(cTES)

	Local aAreaOld:= GetArea()

	Local aCfoSeq:= {"","",""}

	dbSelectArea("SZ1")
	dbSetOrder(2) //Z1_FILIAL+Z1_TES
	If dbSeek(xFilial("SZ1")+cTES)
		aCfoSeq:= {Z1_CFO,Z1_SEQ,Z1_PAR}
	EndIf

	RestArea(aAreaOld)

Return(aCfoSeq)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSLibPdV
Efetua a liberacao do pedido de venda.
A transacao devera ser controlada na rotina de origem.

@author	   Cláudio Luiz da Silva
@since	   

@param 		cPedVen    Numero do Pedido de Venda
@param 		nTipo      1-Avalia bloqueio 2-Libera pedido

@return     lRet       verdadeiro se todos os itens forem liberados
/*/
//-------------------------------------------------------------------
User Function FSLibPdV(cPedVen,nTipo)

	Local aAreaOld	:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aBloqueio:= {}
	Local aPvlNfs	:= {}

	Default nTipo  := 2

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + cPedVen)
	If !Eof()

	//Rotina padrao de liberacao do pedido
		Ma410LbNfs(nTipo,@aPvlNfs,@aBloqueio)

	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaOld)

Return({Len(aPvlNfs)<>0,Len(aBloqueio)==0})


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCanPdv
Efetua o cancelamento da liberacao do pedido de venda.
Será utilizado o parametro FS_SERCOF para definir a serie da nota fiscal a ser gerada.

@author	   Cláudio Luiz da Silva
@since	   15/04/2010

@param 		cPedVen   Pedido de Venda

@return     cNota     Numero da nota fiscal gerada

@obs
A transacao devera ser controlada na rotina de origem

/*/
//-------------------------------------------------------------------
User Function FSCanPdv(cPedVen)

	Local aAreaOld	:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local cSeek		:= ""

//Agora apago o pedido original
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(cSeek:=xFilial("SC6")+cPedVen)
	While  !Eof() .And. cSeek==C6_Filial+C6_Num
	
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(cSeek2:=xFilial("SC9")+SC6->C6_Num+SC6->C6_Item)
		While !Eof() .And. cSeek2==C9_Filial+C9_Pedido+C9_Item
	
			a460Estorna()
   
			dbSelectArea("SC9")
			dbSkip()
		EndDo
	
		dbSelectArea("SC6")
		dbSkip()
	EndDo

	SC6->(RestArea(aAreaSC6))
	SC5->(RestArea(aAreaSC5))
	RestArea(aAreaOld)

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSLibBlq
Efetua a liberacao de bloqueio de estoque.

@author	   Cláudio Luiz da Silva
@since	   25/05/2010

@param 		cPedVen   Pedido de Venda
/*/
//-------------------------------------------------------------------
User Function FSLibBlq(cPedVen)

	Local aAreaOld	:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local cSeek		:= ""

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(cSeek:=xFilial("SC6")+cPedVen)
	While  !Eof() .And. cSeek==C6_Filial+C6_Num
	
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(cSeek2:=xFilial("SC9")+SC6->C6_Num+SC6->C6_Item)
		While !Eof() .And. cSeek2==C9_Filial+C9_Pedido+C9_Item

			MaAvalSC9("SC9",6,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}},Nil,Nil,.F.)
			Reclock("SC9",.F.)
			SC9->C9_BLEST := ""
			MsUnlock()
			MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}})
   
			dbSelectArea("SC9")
			dbSkip()
		EndDo
	
		dbSelectArea("SC6")
		dbSkip()
	EndDo

	SC6->(RestArea(aAreaSC6))
	SC5->(RestArea(aAreaSC5))
	RestArea(aAreaOld)

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGerNFS
Efetua geracao da nota fiscal de saida utilizando processo padrao.
Será utilizado o parametro FS_SERCOF para definir a serie da nota fiscal a ser gerada.

@author	   Cláudio Luiz da Silva
@since	   15/04/2010

@param 		cPedVen   Pedido de Venda

@return     cNota     Numero da nota fiscal gerada
/*/
//-------------------------------------------------------------------
User Function FSGerNFS(cPedVen,cTipPed)

	Local aAreaOld	:= GetArea()
	Local cNota		:= ""
	Local cSerie	:= ""

	If cTipPed=="S"
		cSerie:= GetNewPar("FS_SERSER","1  ")
	Else
		cSerie:= GetNewPar("FS_SERCOF","1  ")
	EndIf

	If !Empty(cSerie)
		IncNota(cPedVen, cSerie)
	
		cNota:= SF2->F2_DOC
	EndIf

	RestArea(aAreaOld)

Return(cNota)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMovArq
Move arquivo de um diretorio para outro, apagando antes do destino caso exista
a funcao FRENAME nao move se o arquivo existir no destino.

@author	   Cláudio Luiz da Silva
@since	   15/04/2010

@param 		cOrigem    Arquivo de origem com diretorio
@param 		cDestino   Arquivo de destino com diretorio

@return     lRet       Se arquivo foi movido com sucesso
/*/
//-------------------------------------------------------------------
User Function FSMovArq(cOrigem,cDestino)

	Local lRet:= .T.

//Se o arquivo ja existe no diretorio de destino apaga antes de mover
	If File(cDestino)
		lRet:= (FErase(cDestino) <> -1)
	EndIf

	If lRet
	//Move o arquivo da origem para destino
		lRet:= (FRename(cOrigem, cDestino) <> -1)
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCOPARQ
Rotina que copia arquivo de uma ORIGEM para DESTINO.
Foi tratado para caso o arquivo ja exista no DESTINO seja excluido antes.

@author	   Cláudio Luiz da Silva
@since	   19/04/2010

@param 		cOrigem    Arquivo de origem com diretorio
@param 		cDestino   Arquivo de destino com diretorio

@return     lRet       Se arquivo foi copiado com sucesso
/*/
//-------------------------------------------------------------------
User Function FSCopArq(cOrigem,cDestino)

	Local lRet:= .T.

//Se o arquivo ja existe no diretorio de destino apaga antes de copiar
	If File(cDestino)
		lRet:= (FErase(cDestino) <> -1)
	EndIf

	If lRet
		__CopyFile(cOrigem, cDestino)
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCNVCNAE
Rotina que formata o codigo CNAE de acordo com padrao Protheus
Formato do codigo CNAE 9999-9/99

@author	   Cláudio Luiz da Silva
@since	   27/04/2010

@param 		cCodCnae   Codigo CNAE recebido pela importacao

@return		cRet       Codigo CNAE convertido para formato Protheus
/*/
//-------------------------------------------------------------------
User Function FSCnvCNAE(cCodCnae)

	Local cRet	:= ""
	Local cValor:= ""
	Local cPict	:= PesqPict("CC3","CC3_COD")

//Retira espacos em branco caso tenha
	cCodNae:= Alltrim(cCodCnae)

//Monta string somente com numeros
	For nXi:= 1 To Len(cCodCnae)
		If IsDigit(SubStr(cCodCnae,nXi,1))
			cValor+= SubStr(cCodCnae,nXi,1)
		EndIf
	Next nXi

//Verifica a existencia do @ na picture. 
//Caso nao tenha inclui formatacao @R para que o hifen e barra nao fique no lugar dos numeros
	If (At("@",cPict)==0)
		cPict:= "@R "+Alltrim(cPict)
	EndIf

//Converter a string no formato especificado
	cRet:= Transform(cValor, cPict)

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSRetVal
Retorno conteudo do campo no array passado em parametro.

@author	   Cláudio Luiz da Silva
@since	   11/05/2010

@param 		aArray    	Array para pesquisa (padrao sigaauto)
@param 		cCampo   	Campo a ser pesquisado no array

@return     xRet       	Conteudo localizado no array
/*/
//-------------------------------------------------------------------
User Function FSRetVal(aArray,cCampo)

	Local xRet
	Local nPos:= 0

	If (nPos:= aScan(aArray,{|x| Alltrim(x[1]) == Alltrim(cCampo)})) <> 0
		xRet := aArray[nPos,2]
	EndIf

Return(xRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSValProd
Valida codigo de produto de acordo com a divisao da filial corrente.

@author	   Jane Mariano Duval
@since	   21/05/2010

@param 		cCod   	codigo do produto a ser validado na SZ7

@return     lRet     Retorno
/*/
//-------------------------------------------------------------------
User Function FSValProd(cCod)

	Local aAreaOld	:= GetArea()
	Local lRet     := .T.
	Local lVal     := .F.
	Local lUsoCon  := Len(AllTrim(cCOD)) > 10
	Local cProduto := Substring(cCod,1,2)

//Verifica se função não está sendo chamada por uma rotina automatica msexecauto
	Do Case
	Case  Type("l410Auto")<>"U"  	 // Variavel Rotina do Pedido de Vendas Mata410
		lVal:=l410Auto
	Case  Type("l103Auto")<>"U"		//  Variavel Rotina da Nota Fiscal de Entrada Mata103
		lVal:=l103Auto
	Case  Type("l140Auto")<>"U"		//  Variavel Rotina da Pré Nota Mata140
		lVal:=l140Auto
	Case  Type("l010Auto")<>"U"   	//  Variavel Rotina do Produto Mata010
		lVal:=l010Auto
	EndCase
 
	If !lUsoCon
		If !lVal

			DbSelectArea("SZ7")
			DbSetOrder(1)
			If dbSeek(xFilial("SZ7")+Right(cFilAnt,02)) // Verifica se existe cadastro de Filial X Divisão para a Filial corrente (M0_CODFIL)
 
				If SZ7->Z7_VALDIV=='S' //Verifica se Filial Cofermeta valida Divisão
					If SZ7->Z7_DIVISAO<>cProduto // Verifica o Codigo do produto digitado
						MsgAlert("Produto informado não permitido para esta Divisão Cofermeta .","::Atenção::")
						lRet:= .F.
					EndIf
				EndIf
			Else
				MsgAlert("Não existe Cadastro de Filial X Divisão para a Filial Corrente - " +(cFilAnt)  +"."+_CRLF+;
					"Favor Contactar o Administrador.","::Atenção::")
				lRet:=.F.
			EndIf
	
		EndIf
	EndIf
	RestArea(aAreaOld)

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSFilCP
Filtra Consulta Padrão SB1.

@author	   Jane Mariano Duval
@since	   21/05/2010

@return     lRet       	Retorno
/*/
//-------------------------------------------------------------------
User Function FSFilCP()

	Local aAreaOld	:= GetArea()
	Local aAreaSZ7	:= SZ7->(GetArea())
	Local lRet     := .t.

	DbSelectArea("SZ7")
	DbSetOrder(1) //Z7_FILIAL+Z7_FILCOF
	If dbSeek(xFilial("SZ7")+Right(cFilAnt,02)) // Verifica se existe cadastro de Filial X Divisão para a Filial corrente (M0_CODFIL)
		If SZ7->Z7_VALDIV=='S'
			If Substring(SB1->B1_COD,1,2)<>Alltrim(SZ7->Z7_DIVISAO) //Verifica se Filial Valida Divisão e Se codigo do produto igual ao Z7_DIVISAO
				lRet:=.f.
			EndIf
		Else
			lRet:=.t.
		EndIf
	EndIf

	RestArea(aAreaSZ7)
	RestArea(aAreaOld)

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSRetDiv
Retorna a divisao da filial passada em parametro.

@author	   Cláudio Luiz da Silva
@since	   25/05/2010

@param 		cFilPar    	Filial a ser verificada

@return     cRet       	Divisao da Filial
/*/
//-------------------------------------------------------------------
User Function FSRetDiv(cFilPar)

	Local aAreaOld:= GetArea()
	Local cRet:= ""

//Localiza a divisao da filial corrente
	dbSelectArea("SZ7")
	dbSetOrder(1) //Z7_FILIAL+Z7_FILCOF
	dbSeek(xFilial("SZ7")+Right(cFilPar,02))
	If !Eof()
		cRet:= Z7_DIVISAO
	EndIf

	RestArea(aAreaOld)

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCnvIte
Converte sequencial de item de numerico para alfanumerico.

@author	   Cláudio Luiz da Silva
@since	   25/05/2010

@param 		cItem      	Filial a ser verificada
@param 		cTipo       C=Converte;D=Desconverte

@return     cRet       	Item convertido
/*/
//-------------------------------------------------------------------
User Function FSCnvIte(cItem,cTipo)

	Local cRet	:= ""
	Local cSoma	:= "00"
	Local nXi	:= 0

	Default cTipo:= "C"

	For nXi:= 1 to 1000
	//Efetua soma alfanumerica
		cSoma:= Soma1(cSoma)

		If cTipo=="C" .And. Val(cItem)==nXi
			cRet:= cSoma
			Exit
		ElseIf cTipo=="D" .And. cItem==cSoma
			cRet:= Strzero(nXi,4)
			Exit
		EndIf
	Next nXi

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGerPNE
Gera pre-nota de entrada baseado no Pedido de Venda

@author	   Cláudio Luiz da Silva
@since	   25/05/2010

@param 		cPedVen     Numero do Pedido de Venda
@param 		cGrvErr     Variavel de mensagem de erro
@param 		lManual     Tipo de execucao
/*/
//-------------------------------------------------------------------
User Function FSGerPNE(cPedVen,cGrvErr,lManual,cFile)             // Incluido o Parametro cFile - Davis 24/10/2011

	Local lContinua:= .T.
	Local	cFilTmp	:= cFilAnt
	Local	aCabec	:= {}
	Local	aItens	:= {}
	Local	aArrAux	:= {}
	Local	cSeek		:= ""
	Local cSeekSC6	:= ""
	Local cItem		:= ""
	Local aCFO		:= {}
	Local cSC5FilLeg  := "" //- Davis 24/10/2011
	Local cSC5TipLeg  := "" //- Davis 24/10/2011
	Local cSC5PedLeg  := "" //- Davis 24/10/2011
	Local cSC5MenLeg  := "" // - Davis 24/10/2011

	Default lManual:= .T.
	Default cPedVen:= ""
	Default cGrvErr:= ""

	Private lMsHelpAuto:= .T.
	Private lMsErroAuto:= .F.

	If !Empty(cPedVen)
	//Reposiciona no Pedido de Venda
		dbSelectArea("SC5")
		dbSetOrder(1) //C5_FILIAL+C5_NUM
		dbSeek(xFilial("SC5")+cPedVen)
	EndIf

	dbSelectArea("SC5")

//Validacoes iniciais
	If C5_ZTRANSF <> "S"
		cGrvErr+= "Pedido de venda "+C5_NUM +" nao e de transferencia!" + _CRLF
		lContinua:= .F.
	ElseIf C5_ZGERTRF == "S"
		cGrvErr+= "Já foi efetuado transferencia para o pedido de venda "+C5_NUM +"!" + _CRLF
		lContinua:= .F.
	ElseIf C5_ZTRANSF == "S" .And. Empty(C5_ZFILDES)
		cGrvErr+= "Filial de destino para transferencia do pedido de venda "+C5_NUM +" deve ser informado!" + _CRLF
		lContinua:= .F.
	ElseIf !(!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ))
		cGrvErr+= "Pedido de venda "+C5_NUM +" ainda nao faturado!" + _CRLF
		lContinua:= .F.
	EndIf


//Valida divisao filial de origem e destino
	If lContinua
	//Localiza a divisao da filial destino
		cDivDes:= U_FSRetDiv(SC5->C5_ZFILDES)

	//Localiza a divisao da filial corrente
		cDivOri:= U_FSRetDiv(cFilAnt)

		If cDivOri<>cDivDes
			lContinua:=.F.
		EndIf
	EndIf

	
//Posiciona na filial (divisao de origem)	
	If lContinua
		dbSelectArea("SZ7")
		dbSetOrder(1) //Z7_FILIAL+Z7_FILCOF
		dbSeek(xFilial("SZ7")+Right(cFilAnt,02))
		If Eof()
			cGrvErr+= "Nao existe cadastro de DIVISAO, cadastrado para a filial "+cFilAnt + _CRLF
			cGrvErr+= "EFETUE A GERACAO DA PRE-NOTA MANUALMENTE." + _CRLF
			lContinua:= .F.
		Else
			If Empty(Z7_FORNECE) .Or. Empty(Z7_LOJA)
				cGrvErr+= "Nao existe fornecedor relacionado ao cadastro de DIVISAO." + _CRLF
				cGrvErr+= "EFETUE A GERACAO DA PRE-NOTA MANUALMENTE." + _CRLF
				lContinua:= .F.
			EndIf
		EndIf
	EndIf

//Efetua tratamento para geracao da pre-nota
	If lContinua
		aCabec:= {}
		aItens:= {}
		aArrAux:= {}
	
		aAdd(aCabec, {'F1_DOC     ',SC5->C5_NOTA, Nil})
		aAdd(aCabec, {'F1_SERIE   ',SC5->C5_SERIE, Nil})
		aAdd(aCabec, {'F1_TIPO    ',"N", Nil})
		aAdd(aCabec, {'F1_FORMUL  ',"N", Nil})
		aAdd(aCabec, {'F1_ESPECIE ',"NFE", Nil})
		aAdd(aCabec, {'F1_FORNECE ',SZ7->Z7_FORNECE, Nil})
		aAdd(aCabec, {'F1_LOJA    ',SZ7->Z7_LOJA, Nil})
		aAdd(aCabec, {'F1_EMISSAO ',dDatabase, Nil})

		dbSelectArea("SC6")
		dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		dbSeek(cSeek:=SC5->(C5_FILIAL+C5_NUM),.T.)
		While !Eof() .And. (cSeek==C6_FILIAL+C6_NUM)

			aArrAux:= {}

			aAdd(aArrAux, {'D1_ITEM    ',U_FSCnvIte(C6_ITEM,"D"), Nil}) //Converte item
			aAdd(aArrAux, {'D1_COD     ',C6_PRODUTO, Nil})
			aAdd(aArrAux, {'D1_QUANT   ',C6_QTDVEN, Nil})
			aAdd(aArrAux, {'D1_VUNIT   ',C6_PRCVEN, Nil})
			aAdd(aArrAux, {'D1_TOTAL   ',C6_VALOR, Nil})
//		aAdd(aArrAux, {'D1_TES     ',U_FSBusTES(C6_ZCFOENT,C6_ZSEQENT,C6_ZPARENT)[1], Nil})
			aAdd(aArrAux, {'D1_ZCFOENT ',C6_ZCFOENT,Nil})
			aAdd(aArrAux, {'D1_ZSEQENT ',C6_ZSEQENT,Nil})
			aAdd(aArrAux, {'D1_ZPARENT ',C6_ZPARENT,Nil})

			aAdd(aItens,aClone(aArrAux))
					
			dbSelectArea("SC6")
			dbSkip()
		EndDo

		aCabec:= U_FSAceArr(aCabec, "SF1")
		aItens:= U_FSAceIte(aItens, "SD1")

	//Alterar a filial para filial destino
		cFilAnt:= SC5->C5_ZFILDES

	//Efetua inclusao automatica
		MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)

	//Tratamento de erro
		If lMsErroAuto
			cGrvErr:= "*** GERADO O ERRO ABAIXO QUE IMPOSSIBILITOU A ATUALIZACAO DO REGISTRO. VERIFIQUE! ***" + _CRLF
			cGrvErr+= "*** Nao foi possivel inserir linha " + StrZero(nRegLid, 10) + " do arquivo."+ _CRLF
			cGrvErr+= "REGISTRO ===> " + cChave  + _CRLF
			cGrvErr+= MemoRead(NomeAutoLog()) + _CRLF
			U_FSGrvLog(cGrvErr)
	
		//GrvLogTb(cRotina,cArqImp,cTitErro,cMensErro,nLinLog,cChave)
			U_GrvLogTb(cNomRot,cFile,"Erro de Importacao!",cGrvErr,nRegLid,cChave)
	
		//Apaga o arquivo de erro apos gravar no log da importacao, devido ser acumulado erros no arquivo
			Ferase(NomeAutoLog())

		Else

		//Atualiza campos de controle
			dbSelectArea("SC5")
			cSC5FilLeg := SC5->C5_ZFILDES //- Davis 24/10/2011
			cSC5TipLeg := SC5->C5_TIPLEG //- Davis 24/10/2011
			cSC5PedLeg := SC5->C5_PEDLEG //- Davis 24/10/2011
			cSC5MenLeg := SC5->C5_ZMENNOT //- Davis 24/10/2011
			If Reclock("SC5",.F.)
				C5_ZGERTRF:= "S"
				MsUnlock()
			EndIf
		
		//Atualiza campos de controle -- Davis  24/10/2011
			dbSelectArea("SF1")
			If Reclock("SF1",.F.)
				F1_ARQIMP	:= cFile
				F1_DTIMP	:= Date()
				F1_ZMENNOT	:= cSC5MenLeg  //U_FSRetVal(aCabec,"F1_ZMENNOT")
				F1_PEDLEG	:= cSC5PedLeg  //U_FSRetVal(aCabec,"F1_PEDLEG")
				F1_FILLEG   := cSC5FilLeg  //U_FSRetVal(aCabec,"F1_FILLEG")
				F1_TIPLEG   := cSC5TipLeg  //U_FSRetVal(aCabec,"F1_TIPLEG")
				MsUnlock()
			EndIf
        
        //Final - Davis 24/10/2011
		
		//Grava a TES e CFO na pre-nota, para ser utilizado na classificacao
			dbSelectArea("SD1")
			dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			dbSeek(cSeek:=SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),.T.)
			While !Eof() .And. (cSeek==D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

			//Converte o item de alfa para numerico
				cItem:= U_FSCnvIte(D1_ITEM)

				dbSelectArea("SC6")
				dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				dbSeek(cSeekSC6:=SC5->(C5_FILIAL+C5_NUM)+cItem+SD1->D1_COD)
				If !Eof() .And. (cSeekSC6==C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO)

				//Localiza a TES correspondente
					aCFO:= U_FSBusTES(C6_ZCFOENT,C6_ZSEQENT,C6_ZPARENT)
				
					dbSelectArea("SD1")
					If Reclock("SD1",.F.)
						D1_ZSUGTES:= aCFO[1]
						D1_TESACLA:= aCFO[1]
//					D1_CF := aCFO[2]
						MsUnlock()
					EndIf
		
				EndIf
						
				dbSelectArea("SD1")
				dbSkip()
			EndDo
		
		EndIf
	EndIf


//Mostra mensagem de erro
	If lManual .And. !Empty(cGrvErr)
		MsgStop(cGrvErr,".:Atenção:.")
	EndIf

//Restaura a filial corrente
	cFilAnt:= cFilTmp

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSVldMsg
Valida limite da mensagem, limitado ao tamanho maximo da string.

@author	   Cláudio Luiz da Silva
@since	   07/06/2010

@param 		cMensagem   Mensagem a ser validada
@result 		lRet 	    	.T. ou .F.
/*/
//-------------------------------------------------------------------
User Function FSVldMsg(cMensagem)

	Local 	lRet:= .T.

//String size overflow! Esta ocorrência é reproduzida quando atingimos o limite do tamanho de uma String em Advpl. 
//A Advpl suporta armazenar e operar uma string com tamanho de até 1 Mb ( 1024 Kb )
	If Len(cMensagem) > (1024*1024)
		MsgStop("A mensagem esta limitada ao tamanho maximo de 1Mb(1024Kb).",".:Atenção:.")
		lRet:= .F.
	EndIf

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} FSSTOD
Converte string (AAAAMMDD) para data.

@author	   Cláudio Luiz da Silva
@since	   16/06/2010

@param 		cData   String a ser convertida
@result 		dData	  Data convertida
/*/
//-------------------------------------------------------------------
User Function FSSTOD(cData)

	Local 	dData:= Ctod("")

	If !Empty(cData)
	//AAAAMMDD  12345678
		cDatAux:= Right(cData,2) +"/"+ SubStr(cData,5,2) +"/"+ Left(cData,4)
		dData:= Ctod(cDatAux)
	EndIf

Return(dData)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSNFEAUT
Avalia rotina se rotina de nota fiscal de entrada esta sendo executada via SIGAAUTO

@author	   Cláudio Luiz da Silva
@since	   29/06/2010

@result 		lRet	  Se rotina esta sendo executada via SIGAAUTO
/*/
//-------------------------------------------------------------------
User Function FSNFEAUT()

	Local 	lRet		:= .F.

	If IsInCallStack("MATA116") //(Upper(Alltrim(FunName())) $ "MATA116/U_FSCOME03") //Frete
		If (Type('l116Auto') <> 'U' .And. l116Auto)
			lRet	:=  .T.
		EndIf
	ElseIf IsInCallStack("MATA103") //(Upper(Alltrim(FunName())) $ "MATA103/U_FSCOME02") //Documento Entrada
		If (Type('l103Auto') <> 'U' .And. l103Auto)
			lRet	:=  .T.
		EndIf
	ElseIf IsInCallStack("MATA140") //(Upper(Alltrim(FunName())) $ "MATA140/U_FSCOME01") //Prenota Entrada
		If (Type('l140Auto') <> 'U' .And. l140Auto)
			lRet	:=  .T.
		EndIf
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSRETNOM
Retorna Nome do Cliente ou Fornecedor

@author	   Cláudio Luiz da Silva
@since	   29/12/2010

@param 		cTipPed Tipo do Pedido/Nota
@param 		cCliFor Codigo do Cliente/Fornecedor
@param 		cLoja 	Loja do Cliente/Fornecedor
@param 		cTipNot Tipo da Nota S=Saida;E=Entrada

@result 	cNome	  Nome do Cliente ou Fornecedor
/*/
//-------------------------------------------------------------------
User Function FSRETNOM(cTipPed,cCliFor,cLoja,cTipNot)

	Local   aAreas 	:= {SA1->(GetArea()),SA2->(GetArea()),GetArea()} // Coletando todas as areas num array
	Local	cNomRet	:= ""
	Local   lCondTip:= .T.
	Default cTipNot	:= "S"

	If cTipNot=="S"
		lCondTip:= Alltrim(cTipPed)$"DB"
	Else
		lCondTip:= !Alltrim(cTipPed)$"DB"
	EndIf

	cNomRet:= Iif(lCondTip,Posicione("SA2",1,xFilial("SA2")+cCliFor+cLoja,"A2_NOME"),Posicione("SA1",1,xFilial("SA1")+cCliFor+cLoja,"A1_NOME"))

	aEval(aAreas, {|x| RestArea(x) }) // restaurando todas as areas dentro do array.

Return(cNomRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMOVENT
Disponibiliza arquivo de nota fiscal de entrada na pasta de saida

@author	   Cláudio Luiz da Silva
@since	   19/04/2010
@param 	   lExclui    Identifica se a operacao e de exclusao
@param 	   lGerArq    Gera arquivo para exportacao
@obs	      
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
11/01/2011 Claudio Silva   Alterada de static function para user function
/*/
//-------------------------------------------------------------------
User Function FSMovEnt(lExclui,lGerArq)

	Private  cDirLay,cDirInt,cDirImp,cDirExp,cDirBkp,cDirTmp,cDirLog,cDirAMD

	Default  lGerArq:= .F.

//Cria variavel private para nao abortar a rotina caso nao seja chamado dos encapsulamentos criados para criar a variavel
	If (Type("cFSDocGer")=="U")
		Private cFSDocGer:= ""
	EndIf
//.And. !lExclui Incluido por Rodolfo. 20111027. Responsável por gerar a nota de entrada na inclusao.
	If lGerArq .And. !lExclui
	//Efetua exportacao nota fiscal de entrada
		U_FSEXPP01("I")
	EndIf


	If !Empty(cFSDocGer)
	//Define diretorios utilizados pela rotina de exportacao e importacao
		U_FSDirInt()

	//Copia arquivo para \BACKUP\SAIDA
		U_FSCopArq(cDirInt+cDirTmp+cDirExp+"\"+cFSDocGer, cDirInt+cDirBkp+cDirExp+cDirAMD+"\"+cFSDocGer)

	//O arquivo sera movido para pasta \SAIDA
		U_FSMovArq(cDirInt+cDirTmp+cDirExp+"\"+cFSDocGer, cDirInt+cDirExp+"\"+cFSDocGer)

		If !lExclui
		//Atualiza flag de arquivo gerado
			dbSelectArea("SF1")
			If Reclock("SF1",.F.)
				F1_ARQEXP:= Iif(lExclui,"",cFSDocGer)
				F1_DTEXP	:= Iif(lExclui,Ctod(""),Date())
				MsUnlock()
			EndIf
		EndIf
	
	//Limpa variavel apos mover arquivo
		cFSDocGer:= ""
	EndIf

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rodolfo 20110930                                                    ³
//³ Somar valor Base ST e imprimir no Danfe para notas de Compl. ICMSST ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function CALCICMST()

	Local aAreaOld 	:= GetArea()
	Local nRet		:= 0
	Local cChave	:= CD2->CD2_DOC+CD2->CD2_SERIE

	nRet := Posicione("SC6",4,xFilial("SC6")+cChave,"C6_BSICMCO")

	RestArea(aAreaOld)

Return ( nRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSEmpInt
Carrega array somente com as empresas, desconsiderando as filiais.

@author	   Cláudio Luiz da Silva
@since	   

@return		aRecnoSM0  		array com as empresas
/*/
//-------------------------------------------------------------------
User Function FSBusPos(cChave)

	Local aRecnoSM0	:= {}

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
   
		If Alltrim(SM0->M0_CODIGO+SM0->M0_CODFIL) == cChave
			Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO+SM0->M0_CODFIL})
		EndIf

		dbSkip()

	EndDo

Return(aRecnoSM0[1,1])
       
//-------------------------------------------------------------------
/*/{Protheus.doc} TrcChrEsp
Le arquivo texto e substitui carcteres especiais do arquivo para
evitar erro de importacao

@author	   Alex T. Souza
@since	   

@return		aRecnoSM0  		array com as empresas
/*/
//-------------------------------------------------------------------
User Function TrcChrEsp(cArq)
	Local nHand 	:= 0
	Local cConteudo	:= ""
	Local cTroca	:= ""
	Local cAux		:= ""
	Local aMatTroca := {}
	Local nXi		:= 0
	Local nPos		:= 0

	aadd(aMatTroca,{000," "})
	aadd(aMatTroca,{001," "})
	aadd(aMatTroca,{002," "})
	aadd(aMatTroca,{003," "})
	aadd(aMatTroca,{004," "})
	aadd(aMatTroca,{005," "})
	aadd(aMatTroca,{006," "})
	aadd(aMatTroca,{007," "})
	aadd(aMatTroca,{128,"C"})
	aadd(aMatTroca,{129,"u"})
	aadd(aMatTroca,{130,"e"})
	aadd(aMatTroca,{130,"e"})
	aadd(aMatTroca,{131,"a"})
	aadd(aMatTroca,{132,"a"})
	aadd(aMatTroca,{133,"a"})
	aadd(aMatTroca,{134,"e"})
	aadd(aMatTroca,{135,"c"})
	    
	nTamArq		:= 0
	nHandle 	:= 0
	nHandle 	:= FOPEN(cArq,2+64)
	
	If nHandle <> -1
		nTamArq 	:= FSEEK(nHandle,0,2)
		cConteudo	:= Space(nTamArq)
		cTroca		:= ""
		
		FSEEK(nHandle,0,0)
		FREAD(nHandle,@cConteudo,nTamArq)
		FCLOSE(nHandle)
		
		While nXi <= nTamArq
			cAux := Substr(cConteudo,nXi,1)
			If (nPos := ascan(aMatTroca,{|x| x[1] == asc(cAux) })) > 0
				cAux := aMatTroca[nPos,2]
			Endif
			cTroca += cAux
			nXi++
		EndDo
		
		MemoWrite(cArq,cTroca)
	Endif
				
Return 