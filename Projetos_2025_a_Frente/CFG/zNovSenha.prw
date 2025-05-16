//Bibliotecas
#Include "TOTVS.ch"
   
/*/{Protheus.doc} zNovSenha
Função para reset de senhas
@type function
@author Julio Martins
@since 04/11/2023
    O design dela foi baseada na clássica zLogin, disponível para download em https://terminaldeinformacao.com/2016/03/15/tela-de-autenticacao-customizada-protheus/
     
    Verifique a empresa, a filial, o usuário e senha informados no RPCSetEnv
/*/
   
User Function zNovSenha()
    //Se o ambiente não estiver preparado ainda
    If Select("SX2") <= 0
        //Faz o login
        RPCSetEnv("01", "01", "pluiz", "Cruzer@2025", "", "")
 
        //Aciona a tela do reset de senhas
        fMontaTela()
 
    //Senão, mostra mensagem de falha
    Else
        FWAlertError("Abra a função u_zNovSenha no programa inicial do sistema!", "Falha")
    EndIf
Return
 
Static Function fMontaTela()
    Local aArea := GetArea()
    Local oGrpLog
    Local oBtnConf
    Private oDlgPvt
    //Says e Gets
    Private oSayUsr
    Private oGetUsr, cGetUsr := Space(25)
    Private oSayPsw
    Private oGetPsw, cGetPsw := Space(20)
    Private oGetObs, cGetObs := ""
    //Dimensões da janela
    Private nJanLarg := 200
    Private nJanAltu := 200
 
    //Criando a janela
    DEFINE MSDIALOG oDlgPvt TITLE "Redinir Senha" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo de Login
        @ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3         PROMPT "Informações: "     OF oDlgPvt COLOR 0, 16777215 PIXEL
            //Label e Get de Usuário
            @ 013, 006   SAY   oSayUsr PROMPT "Usuário:"        SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
           
            //Label e Get da Senha
            @ 033, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 040, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD
           
            //Get de Log, pois se for Say, não da para definir a cor
            @ 060, 006   MSGET oGetObs VAR    cGetObs        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
            oGetObs:lActive := .F.
           
            //Botões
            @ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
            oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
    ACTIVATE MSDIALOG oDlgPvt CENTERED
       
    RestArea(aArea)
Return
   
Static Function fVldUsr()
    Local lDeuCerto := .F.
    Local cUsrAux   := Alltrim(cGetUsr)
    Local cPswAux   := Alltrim(cGetPsw)
 
    //Aciona a redefinição de senha
    lDeuCerto := u_zAtuSenha(cUsrAux, cPswAux)
 
    //Se deu tudo certo, o texto ficará em azul, senão ficará em vermelho
    If lDeuCerto
        cGetObs := "Senha redefinida com sucesso!"
        oGetObs:setCSS("QLineEdit{color:#0000FF; background-color:#FEFEFE;}")
    Else
        cGetObs := "Falha ao definir a senha!"
        oGetObs:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
    EndIf
    oGetObs:Refresh()
 
Return
