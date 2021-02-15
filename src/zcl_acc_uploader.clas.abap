CLASS zcl_acc_uploader DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
    CLASS-METHODS resolve_destination CHANGING c_rfcdest TYPE rfcdest.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_acc_uploader IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
  ENDMETHOD.
  METHOD resolve_destination.
      data lo_rfcdest type REF TO if_rfc_dest.
      TRY. "|bp7210_RFC| |w17200_RFC| |m2x300_RFC|
          lo_rfcdest =
               cl_rfc_destination_provider=>create_by_cloud_destination( i_name = CONV string( c_rfcdest ) ).
          c_rfcdest = lo_rfcdest->get_destination_name( ).
        CATCH cx_root INTO DATA(lx_root).

      ENDTRY.
  ENDMETHOD.
ENDCLASS.
