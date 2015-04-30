//PROGRAMA PARA CRIACAO DO ITEM CONTABIL 

#include "rwmake.ch"
#include "topconn.ch"

User Function CRIAITEM()


cCabecalho := OemToAnsi("Atualização do Item Contabil - Fornecedores")
cMsgRegua  := "Processando..."

Processa( {|| PrcCtb01()} ,cCabecalho,cMsgRegua )

cCabecalho := OemToAnsi("Atualização do Item Contabil - Contratos Clientes")
cMsgRegua  := "Processando..."

Processa( {|| PrcCtb02()} ,cCabecalho,cMsgRegua )


Return



Static Function PrcCtb01()
//*****************************************************************************************************
//*Criacao do Item Contabil para Contratos - Fornecedores
//*
//****

Local cItemCont := ""

dbSelectArea("SA2")
dbGoTop()

While !Eof()
	
	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial("CTD")+"F"+AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA))
	
	If Eof()
		cItemCont := "F"+AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA)
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") 	, ;
		CTD_ITEM   With cItemcont      			, ;
		CTD_DESC01 With SA2->A2_NOME   			, ;
		CTD_CLASSE With "2"            			, ;
		CTD_DTEXIS With CTOD("01/01/2000") 		, ;
		CTD_BLOQ   With '2'						, ;
       CTD_ITLP   With AllTrim(SA2->A2_COD)  
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA2")
	dbSkip()
End

Return


Static Function PrcCtb02()
//*****************************************************************************************************
//* Criacao do Item Contabil para Contratos - Clientes
//*
//****

Local cItemCont := ""
Local nN := 0

dbSelectArea("SA1")
dbGoTop()

While !Eof()
	
	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial("CTD")+"C"+AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA))
	
		If Eof()
			
				cItemCont := "C"+AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
				RecLock("CTD",.T.)
				Replace CTD_FILIAL With xFilial("CTD") , ;
				CTD_ITEM   With cItemcont      , ;
				CTD_DESC01 With SA1->A1_NOME   , ;
				CTD_CLASSE With "2"            , ;
				CTD_DTEXIS With CTOD("01/01/2000") , ;
				CTD_BLOQ   With '2', ;
			    CTD_ITLP   With AllTrim(SA1->A1_COD)  
				MsUnlock("CTD")
					
		EndIf
		
	dbSelectArea("SA1")
	dbSkip()
	
End

Return