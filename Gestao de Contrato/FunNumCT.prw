#Include 'Totvs.ch'
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FunNumCT  �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Numera��o Contratos                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User function funNumCT

	lSoma1 := .T.
	cSeqCli := zUltNum('CN9', 'CN9_NUMERO', lSoma1)

return cSeqCli


/*/{Protheus.doc} zUltNum
Fun��o que retorna o ultimo campo c�digo
@type function
@author Stephen Noel - Equil�brio Tecnologia 
@since 11/08/2022
@version 1.0
    @param cTab, Caracter, Tabela que ser� consultada
    @param cCampo, Caracter, Campo utilizado de c�digo
    @param [lSoma1], L�gico, Define se al�m de trazer o �ltimo, j� ir� somar 1 no valor
    @example
    u_zUltNum("SC5", "C5_X_CAMPO", .T.)
/*/

Static Function zUltNum(cTab, cCampo, lSoma1)
	Local aArea       := GetArea()
	Local cCodFull    := ""
	Local cCodAux     := ""
	Local cQuery      := ""
	Local nTamCampo   := 0
	Local cGrupo      := " "
	Local cCodEmp     := FWCodEmp()
	Default lSoma1    := .T.

	//Definindo o c�digo atual
	nTamCampo := TamSX3(cCampo)[01]
	cCodAux   := StrTran(cCodAux, ' ', '0')

	If cCodEmp == '01'
		cGrupo:='AVB'
	ElseIf cCodEmp == '02'
		cGrupo:='VDM'
	ElseIf cCodEmp == '03'
		cGrupo:='SLM'
	ElseIf cCodEmp == '04'
		cGrupo:='ARM'
	ElseIf cCodEmp == '05'
		cGrupo:='ACG'
	ElseIf cCodEmp == '06'
		cGrupo:='MCT'
	ElseIf cCodEmp == '07'
		cGrupo:='MAB'
	EndIf

	//Fa�o a consulta para pegar as informa��es
	cQuery := " SELECT "
	cQuery += "   ISNULL(MAX("+cCampo+"), '"+cCodAux+"') AS MAXIMO "
	cQuery += " FROM "
	cQuery += "   "+RetSQLName(cTab)+" TAB "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND SUBSTRING(CN9_NUMERO,1,3)= '"+cGrupo+"'"
	cQuery += " AND CN9_FILIAL = '"+cFilAnt+"' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery New Alias "QRY_TAB"

	//Se n�o tiver em branco
	If !Empty(QRY_TAB->MAXIMO)
		cCodAux := QRY_TAB->MAXIMO
	EndIf

	//Se for para atualizar, soma 1 na vari�vel
	If lSoma1
		cCodAux := padl(cvaltochar(val(substr(cCodAux,4,6))+1),6,"0")
	EndIf

	//Definindo o c�digo de retorno
	cCodFull := cCodAux

	QRY_TAB->(DbCloseArea())
	RestArea(aArea)

Return cCodFull
