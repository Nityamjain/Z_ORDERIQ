@EndUserText.label: 'Country Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_COUNTRY
  as select from I_CountryText
{
  key Country,
      CountryName
      
}
