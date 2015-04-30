
#include "PROTHEUS.CH"

User Function UFINA460()

	Local cNum:='123456789'
	Local nZ:=0
	Local aCab:={}
	Local cFiltro:={}
	Local aItens:={}
	Local nOpc:=3//3-Liquidação,4-Reliquidacao,5-Cancelamento da liquidação
	Local aParcelas:={}
	Local nValor := 1000 //Valor a liquidar
	Local cCond := '001' //Condicao de pagamento 4x
	Local cLiqCan := ''


	cFiltro := "E1_FILIAL  = '01FE02' .And. "
	cFiltro += "E1_CLIENTE = '0000134' .And. "
	cFiltro += "E1_LOJA = '00' .AND. "
	cFiltro += "E1_NUM = '123456789' "
	

 //Tela utilizada apenas para exemplo
	
//Array do processo automatico (aAutoCab)
	aCab:={;
	{"cCondicao"	,cCond}	,;
		{"cNatureza" 	,"10105"}	,;
		{"cCLIENTE"  	,'005'}	,;
		{"nMoeda" 	  	,1}			,;
		{"cLOJA" 		,"01" }}

	aParcelas:=Condicao(nValor,cCond,,dDataBase)
	Aadd(aItens,{;
	{"E1_PREFIXO"	,"1 " },;//Prefixo
	{"E1_TIPO"		, "CC"},;
	{"E1_PARCELA"	, "001"},;
	{"E1_BCOCHQ" 	,"XXX" },;//Banco
	{"E1_NUMCART" ,"XXX" },;//Banco
	{"E1_AGECHQ" 	,"XXXX" },;//Agencia
	{"E1_CTACHQ" 	,"XXXXXXXXX" },;//Conta
	{"E1_NUM" 		,cNum },;//Nro. cheque (dará origem ao numero do titulo)
	{"E1_EMITCHQ" ,"LIQ TESTE" },;//Emitente do cheque
	{"E1_VENCTO" 	,ddatabase},;//Data boa
	{"E1_VLCRUZ" 	,1000},;//Valor do cheque/titulo
	{"E1_ACRESC" 	,0 },;//Acrescimo
	{"E1_DECRESC" ,0 }})//Decrescimo


	dbSelectArea("SE1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek('01FE02' + '1  ' + cNum + '001' + 'NF ') .and. SE1->E1_SALDO != 0
		nOpc := 3
		FINA460(,aCab,aItens,nOpc,cFiltro)//Inclusao
		Alert ('liquidado')
	ElSE	
	
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbGoTop()	
		
		cLiqCan := 0 
		nOpc := 5
		FINA460(,,,nOpc,,cLiqCan)//Cancelamento
		
		Alert ('canelado')
	EndIf

Return Nil

