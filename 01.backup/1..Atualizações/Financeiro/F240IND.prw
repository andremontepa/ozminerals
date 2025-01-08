//#Include "TOTVS.CH"

/*/{Protheus.doc} F240IND
Ponto de entrada para manipulação de índice da tela de borderô (FINA240).

@version    P12
@since      10/09/2021
@return     numeric, índice a ser posicionado
@obs        Função utilizada nas rotinas FINA240
/*/
User Function F240IND() As Numeric

    Local aIndices  As Array
    Local lRefresh  As Logical
    Local nIndex    As Numeric

    nIndex      := 1
    lRefresh    := paramIXB[1]
    aIndices    := paramIXB[2] //somente é carregado na execução via botão Atualizar (quando lRefresh está como verdadeiro)

    //Escolha do indice inicial da tabela
    If !lRefresh
        If MsgYesNo("Desejar ordenar por Nome do Fornecedor?", "F240IND - Alterar o Indice")
            nIndex := 18
        EndIf
    Else
        //Chamada via botão refresh da tabela de borderô - Permite a troca do índice atual
        //Sua lógica para seleção de índice - Exemplo utilizando List Box
        nIndex := U_SelIndex(aIndices)
    EndIf

Return nIndex

/*/{Protheus.doc} SelIndex
Rotina para seleção de índice no botão refresh da tela de seleção de borderô.

@version    P12
@since      10/09/2021
@param      aIndices array, array de índices que poderão ser selecionados
@return     numeric, indice a ser utilizado na tela de seleção de borderô
/*/
/*/User Function SelIndex(aIndices As Array) As Numeric

    Local nVar      As Numeric
    Local nOpca     As Numeric
    Local nSE2Index As Numeric
    Local oList     As Object
    Local oDlg      As Object

    nOpca       := 2

    DEFINE MSDIALOG oDlg TITLE "Seleção de Índice" From 9, 0 To 32, 74 OF oMainWnd

    @0.5, 0.3 TO 12.2, 32.2 LABEL "Índices" OF oDlg
    @2.3, 3.0 Say OemToAnsi("  ")
    @1.0, 0.7 LISTBOX oList VAR nVar Fields HEADER "Índice" SIZE 250, 150 NOSCROLL ON DBLCLICK (nSE2Index := aIndices[oList:nAt][1], nOpca := 1, oDlg:End())

    oList:SetArray(aIndices)
    oList:bLine := {|| {aIndices[oList:nAt][2]}}

    DEFINE SBUTTON FROM 10.0, 260 TYPE 1 ACTION (nOpca := 1, nSE2Index := aIndices[oList:nAt][1], oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON FROM 22.5, 260 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED

    //Caso cancelada a seleção, automaticamente seleciona o primeiro índice
    If nOpca == 2
        nSE2Index := 1
    EndIf

Return nSE2Index/*/
