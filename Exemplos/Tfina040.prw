#Include 'Protheus.ch'

User Function TFina040()

Local aVetor := {}

RegToMemory("SE1",.T.,.F.)

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.  

Private CBCOAUTO    := "CX1"
Private CAGEAUTO    := "00001"   
Private CCTAAUTO    := "0000000001"

aVetor :=	{{ "E1_PREFIXO"		, "001"			, Nil},;
			{  "E1_NUM"			, "888888789"		, Nil},;
			{  "E1_PARCELA"		, "001"			, Nil},;
			{  "E1_TIPO"			, "RA "			, Nil},;   
			{  "E1_NATUREZ"		, "10105     "	, Nil},;
			{  "E1_CLIENTE"		, "0000004"		, Nil},;
			{  "E1_LOJA"			, "00"				, Nil},;
			{  "E1_EMISSAO"		, dDataBase		, Nil},;
			{  "E1_VENCTO"		, dDataBase+30	, Nil},;
			{  "E1_VENCREA"		, dDataBase+30	, Nil},;
			{  "E1_VALOR"			, 1000 			, Nil}}

MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao

If lMsErroAuto
	Alert("Erro")   
	MostraErro()
Else
	Alert("Ok")  
Endif

Return


