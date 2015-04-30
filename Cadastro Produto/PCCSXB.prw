#Include 'Protheus.ch'

//----------------------------------------------------------//

/*/{Protheus.doc} FilTpGrp
( Filtro Tipo dentro Cadastro Grupo)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilTpGrp()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZG_CARMA
			
	cZFFilter += "@#"
	cZFFilter += "ZF_FILIAL == '"+ xFilial ("SZF") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZF_CARMA == '" + cArma + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilTpFam
(Filtro Tipo dentro Cadastro Familia)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilTpFam()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZC_CARMAM
	
	cZFFilter += "@#"
	cZFFilter += "ZF_FILIAL == '"+ xFilial ("SZF") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZF_CARMA == '" + cArma + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilTpCar
(Filtro Tipo dentro Cadastro Caracteristica)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilTpCar()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZD_CARMA
	
	cZFFilter += "@#"
	cZFFilter += "ZF_FILIAL == '"+ xFilial ("SZF") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZF_CARMA == '" + cArma + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilGrpFa
(Filtro Grupo dentro Cadastro Familia)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilGrpFa()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZC_CARMAM
	cTipo := M->ZC_CTIPO
	
	cZFFilter += "@#"
	cZFFilter += "ZG_FILIAL == '"+ xFilial ("SZG") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CARMA == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CTIPO == '" + cTipo + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilGrpCa
(long_description)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilGrpCa()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZD_CARMA
	cTipo := M->ZD_CTIPO
	
	cZFFilter += "@#"
	cZFFilter += "ZG_FILIAL == '"+ xFilial ("SZG") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CARMA == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CTIPO == '" + cTipo + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilFamCa
(Filtro Familia dentro Cadastro Caracteristica)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilFamCa()
	
	Local cArma := ""
	Local cZFFilter := ""
	
	cArma := M->ZD_CARMA
	cTipo := M->ZD_CTIPO
	cGrupo:= M->ZD_CGROPO
	
	cZFFilter += "@#"
	cZFFilter += "ZC_FILIAL == '"+ xFilial ("SZC") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CARMAM == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CTIPO == '" + cTipo + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CGROPO == '" + cGrupo + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilTpPrd
(Filtro Tipo dentro Cadastro Produto)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilTpPrd()
	
	Local cZFFilter := ""
	
	cZFFilter += "@#"
	cZFFilter += "ZF_FILIAL == '"+ xFilial ("SZF") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZF_CARMA == '" + cArma + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilGpPro
(Filtro Grupo dentro Cadastro Produto)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilGpPro()
	
	Local cZFFilter := ""
	
	cZFFilter += "@#"
	cZFFilter += "ZG_FILIAL == '"+ xFilial ("SZG") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CARMA == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZG_CTIPO == '" + cZTipo + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilFaPro
(Filtro Familia dentro Cadastro Produto)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilFaPro()
	
	Local cZFFilter := ""
	
	cZFFilter += "@#"
	cZFFilter += "ZC_FILIAL == '"+ xFilial ("SZC") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CARMAM == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CTIPO == '" + cZTipo + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZC_CGROPO == '" + cZGrupo + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilCaPro
(Filtro Caracteristica dentro Cadastro Produto)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilCaPro()
	
	Local cZFFilter := ""
	
	cZFFilter += "@#"
	cZFFilter += "ZD_FILIAL == '"+ xFilial ("SZC") + "'"
	cZFFilter += " .AND. "
	cZFFilter += "ZD_CARMA == '" + cArma + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZD_CTIPO == '" + cZTipo + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZD_CGROPO == '"+ cZGrupo + "' "
	cZFFilter += " .AND. "
	cZFFilter += "ZD_CODF == '" + cFamilia + "' "
	cZFFilter += "@#"

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} FilSB1
(Filtro Tipo dentro Cadastro Produto)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function FilSB1()
	
	Local cZFFilter := ""
	Local cModulos := GetMv("MV_FILSB1") // Recebe nome das rotinas para aplicar filtro
	Local cUsrLPd2 := GetMv("MV_USRAR02") // Recebe nome usuários para aplicar filtros para armazem 02
	Local cUsrLpd3 := GetMv("MV_USRAR03") // Recebe nome usuários para aplicar filtros para armazem 03

	
	If FUNNAME() $cModulos
	
		cZFFilter += "@#"
		cZFFilter += "B1_FILIAL == '"+ xFilial("SB1") + "'"
		cZFFilter += " .AND. "
		cZFFilter += "B1_MSBLQL == '2'"
		If ( (cUserName $cUsrLPd2) .And. (FUNNAME() == "MATA241") .And. (!Empty(cUsrLpd2)) )
			cZFFilter += " .AND. "
			cZFFilter += "B1_LOCPAD == '02'"
		ElseIf ( (cUserName $cUsrLPd3) .And. (FUNNAME() == "MATA241") .And. (!Empty(cUsrLpd3)) )
			cZFFilter += " .AND. "
			cZFFilter += "B1_LOCPAD == '03'"
		EndIF
		cZFFilter += " .AND. "
		cZFFilter += "B1_LOCPAD != '01'"
		cZFFilter += "@#"
	Else
		cZFFilter += "@#"
		cZFFilter += "B1_FILIAL == '"+ xFilial ("SB1") + "'"
		cZFFilter += " .AND. "
		cZFFilter += "B1_MSBLQL == '2'"
		cZFFilter += "@#"
	EndIf

Return (cZFFilter)

//----------------------------------------------------------//

/*/{Protheus.doc} SoliCC
(Retorna o CC de acorndo com o cadastro do usuário)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function SoliCC()

	Local cCC := ""
	Local cUsua := PadL(SubStr(AllTrim(USRRETNAME(__CUSERID)),2,5),6,"0")
	Local cCCRed := ''
	
	If FUNNAME() = "MATA105"

		dbSelectArea("SA3")
		dbSetOrder(1)
		dbGoTop()
		
		If dbSeek(SA3->A3_FILIAL + cUsua)
			cCCRed := AllTrim(SA3->A3_CCUSTO)
			dbSelectArea("CTT")
			dbSetOrder(3)
			dbGoTop()
		
			If dbSeek(CTT->CTT_FILIAL + cCCRed)
				cCC :=Alltrim(CTT->CTT_CUSTO)
			EndIf
		EndIf
	Else
		cCC := ""
	
	EndIf

Return (cCC)

//----------------------------------------------------------//

/*/{Protheus.doc} RetRecn
(Retorna o Recno do primeiro produto de uso/consumo da tabela SB1)
@author Luiz Flávio
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function RetRecn()

	Local cRecno := ""
	
	cQuery := "SELECT TOP 1 R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE B1_FILIAL = '01'"
	cQuery += " AND B1_LOCPAD != '01' "
	cQuery += " AND LEN(B1_COD) = 14 "
	cQuery += " AND D_E_L_E_T_ != '*' "
	cQuery += " ORDER BY R_E_C_N_O_ "
	
	cQuery := ChangeQuery( cQuery )
	
//Garante que a area QRYEXP nao esta em uso
	If Select( "QRYREC" ) > 0
		QRYREC->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "QRYREC", .F., .F. )
	dbSelectArea("QRYREC")
	dbGoTop()
	
	cRecno  := cValtoChar(QRYREC->RECNO)

Return (cRecno)