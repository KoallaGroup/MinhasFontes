#include "protheus.ch"

//******************************************//
// Função cadastro da tabela SZC (Familia)  //
//******************************************//
/* /{Protheus.doc} AxCadSZC
(AxCadastro tabela SZC - Familias)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function AxCadSZC()

	Local cCadastro := "Cadastro de Familias"
	Local cAlias    := "SZC"
	Local cFunAlt   := "U_FunAltZc()"
	Local cFunDel   := ".F."
	
// Verifica filial logada	
	If cFilAnt != "01DA05"
		U_TrcFil() // Troca filial
	EndIF
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	
	AxCadastro(cAlias,cCadastro,cFunDel,cFunAlt) // Cadastro padrão
	
Return Nil

//************************************************//
// Função cadastro da tabela SZD (Característica) //
//************************************************//
                                                                   
/*/{Protheus.doc} AxCadSZD
(AxCadastro tabela SZD - Característica)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function AxCadSZD()
	
	Local cCadastro := "Cadastro de Característica"
	Local cAlias    := "SZD"
	Local cFunAlt   := "U_FunAltZd()"
	Local cFunDel   := ".F."

// Verifica filial logada	

	If cFilAnt != "01DA05"
		U_TrcFil()
	EndIF
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	
	AxCadastro(cAlias,cCadastro,cFunDel,cFunAlt) // Cadastro padrão
	
Return Nil

//***************************************//
// Função cadastro da tabela SZF (Tipos) //
//***************************************//
/*/{Protheus.doc} AxCadSZF
(AxCadastro tabela SZD - Tipos)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function AxCadSZF()
	
	Local cCadastro := "Cadastro de Tipos"
	Local cAlias    := "SZF"
	Local cFunAlt   := ".F."
	Local cFunDel   := ".F."
	
// Verifica filial logada
	
	If cFilAnt != "01DA05"
		U_TrcFil()
	EndIF
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	
	AxCadastro(cAlias,cCadastro,cFunDel,cFunAlt) // Cadastro padrão
	
Return Nil

//****************************************//
// Função cadastro da tabela SZG (Grupos) //
//****************************************//
/*/{Protheus.doc} AxCadSZG
(AxCadastro tabela SZG - Grupos)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function AxCadSZG()
	
	Local cCadastro := "Cadastro de Grupos"
	Local cAlias    := "SZG"
	Local cFunAlt 	:= "U_FunAltZG()"
	Local cFunDel   := ".F."
	
	
// Verifica filial logada
	
	If cFilAnt != "01DA05"
		U_TrcFil()
	EndIF
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	
	AxCadastro(cAlias,cCadastro,cFunDel,cFunAlt) // Cadastro padrão
	
Return Nil

//**********************************************//
// Função para verificar se a família já existe //
//**********************************************//
/*/{Protheus.doc} FunAltZc
(Função para verificar se a família já existe)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FunAltZc()

	Local lRet := .F.
	Local cZCArma  := AllTrim(M->ZC_CARMAM)
	Local cZCTipo  := AllTrim(M->ZC_CTIPO)
	Local cZCGropo := AllTrim(M->ZC_CGROPO)
	Local cZCDesc  := AllTrim(M->ZC_DESC)
	Local cZCCod	 := Alltrim(M->ZC_COD)
	Local cCodigo := (cZCTipo + cZCGropo + cZCCod) //Cod. Tipo + Cod. Grupo
	
	If Inclui
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SZC") 	+ " SZC "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND ZC_CARMAM = '" 	+ cZCArma + "'"
		cQuery += " AND ZC_CTIPO = '" 	+ cZCTipo + "'"
		cQuery += " AND ZC_CGROPO = '" 	+ cZCGropo + "'"
		cQuery += " AND ZC_DESC = '" 	+ cZCDesc + "'"
		
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSZC") > 0
			QRYSZC-> (dbCloseArea())
		Endif
	
		dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSZC", .F.,.F.)
		dbSelectArea("QRYSZC")
		dbGoTop()
		If QRYSZC->TOTAL > 0
			MsgInfo("Família já cadastrada")
		Else
			lRet := .T.
		EndIf
	EndIF
	
	If Altera
		lRet:= (u_ValAlt(cCodigo))
	EndIf

Return lRet
	
	
//*****************************************************//
// Função para verificar se a Característica já existe //
//*****************************************************//

/*/{Protheus.doc} FunAltZD
(Função para verificar se a Característica já existe)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FunAltZD()

	Local lRet := .F.
	Local cCarma  := AllTrim(M->ZD_CARMA)
	Local cTipo   := AllTrim(M->ZD_CTIPO)
	Local cZDGropo:= AllTrim(M->ZD_CGROPO)
	Local cZDCodf := AllTrim(M->ZD_CODF)
	Local cZDCod  := AllTrim(M->ZD_COD)
	Local cZDDesc := AllTrim(M->ZD_DESC)
	Local cCodigo  := (cTipo + cZDGropo + cZDCodf + cZDCod)
	
	If Inclui
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SZD") + " SZD "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND ZD_CARMA = '" + cCarma + "'"
		cQuery += " AND ZD_CTIPO = '" + cTipo + "'"
		cQuery += " AND ZD_CODF = '" + cZDCodf + "'"
		cQuery += " AND ZD_CGROPO = '" + cZdGropo + "'"
		cQuery += " AND ZD_DESC = '" + cZDDesc + "'"
	
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSZD") > 0
			QRYSZD->(dbCloseArea())
		Endif
	
		dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSZD", .F.,.F.)
		dbSelectArea("QRYSZD")
		dbGoTop()
		If QRYSZD->TOTAL > 0
			MsgInfo("Característica já cadastrada")
		Else
			lRet := .T.
		EndIf
	EndIF
	If Altera
		lRet := (u_ValAlt(cCodigo))
	Endif
Return lRet

//********************************************//
// Função para verificar se a grupo já existe //
//********************************************//
/*/{Protheus.doc} FunAltZG
(Função para verificar se a grupo já existe)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FunAltZG()

	Local lRet := .F.
	Local cZGArma  := Alltrim(M->ZG_CARMA)
	Local cZGTipo  := Alltrim(M->ZG_CTIPO)
	Local cZGGrupo := AllTrim(M->ZG_GRUPO)
	Local cZGDESC  := AllTrim(M->ZG_DESCGRP)
	Local cCodigo  := (cZGTipo + cZGGrupo)
	
	If Inclui
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SZG") + " SZG "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND ZG_CARMA = '" + cZGArma +"'"
		cQuery += " AND ZG_CTIPO = '" + cZGTipo +"'"
		cQuery += " AND ZG_GRUPO = '" + cZGGrupo+"'"
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSZG") > 0
			QRYSZG-> (dbCloseArea())
		Endif
	
		dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSZG", .F.,.F.)
		dbSelectArea("QRYSZG")
		dbGoTop()
		If QRYSZG->TOTAL > 0
			MsgInfo("Grupo já cadastrada")
		Else
			lRet := .T.
		EndIf

// Verifica e cria o grupo na tabela SBM

		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SBM") + " SBM "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND BM_GRUPO = '" + cZGGrupo + "'"
	
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSBM") > 0
			QRYSBM-> (dbCloseArea())
		Endif
	
		dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSBM", .F.,.F.)
		dbSelectArea("QRYSBM")
		dbGoTop()
		If QRYSBM->TOTAL < 1
			
			dbSelectArea("SBM")
			RECLOCK("SBM", .T.)
			SBM->BM_FILIAL:= xFilial("SBM")
			SBM->BM_GRUPO := cZGGrupo
			SBM->BM_DESC  := cZGDesc
			msUnlock()
		EndIf
	Endif
	
	If Altera
	
		lRet:= (u_ValAlt(cCodigo))
		
	EndIf
	
Return lRet
	
//*******************************************//
// Função para verificar se a tipo já existe //
//*******************************************//

/*/{Protheus.doc} FunAltZF
(Função para verificar se a tipo já existe)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FunAltZF()

	Local lRet 	:= .F.
	Local cZFTipo := AllTrim(M->ZF_TIPO)
	Local cZFDesc := AllTrim(M->ZF_DESCTP)
	Local cZFArm  := AllTrim(M->ZF_CARMA)
	Local cCodigo := (cZFTipo)
	
	If Inclui
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SZF") + " SZF "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND ZF_CARMA = '" + cZFArm + "'"
		cQuery += " AND ZF_TIPO = '" + cZFTipo + "'"
	
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSZF") > 0
			QRYSZF->(dbCloseArea())
		Endif
	
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSZF", .F.,.F.)
		dbSelectArea("QRYSZF")
		dbGoTop()
		If QRYSZF->TOTAL > 0
			MsgInfo("Tipo já cadastrada")
		Else
			lRet := .T.
		EndIf
		
		cQuery := "SELECT COUNT(*) TOTAL "
		cQuery += "FROM "
		cQuery += RetSqlName("SX5") + " SX5 "
		cQuery += "WHERE D_E_L_E_T_ != '*'"
		cQuery += " AND X5_TABELA = '02'"
		cQuery += " AND X5_FILIAL = '01DA05'"
		cQuery += " AND X5_CHAVE = '" + cZFTipo + "'"
			
		cQuery := ChangeQuery (cQuery)
	
		If Select ("QRYSX5") > 0
			QRYSX5->(dbCloseArea())
		Endif
	
		dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSX5", .F.,.F.)
		dbSelectArea("QRYSX5")
		dbGoTop()
		If QRYSX5->TOTAL < 1
			
			dbSelectArea("SX5")
			RECLOCK("SX5", .T.)
			SX5->X5_FILIAL := xFilial("SX5")
			SX5->X5_TABELA := "02"
			SX5->X5_CHAVE  := cZFTipo
			SX5->X5_DESCRI := cZFDesc
			SX5->X5_DESCSPA:= cZFDesc
			SX5->X5_DESCENG:= cZFDesc
			msUnlock()
		EndIf
	EndIf
	
	If Altera
		lRet:= (u_ValAlt(cCodigo))
	Endif

Return lRet


//**************************************************//
//  Verifica se o produto pode ser alterado.        //
//**************************************************//

User Function ValAlt(cCodigo)
	Local lRet := .T.
	Local nTcod := Len(cCodigo)
		
	cQuery := "SELECT COUNT(*) TOTAL "
	cQuery += "FROM "
	cQuery += RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE D_E_L_E_T_ != '*'"
	cQuery += " AND SubString(B1_COD,1," + cValToChar(nTcod) + ") = '" + cCodigo + "'"
	
	cQuery := ChangeQuery (cQuery)
	
	If Select ("QRYSB1") > 0
		QRYSB1-> (dbCloseArea())
	Endif
	
	dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), "QRYSB1", .F.,.F.)
	dbSelectArea("QRYSB1")
	dbGoTop()
	If QRYSB1->TOTAL > 0
		MsgInfo("Já existem produtos utilizando esse código. Não é possível realizar a alteração.")
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return lRet

//**************************************************//
// Função para trocar filial corrente para "01DA05" //
//**************************************************//

/*/{Protheus.doc} TrcFil
(Função para trocar filial corrente para "01DA05" )
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/


User Function TrcFil()

//Fecha todos os arquivos abertos
	dbCloseAll()

//Abre a empresa que eu desejo
	OpenFile("01")

//Informa a filial da empresa
	cFilAnt := "01DA05"

Return Nil