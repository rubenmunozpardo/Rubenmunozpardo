{{ config(materialized='table') }}

with customer as (
    select  
        C_CUSTKEY,    
        C_NAME,
        C_ADDRESS,
        C_NATIONKEY,
        C_PHONE,
        C_ACCTBAL,
        C_MKTSEGMENT,
        C_COMMENT
    from TPCH_SF1.CUSTOMER
)
select *
from customer