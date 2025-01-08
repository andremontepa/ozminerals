#INCLUDE "PROTHEUS.CH"
#Include "TopConn.Ch"
User Function 2CR01HIS()
Local lRec     := .T.
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario
Local cOrigem  := "Cadastro Orçamentario"

cQuery := "SELECT ZW1_NUM,ZW1_CCUSTO,ZW1_ITEMCO,ZW1_ANO,ZW2_CONTA, "
cQuery += "ZW2_VAL01,ZW2_VAL02, ZW2_VAL03, ZW2_VAL04, ZW2_VAL05, ZW2_VAL06, ZW2_VAL07, ZW2_VAL08, ZW2_VAL09, ZW2_VAL10, ZW2_VAL11, ZW2_VAL12 "
cQuery += "FROM ZW1010 ZW1 "
cQuery += "INNER JOIN ZW2010 ZW2 ON ZW2_NUM = ZW1_NUM AND ZW2.D_E_L_E_T_ <> '*' "
cQuery += "WHERE ZW1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY ZW1_NUM "
TCQUERY cQuery NEW ALIAS "TMP"

dbSelectArea("TMP")
TMP->(dbGoTop())

DbSelectArea("ZW3")
ZW3->(DbSetOrder(2))
While TMP->(!Eof())
	If TMP->ZW2_VAL01 > 0
		dDate := Ctod("01/01/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL01
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Janeiro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL02 > 0
		dDate := Ctod("01/02/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL02
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Fevereiro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL03 > 0
		dDate := Ctod("01/03/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL03
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Março de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL04 > 0
		dDate := Ctod("01/04/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL04
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Abril de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL05 > 0
		dDate := Ctod("01/05/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL05
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Maio de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL06 > 0
		dDate := Ctod("01/06/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL06
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Junho de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL07 > 0
		dDate := Ctod("01/07/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL07
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Julho de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL08 > 0
		dDate := Ctod("01/08/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL08
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Agosto de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL09 > 0
		dDate := Ctod("01/09/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL09
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Setembro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL10 > 0
		dDate := Ctod("01/10/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL10
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Outubro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL11 > 0
		dDate := Ctod("01/11/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL11
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Novembro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	If TMP->ZW2_VAL12 > 0
		dDate := Ctod("01/12/"+TMP->ZW1_ANO)
		RecLock("ZW3",lRec)
		ZW3->ZW3_FILIAL := XFILIAL("ZW3")
		ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
		ZW3->ZW3_TIPO   := "C"
		ZW3->ZW3_CCUSTO := TMP->ZW1_CCUSTO
		ZW3->ZW3_ITEMCO := TMP->ZW1_ITEMCO
		ZW3->ZW3_ANO    := TMP->ZW1_ANO
		ZW3->ZW3_CONTA  := TMP->ZW2_CONTA
		ZW3->ZW3_DATA   := dDate
		ZW3->ZW3_VALOR  := TMP->ZW2_VAL12
		ZW3->ZW3_ORIGEM := cOrigem
		ZW3->ZW3_USUARI := cNamUser
		ZW3->ZW3_HISTOR := "Valor do Orçmento para o mês de Dezembro de "+TMP->ZW1_ANO
		ZW3->(MsUnLock())
		ConfirmSX8()
	Endif
	TMP->(dbSkip())
EndDo

Return()
