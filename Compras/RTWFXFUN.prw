#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'
#Include 'AP5MAIL.ch'

/*/{Protheus.doc} CONSOLE
Função Responsavel por gerar log de processamento de processos separado do console.log.
@author     Ricardo Tavares Ferreira
@since      31/08/2018
@version    12.1.17
@return     Nulo
@obs        Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    User Function CONSOLE(cTxt,cFuncName)
//====================================================================================================

    Local aArea         := GetArea()
    Local nHdl          := 0
    Local cLog          := ""

    Default cTxt        := ""
    Default cFuncName   := ""

    If cTxt == Nil .and. cFuncName == Nil
	    Return
    ElseIf cTxt == Nil
        cTxt := "Unknown Text"
    ElseIf cFuncName == Nil
        cFuncName := "Unknown Function"
    EndIf

    nHdl := FOpen("\workflow\XLOGWF"+cEmpAnt+cFilAnt+".log",2)

    Iif(nHdl > 0,,nHdl := MSFCREATE("\workflow\XLOGWF"+cEmpAnt+cFilAnt+".log",0))
    FSeek(nHdl,0,2)

    cLog := "["+ Dtoc(Date()) +"] ["+ Time() +"] ["+cFuncName+"] "+ cTxt + chr(13) + chr(10)
    Fwrite(nHdl, cLog, Len(cLog))

    cLog := Replicate('-',180) + chr(13) + chr(10)
    FWrite(nHdl,cLog,Len(cLog))

    FClose(nHdl)

    ConOut("["+ Dtoc(Date()) +"] ["+ Time() +"] ["+cFuncName+"] "+ cTxt)

    RestArea(aArea)

Return 

/*/{Protheus.doc} CONSOLE
Retorna a descricao de algum codigo conforme parametro passado.
@author     Ricardo Tavares Ferreira
@since      31/08/2018
@version    12.1.17
@return     Caracter
@obs        Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    User Function RetDesc(cTipo,cCodigo,xEmp)
//====================================================================================================

    Local cDesc 	:= ""
    Local aArea 	:= {GetArea(), SM0->(GetArea())}
    Local nRecSM0 	:= SM0->(Recno())
    Local aUsuario 	:= {}
    
    Default cTipo 	:= ""
    Default cCodigo := ""
    Default xEmp 	:= ""

    If (cTipo == "FILIAL")
        DbSelectArea("SM0")
        SM0->(DbGoTop())
        While (SM0->(!Eof()))
            If (Alltrim(xEmp) == Alltrim(SM0->M0_CODIGO)) .and. (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
                cDesc := SM0->M0_FILIAL
            Endif
            SM0->(DbSkip())
        Enddo

        SM0->(DbGoTo(nRecSM0))
    Elseif (cTipo == "SOLICIT")
        PswOrder(2)
        If PswSeek(cCodigo)
	        aUsuario := PswRet()
	        cDesc := PswRet(1)[1][4]
        EndIf
    Endif
    aEval(aArea, {|x| RestArea(x)})
Return(cDesc)