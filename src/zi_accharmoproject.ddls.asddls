//@VDM.viewType: #BASIC
@AbapCatalog.sqlViewName: 'ZIACCHP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL account harmonization: Project'
//@Analytics.dataCategory: #DIMENSION
define root view ZI_AccHarmoProject 
       as select from zacc_project               as ProjectSource
       composition [0..*] of ZI_AccHarmoOrgUnits as _SourceOrgUnits
{
  @UI.facet: [
  { id: 'idGeneralInformation',
    position: 10,
    label: 'General Information',
    type: #IDENTIFICATION_REFERENCE },
  { id: 'idSource',
    position: 20,
    label: 'Source Definition',
    type: #LINEITEM_REFERENCE,
    targetElement: '_SourceOrgUnits' } ]
    
    @UI.lineItem: [{position: 10, label: 'Project' }, 
                   { type: #FOR_ACTION, dataAction: 'uploadOrgList',
                   label: 'Upload OrgUnits', position: 10 }, 
                   { type: #FOR_ACTION, dataAction: 'uploadAccounts',
                   label: 'Upload Accounts', position: 20 } ]
    @UI.identification: [{position: 10, label: 'Project' }]
    key project as Project,
    @UI.lineItem: [{position: 30, label: 'Source' }]
    @UI.identification: [{position: 30, label: 'Source' }]
    key source  as Source,
    @UI.lineItem: [{position: 20, label: 'Description' }]
    @UI.identification: [{position: 20, label: 'Description' }]
    description as Description,
    @UI.lineItem: [{position: 40, label: 'Business System' }]
    @UI.identification: [{position: 40, label: 'Business System' }]
    bussystem   as BusinessSystem,
    @UI.lineItem: [{position: 50, label: 'RFC Destination' }]
    @UI.identification: [{position: 50, label: 'RFC Destination' }]
    destination as Destination,
    //@ObjectModel.association.type: [#TO_COMPOSITION_CHILD]
    _SourceOrgUnits
}
