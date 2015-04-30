#include "Totvs.ch"
#include "Fileio.ch"
#include "Topconn.ch"

// Gravar produtos na SB9 apartir de informações da SB1

User Function GRVSB9(cFil,dData,cArq)

	Local cCod		:= ""
	Local cLoc		:= '01'
	Local cQuery  := ""
	Local cQuery1 := ""
	Local nInc		:= 0
	Local nAlt		:= 0
	Local nTotal	:= 0
	Local nReg		:= 0
	Local cDiv := SubStr(cFil,3,2)

	cQuery1 := "SELECT COUNT(*) as Total  "
	cQuery1 += "FROM  "
	cQuery1 += RetSqlName("SB1") + " SB1 "
	cQuery1 += "WHERE D_E_L_E_T_ != '*'"
	cQuery1 += "AND SubString(B1_COD,1,2) = '" + cDiv + "'"

	cQuery1 := ChangeQuery (cQuery1)

	If Select ("QRYSB2") > 0
		QRYSB2->(dbCloseArea())
	Endif

	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery1), "QRYSB2", .F.,.F.)
	dbSelectArea("QRYSB2")
	nReg := QRYSB2->TOTAL
	QRYSB2->(dbCloseArea())

	cQuery := "SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO  "
	cQuery += "FROM  "
	cQuery += RetSqlName("SB1")	+ " SB1 "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += "AND SubString(B1_COD,1,2) = '" + cDiv + "'"

	cQuery := ChangeQuery (cQuery)

	If Select ("QRYSB1") > 0
		QRYSB1->(dbCloseArea())
	Endif

	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSB1", .F.,.F.)
	dbSelectArea("QRYSB1")
	QRYSB1->(dbGoTop())
	ProcRegua(nReg)
	While QRYSB1->(!EOF())
		If SubStr(QRYSB1->CODIGO,1,2) == cDiv
			cCod :=  QRYSB1->CODIGO
			dbSelectArea("SB9")
			SB9->(dbSetOrder(1))
			SB9->(dbGoTop())
			If SB9->(!dbSeek(cFil + cCod + cLoc + dTos(cTod(dData)))) //Produto/Local/Data
				Reclock ("SB9", .T.)
				SB9->B9_FILIAL  := cFil
				SB9->B9_COD 	  := cCod
				SB9->B9_LOCAL   := '01'
				SB9->B9_QINI    := 0
				SB9->B9_QISEGUM := 0
				SB9->B9_VINI1   := 0
				SB9->B9_VINI2   := 0
				SB9->B9_DATA    := cTod(dData)
				SB9->B9_CM1     := 0
				SB9->B9_CM2     := 0
				SB9->(MsUnlock())
				nInc++
			Else
				Reclock ("SB9", .F.)
				SB9->B9_FILIAL  := cFil
				SB9->B9_COD 	  := cCod
				SB9->B9_LOCAL   := '01'
				SB9->B9_QINI    := 0
				SB9->B9_QISEGUM := 0
				SB9->B9_VINI1   := 0
				SB9->B9_VINI2   := 0
				SB9->B9_DATA    := cTod(dData)
				SB9->B9_CM1     := 0
				SB9->B9_CM2     := 0
				SB9->(MsUnlock())
				nAlt++
			EndIf
		EndIf
		IncProc()
		nTotal++
		QRYSB1->(dbSkip())
		Conout ("Registro: " +"| " + AllTrim(Str(nTotal))+ " -- " + Alltrim(cCod) + " |")
	Enddo
		
	If MsgYESNO("Confirma o acerto do estoque ? ",".:Confirma:.")
		Processa({|| u_lertxt(cFil,dData,cArq) }, "Aguarde...", "Atualizando saldos iniciais...",.F.)
		MSGINFO( "Estoque Atualizado")
	Else
		MSGINFO( "Operação cancelada!!!")
	EndIf

Return Nil