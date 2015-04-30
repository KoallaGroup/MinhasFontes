
//-------------------------------------------------------------------------------
/* 
{Protheus.doc} F580LIB
Ponto de Entrada - Bloqueio de liberação manual
Cofermeta 
@author Luiz Flávio
@since 27/08/2013
@version P11 
*/
//-------------------------------------------------------------------------------

User Function FA580LIB()
	
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

