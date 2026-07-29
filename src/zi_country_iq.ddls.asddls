@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_Country_iq as select from zso_country
{
    key country_code as CountryCode,
    country_name as CountryName,
    currency_code as CurrencyCode,
    is_active as IsActive,
    created_by as CreatedBy,
    created_at as CreatedAt,
    changed_by as ChangedBy,
    changed_at as ChangedAt
}
