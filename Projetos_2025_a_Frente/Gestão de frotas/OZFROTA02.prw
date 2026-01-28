#include"Protheus.ch"
#include"tbiconn.ch"

// TPA  - Etapas
// TPF  - Manutenção Padrão
// TPH  - Etapas de Manutenção?

User Function zImpmanut()
    Local aArea    := GetArea()
    Public cArqOri := ""
  
    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )
      
    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)
          
        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| fImpmanut() }, "Importando...")
        Else
            MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
        EndIf
    EndIf
      
     RestArea(aArea)
 Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 | Layout csv : produto / localm / custo                                         |
 *-------------------------------------------------------------------------------*/
  Static Function fImpmanut()
    Local aArea      := GetArea()
    Local cArqLog    := "fImpmanut_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0

    Local cCodbem    := ""  // Código do Bem
    Local cServic    := ""  // Código do Serviço
    Local nSequen    := 0   // Sequência da Manutenção

    Local cCodbem1   := ""  // Código do Bem
    Local cServic1   := ""  // Código do Serviço
    Local nSequen1   := "000"
    Local cTarefa    := ""  // Tarefa
    Local cDestar    := ""  // Descrição da Tarefa
    Local cEtapa     := ""  // Etapa
    Local nSeqta     := 0   // Sequência da Etapa
    Local dDatma     := ""  // Data da última manutenção
    Local cNomema    := ""  // Nome da Manutenção 
    Local cTioaco    := ""  // Tipo de Acompanhamento
    Local cCalema    := ""  // Calendário da Manutenção
    Local cMandia    := ""  // Dia não útil ?
    Local nDiasma    := 0   // Numero de Dias da Manutenção
    Local cUniman    := ""  // Unidade da Manutenção
    Local nTolman    := 0   // Tempo tolerância da manutenção
    Local cParman    := ""  // Necessita de parada ?
    Local cPriman    := ""  // Prioridade da Manutenção
    Local cPerman    := ""  // Periocidade da Manutenção
    Local cDesman    := ""  // Descrição detalahda da manutenção
    Local hIncrem    := 0   // Horas incremento manutenção
    Local nTama      := 0
           
    Local oArquivo
    Local aLinhas
    Local aLinha       := {}
    Local aItem        := {}
    Public lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Public lMsErroAuto := .f. //necessario a criacao
    Public cDirLog     := GetTempPath() + "importacao\"
    Public cLog        := ""
      
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
If (oArquivo:Open())
    //Se não for fim do arquivo
    If ! (oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            //Enquanto tiver linhas
While (oArquivo:HasLine())
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")
                if substring(cLinAtu,1,1)=";"
                exit 
                endif

                //Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
If ! "codbem" $ Lower(cLinAtu) .and. substring(cLinAtu,1,1)<>";"
  
                    //Zera as variaveis
                    aItem := {}
                        
                        cCodbem     := aLinha[1]  // Código do Bem
                        cServic     := aLinha[2]  // Código do Serviço
                        nSequen     := aLinha[3]  // Sequência da Manutenção
                        cTarefa     := aLinha[4]  // Tarefa
                        cEtapa      := aLinha[5]  // Etapa
                        nSeqta      := aLinha[6]  // Sequência da Etapa
                        dDatma      := aLinha[7]  // Data da última manutenção
                        cNomema     := aLinha[8]  // Nome da Manutenção 
                        cTioaco     := aLinha[9]  // Tipo de Acompanhamento
                        cCalema     := aLinha[10] // Calendário da Manutenção
                        cMandia     := aLinha[11] // Dia não útil ?
                        nDiasma     := aLinha[12] // Numero de Dias da Manutenção
                        cUniman     := aLinha[13] // Unidade da Manutenção
                        nTolman     := aLinha[14] // Tempo tolerância da manutenção
                        cParman     := aLinha[15] // Necessita de parada ?
                        cPriman     := aLinha[16] // Prioridade da Manutenção
                        cPerman     := aLinha[17] // Periocidade da Manutenção
                        cDesman     := aLinha[18] // Descrição detalahda da manutenção
                        hIncrem     := aLinha[19] // Horas Incremento manutenção

                        nTama       := 16-len(alltrim(cCodbem))
                        cCodbem     := alltrim(cCodbem)+space(nTama)
                      
                        nTama       := 6-len(alltrim(cServic))
                        cServic     := alltrim(cServic)+space(nTama)

                        nSequen     := strzero(val(nSequen),3,0)  // Sequência da Manutenção
                        nSeqta      := strzero(val(nSeqta),3,0)   // Sequência da Etapa

                        nTama       := 6-len(alltrim(cTarefa))
                        cTarefa     := alltrim(cTarefa)+space(nTama)

                        nTama       := 6-len(alltrim(cEtapa))
                        cEtapa      := alltrim(cEtapa)+space(nTama)

                        

                           
    DbSelectArea("TPA")
    DbSetOrder(1)
    If Dbseek(xFilial("TPA")+cEtapa)    // Verifica se a Etapa Existe !    
    
        DbSelectArea("TT9")
	    DbSetOrder(1)
        If Dbseek(xFilial("TT9")+cTarefa)   // Verifica se a Tarefa Existe !
        cDestar := TT9->TT9_DESCRI

            DbSelectArea("ST9") 
		    DbSetOrder(1)   
            If Dbseek(xFilial("ST9")+cCodbem)   // Verifica se o Bem Existe !
           
                DbSelectArea("ST4")
			    DbSetOrder(1)   
                If Dbseek(xFilial("ST4")+cServic)   // Verifica se o Serviço Existe !
                cCdarea     := ST4->T4_CODAREA   
                cTipoma     := ST4->T4_TIPOMAN

                    DbSelectArea("SH7")
			        DbSetOrder(1)   
                    If Dbseek(xFilial("SH7")+cCalema)   // Verifica se o Calendário existe !
  

                      If cCodbem1 <> cCodbem .and. cServic1 <> cServic .and. nSequen <> nSequen1  // Verifica se é a primeira linha da Manuteação
                            //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Exclui as Manutenções Registradas //
                             //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
                             DbSelectArea("STF")
			                 DbSetOrder(1)
                             Dbgotop()
                             If Dbseek(xFilial("STF")+cCodbem+cServic+nSequen)
                             While STF->TF_CODBEM == cCodbem .and. STF->TF_SERVICO == cServic .and. STF->TF_SEQRELA == nSequen .and. !EOF()
                             RecLock("STF", .F.)
                             DbDelete()
                             STF->( MsUnlock() )
                             Dbskip()
                             Enddo
                             Endif

                             //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Exclui as Tarefas Registradas //
                             //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

                             DbSelectArea("ST5")
		                     DbSetOrder(7)
                             If Dbseek(xFilial("ST5")+cCodbem+cServic+nSequen)
                             While ST5->T5_CODBEM == cCodbem .and. ST5->T5_SERVICO == cServic .and.  ST5->T5_SEQRELA == nSequen .and. !EOF()
                             RecLock("ST5", .F.)
                             DbDelete()
                             ST5->( MsUnlock() )
                             Dbskip()
                             Enddo
                             Endif
                             //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Exclui as Etapas Registradas //
                             //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
                             DbSelectArea("STH")
			                 DbSetOrder(5)
                             If Dbseek(xFilial("STH")+cCodbem+cServic+nSequen+cTarefa)
                                While STH->TH_CODBEM ==cCodbem .and. STH->TH_SERVICO == cServic .and. STH->TH_SEQRELA == nSequen .and. !EOF()
                                  //  If STH->TH_SEQRELA == nSeqta  // Exclui a Sequência anterior da Etapa
                                    RecLock('STH', .F.)
                                    DbDelete()
                                    STH->( MsUnlock() )
                                  //  Endif
                                Dbskip()
                                Enddo
                             Endif
                        // Iguala as variáveis de Controle
                        cCodbem1 := cCodbem
                        cServic1 := cServic
                        cSequen1 := nSequen

                      Endif

                             
                        DbSelectArea("STF")
			            DbSetOrder(1)
                        Dbgotop()

                        If !Dbseek(xFilial("STF")+cCodbem+cServic+nSequen) // Verifica se já existe na Filial
                             RecLock("STF", .T.)
                            // cCodbem1   := cCodbem  // Código do Bem
                            // cServic1   := cServic  // Código do Serviço
                            // nSequen1   := nSequen  // Sequência da Manutenção
                             STF->TF_FILIAL  := cFilAnt    // Filial
                             STF->TF_CODBEM  := cCodbem    // Código do Bem
                             STF->TF_SERVICO := cServic    // Código do Serviço
                             STF->TF_SEQRELA := nSequen    // Sequência da Manutenção
                             STF->TF_DTULTMA := ctod(dDatma)     // Data da última Manutenção
                             STF->TF_NOMEMAN := cNomema    // Nome da Manutenção
                             STF->TF_CODAREA := cCdarea    // Código da área
                             STF->TF_TIPO    := cTipoma    // Tipo de Manutenção
                             STF->TF_TIPACOM := cTioaco    // Tipo acompanhamento T=Tempo / C=Contador / A-Tempo e Contador / P=Produção / F=Contador Fixo / S=Segundo contador
                             STF->TF_CALENDA := cCalema    // Calendário
                             STF->TF_NAOUTIL := cMandia    // Dia não útil  A=Antecipa / T=Atrasa / U-Utiliza dia
                             STF->TF_TEENMAN := val(nDiasma)    // Dias de Manutenção
                             STF->TF_UNENMAN := cUniman    // Unidade de Manutenção H=Horas / D=Dias / S=Semana / M=Meses
                             STF->TF_TOLERA  := val(nTolman)    // Tolerância de Tempo em Dias
                             STF->TF_PARADA  := cParman    // Necessita parada do Bem ? S=Sim / N=Não / T=Todos
                             STF->TF_PRIORID := cPriman    // Prioridade
                             STF->TF_PERIODO := cPerman    // Periocidade da Manutenção R=Repetitiva / U=Unica / E=Eventual
                             STF->TF_DESCRIC := cDesman    // Descrição detalhada da Manutenção
                             if cTioaco="C" .or. cTioaco="S"
                             STF->TF_INENMAN := val(hIncrem)    // Horas incremento manutenção
                             Else
                             STF->TF_INENMAN := 0         // Horas incremento manutenção
                             Endif
                             STF->TF_CONMANU := 1
                             STF->TF_PADRAO  := "N"        // Manutenção Padrão = N -> fixa opção
                             STF->TF_ATIVO   := "S"        // Indica se a Manutenção está Ativa = S -> fixa opção 
                             STF->( MsUnlock() )
                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Grava a Tarefa do Bem //
                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                            
                             RecLock("ST5", .T.)
                             ST5->T5_FILIAL  := cFilAnt    // Filial
                             ST5->T5_CODBEM  := cCodbem    // Código do Bem
                             ST5->T5_SERVICO := cServic    // Código do Serviço
                             ST5->T5_SEQRELA := nSequen    // Sequência da Manutenção
                             ST5->T5_TAREFA  := cTarefa    // Tarefa
                             ST5->T5_DESCRIC := cDestar    // Descrição da Tarefa
                             ST5->T5_SEQUENC := 0          // Sequência
                             ST5->T5_ATIVA   := "1"        // Ativa
                             ST5->( MsUnlock() )
                            
                             
                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Grava a primeira Etapa //
                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                             RecLock('STH', .T.)  // Inclui a Primeira Etapa
                             STH->TH_FILIAL  := cFilAnt    // Filial
                             STH->TH_CODBEM  := cCodbem    // Código do Bem
                             STH->TH_SERVICO := cServic    // Código do Serviço
                             STH->TH_SEQRELA := nSequen    // Sequência da Etapa
                             STH->TH_TAREFA  := cTarefa    // Tarefa
                             STH->TH_ETAPA   := cEtapa     // Etapa
                             STH->TH_OPCOES  := "0"        // Opções
                             STH->TH_SEQETA  := strzero(val(nSeqta),3,0)      // Sequência Etapa
                             STH->( MsUnlock() )
                           
                        Else
                             RecLock("STF", .F.)
                           //  cCodbem1   := cCodbem  // Código do Bem
                           //  cServic1   := cServic  // Código do Serviço
                           //  nSequen1   := nSequen  // Sequência da Manutenção
                             STF->TF_FILIAL  := cFilAnt    // Filial
                             STF->TF_CODBEM  := cCodbem    // Código do Bem
                             STF->TF_SERVICO := cServic    // Código do Serviço
                             STF->TF_SEQRELA := nSequen    // Sequência da Manutenção
                             STF->TF_DTULTMA := ctod(dDatma)     // Data da última Manutenção
                             STF->TF_NOMEMAN := cNomema    // Nome da Manutenção
                             STF->TF_CODAREA := cCdarea    // Código da área
                             STF->TF_TIPO    := cTipoma    // Tipo de Manutenção
                             STF->TF_TIPACOM := cTioaco    // Tipo acompanhamento T=Tempo / C=Contador / A-Tempo e Contador / P=Produção / F=Contador Fixo / S=Segundo contador
                             STF->TF_CALENDA := cCalema    // Calendário
                             STF->TF_NAOUTIL := cMandia    // Dia não útil  A=Antecipa / T=Atrasa / U-Utiliza dia
                             STF->TF_TEENMAN := val(nDiasma)    // Dias de Manutenção
                             STF->TF_UNENMAN := cUniman    // Unidade de Manutenção H=Horas / D=Dias / S=Semana / M=Meses
                             STF->TF_TOLERA  := val(nTolman)    // Tolerância de Tempo em Dias
                             STF->TF_PARADA  := cParman    // Necessita parada do Bem ? S=Sim / N=Não / T=Todos
                             STF->TF_PRIORID := cPriman    // Prioridade
                             STF->TF_PERIODO := cPerman    // Periocidade da Manutenção R=Repetitiva / U=Unica / E=Eventual
                             STF->TF_DESCRIC := cDesman    // Descrição detalhada da Manutenção
                             if cTioaco="C" .or. cTioaco="S"
                             STF->TF_INENMAN := val(hIncrem)    // Horas incremento manutenção
                             Else
                             STF->TF_INENMAN := 0         // Horas incremento manutenção
                             Endif
                             STF->TF_PADRAO  := "N"        // Manutenção Padrão = N -> fixa opção
                             STF->TF_ATIVO   := "S"        // Indica se a Manutenção está Ativa = S -> fixa opção 
                             STF->( MsUnlock() )

                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                             // Grava a Tarefa do Bem //
                             //%%%%%%%%%%%%%%%%%%%%%%%%//
                             DbSelectArea("ST5")
		                     DbSetOrder(1)
                             If Dbseek(xFilial("ST5")+cCodbem+cServic+nSequen+cTarefa)
                             RecLock("ST5", .F.)
                             else
                             RecLock("ST5", .T.)
                             Endif
                                ST5->T5_FILIAL  := cFilAnt    // Filial
                                ST5->T5_CODBEM  := cCodbem    // Código do Bem
                                ST5->T5_SERVICO := cServic    // Código do Serviço
                                ST5->T5_SEQRELA := nSequen    // Sequência da Manutenção
                                ST5->T5_TAREFA  := cTarefa    // Tarefa
                                ST5->T5_DESCRIC := cDestar    // Descrição da Tarefa
                                ST5->T5_SEQUENC := 0          // Sequência
                                ST5->T5_ATIVA   := "1"        // Ativa
                                ST5->( MsUnlock() )
                             //%%%%%%%%%%%%%%%%%//
                             // Grava as Etapas //
                             //%%%%%%%%%%%%%%%%%%//
                             DbSelectArea("STH")
			                 DbSetOrder(1)
                             If Dbseek(xFilial("STH")+cCodbem+cServic+nSequen+cTarefa+cEtapa)
                             RecLock("STH", .F.)
                             else
                             RecLock("STH", .T.)
                             Endif
                                STH->TH_FILIAL  := cFilAnt    // Filial
                                STH->TH_CODBEM  := cCodbem    // Código do Bem
                                STH->TH_SERVICO := cServic    // Código do Serviço
                                STH->TH_SEQRELA := nSequen    // Sequência da Etapa
                                STH->TH_TAREFA  := cTarefa    // Tarefa
                                STH->TH_ETAPA   := cEtapa     // Etapa
                                STH->TH_OPCOES  := "0"        // Opções
                                STH->TH_SEQETA  := strzero(val(nSeqta),3,0)     // Sequência Etapa
                                STH->( MsUnlock() )
                        Endif    
                            
                    else
                    msgalert("Item não Importado Calendário ->> "+cCalema+" não cadastrado!!")
                    Endif
                else
                msgalert("Item não Importado Serviço ->> "+cServic+" não cadastrado!!")
                Endif   
            else
            msgalert("Item não Importado Bem ->> "+cCodbem+" não cadastrado!!")
            Endif       
        else
        msgalert("Item não Importado Tarefa ->> "+cTarefa+" não cadastrada!!")
        Endif
    else
    msgalert("Item não Importado Etapa ->> "+cEtapa+" não cadastrada!!")
    Endif
EndIf
EndDo
    
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
    Else
    MsgStop("Arquivo não tem conteúdo!", "Atenção")
    EndIf
    //Fecha o arquivo
    oArquivo:Close()
Else
MsgStop("Arquivo não pode ser aberto!", "Atenção")
EndIf
  
RestArea(aArea)
Return

