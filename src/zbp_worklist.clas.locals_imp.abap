*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lhc_worklist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS checkAccount  FOR MODIFY IMPORTING it_keys
                          FOR ACTION WorkList~checkAccount  RESULT rt_result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WorkList RESULT result.
    "METHODS checkAccount FOR FEATURES
    "        IMPORTING it_keys REQUEST requested_features FOR WorkList RESULT result.
ENDCLASS.

CLASS lhc_worklist IMPLEMENTATION.
  METHOD checkAccount.
    TYPES: BEGIN OF t_acc_keys,
             src_logsys(10) TYPE c,
             src_ktopl(4)   TYPE c,
             src_bukrs(4)   TYPE c,
             src_saknr(10)  TYPE c,
             trg_logsys(10) TYPE c,
             trg_ktopl(4)   TYPE c,
             trg_bukrs(4)   TYPE c,
             trg_saknr(10)  TYPE c,
           END   OF t_acc_keys,
           BEGIN OF t_result,
             tab_name(16)   TYPE c,
             field_name(30) TYPE c,
             field_val(160) TYPE c,
             type(1)        TYPE c,
             text(200)      TYPE c,
           END   OF t_result.
    DATA: ls_source  TYPE zi_accharmoaccounts,
          ls_acc_key TYPE t_acc_keys,
          lt_acc_key TYPE TABLE OF t_acc_keys,
          ls_result  TYPE t_result,
          lt_result  TYPE TABLE OF t_result.
    DATA: l_rfcdest TYPE rfcdest.
    FIELD-SYMBOLS: <keys> TYPE any.

    READ TABLE it_keys ASSIGNING <keys> INDEX 1.
    CHECK sy-subrc = 0.
    MOVE-CORRESPONDING <keys> TO ls_source.

    zcl_acc_uploader=>resolve_destination( CHANGING c_rfcdest = l_rfcdest ).
    CHECK l_rfcdest IS NOT INITIAL.

    ls_acc_key-src_ktopl = ls_source-ChartOfAccount.
    ls_acc_key-src_bukrs = ls_source-CompanyCode.
    ls_acc_key-src_saknr = ls_source-GLAccount.
    APPEND ls_acc_key TO lt_acc_key.
    CALL FUNCTION '/DMT/CC_GL_VALIDATE' DESTINATION l_rfcdest
      EXPORTING
        it_data   = lt_acc_key
      IMPORTING
        et_result = lt_result.

  ENDMETHOD.
  METHOD get_instance_features.
  check 1 = 2.
  ENDMETHOD.

ENDCLASS.
