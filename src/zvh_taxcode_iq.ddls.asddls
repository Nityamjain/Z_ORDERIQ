@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_TAXCODE_IQ
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
    p_domain_name: 'ZTAX_CODE'
  )
{
  key value_low as TaxCode,

  @Semantics.text: true
  text as TaxCodeText
}
