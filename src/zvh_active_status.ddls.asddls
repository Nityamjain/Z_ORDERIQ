@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_ACTIVE_STATUS
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
    p_domain_name: 'ZACTIVE_FLAG'
  )
{
  key value_low as ActiveStatus,

  @Semantics.text: true
  text as ActiveStatusText
}
