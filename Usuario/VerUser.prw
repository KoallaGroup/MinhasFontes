#Include "TOTVS.ch"
#Include "PROTHEUS.CH"
#include "rwmake.ch"

/*/{Protheus.doc} ${function_method_class_name}
(Função para exibir usuário de inclusão/alteração)
@author luiz
@since 07/03/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function ViewUser()

	Local lCheck := .T.
	Local nRadio := 1
	Local aItens := {'Contas a Receber','Contas a Pagar'}
	
	Private aRotina := {}
	Private cCadastro := "Visualiza o criador do titulos"
	Private cAlias := ""
	
	DEFINE MSDIALOG oDlg TITLE "Consulta no . . ." FROM 000,000 TO 100,250 PIXEL

	DEFINE SBUTTON FROM 035, 040 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		
	oRadio := TRadMenu():Create (oDlg,,010,010,aItens,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
	
	ACTIVATE DIALOG oDlg CENTERED
	
	Do Case
	Case nRadio == 1
		cAlias := "SE1"
	Case nRadio == 2
		cAlias := "SE2"
	End Case
		
	AADD(aRotina,{"Visualizar"	,"U_VerUser(cAlias)" ,0,2})
	                         
	dbSelectArea(cAlias)
	dbGoTop()

	mBrowse(6,1,22,75,cAlias)
	
Return Nil


User Function VerUser(cAlias)
	
	Local cIncUser := ''
	Local cAltUser := ''
	Local dIncUser := ''
	Local dAltUser := ''
	Local cNum := &(cAlias + "->" + SubStr(cAlias,2,3)+ "_NUM" )
	Local cFil := &(cAlias + "->" + SubStr(cAlias,2,3)+ "_FILIAL")

	cIncUser:= FWLeUserlg("E1_USERLGI")	// Nome do usuário de inclusão
	dIncUser:= FWLeUserlg("E1_USERLGI", 2) // Data da inclusão
	cAltUser:= FWLeUserlg("E1_USERLGA")	// Nome do usuário de alteração
	dAltUser:= FWLeUserlg("E1_USERLGA", 2)//Data de alteração
    
	DEFINE MSDIALOG oDlg TITLE "Usuário de inclusão/alteração" FROM 000,000 TO 260,250 PIXEL

	@ 012,010 SAY "Filial . . . . . . . . . . . . :" SIZE 055, 010 OF oDlg PIXEL
	@ 032,010 SAY "Número Titulo . . . .  :" 			SIZE 055, 010 OF oDlg PIXEL
	@ 052,010 SAY "Usuário Inclusão . . :" 			SIZE 055, 010 OF oDlg PIXEL
	@ 072,010 SAY "Data Inclusão . . . .  :	" 		SIZE 055, 010 OF oDlg PIXEL
	@ 092,010 SAY "Usuário Alteraçao . :" 				SIZE 055, 010 OF oDlg PIXEL
	@ 112,010 SAY "Data Alteração . . .  :"	 		SIZE 055, 010 OF oDlg PIXEL
	
	@ 010,062 MSGET cFil  		SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 030,062 MSGET cNum  		SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 050,062 MSGET cIncUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 070,062 MSGET dIncUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 090,062 MSGET cAltUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
	@ 110,062 MSGET dAltUser  	SIZE 050, 010 OF oDlg  READONLY PIXEL PICTURE "@!"
		
	ACTIVATE DIALOG oDlg CENTERED

 Return Nil        