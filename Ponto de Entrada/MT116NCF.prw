/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT116NCF  �Autor  �Luiz Fl�vio         � Data �  05/21/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para preencher n�mero do conhecimeto de    ���
���          �frete com zeros a esquerda.                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/{Protheus.doc} MT116NCF
(long_description)
@author Analista Sistema
@since 10/11/2014
@version 1.0
@return ${return}, ${return_description}/*/

User Function MT116NCF()

	Local cNCF:= PARAMIXB[1]
	Local nTamCod   := TamSX3("F1_DOC")[1]

	If Len(Trim(cNCF))>0
	
		If Len(Trim(cNCF))< nTamCod
			cNCF = StrZero(0,nTamCod-Len(Trim(cNCF)))+trim(cNCF)
		Endif
	
	Else
		cNCF = ""
	Endif

Return (cNCF)