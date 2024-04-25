#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ02M001
Rotina em botão que realiza a rejeição da solicitação de doação.
@type function           
@author Ricardo Tavares Ferreira
@since 02/02/2022
@version 12.1.27
@history 02/02/20222, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ02M001()
//=============================================================================================================================

    Local lRejeita  := .F.
    Local aArea     := GetArea()

    Private oDlg    := Nil
    Private oObsSD  := Nil
    Private cObsSD  := ""
    Private nOpc    := 0
    Private bOk     := {|| nOpc := 1, oDlg:End() }
    Private oFont1  := Nil

    If Alltrim(SCR->CR_TIPO) == "SD"
        TelaObseva()
        If nOpc == 1
            If Empty(cObsSD)
                MsgStop("Não é Possivel Rejeitar a Solicitação de Doação sem informar o motivo da Rejeição.","Atenção")
            Else
                lRejeita := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,cObsSD},Date(),7)
                If lRejeita
                    DbSelectArea("SZE")
                    SZE->(DbSetOrder(2))
                    If SZE->(DbSeek(FWXFilial("SZE")+Alltrim(SCR->CR_NUM)))
                        RecLock("SZE",.F.)
                            SZE->ZE_STATUS  := "2"
                            SZE->ZE_OBSREJ  := cObsSD
                        SZE->(MsUnlock())
                    Else
                        MsgStop("Falha ao posicionar na Solicitação de Doação para alteração do STATUS,", "Atenção")
                    EndIf
                Else 
                    MsgStop("Falha ao executar a Função MaAlcDoc", "Atenção")
                EndIf 
            EndIf
        Else 
            MsgStop("O Documento nao será rejeitado pois não foi confirmado o motivo da Rejeição", "Atenção")
        EndIf 
    Else 
        MsgStop("Opção de Rejeição somente para o tipo de documento SD (Solicitação de Doação).", "Atenção")
    EndIf 
    RestArea(aArea)
Return

/*/{Protheus.doc} TelaObseva
Monta a tela para o usuario descrever o motivo da rejeição da solicitação de doação.
@type function           
@author Ricardo Tavares Ferreira
@since 02/02/2022
@version 12.1.27
@history 02/02/20222, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    Static Function TelaObseva()
//=============================================================================================================================

	Define MsDialog oDlg Title "Justificativa da Rejeição da Solicitação de Doação" From 0,0 To 190,532 Style 128 Of oDlg Pixel
	
	@ 06,06 To 60,261 LABEL " Informe a Justificativa da Rejeição da Solicitação de Doação" OF oDlg PIXEL
	@ 20,15 Get oObsSD     Var cObsSD Multiline Text Font oFont1 Size 240,30 Pixel Of oDlg
	
	@ 70,225 Button "&Ok"       Size 36,16 Pixel Action Eval(bOk)	
	
	Activate MsDialog oDlg Center
Return
