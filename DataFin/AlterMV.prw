#Include 'Protheus.ch'

/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@author luiz
@since 04/03/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function AlterMV()

	Local lChkMod 	:= .T.
	Local lChkEmp 	:= .T.
	Local nRadMod 	:= 1
	Local nRadEmp 	:= 1
				
	Local aItenMod := {'FINANCEIRO','FISCAL'}
	Local aItenEmp := {'01 - COFERMETA','02 - ALOC','03 - SORET', '04 - ADMIB'}
	
	Private aRotina := {}
	Private nOpca   := 0
	
	DEFINE MSDIALOG oDlg TITLE "Bloqueio de movimentações" FROM 000,000 TO 220,160 PIXEL Style 128
	
	@ 005,010 SAY "Parâmetro:"	SIZE 055, 020 OF oDlg PIXEL
	@ 040,010 SAY "Empresa:"		SIZE 055, 020 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 095,010 TYPE 15 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 095,045 TYPE 02 ACTION (oDlg:End()) ENABLE OF oDlg
	
	oRadPar := TRadMenu():Create (oDlg,,015,015,aItenMod,,,,,,,,60,12,,,,.T.)
	oRadEmp := TRadMenu():Create (oDlg,,050,015,aItenEmp,,,,,,,,60,12,,,,.T.)
	
	oRadPar:bSetGet := {|u|Iif (PCount()==0,nRadMod,nRadMod:=u)}
	oRadEmp:bSetGet := {|u|Iif (PCount()==0,nRadEmp,nRadEmp:=u)}

	ACTIVATE DIALOG oDlg CENTERED
		
	If nOpca == 1
		// Chama função
		U_AlterPar(nRadMod,nRadEmp)
	EndIf
				
Return Nil

User Function AlterPar(nRadMod,nRadEmp)

	Local dParam 		:= ''
	Local cParam 		:= ""
	Local cEmpresa	:= ""
		
	Do Case
	Case nRadMod == 1
		cParam = 'MV_DATAFIN'
		oRadEmp := 1
	Case nRadMod == 2
		cParam = 'MV_DATAFIS'
		oRadEmp := 1
	End Case
	
	Do Case
	Case nRadEmp == 1
		cEmpresa := '01'
	Case nRadEmp == 2
		cEmpresa := '02'
	Case nRadEmp == 3
		cEmpresa := '03'
	Case nRadEmp == 4
		cEmpresa := '04'
	End Case
	
	// Troca empresa logada
	If cEmpAnt != cEmpresa
		cEmpAnt := cEmpresa
		dbSelectArea("SM0")
		dbSeek("01" + cEmpresa)
		cFilAnt := AllTrim(SM0->M0_CODFIL)
	EndIf
		
	dParam := GetMv(cParam)
		
	DEFINE MSDIALOG oDlg TITLE cParam FROM 000,000 TO 120,170 PIXEL Style 128
		
	@ 010,020 SAY "Data de Bloqueio:"	SIZE 055, 020 OF oDlg PIXEL
	@ 020,015 MSGET dParam SIZE 055, 010 OF oDlg  PIXEL PICTURE "@9"
		
	DEFINE SBUTTON FROM 040, 015 TYPE 01 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 040 ,045 TYPE 02 ACTION (oDlg:End()) ENABLE OF oDlg
	ACTIVATE DIALOG oDlg CENTERED
	
	If nOpca = 2
		If MsgYESNO("Confirma a alteração do " + cParam + " com a data " +   cvaltochar(dparam) + "?",".:Confirma:.")
			PutMv(cParam,DTOS(dParam))
			MSGINFO( "Alteração realizada com sucesso", cParam )
		Else
			MSGINFO( "Operação cancelada!!!", cParam )
		EndIf
	Endif

Return Nil