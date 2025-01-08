#include "prtopdef.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} RT02JB01
Job Responsavel por executar as regras cadastradas na rotina de manutenção de aprovadores.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function RT02JB01(cEmp,cFil)
//====================================================================================================

    Default cEmp      := "99"
    Default cFil      := "01"
    Private aDadosAL  := {}
    Private aDadosCR  := {}
    Private cAprovPri := ""
    Private cUserPri  := ""
    
    If IsBlind()
	    Conout("[RT02JB01] ["+cEmp+"-"+cFil+"] [" + Dtoc(Date()) +" "+ Time()+ "]  Inicio do processo de Verificacao ...")
    Else 
        Conout("[RT02JB01] ["+cEmpAnt+"-"+cFilAnt+"] [" + Dtoc(Date()) +" "+ Time()+ "]  Inicio do processo de Verificacao ...")
    EndIf 

    If IsBlind()
        RpcSetType(3)
        RpcSetEnv(cEmp,cFil,,,,getEnvServer(),{"SAL","SAK","ZZY"})
            BuscaZZY()
        RpcClearEnv()
    Else 
        BuscaZZY()
    EndIf

    If IsBlind()
	    Conout("[RT02JB01] ["+cEmp+"-"+cFil+"] [" + Dtoc(Date()) +" "+ Time()+ "]  Fim do processo de Verificacao ...")
    Else 
        Conout("[RT02JB01] ["+cEmpAnt+"-"+cFilAnt+"] [" + Dtoc(Date()) +" "+ Time()+ "]  Fim do processo de Verificacao ...")
    EndIf
Return

/*/{Protheus.doc} BuscaZZY
Busca os Dados da Tabela ZZY para ser processada.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function BuscaZZY()
//====================================================================================================

	Local cQuery		:= ""
	Local QbLinha		:= chr(13)+chr(10)
    Local cAliasZZY 	:= GetNextAlias()
    Local nQtdReg   	:= 0

    cQuery := " SELECT ZZY.* "+QbLinha 
	cQuery += " FROM "
	cQuery +=   RetSqlName("ZZY") + " ZZY "+QbLinha
    cQuery += " WHERE "+QbLinha 
    cQuery += " ZZY.D_E_L_E_T_ = ' ' "+QbLinha 

    If IsBlind()
        cQuery += " AND ZZY_STATUS IN ('AA','AP') "+QbLinha
        cQuery += " AND ZZY_TPEXEC = 'A' "+QbLinha
    Else 
        cQuery += " AND ZZY_CODIGO = '"+Alltrim(ZZY->ZZY_CODIGO)+"' "+QbLinha
        cQuery += " AND ZZY_TPEXEC = 'M' "+QbLinha
        cAprovPri := Alltrim(ZZY->ZZY_APROV)
        cUserPri  := GetUserSAK(AllTrim(ZZY->ZZY_APROV))
    EndIf

    MemoWrite("C:/ricardo/RT02JB01_BuscaZZY.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZZY,.F.,.T.)
            
    DbSelectArea(cAliasZZY)
    (cAliasZZY)->(DbGoTop())
    Count To nQtdReg
    (cAliasZZY)->(DbGoTop())
            
    If nQtdReg <= 0
		(cAliasZZY)->(DbCloseArea())
		Conout("[RT02JB01] [BuscaZZY]  [" + Dtoc(Date()) +" "+ Time()+ "] Nao foi encontrada nenhuma regra de substituicao para ser executada ...")
	Else
		While ! (cAliasZZY)->(Eof())
            ProcGrupo(cAliasZZY)
            (cAliasZZY)->(DbSkip())
        End
        (cAliasZZY)->(DbCloseArea())
    EndIf
Return Nil

/*/{Protheus.doc} ProcGrupo
Busca e Salva os Dados dos Grupos na tabela ZZZ.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ProcGrupo(cAliasZZY)
//====================================================================================================

    Local cQuery		:= ""
	Local QbLinha		:= chr(13)+chr(10)
    Local cAliasGer 	:= GetNextAlias()
    Local nQtdReg   	:= 0
    Local cCodAprov     := ""
    Local cUsrAprov     := ""  
    Local lExiste       := .F.    

    If (cAliasZZY)->ZZY_STATUS $ "AA/MA"
        cQuery := " SELECT SAL.* "+QbLinha 
        cQuery += " FROM "
	    cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
        cQuery += " WHERE "+QbLinha 
        cQuery += " SAL.D_E_L_E_T_ = ' ' "+QbLinha 

        If IsBlind()
            cQuery += " AND AL_APROV = '"+Alltrim((cAliasZZY)->ZZY_APROV)+"' "+QbLinha
        Else 
            If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                cQuery += " AND AL_APROV = '"+Alltrim((cAliasZZY)->ZZY_APROV)+"' "+QbLinha
            EndIf 
            If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                cQuery += " AND AL_APROV = '"+Alltrim((cAliasZZY)->ZZY_SUBTMP)+"' "+QbLinha
            EndIf
        EndIf 
    ElseIf (cAliasZZY)->ZZY_STATUS $ "AP/MP" 
        If IsBlind()
            If .not. (Val(Dtos(Date())) > Val((cAliasZZY)->ZZY_DTFIM) .and. (cAliasZZY)->ZZY_TPEXEC == "A")
                Conout("[RT02JB01] [ProcGrupo]  [" + Dtoc(Date()) +" "+ Time()+ "] Nao ha regras programadas para executar na data de hoje: "+Dtoc(Date())+" ...")
                Return Nil 
            EndIf 
        EndIf 
        cQuery := " SELECT ZZZ.* "+QbLinha 
        cQuery += " FROM "
	    cQuery +=   RetSqlName("ZZZ") + " ZZZ "+QbLinha
        cQuery += " WHERE ZZZ.D_E_L_E_T_ = ' ' "+QbLinha 
        cQuery += " AND ZZZ_STATUS = 'A' "+QbLinha

        If IsBlind()
            cQuery += " AND ZZZ_APROV = '"+Alltrim((cAliasZZY)->ZZY_APROV)+"' "+QbLinha
        Else
            If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                cQuery += " AND ZZZ_APROV = '"+Alltrim((cAliasZZY)->ZZY_SUBTMP)+"' "+QbLinha
            EndIf 
            If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                cQuery += " AND ZZZ_APROV = '"+Alltrim((cAliasZZY)->ZZY_SUBTMP)+"' "+QbLinha
            EndIf
        EndIf 
    EndIf 

    If .not. Empty(cQuery)
        MemoWrite("C:/ricardo/RT02JB01_ProcGrupo.sql",cQuery)			     
        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasGer,.F.,.T.)
                
        DbSelectArea(cAliasGer)
        (cAliasGer)->(DbGoTop())
        Count To nQtdReg
        (cAliasGer)->(DbGoTop())

        If nQtdReg <= 0
            (cAliasGer)->(DbCloseArea())
            Conout("[RT02JB01] [ProcGrupo]  [" + Dtoc(Date()) +" "+ Time()+ "] Dados dos Grupos nao Encontrados ...")
        Else
            If (cAliasZZY)->ZZY_STATUS $ "AA/MA"
                While .not. (cAliasGer)->(Eof())
                    If GetCodAprov(AllTrim((cAliasZZY)->ZZY_SUBST),AllTrim((cAliasGer)->AL_COD),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasZZY)->ZZY_SUBTMP),(cAliasZZY)->ZZY_STATUS,AllTrim((cAliasZZY)->ZZY_TPEXEC))
                        Conout("[RT02JB01] [ProcGrupo]  [" + Dtoc(Date()) +" "+ Time()+ "] O Substituto ja se Encontra cadastrado no Grupo de Aprovação da Regra Selecionada ...  [GRUPO: "+AllTrim((cAliasGer)->AL_COD)+"] [USUARIO: "+AllTrim((cAliasGer)->AL_USER) +"] [NIVEL: "+AllTrim((cAliasGer)->AL_NIVEL)+"] [APROVADOR: "+(cAliasGer)->AL_APROV+"] [STATUS: "+(cAliasZZY)->ZZY_STATUS+"]")
                        lExiste := .T.
                    Else 
                        lExiste := .F. 
                    EndIf 

                    If .not. lExiste
                        If AllTrim((cAliasZZY)->ZZY_TPEXEC) == "M" .and. (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                            cCodAprov   := AllTrim((cAliasZZY)->ZZY_SUBTMP)
                            cUsrAprov   := GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP))
                        Else 
                            cCodAprov   := AllTrim((cAliasGer)->AL_APROV)
                            cUsrAprov   := AllTrim((cAliasGer)->AL_USER) 
                        EndIf
                        aadd(aDadosAL,{AllTrim((cAliasGer)->AL_FILIAL)  ,;
                                    AllTrim((cAliasGer)->AL_COD)     ,;
                                    AllTrim((cAliasGer)->AL_DESC)    ,;
                                    AllTrim((cAliasGer)->AL_ITEM)    ,;
                                    cCodAprov                        ,;
                                    cUsrAprov                        ,;
                                    AllTrim((cAliasGer)->AL_NIVEL)   ,;
                                    AllTrim((cAliasGer)->AL_LIBAPR)  ,;
                                    AllTrim((cAliasGer)->AL_AUTOLIM) ,;
                                    AllTrim((cAliasGer)->AL_TPLIBER) ,;
                                    AllTrim((cAliasGer)->AL_PERFIL)  ,;
                                    "A"                              ,;
                                    0                                ,;
                                    AllTrim((cAliasGer)->AL_DOCAE)   ,;
                                    AllTrim((cAliasGer)->AL_DOCCO)   ,;
                                    AllTrim((cAliasGer)->AL_DOCCP)   ,;
                                    AllTrim((cAliasGer)->AL_DOCMD)   ,;
                                    AllTrim((cAliasGer)->AL_DOCNF)   ,;
                                    AllTrim((cAliasGer)->AL_DOCPC)   ,;
                                    AllTrim((cAliasGer)->AL_DOCSA)   ,;
                                    AllTrim((cAliasGer)->AL_DOCSC)   ,;
                                    AllTrim((cAliasGer)->AL_DOCST)   ,;
                                    AllTrim((cAliasGer)->AL_DOCIP)   ,;
                                    AllTrim((cAliasGer)->AL_DOCCT)   ,;
                                    AllTrim((cAliasGer)->AL_DOCGA)   ,;
                                    AllTrim((cAliasGer)->AL_APROSUP) ,;
                                    AllTrim((cAliasGer)->AL_USERSUP) ,;
                                    AllTrim((cAliasGer)->AL_AGRCNNG) ,;
                                    AllTrim((cAliasGer)->AL_XESTOQ)  })
                        
                        ExecAbertos(cAliasZZY,cAliasGer)
                    EndIf 
                    (cAliasGer)->(DbSkip())
                End
                
                DbSelectArea("ZZY")
                ZZY->(DbGotop())
                ZZY->(DbGoto((cAliasZZY)->R_E_C_N_O_))

                RecLock("ZZY",.F.)
                    ZZY->ZZY_DTEXEC := Date()
                    ZZY->ZZY_HREXEC := Time()
                    If IsBlind()
                        ZZY->ZZY_STATUS := "AP"   
                    Else 
                        If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                            ZZY->ZZY_STATUS := "MP"
                        ElseIf .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST))
                            ZZY->ZZY_STATUS := "MF"
                        EndIf
                    EndIf   
                ZZY->(MsUnlock()) 
                GravaZZZ(aDadosAL,"I")
            ElseIf (cAliasZZY)->ZZY_STATUS $ "AP/MP"
                While .not. (cAliasGer)->(Eof())
                    aadd(aDadosAL,{AllTrim((cAliasGer)->ZZZ_FILIAL) ,;
                                   AllTrim((cAliasGer)->ZZZ_GRUPO)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DESC)   ,;
                                   AllTrim((cAliasGer)->ZZZ_ITEM)   ,;
                                   AllTrim((cAliasGer)->ZZZ_APROV)  ,;
                                   AllTrim((cAliasGer)->ZZZ_USER)   ,;
                                   AllTrim((cAliasGer)->ZZZ_NIVEL)  ,;
                                   AllTrim((cAliasGer)->ZZZ_LIBAPR) ,;
                                   AllTrim((cAliasGer)->ZZZ_AUTLIM) ,;
                                   AllTrim((cAliasGer)->ZZZ_TPLIB)  ,;
                                   AllTrim((cAliasGer)->ZZZ_PERFIL) ,;
                                   "F"                              ,;
                                   (cAliasGer)->R_E_C_N_O_          ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCAE)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCCO)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCCP)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCMD)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCNF)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCPC)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCSA)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCSC)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCST)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCIP)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCCT)  ,;
                                   AllTrim((cAliasGer)->ZZZ_DOCGA)  ,;
                                   AllTrim((cAliasGer)->ZZZ_APROSU) ,;
                                   AllTrim((cAliasGer)->ZZZ_USERSU) ,;
                                   AllTrim((cAliasGer)->ZZZ_AGRCNN) ,;
                                   AllTrim((cAliasGer)->ZZZ_XESTOQ) })
                    
                    ExecProg(cAliasZZY,cAliasGer)
                    (cAliasGer)->(DbSkip())
                End
                DbSelectArea("ZZY")
                ZZY->(DbGotop())
                ZZY->(DbGoto((cAliasZZY)->R_E_C_N_O_))

                RecLock("ZZY",.F.)
                    ZZY->ZZY_DTEXEC := Date()
                    ZZY->ZZY_HREXEC := Time()
                    If IsBlind()
                        ZZY->ZZY_STATUS := "AF"   
                    Else 
                        If (Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                            ZZY->ZZY_STATUS := "MP"
                        ElseIf (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                            ZZY->ZZY_STATUS := "MF"
                        EndIf
                    EndIf   
                ZZY->(MsUnlock()) 
                GravaZZZ(aDadosAL,"F")
            EndIf 
            (cAliasGer)->(DbCloseArea())
        EndIf    
    EndIf 

    If IsBlind()
        StartJob("U_ExecCRFull",GetEnvServer(),.T.,aDadosCR,"03","01")
        StartJob("U_ExecCRFull",GetEnvServer(),.T.,aDadosCR,"04","01")
    Else 
        ExecCRTela(aDadosCR)
    EndIf 
Return Nil 

/*/{Protheus.doc} ExecCRTela
Executa a SCR de outras Empresas.
@type function
@author Ricardo Tavares Ferreira
@since 28/08/2021
@version 12.1.25
@history 28/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecCRTela(aDadosCR)
//====================================================================================================

    Local nX        := 0
    Local cUpd      := ""
    Local QbLinha	:= chr(13)+chr(10)
    Local cUserFim  := ""
    Local cAprovFim := ""
    Local cUserApr  := ""
    Local cAprovSub := ""

    For nX := 1 To Len(aDadosCR)
        cUpd := "UPDATE SCR030 "
        If aDadosCR[nX][8] == "S"
            cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][7])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"'"+QbLinha
        Else 
            If aDadosCR[nX][5] $ "AP/MP"
                cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][1])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"'"+QbLinha
            ElseIf aDadosCR[nX][5] $ "AA/MA"
                cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][7])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"'"+QbLinha
            EndIf 
        EndIf 
		cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha 
        cUpd += " AND CR_STATUS IN ('01','02') "+QbLinha
        cUpd += " AND CR_GRUPO = '"+AllTrim(aDadosCR[nX][4])+"' "+QbLinha 
        cUpd += " AND CR_NIVEL = '"+AllTrim(aDadosCR[nX][3])+"' "+QbLinha

        If aDadosCR[nX][8] == "S"
            cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][1])+"' "+QbLinha
            cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"' "+QbLinha 

            cUserFim  := AllTrim(aDadosCR[nX][1])
            cAprovFim := AllTrim(aDadosCR[nX][2])
            cUserApr  := AllTrim(aDadosCR[nX][7])
            cAprovSub := AllTrim(aDadosCR[nX][6])
        Else 
            If aDadosCR[nX][5] $ "AP/MP"
                cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][7])+"' "+QbLinha
                cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"' "+QbLinha 
            ElseIf aDadosCR[nX][5] $ "AA/MA" 
                cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][1])+"' "+QbLinha
                cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"' "+QbLinha 
            EndIf 
        EndIf
		
		If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SCR ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SCR executado com sucesso ...")
		EndIf

        cUpd := "UPDATE SCR040 "
        If aDadosCR[nX][8] == "S"
            cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][7])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"'"+QbLinha
        Else 
            If aDadosCR[nX][5] $ "AP/MP"
                cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][1])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"'"+QbLinha
            ElseIf aDadosCR[nX][5] $ "AA/MA"
                cUpd += "SET CR_USER = '"+AllTrim(aDadosCR[nX][7])+"', CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"'"+QbLinha
            EndIf 
        EndIf 

		cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha 
        cUpd += " AND CR_STATUS IN ('01','02') "+QbLinha
        cUpd += " AND CR_GRUPO = '"+AllTrim(aDadosCR[nX][4])+"' "+QbLinha 
        cUpd += " AND CR_NIVEL = '"+AllTrim(aDadosCR[nX][3])+"' "+QbLinha

        If aDadosCR[nX][8] == "S"
            cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][1])+"' "+QbLinha
            cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"' "+QbLinha 
        Else 
            If aDadosCR[nX][5] $ "AP/MP"
                cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][7])+"' "+QbLinha
                cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][6])+"' "+QbLinha 
            ElseIf aDadosCR[nX][5] $ "AA/MA" 
                cUpd += " AND CR_USER  = '"+AllTrim(aDadosCR[nX][1])+"' "+QbLinha
                cUpd += " AND CR_APROV = '"+AllTrim(aDadosCR[nX][2])+"' "+QbLinha 
            EndIf 
        EndIf
		
		If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SCR ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SCR executado com sucesso ...")
		EndIf
    Next nX

    If .not. Empty(cUserFim) .and. .not. Empty(cAprovFim)
        cUpd := " UPDATE SCR010 "+QbLinha
        cUpd += " SET CR_USER = '"+cUserApr+"', CR_APROV = '"+cAprovSub+"'"+QbLinha
        cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha  
        cUpd += " AND CR_STATUS IN ('01','02') "+QbLinha
        cUpd += " AND CR_APROV = '"+cAprovPri+"' "+QbLinha
        cUpd += " AND CR_USER = '"+cUserPri+"' "+QbLinha
        
        If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SCR ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SCR executado com sucesso ...")
		EndIf
    
        cUpd := " UPDATE SCR030 "+QbLinha
        cUpd += " SET CR_USER = '"+cUserApr+"', CR_APROV = '"+cAprovSub+"'"+QbLinha
        cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha  
        cUpd += " AND CR_STATUS IN ('01','02') "+QbLinha
        cUpd += " AND CR_APROV = '"+cAprovPri+"' "+QbLinha
        cUpd += " AND CR_USER = '"+cUserPri+"' "+QbLinha
        
        If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SCR ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SCR executado com sucesso ...")
		EndIf

        cUpd := " UPDATE SCR040 "+QbLinha
        cUpd += " SET CR_USER = '"+cUserApr+"', CR_APROV = '"+cAprovSub+"'"+QbLinha
        cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha  
        cUpd += " AND CR_STATUS IN ('01','02') "+QbLinha
        cUpd += " AND CR_APROV = '"+cAprovPri+"' "+QbLinha
        cUpd += " AND CR_USER = '"+cUserPri+"' "+QbLinha
        
        If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SCR ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SCR executado com sucesso ...")
		EndIf

        cUpd := " UPDATE SAL010 "+QbLinha
        cUpd += " SET AL_USER = '"+cUserApr+"', AL_APROV = '"+cAprovSub+"'"+QbLinha
        cUpd += " WHERE D_E_L_E_T_ = ' ' "+QbLinha  
        cUpd += " AND AL_APROV = '"+cAprovPri+"' "+QbLinha
        cUpd += " AND AL_USER = '"+cUserPri+"' "+QbLinha
        
        If (TcSqlExec(cUpd) < 0)
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SAL ...")
		Else
			Conout("[RT02JB01][ExecCRTela]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SAL executado com sucesso ...")
		EndIf
    EndIf 
Return 

/*/{Protheus.doc} ExecCRFull
Executa a SCR de outras Empresas.
@type function
@author Ricardo Tavares Ferreira
@since 28/08/2021
@version 12.1.25
@history 28/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function ExecCRFull(aDadosCR,cEmp,cFil)
//====================================================================================================

    Local nX := 0

    RpcSetType(3)
    RpcSetEnv(cEmp,cFil,,,,getEnvServer(),{"SCR","SAL","SAK"})
    
    For nX := 1 To Len(aDadosCR)
        PutSCRAll(aDadosCR[nX][1],aDadosCR[nX][2],aDadosCR[nX][3],aDadosCR[nX][4],aDadosCR[nX][5],aDadosCR[nX][6],aDadosCR[nX][7],aDadosCR[nX][8])
    Next nX

    RpcClearEnv()
Return 

/*/{Protheus.doc} GravaZZZ
Grava ou Altera os dados da Tabela ZZZ.
@type function
@author Ricardo Tavares Ferreira
@since 28/08/2021
@version 12.1.25
@history 28/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function GravaZZZ(aDadosAL,cTipo)
//====================================================================================================

    Local nX           := 0
    Default aDadosAL   := {}

    DbSelectArea("ZZZ")
    ZZZ->(DbSetOrder(1))

    If Len(aDadosAL) > 0
        For nX := 1 To Len(aDadosAL)
            If cTipo == "I"
                RecLock("ZZZ", .T.)
            Else 
                ZZZ->(DbGoto(aDadosAL[nX][13]))
                RecLock("ZZZ", .F.)
            EndIf
                ZZZ->ZZZ_FILIAL  := aDadosAL[nX][1]  
                ZZZ->ZZZ_GRUPO   := aDadosAL[nX][2] 
                ZZZ->ZZZ_DESC    := aDadosAL[nX][3] 
                ZZZ->ZZZ_ITEM    := aDadosAL[nX][4] 
                ZZZ->ZZZ_APROV   := aDadosAL[nX][5] 
                ZZZ->ZZZ_USER    := aDadosAL[nX][6] 
                ZZZ->ZZZ_NIVEL   := aDadosAL[nX][7] 
                ZZZ->ZZZ_LIBAPR  := aDadosAL[nX][8] 
                ZZZ->ZZZ_AUTLIM  := aDadosAL[nX][9] 
                ZZZ->ZZZ_TPLIB   := aDadosAL[nX][10] 
                ZZZ->ZZZ_PERFIL  := aDadosAL[nX][11] 
                ZZZ->ZZZ_STATUS  := aDadosAL[nX][12] 
                ZZZ->ZZZ_DOCAE   := Iif(aDadosAL[nX][14] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCCO   := Iif(aDadosAL[nX][15] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCCP   := Iif(aDadosAL[nX][16] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCMD   := Iif(aDadosAL[nX][17] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCNF   := Iif(aDadosAL[nX][18] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCPC   := Iif(aDadosAL[nX][19] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCSA   := Iif(aDadosAL[nX][20] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCSC   := Iif(aDadosAL[nX][21] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCST   := Iif(aDadosAL[nX][22] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCIP   := Iif(aDadosAL[nX][23] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCCT   := Iif(aDadosAL[nX][24] == "T",.T.,.F.)
                ZZZ->ZZZ_DOCGA   := Iif(aDadosAL[nX][25] == "T",.T.,.F.)
                ZZZ->ZZZ_APROSU  := aDadosAL[nX][26]
                ZZZ->ZZZ_USERSU  := aDadosAL[nX][27]
                ZZZ->ZZZ_AGRCNN  := Iif(aDadosAL[nX][28] == "T",.T.,.F.)
                ZZZ->ZZZ_XESTOQ  := Iif(aDadosAL[nX][29] == "T",.T.,.F.)
            ZZZ->(MsUnlock())
        Next nX 
    EndIf 
Return Nil 

/*/{Protheus.doc} ExecAbertos
Executa registros com status de abertos.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecAbertos(cAliasZZY,cAliasGer)
//====================================================================================================

    Local cQuery		:= ""
	Local QbLinha		:= chr(13)+chr(10)
    Local cAliasSAL 	:= GetNextAlias()
    Local nQtdReg   	:= 0

    cQuery := " SELECT SAL.* "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += " WHERE SAL.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AL_COD = '"+AllTrim((cAliasGer)->AL_COD)+"' "+QbLinha
    cQuery += " AND AL_USER = '"+AllTrim((cAliasGer)->AL_USER)+"' "+QbLinha
    cQuery += " AND AL_APROV = '"+AllTrim((cAliasGer)->AL_APROV)+"' "+QbLinha
    cQuery += " AND AL_ITEM = '"+AllTrim((cAliasGer)->AL_ITEM)+"' "+QbLinha
    cQuery += " ORDER BY AL_ITEM "+QbLinha

    MemoWrite("C:/ricardo/RT02JB01_ExecAbertos.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSAL,.F.,.T.)
            
    DbSelectArea(cAliasSAL)
    (cAliasSAL)->(DbGoTop())
    Count To nQtdReg
    (cAliasSAL)->(DbGoTop())

    If nQtdReg <= 0
		(cAliasSAL)->(DbCloseArea())
		Conout("[RT02JB01] [ExecAbertos]  [" + Dtoc(Date()) +" "+ Time()+ "] O Aprovador cadastrado na regra nao foi encontrado no grupo de aprovacao ...")
	Else
        DbSelectArea("SAL")
        SAL->(DbSetOrder(1))
		While ! (cAliasSAL)->(Eof())
            nRecnoSAL   := (cAliasSAL)->R_E_C_N_O_

            DbSelectArea("SAL")
            SAL->(DbSetOrder(1))
            SAL->(DbGoTo(nRecnoSAL))

            RecLock("SAL", .F.)
                SAL->AL_FILIAL  := FWXFilial("SAL")
                SAL->AL_COD     := AllTrim((cAliasSAL)->AL_COD)
                SAL->AL_DESC    := Alltrim((cAliasSAL)->AL_DESC)
                SAL->AL_ITEM    := Alltrim((cAliasSAL)->AL_ITEM)

                If IsBlind()
                    SAL->AL_APROV   := AllTrim((cAliasZZY)->ZZY_SUBST)
                    SAL->AL_USER    := GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST))
                    ProcSCR(AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"AA",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)))
                    aadd(aDadosCR,{AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"AA",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)),""})
                Else 
                    If (cAliasZZY)->ZZY_TPEXEC == "M" .and.  (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                        SAL->AL_APROV   := AllTrim((cAliasZZY)->ZZY_SUBTMP)
                        SAL->AL_USER    := GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP))
                        ProcSCR(AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"MA",AllTrim((cAliasZZY)->ZZY_SUBTMP),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP)))
                        aadd(aDadosCR,{AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"MA",AllTrim((cAliasZZY)->ZZY_SUBTMP),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP)),""})
                    EndIf 
                    If (cAliasZZY)->ZZY_TPEXEC == "M" .and. (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                        SAL->AL_APROV   := AllTrim((cAliasZZY)->ZZY_SUBST)
                        SAL->AL_USER    := GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST))
                        ProcSCR(AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"MA",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)))
                        aadd(aDadosCR,{AllTrim((cAliasGer)->AL_USER),AllTrim((cAliasGer)->AL_APROV),AllTrim((cAliasGer)->AL_NIVEL),AllTrim((cAliasGer)->AL_COD),"MA",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)),""})
                    EndIf 
                EndIf 

                SAL->AL_PERFIL  := (cAliasSAL)->AL_PERFIL
                SAL->AL_NIVEL   := (cAliasSAL)->AL_NIVEL
                SAL->AL_APROSUP := (cAliasSAL)->AL_APROSUP 
                SAL->AL_USERSUP := (cAliasSAL)->AL_USERSUP 
                SAL->AL_LIBAPR  := (cAliasSAL)->AL_LIBAPR  
                SAL->AL_AUTOLIM := (cAliasSAL)->AL_AUTOLIM 
                SAL->AL_TPLIBER := (cAliasSAL)->AL_TPLIBER 
            SAL->(MsUnlock())

            (cAliasSAL)->(DbSkip())
        End
        (cAliasSAL)->(DbCloseArea())
    EndIf
Return Nil 

/*/{Protheus.doc} ProcSCR
Altera os registros abertos na tabela SCR.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ProcSCR(cUser,cAprov,cNivel,cGrupo,cStatus,cAprovSub,cUsrSub,cFim)
//====================================================================================================

    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
    Local cAliasEXC := GetNextAlias()

    Default cFim    := ""

    cQuery := " SELECT SCR.* "+QbLinha 
	cQuery += " FROM "
	cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha
    cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CR_STATUS IN ('01','02') "+QbLinha
    cQuery += " AND CR_GRUPO = '"+AllTrim(cGrupo)+"' "+QbLinha 
    cQuery += " AND CR_NIVEL = '"+AllTrim(cNivel)+"' "+QbLinha

    If cFim == "S"
        cQuery += " AND CR_USER  = '"+AllTrim(cUser)+"' "+QbLinha
        cQuery += " AND CR_APROV = '"+AllTrim(cAprov)+"' "+QbLinha 
    Else 
        If cStatus $ "AP/MP"
            cQuery += " AND CR_USER  = '"+AllTrim(cUsrSub)+"' "+QbLinha
            cQuery += " AND CR_APROV = '"+AllTrim(cAprovSub)+"' "+QbLinha 
        ElseIf cStatus $ "AA/MA" 
            cQuery += " AND CR_USER  = '"+AllTrim(cUser)+"' "+QbLinha
            cQuery += " AND CR_APROV = '"+AllTrim(cAprov)+"' "+QbLinha 
        EndIf 
    EndIf

    MemoWrite("C:/ricardo/RT02JB01_ProcSCR.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasEXC,.F.,.T.)
            
    DbSelectArea(cAliasEXC)
    (cAliasEXC)->(DbGoTop())

    If (cAliasEXC)->(Eof())
        (cAliasEXC)->(DbCloseArea())
		Conout("[RT02JB01] [ProcSCR]  [" + Dtoc(Date()) +" "+ Time()+ "] Nada na SRC para Processar pelo Filtro -> [GRUPO: "+AllTrim(cGrupo)+"] [USUARIO: "+AllTrim(cUser)+"] [NIVEL: "+AllTrim(cNivel)+"] [APROVADOR: "+AllTrim(cAprov)+"] [STATUS: "+AllTrim(cStatus)+"] ...")
    Else 
        (cAliasEXC)->(DbGoTop())
        DbSelectArea("SCR")
        SCR->(DbSetOrder(1))

        While .not. (cAliasEXC)->(Eof())
            SCR->(DbGoto((cAliasEXC)->R_E_C_N_O_))
            RecLock("SCR",.F.)
                If cFim == "S"
                    SCR->CR_USER  := cUsrSub
                    SCR->CR_APROV := cAprovSub
                Else 
                    If cStatus $ "AP/MP"
                        SCR->CR_USER  := cUser
                        SCR->CR_APROV := cAprov
                    ElseIf cStatus $ "AA/MA" 
                        SCR->CR_USER  := cUsrSub
                        SCR->CR_APROV := cAprovSub
                    EndIf 
                EndIf 
            SCR->(MsUnlock())
            (cAliasEXC)->(DbSkip())
        End
        (cAliasEXC)->(DbCloseArea())
    EndIf
Return Nil 

/*/{Protheus.doc} PutSCRAll
Altera os registros abertos na tabela SCR das demais empresas.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function PutSCRAll(cUser,cAprov,cNivel,cGrupo,cStatus,cAprovSub,cUsrSub,cFim,cTabEmp)
//====================================================================================================

    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
    Local cAliasAll := GetNextAlias()
    Local cBckEmp   := cEmpAnt

    Default cFim    := ""

    If cTabEmp == "SCR030"
        cEmpAnt := "03"
        cFilAnt := "01"
    Else 
        cEmpAnt := "04"
        cFilAnt := "01"
    EndIf 

    cQuery := " SELECT SCR.* "+QbLinha 
    cQuery += " FROM "+QbLinha 
    cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha
    cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND CR_STATUS IN ('01','02') "+QbLinha
    cQuery += " AND CR_GRUPO = '"+AllTrim(cGrupo)+"' "+QbLinha 
    cQuery += " AND CR_NIVEL = '"+AllTrim(cNivel)+"' "+QbLinha

    If cFim == "S"
        cQuery += " AND CR_USER  = '"+AllTrim(cUser)+"' "+QbLinha
        cQuery += " AND CR_APROV = '"+AllTrim(cAprov)+"' "+QbLinha 
    Else 
        If cStatus $ "AP/MP"
            cQuery += " AND CR_USER  = '"+AllTrim(cUsrSub)+"' "+QbLinha
            cQuery += " AND CR_APROV = '"+AllTrim(cAprovSub)+"' "+QbLinha 
        ElseIf cStatus $ "AA/MA" 
            cQuery += " AND CR_USER  = '"+AllTrim(cUser)+"' "+QbLinha
            cQuery += " AND CR_APROV = '"+AllTrim(cAprov)+"' "+QbLinha 
        EndIf 
    EndIf

    MemoWrite("C:/ricardo/RT02JB01_PutSCRAll.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAll,.F.,.T.)
            
    DbSelectArea(cAliasAll)
    (cAliasAll)->(DbGoTop())

    If (cAliasAll)->(Eof())
        (cAliasAll)->(DbCloseArea())
		Conout("[RT02JB01] [PutSCRAll]  [" + Dtoc(Date()) +" "+ Time()+ "] Nada na SRC para Processar pelo Filtro -> [GRUPO: "+AllTrim(cGrupo)+"] [USUARIO: "+AllTrim(cUser)+"] [NIVEL: "+AllTrim(cNivel)+"] [APROVADOR: "+AllTrim(cAprov)+"] [STATUS: "+AllTrim(cStatus)+"] ...")
    Else 
        (cAliasAll)->(DbGoTop())
        DbSelectArea("SCR")
        SCR->(DbSetOrder(1))

        While .not. (cAliasAll)->(Eof())
            SCR->(DbGoto((cAliasAll)->R_E_C_N_O_))
            RecLock("SCR",.F.)
                If cFim == "S"
                    SCR->CR_USER  := cUsrSub
                    SCR->CR_APROV := cAprovSub
                Else 
                    If cStatus $ "AP/MP"
                        SCR->CR_USER  := cUser
                        SCR->CR_APROV := cAprov
                    ElseIf cStatus $ "AA/MA" 
                        SCR->CR_USER  := cUsrSub
                        SCR->CR_APROV := cAprovSub
                    EndIf 
                EndIf 
            SCR->(MsUnlock())
            (cAliasAll)->(DbSkip())
        End
        (cAliasAll)->(DbCloseArea())
    EndIf
    cEmpAnt := cBckEmp
Return Nil 

/*/{Protheus.doc} ExecProg
Executa registros com status de Programados.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function ExecProg(cAliasZZY,cAliasGer)
//====================================================================================================

    Local cQuery		:= ""
	Local QbLinha		:= chr(13)+chr(10)
    Local cAliasFIM 	:= GetNextAlias()
    Local nQtdReg   	:= 0
    Local cCodAprov     := ""
    Local cUsrAprov     := ""
    Local aDadFimSAL    := {}

    cQuery := " SELECT SAL.* "+QbLinha
    cQuery += " FROM "
    cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += " WHERE SAL.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AL_COD = '"+AllTrim((cAliasGer)->ZZZ_GRUPO)+"' "+QbLinha

    If IsBlind()
        cQuery += " AND AL_USER = '"+GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST))+"' "+QbLinha
        cQuery += " AND AL_APROV = '"+AllTrim((cAliasZZY)->ZZY_SUBST)+"' "+QbLinha
    Else 
        If Empty(AllTrim((cAliasZZY)->ZZY_SUBST)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP))
            cQuery += " AND AL_USER = '"+GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP))+"' "+QbLinha
            cQuery += " AND AL_APROV = '"+AllTrim((cAliasZZY)->ZZY_SUBTMP)+"' "+QbLinha
        EndIf 
        If .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP))
            cQuery += " AND AL_USER = '"+GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP))+"' "+QbLinha
            cQuery += " AND AL_APROV = '"+AllTrim((cAliasZZY)->ZZY_SUBTMP)+"' "+QbLinha
        EndIf 
    EndIf
    
    cQuery += " ORDER BY AL_ITEM "+QbLinha

    MemoWrite("C:/ricardo/RT02JB01_ExecProg.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasFIM,.F.,.T.)
                
    DbSelectArea(cAliasFIM)
    (cAliasFIM)->(DbGoTop())
    Count To nQtdReg
    (cAliasFIM)->(DbGoTop())

    If nQtdReg <= 0
        (cAliasFIM)->(DbCloseArea())
        Conout("[RT02JB01] [ExecAbertos]  [" + Dtoc(Date()) +" "+ Time()+ "] O Aprovador cadastrado na regra nao foi encontrado no grupo de aprovacao ...")
    Else
        DbSelectArea("SAL")
        SAL->(DbSetOrder(1))
        While ! (cAliasFIM)->(Eof())
            nRecnoSAL := (cAliasFIM)->R_E_C_N_O_
            cUsrAprov := AllTrim((cAliasGer)->ZZZ_USER)
            cCodAprov := AllTrim((cAliasGer)->ZZZ_APROV) 

            DbSelectArea("SAL")
            SAL->(DbSetOrder(1))

            If IsBlind()
                ProcSCR(AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"AP",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)))
                aadd(aDadosCR,{AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"AP",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)),""})
            Else 
                If (cAliasZZY)->ZZY_TPEXEC == "M" .and.  (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                    ProcSCR(AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"MP",AllTrim((cAliasZZY)->ZZY_SUBTMP),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP)))
                    aadd(aDadosCR,{AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"MP",AllTrim((cAliasZZY)->ZZY_SUBTMP),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBTMP)),""})
                EndIf 
                If (cAliasZZY)->ZZY_TPEXEC == "M" .and. (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                    ProcSCR(AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"MP",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)),"S")
                    aadd(aDadosCR,{AllTrim((cAliasGer)->ZZZ_USER),AllTrim((cAliasGer)->ZZZ_APROV),AllTrim((cAliasGer)->ZZZ_NIVEL),AllTrim((cAliasGer)->ZZZ_GRUPO),"MP",AllTrim((cAliasZZY)->ZZY_SUBST),GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST)),"S"})
                    cCodAprov := AllTrim((cAliasZZY)->ZZY_SUBST)
                    cUsrAprov := GetUserSAK(AllTrim((cAliasZZY)->ZZY_SUBST))
                EndIf 
            EndIf 
            aDadFimSAL := GetSALFim(AllTrim((cAliasGer)->ZZZ_FILIAL),AllTrim((cAliasGer)->ZZZ_GRUPO),AllTrim((cAliasGer)->ZZZ_ITEM),AllTrim((cAliasGer)->ZZZ_NIVEL))
            If aDadFimSAL[1]
                SAL->(DbGoTo(aDadFimSAL[2]))
                RecLock("SAL", .F.)
                    SAL->AL_APROV   := cCodAprov 
                    SAL->AL_USER    := cUsrAprov  
                SAL->(MsUnlock())
            EndIf     

            DbSelectArea("ZZY")
            ZZY->(DbGotop())
            ZZY->(DbGoto((cAliasZZY)->R_E_C_N_O_))

            RecLock("ZZY",.F.)
                ZZY->ZZY_DTEXEC := Date()
                ZZY->ZZY_HREXEC := Time()
                If IsBlind()
                    ZZY->ZZY_STATUS := "AF"      
                Else 
                    If (cAliasZZY)->ZZY_TPEXEC == "M" .and. (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                        ZZY->ZZY_STATUS := "MP"
                    EndIf 
                    If (cAliasZZY)->ZZY_TPEXEC == "M" .and. (.not. Empty(AllTrim((cAliasZZY)->ZZY_SUBTMP)) .and. .not. Empty(AllTrim((cAliasZZY)->ZZY_SUBST)))
                        ZZY->ZZY_STATUS := "MF"
                    EndIf
                EndIf 
            ZZY->(MsUnlock()) 
            (cAliasFIM)->(DbSkip())
        End
        (cAliasFIM)->(DbCloseArea())
    EndIf
Return Nil 

/*/{Protheus.doc} GetSALFim
Busca o Item na tabela SAL posicionando sua substituição.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function GetSALFim(xFil,xGrupo,xItem,xNivel)
//====================================================================================================

    Local lExiste   := .F.
    Local nRecno    := 0
    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
    Local cAliasEZX := GetNextAlias()
    Local nQtdReg   := 0

    cQuery := " SELECT SAL.* "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += " WHERE SAL.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AL_FILIAL = '"+AllTrim(xFil)+"' "+QbLinha
    cQuery += " AND AL_COD = '"+AllTrim(xGrupo)+"' "+QbLinha
    cQuery += " AND AL_ITEM = '"+AllTrim(xItem)+"' "+QbLinha
    cQuery += " AND AL_NIVEL = '"+AllTrim(xNivel)+"' "+QbLinha
    cQuery += " ORDER BY AL_ITEM "+QbLinha

    MemoWrite("C:/ricardo/RT02JB01_GetSALFim.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasEZX,.F.,.T.)
            
    DbSelectArea(cAliasEZX)
    (cAliasEZX)->(DbGoTop())
    Count To nQtdReg
    (cAliasEZX)->(DbGoTop())

    If nQtdReg > 0
        lExiste := .T.
        While .not. (cAliasEZX)->(Eof())
            nRecno := (cAliasEZX)->R_E_C_N_O_
            (cAliasEZX)->(DbSkip())
        End
        (cAliasEZX)->(DbCloseArea())
    Else 
        (cAliasEZX)->(DbCloseArea())
    EndIf

Return {lExiste,nRecno}

/*/{Protheus.doc} GetCodAprov
Verifica se Existe o substituto no grupo da regra criada.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function GetCodAprov(cCodSubst,cCodGrupo,cNivel,cCodSubTemp,cStatus,cTpExec)
//====================================================================================================

    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
    Local cAliasGRP := GetNextAlias()
    Local nQtdReg   := 0

    cQuery := " SELECT SAL.* "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += " WHERE SAL.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AL_COD = '"+AllTrim(cCodGrupo)+"' "+QbLinha

    If IsBlind()
        cQuery += " AND AL_APROV = '"+AllTrim(cCodSubst)+"' "+QbLinha
    Else 
        If cTpExec == "M" .and.  (.not. Empty(AllTrim(cCodSubTemp)) .and. Empty(AllTrim(cCodSubst)))
            cQuery += " AND AL_APROV = '"+AllTrim(cCodSubTemp)+"' "+QbLinha
        EndIf 
        If cTpExec == "M" .and.  (.not. Empty(AllTrim(cCodSubTemp)) .and. .not. Empty(AllTrim(cCodSubst)))
            cQuery += " AND AL_APROV = '"+AllTrim(cCodSubst)+"' "+QbLinha
        EndIf 
    EndIf 

    cQuery += " AND AL_NIVEL = '"+AllTrim(cNivel)+"' "+QbLinha
    cQuery += " ORDER BY AL_ITEM "+QbLinha

    MemoWrite("C:/ricardo/RT02JB01_GetCodAprov.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasGRP,.F.,.T.)
            
    DbSelectArea(cAliasGRP)
    (cAliasGRP)->(DbGoTop())
    Count To nQtdReg
    (cAliasGRP)->(DbGoTop())

    If nQtdReg > 0
        (cAliasGRP)->(DbCloseArea())
		Return .T.
    Else 
        (cAliasGRP)->(DbCloseArea())
    EndIf
Return .F. 

/*/{Protheus.doc} GetUserSAK
Busca o Usuario do Aprovador.
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Static Function GetUserSAK(cCodSubst)
//====================================================================================================

    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
    Local cAliasSAK := GetNextAlias()
    Local nQtdReg   := 0
    Local cCodUsr   := ""

    cQuery := " SELECT SAK.* "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SAK") + " SAK "+QbLinha
    cQuery += " WHERE SAK.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AK_COD = '"+AllTrim(cCodSubst)+"' "+QbLinha

    MemoWrite("C:/ricardo/RT02JB01_GetUserSAK.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSAK,.F.,.T.)
            
    DbSelectArea(cAliasSAK)
    (cAliasSAK)->(DbGoTop())
    Count To nQtdReg
    (cAliasSAK)->(DbGoTop())

    If nQtdReg <= 0
        (cAliasSAK)->(DbCloseArea())
    Else 
        cCodUsr := AllTrim((cAliasSAK)->AK_USER)
        (cAliasSAK)->(DbCloseArea())
    EndIf
Return cCodUsr
