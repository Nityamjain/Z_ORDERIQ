@EndUserText.label: 'Currency Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'CurrencyCode'

define view entity ZVH_CURRENCY
  as select distinct from zso_country
{
  key currency_code as CurrencyCode,
  country_name as CountryName
}
where is_active = 'X'
