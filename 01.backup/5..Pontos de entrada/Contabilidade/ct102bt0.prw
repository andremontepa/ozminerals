#include 'protheus.ch'
/*
    Desenvolvedor: Felipe Andrews
    Ponto de Entrada: Botao adicional para Apuracao CTA
    Data: 31/01/2022
    Release: 12.1.25
*/
User Function CT102BTO()
    Local aRetBtn := {}

If INCLUI                  // Somente aparece o bot�o caso seja a op��o de 'Incluir Lan�amento' e o Lote informado seja o 'APUCTA' 
    If cLote == "APUCTA"
        Aadd( aRetBtn, {"NEXT",{ || U_IACTBP01() },"Apura��o CTA","Apura��o CTA"})
    Endif
Endif

Return(aRetBtn)
