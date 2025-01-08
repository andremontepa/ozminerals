#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F050MDVC
    Ponto de entrada para alterar regra de data de vencimento do PCC
    @type  User Function
    @author Stephen Noel - Equilibrio T.I.
    @since 04/01/2024
    @version 1.0
/*/

USER FUNCTION F050MDVC()

    Local dVencRea := daysum(monthsum(ParamIXB[3],1),20-day(ParamIXB[3]))
   
RETURN dVencRea
