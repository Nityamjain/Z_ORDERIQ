@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Country_iq as projection on ZI_Country_iq
{
    key CountryCode,
    CountryName,
    CurrencyCode,
    IsActive,
    CreatedBy,
    CreatedAt,
    ChangedBy,
    ChangedAt
}
