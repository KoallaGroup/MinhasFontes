#Include "protheus.ch"

User Function M460SOLI()
	//TESTE
	Local _nItem 	:= ParamIxb[1]	//Item do aCols
	Local aSolid:={}
	Local cAlicInterna	:= GetMV("MV_ICMPAD")	// Busca Aliquota Interna do estado
	Local _nTotIpi		:= MaFisRet(_nItem,"IT_VALIPI")
	Local _nTot	   		:= MaFisRet(_nItem,"IT_BASEICM")
	Local _ValIcms		:= MaFisRet(_nItem,"IT_VALICM")
	Local nAlicIntEst		:= MaFisRet(_nItem,"IT_ALIQICM")
	Local _FRETE 			:= MaFisRet(_nItem,"IT_FRETE")
	Local nMVAProd		:= MARGEMLUCR
	Local lTemSt			:= .F.
	Local lAchOri			:= .F.
	Local nVrReduc		:= 0
	Local nICMSRet 		:= 0
	Local nBaseCalc 		:= 0

// Se produto importado
	If SB1->B1_ORIGEM $ '1|2|3|8' // IMPORTADO

	// Se tipo do pedido igual a normal, Cliente de fora do estado e contribuinte
		If SC5->C5_TIPO == "N" .AND. SA1->A1_EST <> 'MG' .AND. SA1->A1_TIPO == 'S'
		
		// Produto base de calculo reduzida
			If SC6->C6_OPCST == "2" // USO E CONSUMO - DIFERENCIAL DE ALIQUOTA
		/*	
			If RIGHT(SF4->F4_SITTRIB,2) == '70' // IMPORTADO COM BASE DE CALCULO REDUZIDA
				nBaseCalc := _nTot * SF4->F4_BSICMST * 0.01
				nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
				nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
				aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
			Else
				nBaseCalc := ROUND(_nTot,2)
				nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
				nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
				aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014	
			EndIf
		*/
			ElseIf SC6->C6_OPCST == "3" // COMERCIALIZAÇÃO - APLICA O MVA AJUSTADO
			
				If RIGHT(SF4->F4_SITTRIB,2) == '70' // IMPORTADO COM BASE DE CALCULO REDUZIDA
					nBaseCalc := ROUND(_nTot * SF4->F4_BSICMST * 0.01,2)
					nVrReduc  := ROUND(((nBaseCalc * SC6->C6_MVALEG)/100),2)
					nBaseCalc := nBaseCalc + nVrReduc
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
				Else
					nBaseCalc := ROUND(_nTot,2)
					nVrReduc  := ROUND(((nBaseCalc * SC6->C6_MVALEG)/100),2)
					nBaseCalc := nBaseCalc + nVrReduc
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
				EndIf
			EndIf
		
		EndIf

	ElseIf SB1->B1_ORIGEM $ '0|4|5|6|7' // NACIONAL

	// Se tipo do pedido igual a normal, Cliente de fora do estado e contribuinte
		If SC5->C5_TIPO == "N" .AND. SA1->A1_EST <> 'MG' .AND. SA1->A1_TIPO == 'S'
		
			If SC6->C6_OPCST == "2" // USO E CONSUMO - DIFERENCIAL DE ALIQUOTA
			
				If RIGHT(SF4->F4_SITTRIB,2) == '70' // IMPORTADO COM BASE DE CALCULO REDUZIDA
					nBaseCalc := ROUND(_nTot * SF4->F4_BSICMST * 0.01,2)
					nVrReduc  := ROUND(((nBaseCalc * SC6->C6_MVALEG)/100),2)
					nBaseCalc := nBaseCalc + nVrReduc
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet}
				Else
					nBaseCalc := ROUND(_nTot,2)
					nVrReduc  := ROUND(((nBaseCalc * SC6->C6_MVALEG)/100),2)
					nBaseCalc := nBaseCalc + nVrReduc
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
				EndIf
			
			ElseIf SC6->C6_OPCST == "3" // COMERCIALIZAÇÃO - APLICA O MVA AJUSTADO
				If RIGHT(SF4->F4_SITTRIB,2) == '70' // IMPORTADO COM BASE DE CALCULO REDUZIDA
					nBaseCalc := ROUND(SC6->C6_VALOR+_FRETE,2)
					nVrReduc  := ROUND(((nBaseCalc * SF4->F4_BSICMST)/100),2)
					nBaseCalc  := nVrReduc + ( ROUND(((nVrReduc * SC6->C6_MVALEG)/100),2))
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
				Else
					nBaseCalc := ROUND(_nTot,2)
					nVrReduc  := ROUND(((nBaseCalc * SC6->C6_MVALEG)/100),2)
					nBaseCalc := nBaseCalc + nVrReduc
					nICMSRet  := Round((nBaseCalc * nMVAProd * 0.01),2) - _ValIcms
					nICMSRet := IIf(nICMSRet<0,0,nICMSRet)
					aSolid := { nBaseCalc, nICMSRet} // VALIDADO POR MARCIO FELIPE - 27/05/2014
				EndIf
			EndIf
		
		EndIf
		
	EndIf

Return aSolid
