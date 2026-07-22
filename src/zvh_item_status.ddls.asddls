@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_ITEM_STATUS
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
    p_domain_name: 'ZSO_ITM_STATUS'
  )
{
  key value_low as ItemStatus,

  @Semantics.text: true
  text as ItemStatusText
}
