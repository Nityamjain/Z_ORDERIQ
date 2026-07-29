CLASS lhc_ZI_Country_iq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Country_iq RESULT result.
    METHODS derivecountryname FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_country_iq~derivecountryname.


ENDCLASS.

CLASS lhc_ZI_Country_iq IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


 METHOD DeriveCountryName.

  READ ENTITIES OF zi_country_iq IN LOCAL MODE
    ENTITY ZI_Country_iq
    FIELDS ( CountryCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_country).

  DATA lt_update TYPE TABLE FOR UPDATE zi_country_iq.

  LOOP AT lt_country INTO DATA(ls_country).

    SELECT SINGLE CountryName
      FROM I_CountryText
      WHERE Country  = @ls_country-CountryCode
        AND Language = @sy-langu
      INTO @DATA(lv_country_name).

    IF sy-subrc = 0.

      APPEND VALUE #(
        %tky        = ls_country-%tky
        CountryName = lv_country_name
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  MODIFY ENTITIES OF zi_country_iq IN LOCAL MODE
    ENTITY ZI_Country_iq
    UPDATE FIELDS ( CountryName )
    WITH lt_update.

ENDMETHOD.


ENDCLASS.
