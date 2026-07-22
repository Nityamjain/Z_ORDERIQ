CLASS lhc_ZI_Customer_IQ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Customer_IQ RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_Customer_IQ.

ENDCLASS.

CLASS lhc_ZI_Customer_IQ IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

METHOD earlynumbering_create.

  SELECT MAX( customer_id )
    FROM zcustomer_mstr
    INTO @DATA(lv_max_customer).

  DATA lv_number TYPE i.

  IF lv_max_customer IS INITIAL.
    lv_number = 1.
  ELSE.
    lv_number = CONV i( lv_max_customer+2(8) ) + 1.
  ENDIF.

  LOOP AT entities INTO DATA(ls_entity).

    APPEND VALUE #(
      %cid        = ls_entity-%cid
      %is_draft   = ls_entity-%is_draft
      customerid  = |CU{ lv_number WIDTH = 8 PAD = '0' }|
    ) TO mapped-zi_customer_iq.

    lv_number += 1.

  ENDLOOP.

ENDMETHOD.

ENDCLASS.
