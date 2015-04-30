#include "protheus.ch"

/*/{Protheus.doc} MBrwSB1
(Monta tela do MBroser padrão com as funções de *Incluir *Alterar *Excluir)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function MBrwSB1()

	Local cAlias := "SB1"
	Local cFiltra := ""
	Local cRecno := 0
	
// Verifica filial logada 

	If cFilAnt != "01DA05"
		U_TrcFil() // Troca filial atual para '01DA05'
	EndIF
	
// Filtro do MBrowse

	cRecno := U_RetRecn() // Retorna o Recno do primeiro produto de uso consumo.
	
	cFiltra := SB1->("@R_E_C_N_O_ > " + cRecno + " AND B1_FILIAL = '01' AND  B1_LOCPAD != '01'")
	
	Private cCadastro := "Cadastro de Produtos de Consumo"
	Private aRotina := {}
	
//+-----------------------------------------
//	opções de filtro utilizando aFilBrowse
//+-----------------------------------------
	Private aIndexSB1 := {}
	Private bFiltraBrw:= { ||FilBrowse(cAlias,@aIndexSB1,@cFiltra)}

	AADD(aRotina,{"Pesquisar" 	,"PesqBrw"		,0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual"	,0,2})
	AADD(aRotina,{"Incluir"		,"U_Inclui"	,0,3})
	AADD(aRotina,{"Alterar"		,"U_Altera"	,0,4})
	AADD(aRotina,{"Excluir"		,"U_Exclui"	,0,5})
	AADD(aRotina,{"Cadastrador"	,"U_VUser"		,0,6})
	AADD(aRotina,{"Saldo"		,"U_Saldo"		,0,7})
 
	Eval(bFiltraBrw)
	                         
	dbSelectArea(cAlias)
	dbGoTop()

	mBrowse(6,1,22,75,cAlias)

EndFilBrw(cAlias,aIndexSB1)

Return Nil

// Função Incluir

/*/{Protheus.doc} Inclui
(Função inclui)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function Inclui()

	U_TELA() //Chama Função Tela

Return Nil

// Função Altera

/*/{Protheus.doc} Altera
(Função altera)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function Altera()

	Local aCposBlq :={"B1_COD","B1_DESC","B1_TIPO","B1_GRUPO","B1_LOCPAD"} // Campos bloqueados na tela de alteração
	Local aCpos := {}
	
	aCpos := U_fCposBlq(aCposBlq) // Array com os campos que pode ser editados.

	AxAltera("SB1",,4,,aCpos,,,"U_fTok()","U_Replica()")
	
Return Nil


/*/{Protheus.doc} Botao OK
(Função botão OK)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function fTok()

	Local aCposSB1:= {}
	Local cCodigo := PadR(Substr(M->B1_COD,1,14),15)
	Local nPosCod := 0
	Local nPosLoc := 0
	Local cArm := AllTrim(M->B1_ARQIMP)

	If M->B1_MSBLQL == '2'

		dBSelectArea("SB1")
		SB1->(dBSetOrder(1))
		SB1->(dBGoTop())
		If !SB1->(DbSeek(xFilial("SB1") + cCodigo))//Filial + Codigo

			aCposSB1:= SB1->(dBStruct())

			For nCont := 1 To Len(aCposSB1)
				aAdd(aAuto,{&('"' + aCposSB1[nCont][1] + '"'), &("M->" + aCposSB1[nCont][1]),NIL})
			Next
		
			bSeek := {|x| Alltrim(x[1]) == "B1_COD" }
			nPosCod:= aScan (aAuto,bSeek)
			bSeek := {|x| Alltrim(x[1]) == "B1_LOCPAD"}
			nPosLoc:= aScan(aAuto,bSeek)
		
			aAuto[nPosCod][2]:= cCodigo
			aAuto[nPosLoc][2]:= cArm
			
		EndIf

	Endif

Return .T.

// Função de exclusão

/*/{Protheus.doc} Exclui
(Funçao para validar a exclusão do produto.)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function Exclui()

	MsgInfo("Exclusão não permitida!!!")

Return Nil

// Função para passar campos liberados para edição

/*/{Protheus.doc} fCposBlq
(Função para informar quais os campos estaram bloqueados na tela do cadastro do produto.)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@param aCposBlq, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function fCposBlq(aCposBlq)

	Local aCpos	:={} // Array com os campos liberados para edição.
	Local aCposSB1 := {}
	Local nPos 	:= 0

// Cria array com os campos da SB1	
	dBSelectArea("SB1")
	aCposSB1:= SB1->(DBSTRUCT())
	
	For nCont:= 1 to Len(aCposSB1)
		bSeek := {|x| Alltrim(x) == AllTrim(aCposSB1[nCont][1])}
		nPos:= aScan (aCposBlq ,bSeek)
		If nPos = 0
			aAdd(aCpos,aCposSB1[nCont][1])
		Endif
		nPos := 0
	Next

Return (aCpos)


	
/*/{Protheus.doc} VUser
(Função do botao "Cadastrador" que exibe o nome do funcionario que realizou o cadastro.)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function VUser()
	
	Local cIncUser := ''
	Local dIncUser := ''
	Local cCod := SB1->B1_COD
	Local cFil := SB1->B1_FILIAL

	cIncUser:= FWLeUserlg("B1_USERLGI") 	// Nome do usuario de inclusão
	dIncUser:= FWLeUserlg("B1_USERLGI", 2) // Data da inclusão
	  
	DEFINE MSDIALOG oDlg TITLE "Usuário de inclusão" FROM 000,000 TO 200,250 PIXEL

	@ 012,010 SAY "Filial . . . . . . . . . . . . :"	SIZE 060, 010 OF oDlg PIXEL
	@ 032,010 SAY "Codigo Produto . . . .  :" 		SIZE 060, 010 OF oDlg PIXEL
	@ 052,010 SAY "Usuário Inclusão . . :" 			SIZE 060, 010 OF oDlg PIXEL
	@ 072,010 SAY "Data Inclusão . . . .  :"			SIZE 060, 010 OF oDlg PIXEL
		
	@ 010,062 MSGET cFil  		SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 030,062 MSGET cCod  		SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 050,062 MSGET cIncUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 070,062 MSGET dIncUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
		
	ACTIVATE DIALOG oDlg CENTERED

Return Nil

User Function Saldo()
	
//	Esta função calcula o saldo atual do produto (do Arquivo SB2), descontando os valores empenhados, reservados, etc. É necessário que o Arquivo SB2 esteja posicionado no produto desejado.
	Local cSld 	:= ""
	Local cProd 	:= SB1->B1_COD
	Local cLocpad := SB1->B1_LOCPAD
	Local aArea 	:= GetArea()
	Local cFl		:= "01HI04"
	
	dbSelectArea("SB2")
	dbGotop()
//	dbSeek(xFilial("SB2") + cProd + cLocPad)
	dbSeek(cFl + cProd + cLocPad)
	cSld := Transform(SaldoSb2(),"@E 9,999,999.99")
 
	
	DEFINE MSDIALOG oDlg TITLE "Saldo em estoque" FROM 000,000 TO 160,250 PIXEL

	@ 012,010 SAY "Codigo Produto . :"	SIZE 050, 010 OF oDlg PIXEL
	@ 032,010 SAY "Armazem . . . . .:"	SIZE 050, 010 OF oDlg PIXEL
	@ 052,010 SAY "Saldo . . . . . .:" SIZE 050, 010 OF oDlg PIXEL

		
	@ 010,062 MSGET cProd  			SIZE 060, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 030,062 MSGET cLocpad  		SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 050,062 MSGET AllTrim(cSld)  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
		
	ACTIVATE DIALOG oDlg CENTERED
	
	RestArea(aArea) //³Restaura ambiente³
	
Return Nil