#include "protheus.ch" 

/*
//-------------------------------------------------------------------------------
{Protheus.doc} F580LBA
Ponto de Entrada - Bloqueio de liberação automatica
Cofermeta 
@author Luiz Flávio
@since 27/08/2013
@version P11 

//------------------------------------------------------------------------------- 
*/

User Function F580LBA()

	Local uRet := .F.
	
		dbSelectArea("SZ8")
		dbGoTop()
		SZ8->(dbSetOrder(01))
		If SZ8->(dbSeek(cUserName))
			uRet := .T.
		Else
			MsgAlert("Usuário " + cUserName + " sem permissão")
		Endif
		SZ8->(dbCloseArea())

Return  uRet                          
