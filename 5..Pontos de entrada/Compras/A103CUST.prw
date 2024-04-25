
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103CUST  ºAutor  ³ Toni Aguiar        º Data ³  23/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o custo do produto pelo DOC. DE ENTRADA acrescentandoº±±
±±º          ³ 35% de deságio, caso configure a TES F4_CREDICM='S' e      º±±
±±º          ³ F4_XDESGI='S', do contrário, assume o custo padrão.        º±±
±±º          ³                                                            º±±
±±º          ³ O Kardex ficará com o laçamento ajustado automaticamente   º±±
±±º          ³ já acrescentado os 35%.                                    º±±
±±º          ³ Em relação ao LP contábil, este deve ser configurado para  º±±
±±º          ³ contabilizar o valor de deságio debitando a conta de estoqueº±±
±±º          ³ e creditando a conta de ICMS A RECUPERAR.                  º±±
±±º          ³                                                            º±±
±±º          ³ Fiscalmente não muda nada do padrão, será modificado apenasº±±
±±º          ³ o custo de entrada no kardex e na contabilidade.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A103CUST 
Local aRet  := PARAMIXB[1]
Local nIcms := SD1->D1_VALICM

If SF4->F4_ESTOQUE="S" .And. SF4->F4_CREDICMS=='S' .And. SF4->F4_XDESAGI=='S'
   aRet[1][1]+=NoRound((nIcms * 100)/100,2) 
   aRet[1][2]+=nIcms/RecMoeda(dDataBase,2)  
Endif

Return aRet
