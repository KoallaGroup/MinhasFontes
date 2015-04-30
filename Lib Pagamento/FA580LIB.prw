
//-------------------------------------------------------------------------------
/* 
{Protheus.doc} F580LIB
Ponto de Entrada - Bloqueio de libera��o manual
Cofermeta 
@author Luiz Fl�vio
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
			MsgAlert("Usu�rio " + cUserName + " sem permiss�o")
		Endif
		SZ8->(dbCloseArea()) 
        
Return  uRet                          

