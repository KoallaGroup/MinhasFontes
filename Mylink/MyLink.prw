#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@author luiz
@since 29/04/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MyLink()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M020ALT  �Autor  � Microsiga          � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �  PONTO DE ENTRADA APOS ALTERACAO DO FORNECEDOR.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ALTERA o Fornecedor na base Gerencial.                     ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


	Local cDBSQL := "MSSQL/TESTEFIS"
	Local cSrvSQL := "192.168.1.18"
	Local nHndSQL
	
	nHndSQL := TcLink(cDBSQL,cSrvSQL,7890)
	
	If nHndSQL < 0
		UserException("Erro ("+srt(nHndSQL,4)+") ao conectar com "+cDbSQL+" em "+cSrvSQL)
	Endif
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	If dbSeek(xFilial("SA1") +  "0000004" + "00" )
		
		Alert(SA1->A1_NOME)
		
	EndIf
			
	TcUnlink(nHndSQL)
	
	Alert("MSSQL desconectado.")
	
Return Nil
