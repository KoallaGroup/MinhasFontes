#include "rwmake.ch"
/*
+----------+----------+-------+---------------------+-----+-----------------+
|Programa  |M030INC   |Autor  |Ricardo Diniz        |Data |  06/03/06       |
+----------+----------+-------+---------------------+-----+-----------------+
|Desc.     |Ponto de Entrada na inclusão do cliente para gerar automatica-  |
|          |mente o item contabil a partir do código e loja do cliente.     |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/
/* Tratamento para não cadastrar clientes balão - 10/09/2014 -- Luiz Flávio */


User Function M030INC()
	Local cItemcont := "" /* Item Contábil */
	

	dbSelectArea("CTD")
	CTD->(dbSetOrder(01))
	
		If !CTD->(dbseek(xFilial("CTD") + "C" + SA1->A1_COD + SA1->A1_LOJA))
			
			cItemcont := "C" + SA1->A1_COD + SA1->A1_LOJA

			dbSelectArea("CTD")
			Reclock("CTD",.T.)
			CTD->CTD_FILIAL := xFilial("CTD")
			CTD->CTD_ITEM   := cItemcont
			CTD->CTD_DESC01 := SA1->A1_NOME
			CTD->CTD_CLASSE := "2"
			CTD->CTD_DTEXIS := CTOD("01/01/2000") 
			CTD->CTD_BLOQ   := '2' 
			CTD->CTD_ITLP   := SA1->A1_COD
			CTD->(MsUnlock())
	
	Endif
Return