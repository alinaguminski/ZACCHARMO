@AbapCatalog.sqlViewName: 'ZIACCHA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL account harmonization: Accounts'
@Search.searchable: true
@UI.headerInfo: { typeNamePlural: 'GL Account Worklist',
    typeName: 'GL Account', title: { value: 'Project' },
    description: { value: 'Project' }
 }

define root view ZI_AccHarmoAccounts
       as select from ZI_AccHarmoAccBase as GLAccBase
       left outer to one join zacc_mapping      as Mapping
         on Mapping.project    = GLAccBase.Project        and
            Mapping.source     = GLAccBase.Source         and
            Mapping.ktopl      = GLAccBase.ChartOfaccount and
            Mapping.bukrs      = GLAccBase.CompanyCode    and
            Mapping.saknr      = GLAccBase.GLAccount
       left outer to one join zacc_kttyp        as CategoryType
         on CategoryType.katyp = GLAccBase.CostElementCategory
       left outer to one join zacc_status       as Status
         on Status.project     = GLAccBase.Project        and
            Status.source      = GLAccBase.Source         and
            Status.ktopl       = GLAccBase.ChartOfaccount and
            Status.bukrs       = GLAccBase.CompanyCode    and
            Status.saknr       = GLAccBase.GLAccount
{
    @UI.facet: [ { id: 'idGeneralInformation', position: 10, label: 'Worklist',
                   type: #IDENTIFICATION_REFERENCE } ]
    
    @UI.lineItem: [{position: 10, label: 'Project' }, 
                   { type: #FOR_ACTION, dataAction: 'checkAccount',
                     label: 'Check Account', invocationGrouping: #ISOLATED, position: 10 } ] 
    key GLAccBase.Project        as Project,
    key GLAccBase.Source         as Source,
    @UI.lineItem: [{position: 30, label: 'Chart', importance: #HIGH }]
    @UI.identification: [{position: 30, label: 'Chart' }]
    key GLAccBase.ChartOfaccount as ChartOfAccount,
    @UI.lineItem: [{position: 33, label: 'CCode', importance: #HIGH }]
    @UI.identification: [{position: 33, label: 'CCode' }]
    @UI.selectionField: [{ position: 20 }]
    key GLAccBase.CompanyCode    as CompanyCode,
    @UI.lineItem: [{position: 36, label: 'Account', importance: #HIGH }]
    @UI.identification: [{position: 36, label: 'Account' }]
    @Search.defaultSearchElement: true
    key GLAccBase.GLAccount      as GLAccount,
    @UI.lineItem: [{position: 38, label: 'Text', importance: #HIGH }]
    @UI.identification: [{position: 38, label: 'Text' }]
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.7
        GLAccBase.shortText      as shortText,
    @UI.hidden: true
        isBalanceSheetAccount,
    @UI.hidden: true
        CostElementCategory,
    @UI.lineItem: [{position: 40, label: 'Type', importance: #HIGH }]
    @UI.identification: [{position: 40, label: 'Type' }]
    @UI.selectionField: [{ position: 10 }]
        case isBalanceSheetAccount
          when 'X' then
            case GLAccBase.Mitkz
              when 'A' then 'BS Asset'
              when 'D' then 'BS Customers'
              when 'K' then 'BS Vendors'
              when 'V' then 'BS Receiv.'
              else          'BS'
            end
          when ' ' then
            case CostElementCategory
              when '  ' then 'NonOperating'
              else CategoryType.acctype
            end
          end as AccountType,
    @UI.lineItem: [{position: 60, label: 'new Chart', importance: #MEDIUM }]
    @UI.identification: [{position: 60, label: 'new Chart' }]
        case trgktopl
          when ''       then GLAccBase.ChartOfaccount
          else               trgktopl
        end             as   TargetChartOfAccount,
    @UI.lineItem: [{position: 63, label: 'new CCode', importance: #MEDIUM }]
    @UI.identification: [{position: 63, label: 'new CCode' }]
        case trgbukrs
          when ''       then GLAccBase.ChartOfaccount
          else               trgbukrs
        end             as   TargetCompanyCode,
    @UI.lineItem: [{position: 66, label: 'new Account', importance: #MEDIUM }]
    @UI.identification: [{position: 66, label: 'new Account' }]
        case trgsaknr
          when ''       then GLAccBase.ChartOfaccount
          else               trgsaknr
        end             as   TargetGLAccount,
    @UI.hidden: true 
    case //when status = 'C' then 1
         //when status = 'A' then 2
         when GLAccount = '0000002000' then 2
         else 0 end as StatusCriticality, 
    @UI.lineItem: [{position: 70, label: 'Status', importance: #HIGH,
                    criticality: 'StatusCriticality', criticalityRepresentation: #WITHOUT_ICON }]
    @UI.identification: [{position: 70, label: 'Status' }] 
    case //when status = 'C' then 1
         //when status = 'A' then 2
         when GLAccount = '0000002000' then
        cast( 'C' as abap.char(1) ) end as Status,
        //status          as   Status,
    @UI.lineItem: [{position: 74, label: 'Comment', importance: #LOW }]
    @UI.identification: [{position: 74, label: 'Comment' }]
        remark          as   Remark     
}
