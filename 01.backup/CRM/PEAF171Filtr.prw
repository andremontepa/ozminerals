#Include "Totvs.ch"
  
/*/{Protheus.doc} User Function OZR0101
Produtos
@author André Mendes -CRM
@since 14/11/2023
@version 1.0
@type function

@Obs: Relatorio depreciação acelarada

/*/
  
User Function AF171FILTR()

Local cTipoDep := '07'

cFiltro := 'N3_FILIAL == "' + xFilial("SN3")
	cFiltro += '" .AND. N3_CBASE   >= "' + mv_par01 
	cFiltro += '" .AND. N3_CBASE   <= "' + mv_par02
	cFiltro += '" .AND. N3_ITEM    >= "' + mv_par03
	cFiltro += '" .AND. N3_ITEM    <= "' + mv_par04    
    cFiltro += '" .AND. N3_TIPO    == "' + cTipoDep 
	cFiltro += '" .AND. N3_CCONTAB >= "' + mv_par08
	cFiltro += '" .AND. N3_CCONTAB <= "' + mv_par09
	cFiltro += '" .AND. N3_CUSTBEM >= "' + mv_par10
	cFiltro += '" .AND. N3_CUSTBEM <= "' + mv_par11
	cFiltro += '" .AND. N3_SUBCCON >= "' + mv_par12
	cFiltro += '" .AND. N3_SUBCCON <= "' + mv_par13
	cFiltro += '" .AND. N3_CLVLCON >= "' + mv_par14
	cFiltro += '" .AND. N3_CLVLCON <= "' + mv_par15
	cFiltro += '" .AND. Val(N3_BAIXA) == 0 '
	cFiltro += ' .AND.  N3_CCONTAB <> " " .And. N3_CCDEPR <> " " .And. N3_CDEPREC <> " "' 

   // cFiltro := 'N3_TIPO == "07" '


Return(cFiltro)
