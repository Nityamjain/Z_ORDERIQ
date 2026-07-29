@EndUserText.label: 'Country Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_COUNTRY
  as select from zso_country
{
  key country_code  as CountryCode,
      country_name  as CountryName,
      currency_code as CurrencyCode
}
