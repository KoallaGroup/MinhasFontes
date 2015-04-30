#Include 'Protheus.ch'

User Function AjusEst()

	Local cFil := SPACE(6)
	Local dData:= "31/12/2014"
	
	Private nX := 150
	Private nY := 430
	
	Private cArq := ''
	
	DEFINE MSDIALOG oDlg TITLE "Gerar SB9" FROM 000,000 TO nX,nY PIXEL Style 128
	
	@ 002,055 SAY " Abrir arquivo: " SIZE 055, 010 OF oDlg PIXEL
	@ 024,055 SAY "Digite a filial:" SIZE 055, 010 OF oDlg PIXEL
	@ 024,125 SAY " Digite a Data :" SIZE 055, 010 OF oDlg PIXEL
	@ 046,090 SAY "  Processar!!!  " SIZE 055, 010 OF oDlg PIXEL
	@ 035,055 MSGET cFil	SIZE 035, 005 OF  oDlg	PIXEL PICTURE "@!"
	@ 035,125 MSGET dData SIZE 035, 005 OF  oDlg	PIXEL PICTURE "@!"
	
	DEFINE SBUTTON FROM 056,095 TYPE 1 ACTION  Processa({|| U_GRVSB9(cFil,dData,cArq) }, "Aguarde...", "Atualizando produtos...",.F.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 010,060 TYPE 14 ACTION U_BusArq()  ENABLE OF oDlg
		 
	@ 010,110 SAY " == " + cArq + " . " SIZE 155, 050 OF oDlg PIXEL
	
	ACTIVATE DIALOG oDlg CENTERED

Return

User Function BusArq()

	cArq := cGetFile( "Arquivo Estoque (*.txt) | *.txt", "Selecione o Arquivo do inventario de estoque",,'C:\ESTOQUE',.F.,)
	cArq := UPPER(cArq)
	oDlg:Refresh()
Return cArq

