#INCLUDE "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA080PE   �Autor  �Ismael Junior       � Data �  05/11/2021 ���
�������������������������������������������������������������������������͹��
���Desc.     � sera executado na saida da funcao de baixa, apos gravar    ���
���          � todos os dados e ap�s a contabiliza��o                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA080PE()
// Pesquisa tipo TX - 
        cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
        cUpdate += "WHERE E2_FILIAL = '" + SE2->E2_FILIAL + "' ""
        cUpdate += "AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
        cUpdate += "AND E2_NUM = '" + SE2->E2_NUM + "' "
        cUpdate += "AND E2_TIPO IN ('TX','INS','ISS') "
        //cUpdate += "AND E2_FORNECE = 'UNIAO' "
        //cUpdate += "AND E2_LOJA = '00' "
        cUpdate += "AND D_E_L_E_T_ != '*' "
        nFlag := TcSqlExec(cUpdate) 
Return(.T.)
