#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

User Function CN300RST()

Local xRet := ParamixB[1]
Local cTpCnt := ParamixB[2]

If FWIsInCallStack('CNTA120') .And. FWIsInCallStack('CN130TudOk') .And. (cTpCnt == "003" .Or. cTpCnt == "004")
    xRet := .T.
EndIf

Return .T.
