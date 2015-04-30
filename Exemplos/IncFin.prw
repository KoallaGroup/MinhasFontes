#Include 'Protheus.ch'

User Function IncFin()
	
	Local aTitulo := {}
	
	PRIVATE lMsErroAuto := .F.
	
	//RegToMemory("SE1")
	
		
	aTitulo :={{;
	{"E1_PREFIXO"	, "1  " 		, Nil },;	//Prefixo
	{"E1_NUM"		, "251525152" , Nil },;	//Numero
	{"E1_PARCELA"	, "123" 		, Nil },;	//Parcela
	{"E1_TIPO"		, "NF "		, Nil },; 	//Tipo
	{"E1_NATUREZ"	, "10105     ", Nil },;	//Natureza
	{"E1_CLIENTE"	, "0000004"	, Nil },;	//Cliente
	{"E1_LOJA"		, "00"			, Nil },;	//Loja
	{"E1_VENCTO"	, dDataBase	, Nil },;	//Vencimento
	{"E1_VALOR"	, 100  		, Nil }}}
	//,; 	//Valor
	//{"E1_HIST"		, "TESTE RA                 "	, Nil }})	//Historico
	//{"E1_EMISSAO"	, dDataBase	, Nil },;	//Emissao
	//{CBCOAUTO		, "CX1"		, Nil },;	//Caixa
	//{CAGEAUTO 		, "00001"		, Nil },;	//Agencia
	//{CCTAAUTO	 	, "0000000001", Nil },; //Conta
	//Conta

	MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	If lMsErroAuto
		MostraErro()
	Else
		Alert("Título incluído com sucesso!")
	Endif
Return Nil

