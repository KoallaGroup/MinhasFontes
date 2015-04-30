#Include 'Protheus.ch'


User Function My103()

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local nY     := 0
	Local cDoc   := ""
	Local lOk    := .T.
	PRIVATE lMsErroAuto := .F.
	
	aCabec := {}
	aItens := {}

		
	aadd(aCabec,{"F1_FILIAL"   ,"01FE02"})
	aadd(aCabec,{"F1_DOC"   ,"000406176"})
	aadd(aCabec,{"F1_SERIE"   ,"1  "})
	aadd(aCabec,{"F1_FORNECE","0036907"})
	aadd(aCabec,{"F1_LOJA"   ,"00"})
	aadd(aCabec,{"F1_COND","001"})
	aadd(aCabec,{"F1_EMISSAO",STOD("20150121")})
	aadd(aCabec,{"F1_FRETE",0})
	aadd(aCabec,{"F1_DESPESA",0})
	aadd(aCabec,{"F1_TIPO"   ,"D"})
	aadd(aCabec,{"F1_DESCONT",0})
	aadd(aCabec,{"F1_FORMUL" ,"S"})
	aadd(aCabec,{"F1_ESPECIE","SPED "})
	aadd(aCabec,{"F1_SEGURO",0})
	aadd(aCabec,{"F1_ZMENNOT","Nosso Pedido:   9536812 "})
	aadd(aCabec,{"F1_FILLEG","02"})
	aadd(aCabec,{"F1_TIPLEG" ,"03"})
	aadd(aCabec,{"F1_PEDLEG" ,"09536812"})

	
		

	aLinha := {}
	aadd(aLinha,{"D1_ITEM"  	,"0001",Nil})
	aadd(aLinha,{"D1_COD"  	,"FE050380       ",Nil})
	aadd(aLinha,{"D1_QUANT"	,330,Nil})
	aadd(aLinha,{"D1_VUNIT"	,1.08,Nil})
	aadd(aLinha,{"D1_TOTAL"	,356.40,Nil})
	aadd(aLinha,{"D1_TES"	,"211",Nil})
	aadd(aLinha,{"D1_ZCFOENT","2202",Nil})
	aadd(aLinha,{"D1_ZSEQENT","0001",Nil})
	aadd(aLinha,{"D1_ZPARENT","DS10",Nil})
	aadd(aLinha,{"D1_NFORI"	,"000363568",Nil})
	aadd(aLinha,{"D1_LOCAL"	,"01",Nil})
	aadd(aLinha,{"D1_SERIORI","1  ",Nil})
	aadd(aLinha,{"D1_FILORIG","01FE02",Nil})
	aadd(aLinha,{"D1_ITEMORI","01  ",Nil})
	aadd(aItens,aLinha)
	MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)

	If lMsErroAuto
		mostraerro()
	Endif
		
Return




