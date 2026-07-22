@EndUserText.label: 'Customer Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'CustomerId'
define view entity ZVH_CUSTOMER
  as select from zcustomer_mstr
{
  key customer_id   as CustomerId,
      customer_name as CustomerName
}
