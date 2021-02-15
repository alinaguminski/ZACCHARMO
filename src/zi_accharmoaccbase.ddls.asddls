@AbapCatalog.sqlViewName: 'ZIACCHBASE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL account harm.: Full acct. incl. ccode'
define view ZI_AccHarmoAccBase 
       as select from zacc_4ccode          as GLAcc4CCode
       inner join zacc_prorglist           as OrgConversion
         on OrgConversion.project = GLAcc4CCode.project and
            OrgConversion.source  = GLAcc4CCode.source  and
            OrgConversion.bukrs   = GLAcc4CCode.bukrs
       inner join zacc_header              as GLAccHeader
         on GLAccHeader.project   = GLAcc4CCode.project and
            GLAccHeader.source    = GLAcc4CCode.source  and
            GLAccHeader.ktopl     = OrgConversion.ktopl and
            GLAccHeader.saknr     = GLAcc4CCode.saknr
       inner join zacc_text                as GLAccText
         on GLAccText.project     = GLAcc4CCode.project and
            GLAccText.source      = GLAcc4CCode.source  and
            GLAccText.spras       = 'E' and
            GLAccText.ktopl       = OrgConversion.ktopl and
            GLAccText.saknr       = GLAcc4CCode.saknr
       left outer to one join zacc_costcat as CostElement
         on CostElement.project   = GLAcc4CCode.project and
            CostElement.source    = GLAcc4CCode.source  and
            CostElement.kokrs     = OrgConversion.kokrs and
            CostElement.kstar     = GLAcc4CCode.saknr  
{
    key GLAcc4CCode.project as Project,
    key GLAcc4CCode.source  as Source,
    key OrgConversion.ktopl as ChartOfaccount,
    key GLAcc4CCode.bukrs   as CompanyCode,
    key GLAcc4CCode.saknr   as GLAccount,
        GLAccText.txt20     as shortText,
        GLAccHeader.xbilk   as isBalanceSheetAccount,
        GLAcc4CCode.begru   as AuthorizationGroup,
        GLAcc4CCode.erdat   as CreatedAt,
        GLAcc4CCode.ernam   as CreatedBy,
        GLAcc4CCode.mitkz   as Mitkz,
        GLAcc4CCode.mwskz   as Mwskz,
        GLAcc4CCode.xopvw   as Xopvw,
        GLAcc4CCode.xspeb   as Xspeb,
        GLAcc4CCode.xmwno   as Xmwno,
        OrgConversion.kokrs as ControllingArea,
        CostElement.katyp   as CostElementCategory
}
