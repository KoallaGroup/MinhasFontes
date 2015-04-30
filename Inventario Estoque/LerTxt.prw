#include "Protheus.ch"
#include "Fileio.ch"
#include "Topconn.ch"

User Function LerTxt(cFil, dData,cArq)

	Local cCod 	  := ''
	Local cLoc      := '01'
	Local nQnt 	  := 0
	Local nB1Conv   := 0
	Local nTamLinha := 0
	Local nLinhas   := 0
	Local nNaoGra   := 0
	Local Ngrav  	  := 0

// Ajustes
	Local cDiv := SubStr(cFil,3,2)

// Abre o arquivo de Origem
	FT_FUSE(cArq)
	FT_FGOTOP() //vai para o topo
	nLinhas   := FT_FLastRec()
	nTamLinha := Len(FT_FREADLN())
	ProcRegua(nLinhas)
	
	While !FT_FEOF()
		cBuffer := FT_FREADLN() //lendo a linha
		cCod 	 :=(AllTrim(cDiv + Substr(cBuffer,1,6)))
		nQnt 	 :=(Val(Substr(cBuffer,44,11))/100)
		nValUni :=(Val(Substr(cBuffer,55,11))/100)
		nValTot :=(Val(Substr(cBuffer,66,11))/100)
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB1") + PadR(cCod,15))
			nB1Conv := SB1->B1_CONV
		EndIf
	
		dbSelectArea("SB9")
		dbSetOrder(1)
		dbGoTop()
	
		If dbSeek(cFil + PadR(cCod,15) + cLoc + dTos(cTod(dData))) //Produto/Local/Data
			Reclock ("SB9", .F.)
			SB9->B9_FILIAL  := cFil
			SB9->B9_COD 	  := cCod
			SB9->B9_LOCAL   := cLoc
			SB9->B9_QINI 	  := nQnt
			SB9->B9_QISEGUM := (nQnt / nB1Conv)
			SB9->B9_VINI1   := nValTot
			SB9->B9_VINI2   := (nValTot / nB1Conv)
			SB9->B9_DATA    := cTod(dData)
			SB9->B9_CM1     := nValUni
			SB9->B9_CM2     := (nValUni / nB1Conv)
			SB9->(MsUnlock())
			nGrav ++
		EndIf
		FT_FSKIP()
		CONOUT (cCod)
		IncProc()
	Enddo
	FT_Fuse()
Return Nil