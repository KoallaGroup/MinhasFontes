#Include "TOTVS.ch"
#Include "PROTHEUS.CH"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRIMEIRATELAºAutor  ³Luiz Flávio         º Data ³  24/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} Tela
(Função cria tela para montagem do codigo e descrição de acordo com pre-cadastro)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User Function Tela()

	Private cZTipo 	:= Space(2)
	Private cZGrupo	:= Space(4)
	Private cFamilia	:= Space(3)
	Private cCaract 	:= Space(3)
	Private cOpcao  	:= Space(2)
	Private cOrigem 	:= Space(1)
	Private cArma   	:= Space(2)

	Private cZTipoD 	:= Space(15)
	Private cZGrupoD	:= Space(15)
	Private cFamiD	:= Space(16)
	Private cCaractD	:= Space(10)
	Private cOpcaoD 	:= Space(14)
	Private cOrigemD	:= Space(25)
	Private cArmaD  	:= Space(20)
	
	Private lGrvSZE	:= .F.
	Private lRetTela 	:= .F.
	Private cCodigo 	:= ''
	Private cDesc 	:= ''
    	
	Private oBrowse
	Private aBrowse 	:= {}

	aAdd(aBrowse,{"",""})
	
	DEFINE MSDIALOG oDlg TITLE "Gerar Codigo" FROM 000,000 TO 550,450 PIXEL Style 128

	@ 010,010 SAY "Selecione o Armazem.:" SIZE 055, 010 OF oDlg PIXEL
	@ 030,010 SAY "Selecione o Tipo....:" SIZE 055, 010 OF oDlg PIXEL
	@ 050,010 SAY "Selecione o Grupo...:" SIZE 055, 010 OF oDlg PIXEL
	@ 070,010 SAY "Selecione a Familia.:" SIZE 055, 010 OF oDlg PIXEL
	@ 090,010 SAY "Selecione a Caract..:" SIZE 055, 010 OF oDlg PIXEL
	@ 110,010 SAY "Digite a Opcao......:" SIZE 055, 010 OF oDlg PIXEL
	@ 130,010 SAY "Codigo Completo.....:" SIZE 055, 010 OF oDlg PIXEL
	@ 150,010 SAY "Descrição Completa..:" SIZE 055, 010 OF oDlg PIXEL
				
	@ 006,065 MSGET cArma		SIZE 035, 010 OF oDlg Valid GERCOD(6)	PIXEL PICTURE "@!" F3 "NNRZ"
	@ 026,065 MSGET cZTipo	 	SIZE 035, 010 OF oDlg Valid GERCOD(1)	PIXEL PICTURE "@!" F3 "SZF3"
	@ 046,065 MSGET cZGrupo 		SIZE 035, 010 OF oDlg Valid GERCOD(2)	PIXEL PICTURE "@!" F3 "SZG2"
	@ 066,065 MSGET cFamilia		SIZE 035, 010 OF oDlg Valid GERCOD(3)	PIXEL PICTURE "@!" F3 "SZC1"
	@ 086,065 MSGET cCaract 		SIZE 035, 010 OF oDlg Valid GERCOD(4)	PIXEL PICTURE "@!" F3 "SZD1"
	@ 106,065 MSGET cOpcaoD 		SIZE 100, 010 OF oDlg Valid GERCOD(5) PIXEL PICTURE "@!"
	
	DEFINE SBUTTON FROM 165, 010 TYPE 1 ACTION (nOpca := 1,fOKBTO()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 165, 040 TYPE 2 ACTION (nOpca := 2,oDlg:End(),lRetTela:= .T.) ENABLE OF oDlg
	
	@ 006,115 MSGET cArmaD		SIZE 100, 010 OF oDlg  READONLY 		PIXEL PICTURE "@!"
	@ 026,115 MSGET cZTipoD		SIZE 100, 010 OF oDlg  READONLY 		PIXEL PICTURE "@!"
	@ 046,115 MSGET cZGrupoD 	SIZE 100, 010 OF oDlg  READONLY 		PIXEL PICTURE "@!"
	@ 066,115 MSGET cFamiD 		SIZE 100, 010 OF oDlg  READONLY 		PIXEL PICTURE "@!"
	@ 086,115 MSGET cCaractD 	SIZE 100, 010 OF oDlg  READONLY 		PIXEL PICTURE "@!"
	@ 106,170 MSGET cOpcao 		SIZE 035, 010 OF oDlg  READONLY  		PIXEL PICTURE "@!"
	
	@ 126,065 MSGET cCodigo 		SIZE 055, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 146,065 MSGET cDesc		SIZE 150, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	
	fWBrowSB1()
 
	ACTIVATE DIALOG oDlg CENTERED
	
Return lRetTela

//###########################################
//# Função do botao OK                      #
//###########################################
/* /{Protheus.doc} fOKBTO
(Função do botão OK)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function fOkBto()

	Local aCposBlq :={"B1_COD","B1_DESC","B1_MSBLQL","B1_TIPO","B1_GRUPO","B1_LOCPAD"} // Campos bloqueados na tela de cadastro
	Local lInclui := .T.
	Local nCntFor := 0
	Local cFil 	:= "02"

	aCpos := U_fCposBlq(aCposBlq)//# Chama Função Libera campos para inclusao.
	
	If AllTrim(cArma) != "" .And.	AllTrim(cZTipo) != "" .And.  AllTrim(cZGrupo) != "" .And. AllTrim(cFamilia) != "" .And. AllTrim(cCaract) != "" .And. AllTrim(cOpcao) != ""
		 
		If Len(aBrowse) == 1 .AND. aBrowse[1][1] == ""
			dBSelectArea("SB1")
			AxInclui("SB1",0,3,,"U_fPasVar",aCpos,,,"U_Replica()")
			
			If lGrvSZE
				dBSelectArea("SZE")
				RECLOCK("SZE", .T.)
				SZE->ZE_FILIAL:= xFILIAL("SZE")
				SZE->ZE_COD 	:= U_ContSZE()
				SZE->ZE_DESC 	:= cOpcaoD
				MSUNLOCK()
			Endif
			oDlg:End()
		Else
			MsgInfo("Produto já cadastrado!!!")
		Endif
	EndIf
	
Return

// Funçao passa variaveis da tela para o AxInclui

/*/{Protheus.doc} fPasVar
(Função para passar dados para o cadastro padrão.)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User Function fPasVar()

	M->B1_COD 		:= cCodigo
	M->B1_DESC 	:= cDesc
	M->B1_MSBLQL	:= '2'
	M->B1_TIPO  	:= cZTipo
	M->B1_GRUPO	:= cZGrupo
	M->B1_LOCPAD	:= cArma
	M->B1_UM		:= "UN"
	M->B1_SEGUM	:= "UN"
	M->B1_CONV		:= 1
	
Return Nil

// Função para preencher os MSGET da tela 
/*/{Protheus.doc} GERCOD
(Função que gera o codigo de acordo com o pre-cadastro)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GERCOD(nOpc)
	
	Local lRet := .T.
   
	If nOpc == 1
		lRet:= Empty(cZTipo) .or. ExistCpo ("SZF",cArma + cZtipo)
		If lRet
			If cZTipo != ''
				cZTipoD:= Posicione("SZF",1,xFilial("SZF")+ cArma + cZTipo,"ZF_DESCTP")
			Else
				ClearVar(1)
			EndIf
			fRetSB1()
		Endif
	
	Elseif nOpc == 2
		lRet:= Empty(cZGrupo) .or. ExistCpo("SZG", cArma+ cZTipo + cZGrupo)
		If lRet
			If cZGrupo != ''
				cZGrupoD:= Posicione("SZG",1,xFilial("SZG")+ cArma + cZTipo + cZGrupo,"ZG_DESCGRP")
			Else
				ClearVar(2)
			EndIf
			fRetSB1()
		EndIF
	
	Elseif nOpc == 3
		lRet:= Empty(cFamilia) .or. ExistCpo("SZC", cArma + cZTipo + cZGrupo + cFamilia)
		If lRet
			If cFamilia != ''
				cFamiD:= Posicione("SZC",1,xFilial("SZC") + cArma + cZTipo + cZGrupo + cFamilia,"ZC_DESC")
			Else
				ClearVar(3)
			EndIF
			fRetSB1()
		EndIf
	
	Elseif nOpc == 4
		lRet:= Empty(cCaract) .or. ExistCpo("SZD",cArma + cZTipo + cZGrupo + cFamilia + cCaract)
		If lRet
			If cCaract != ''
				cCaractD := Posicione("SZD",1,xFilial("SZD") + cArma + cZTipo + cZGrupo + cFamilia + cCaract,"ZD_DESC")
			Else
				ClearVar(4)
			EndIF
			fRetSB1()
		EndIF
	
	Elseif nOpc == 5
		If Empty(AllTrim(cOpcaoD))
			cOpcao := "00"
			fRetSB1()
		Else
			dbSelectArea("SZE")
			SZE->(dBSetOrder(2))
			SZE->(dBGoTop())
			If SZE->(DbSeek (Padr(AllTrim(cOpcaoD),14))) //Descrição
				cOpcao := SZE->ZE_COD
				lGrvSZE:= .F.
			Else
				cOpcao := U_ContSZE()
				lGrvSZE:= .T.
			EndIf
			fRetSB1()
		Endif
							
	Elseif nOpc == 6
		lRet:=   Empty(cArma) .OR. ExistCpo("NNR",cArma)
		If lRet
			cArmaD  := Posicione("NNR",1,xFilial("NNR") + cArma,"NNR_DESCRI")
			fRetSB1()
		Endif
	Endif

Return lRet

/*/{Protheus.doc} fwBrowSB1
(Função para montar o LISTBOX para mostrar produtos cadastrados)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

Static Function fwBrowSB1()

// Insert items here
	@ 180, 010 LISTBOX oBrowse Fields HEADER "Codigo","Descrição" SIZE 210,090 OF oDlg PIXEL ColSizes 60,90

// carrega o array do oBrowse
	fSetArray()

Return Nil
                                    
/*/{Protheus.doc} fSetArray
(Função para preencher o LISTBOX)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

Static Function fSetArray()

	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {|| {;
		aBrowse[oBrowse:nAt,1],;
		aBrowse[oBrowse:nAt,2]}}
			
Return Nil

/*/{Protheus.doc} fRetSB1
(Função para retornar as informações para preencher o LISTBOX)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

Static Function fRetSB1()

	Local cQuery	:= ""
	Local cReturn	:= ""
	
	cCodigo := Alltrim(cZTipo)
	cCodigo += Alltrim(cZGrupo)
	cCodigo += Alltrim(cFamilia)
	cCodigo += Alltrim(cCaract)
	cCodigo += Alltrim(cOpcao)
         
	cDesc := Alltrim(cFamiD)+ Space(1)
	cDesc += Alltrim(cCaractD)+ Space(1)
	cDesc += Alltrim(cOpcaoD)
	 
	aBrowse := {}
	
	cQuery := "SELECT B1_COD, B1_DESC , B1_ORIGEM "
	cQuery += " FROM "
	cQuery += RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE B1_FILIAL = '01'"
	cQuery += " AND B1_LOCPAD != '01' "
	cQuery += " AND B1_COD LIKE '"+ cCodigo +"%' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY R_E_C_N_O_ "
	
	cQuery := ChangeQuery( cQuery )
	
//Garante que a area QRYEXP nao esta em uso
	If Select( "QRYEXP" ) > 0
		QRYEXP->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "QRYEXP", .F., .F. )
	dbSelectArea("QRYEXP")
	dbGoTop()
	
	While !Eof()
		aAdd(aBrowse,{QRYEXP->B1_COD, QRYEXP->B1_DESC})
		dbSelectArea("QRYEXP")
		dBskip()
	EndDo
	
	If Len(aBrowse) == 0
		aAdd(aBrowse,{"",""})
	EndIf

	QRYEXP->(dbCloseArea())
	fSetArray()
	oBrowse:Refresh()

Return Nil

/*/{Protheus.doc} ClearVar
(Função para limpar as informações dos campos quando e realizado alteração dos pre-cadastros)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@param nNivel, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}/*/

Static Function ClearVar(nNivel)
	
	If nNivel <= 1
	
		cZTipo 	:= ''
		cZTipoD	:= ''

	EndIf

	If nNivel <= 2
	
		cZGrupo 	:= ''
		cZGrupoD 	:= ''
	
	EndIf

	If nNivel <= 3

		cFamilia	:= ''
		cFamiD 	:= ''

	EndIf
	If nNivel <= 4
	
		cCaract 	:= ''
		cCaractD 	:= ''
		cCodigo 	:= ''
		cDesc		:= ''

	EndIf

	If nNivel <= 5

		cOpcao 	:= ''
		cOpcaoD 	:= ''
		cCodigo 	:= cFamilia
		cDesc		:= cFamiD

	EndIf

Return Nil