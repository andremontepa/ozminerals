//#Include "TOTVS.CH"

/*/{Protheus.doc} F240IND
Ponto de entrada para manipula��o de �ndice da tela de border� (FINA240).

@version    P12
@since      10/09/2021
@return     numeric, �ndice a ser posicionado
@obs        Fun��o utilizada nas rotinas FINA240
/*/
User Function F240IND() As Numeric

    Local aIndices  As Array
    Local lRefresh  As Logical
    Local nIndex    As Numeric

    nIndex      := 1
    lRefresh    := paramIXB[1]
    aIndices    := paramIXB[2] //somente � carregado na execu��o via bot�o Atualizar (quando lRefresh est� como verdadeiro)

    //Escolha do indice inicial da tabela
    If !lRefresh
        If MsgYesNo("Desejar ordenar por Nome do Fornecedor?", "F240IND - Alterar o Indice")
            nIndex := 18
        EndIf
    Else
        //Chamada via bot�o refresh da tabela de border� - Permite a troca do �ndice atual
        //Sua l�gica para sele��o de �ndice - Exemplo utilizando List Box
        nIndex := U_SelIndex(aIndices)
    EndIf

Return nIndex

/*/{Protheus.doc} SelIndex
Rotina para sele��o de �ndice no bot�o refresh da tela de sele��o de border�.

@version    P12
@since      10/09/2021
@param      aIndices array, array de �ndices que poder�o ser selecionados
@return     numeric, indice a ser utilizado na tela de sele��o de border�
/*/
/*/User Function SelIndex(aIndices As Array) As Numeric

    Local nVar      As Numeric
    Local nOpca     As Numeric
    Local nSE2Index As Numeric
    Local oList     As Object
    Local oDlg      As Object

    nOpca       := 2

    DEFINE MSDIALOG oDlg TITLE "Sele��o de �ndice" From 9, 0 To 32, 74 OF oMainWnd

    @0.5, 0.3 TO 12.2, 32.2 LABEL "�ndices" OF oDlg
    @2.3, 3.0 Say OemToAnsi("  ")
    @1.0, 0.7 LISTBOX oList VAR nVar Fields HEADER "�ndice" SIZE 250, 150 NOSCROLL ON DBLCLICK (nSE2Index := aIndices[oList:nAt][1], nOpca := 1, oDlg:End())

    oList:SetArray(aIndices)
    oList:bLine := {|| {aIndices[oList:nAt][2]}}

    DEFINE SBUTTON FROM 10.0, 260 TYPE 1 ACTION (nOpca := 1, nSE2Index := aIndices[oList:nAt][1], oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON FROM 22.5, 260 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED

    //Caso cancelada a sele��o, automaticamente seleciona o primeiro �ndice
    If nOpca == 2
        nSE2Index := 1
    EndIf

Return nSE2Index/*/
