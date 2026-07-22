@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_ORDER_STATUS
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
    p_domain_name: 'ZSO_HDR_STATUS'
  )
{
  key value_low as OrderStatus,

  @Semantics.text: true
  text as OrderStatusText
}
