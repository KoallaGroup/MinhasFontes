#Include "TOTVS.ch"
#Include "PROTHEUS.CH"
#include "rwmake.ch"

//----------------------------------------------------------//
 
/*/{Protheus.doc} ContSZD
(Função para gerar código automatico para O Código da Caracteristicas)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User Function ContSZD()
	Local SZDCod := 0
	Local cQuery :=""
	Local FCod := M->ZD_CODF
	
	cQuery := "SELECT MAX(ZD_COD) ZDCOD "
	cQuery += "FROM"
	cQuery += RetSqlName("SZD") + " SZD "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND ZD_CODF = '" + FCod + "'"
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYEXP") > 0
		QRYEXP->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYEXP", .F.,.F.)
	dbSelectArea("QRYEXP")
	dbGoTop()
	SZDCod := QRYEXP->ZDCOD
	If SZDCod == NIL
		SZDCod := '001'
	Else
		SZDCod := Soma1(SZDCod)
	EndIF
	
Return SZDCod

//----------------------------------------------------------//

/*/{Protheus.doc} ContSZE
(Função para gerar código automatico para O Código da Opção)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User Function ContSZE()
	Local SZECod := 0
	Local cQuery :=""
		
	cQuery := "SELECT MAX(ZE_COD) ZECOD "
	cQuery += "FROM"
	cQuery += RetSqlName("SZE") + " SZE "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
		
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYEXP") > 0
		QRYEXP->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYEXP", .F.,.F.)
	dbSelectArea("QRYEXP")
	dbGoTop()
	SZECod := QRYEXP->ZECOD
	If SZECod == NIL
		SZECod := '01'
	Else
		SZECod := Soma1(SZECod)
	EndIF

Return SZECod

//----------------------------------------------------------//

/*/{Protheus.doc} ContSZC
(Função para gerar código automatico para O Código da Familia)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User Function ContSZC()
	Local SZCCod := 0
	Local cQuery :=""
	Local FCod := M->ZC_CGROPO
	
	cQuery := "SELECT MAX(ZC_COD) ZCCOD "
	cQuery += "FROM"
	cQuery += RetSqlName("SZC") + " SZC "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND ZC_CGROPO = '" + FCod + "'"
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYEXP") > 0
		QRYEXP->(dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYEXP", .F.,.F.)
	dbSelectArea("QRYEXP")
	dbGoTop()
	SZCCod := QRYEXP->ZCCOD
	If SZCCod == NIL
		SZCCod := '001'
	Else
		SZCCod := Soma1(SZCCod)
	EndIF
	
Return SZCCod


//----------------------------------------------------------//

/*/{Protheus.doc} Replica
(Função para gerar código automatico para O Código da Familia)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}
/*/

User Function Replica

	Local aArea := GetArea()
	Local cFil	 := "02"
	Local nX 	 := 0
	Local nFil	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o conteudo no cadastramento original na Memoria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Grava na base de dados da outra filial o conteúdo ³
//³ que estava na Memoria                             ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	dbSelectArea("SB1")

	If Inclui
		For nFil := 1 To 3
			RecLock("SB1",.T.)
			For nX := 1 To FCount()
				FieldPut(nX, &("M->" + FieldName(nX)))
			Next nX
			SB1->B1_FILIAL := cFil
			msUnlock()
			cFil :=soma1(cfil)
		Next nFil
	Else
		For nFil := 1 To 3
			dbSetOrder(1)
			If dbSeek(PadR(cFil,6) + SB1->B1_COD)
				RecLock("SB1",.F.)
			Else
				RecLock("SB1",.T.)
			Endif
			For nX := 1 To FCount()
				FieldPut(nX, &("M->" + FieldName(nX)))
			Next nX
			SB1->B1_FILIAL := cFil
			msUnlock()
			cFil := Soma1(cFil)
		Next nFil
	
	Endif
			
	RestArea(aArea) //³Restaura ambiente³

Return  