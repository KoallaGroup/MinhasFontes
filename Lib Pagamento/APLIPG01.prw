#include "protheus.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} APLIPG01

Cadastro aprovadores lib. pagamento
@author  ###
@since	  27/08/2013
@version ###
@obs	      

Data       Programador     Motivo
27/08/13	Luiz Flávio
/*/
//-------------------------------------------------------------------

User Function APLIPG01()

	Local  cCadastro:= "Cadastro aprovadores lib. pagamento"
	Local  cVldAlt 	:= ".T." // Validacao para permitir a alteracao/inclusao. Pode-se utilizar ExecBlock.
	Local  cVldExc 	:= ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Local  cAlias 	:= "SZ8" // Nome da tabela.

//Abrir Area Arquivo Trabalho 
		DbSelectArea(cAlias) //Visualizar Registros Ordenados
		DbSetOrder(1)        //Filial+Tipo de Documento Baan     

//Funcao AxCadastro ...
		AxCadastro(cAlias, cCadastro, cVldExc, cVldAlt)

Return Nil 