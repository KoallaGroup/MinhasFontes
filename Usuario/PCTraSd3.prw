#Include 'Protheus.ch'
User Function PCTraSd3()
 
	Local aCab1 := {}
	Local aItem := {}
	Local aTotitem:={}
	Local cCodigoTM:="504"
	
	Private lMsHelpAuto := .T. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .F. //necessario a criacao

	Private acod:={"1","MP1"}
	
	For nX := 1 to Len(aCols)
	
		aCab1 := { {"D3_TM" ,cCodigoTM , NIL},;
			{"D3_EMISSAO" ,ddatabase, NIL}}
		aItem:={ {"D3_COD" ,aCols[nX][2] ,NIL},;
			{"D3_UM" ,aCols[nX][5] ,NIL},;
			{"D3_QUANT" ,aCols[nX][6] ,NIL},;
			{"D3_LOCAL" ,aCols[nX][32] ,NIL}}

		aadd(atotitem,aitem)
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab1,atotitem,3)

		If lMsErroAuto
			Mostraerro()
			DisarmTransaction()
			break

		EndIf
	Next

Return Nil 

