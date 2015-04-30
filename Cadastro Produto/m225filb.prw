#Include 'Protheus.ch'

/*User Function M225FILB()

	Local cRet := ""// validações do usuário
	Local cModulos := GetMv("MV_FILSB1") // Recebe nome das rotinas para aplicar filtro
	Local cUsrLPd2 := GetMv("MV_USRAR02") // Recebe nome usuários para aplicar filtros para armazem 02
	Local cUsrLpd3 := GetMv("MV_USRAR03") // Recebe nome usuários para aplicar filtros para armazem 03

	
	If FUNNAME() $cModulos
	
		cRet := ""
		
		If ( (cUserName $cUsrLPd2) .And. (FUNNAME() == "MATA225") .And. (!Empty(cUsrLpd2)) )
			
			cRet += " B2_FILIAL == '01HI04' "
			cRet += " .AND. "
			cRet += " B2_LOCAL == '02' "

		ElseIf ( (cUserName $cUsrLPd3) .And. (FUNNAME() == "MATA225") .And. (!Empty(cUsrLpd3)) )
			cRet += " B2_FILIAL == '01HI04' "
			cRet += " .AND. "
			cRet += " B2_LOCAL == '03' "
		Else
			cRet += " B2_LOCAL != '01' "
		EndIf
	EndIf
	
Return cRet*/