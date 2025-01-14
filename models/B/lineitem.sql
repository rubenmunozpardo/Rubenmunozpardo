{{ config(materialized='table') }}

with lineitem as (
    select  
	L_ORDERKEY,
	L_PARTKEY,
	L_SUPPKEY,
	L_LINENUMBER,
	L_QUANTITY,
	L_EXTENDEDPRICE,
	L_DISCOUNT,
	L_TAX,
	L_RETURNFLAG,
	L_LINESTATUS,
	L_SHIPDATE,
	L_COMMITDATE,
	L_RECEIPTDATE,
	L_SHIPINSTRUCT,
	L_SHIPMODE,
	L_COMMENT
    from TPCH_SF1.LINEITEM
)
select *
from lineitem