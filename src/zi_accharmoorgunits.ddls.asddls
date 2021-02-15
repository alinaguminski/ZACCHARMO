@AbapCatalog.sqlViewName: 'ZIACCHPO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL account harmonization: Org. units'
define view ZI_AccHarmoOrgUnits
       as select from zacc_prorglist            as SourceOrgUnits
       association to parent ZI_AccHarmoProject as _ProjectSource
         on $projection.Project = _ProjectSource.Project and
            $projection.Source  = _ProjectSource.Source
{
  @UI.facet: [
  { id: 'idSource',
    position: 10,
    label: 'Source Definition',
    type: #IDENTIFICATION_REFERENCE } ]

    @UI.lineItem: [{position: 10, label: 'Project' }]
    @UI.identification: [{position: 10, label: 'Project' }]
    key project as Project,
    @UI.lineItem: [{position: 20, label: 'Source' }]
    @UI.identification: [{position: 20, label: 'Source' }]
    key source  as Source,
    @UI.lineItem: [{position: 30, label: 'Company Code' }]
    @UI.identification: [{position: 30, label: 'Company Code' }]
    key bukrs   as CompanyCode,
    @UI.lineItem: [{position: 40, label: 'Controlling Area' }]
    @UI.identification: [{position: 40, label: 'Controlling Area' }]
        kokrs   as ControllingArea,
    @UI.lineItem: [{position: 50, label: 'Chart of Account' }]
    @UI.identification: [{position: 50, label: 'Chart of Account' }]
        ktopl   as ChartOfAccount,
    //@ObjectModel.association.type: [#TO_COMPOSITION_ROOT,#TO_COMPOSITION_PARENT]
    _ProjectSource
}
