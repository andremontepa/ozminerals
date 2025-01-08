#include 'protheus.ch'
/*
    Desenvolvedor: Felipe Andrews
    Ponto de Entrada: Botao adicional para Apuracao CTA
    Data: 31/01/2022
    Release: 12.1.25
*/
User Function CT102BTO()
    Local aRetBtn := {}

If INCLUI                  // Somente aparece o botão caso seja a opção de 'Incluir Lançamento' e o Lote informado seja o 'APUCTA' 
    If cLote == "APUCTA"
        Aadd( aRetBtn, {"NEXT",{ || U_IACTBP01() },"Apuração CTA","Apuração CTA"})
    Endif
Endif

Return(aRetBtn)
