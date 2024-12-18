-- CTEs: LIMPIAR, EVENTO, CAMBIO_MONEDA, PLAZO_ENTREGA, NATION
with
    limpiar as (
        select
            o_orderkey,
            o_custkey,
            o_orderstatus,
            o_totalprice,
            o_orderdate,
            o_orderpriority,
            o_clerk,
            o_shippriority,
            o_comment,
            cast(regexp_substr(o_clerk, '[0-9]+') as integer) as clerk_id
        from {{ ref("orders") }}
        where o_orderstatus in ('F', 'O')
    ),

    evento as (
        select
            o_orderkey,
            case
                when o_orderdate between '2023-11-01' and '2023-11-30'
                then 'Black Friday'
                when o_orderdate between '2023-12-01' and '2023-12-31'
                then 'Navidad'
                else 'Sin Evento'
            end as id_evento
        from {{ ref("orders") }}
    ),

    cambio_moneda as (
        select 'UNITED STATES' as pais, 1.0 as tasa_cambio
        union all
        select 'IRAN' as pais, 20.0 as tasa_cambio
        union all
        select 'CANADA' as pais, 1.3 as tasa_cambio
    ),

    plazo_entrega as (
        select
            l_orderkey,
            case
                when datediff(day, l_commitdate, l_receiptdate) > 10
                then 0
                when datediff(day, l_commitdate, l_receiptdate) <= 0
                then 1
                else 2
            end as id_plazo_entrega
        from {{ ref("lineitem") }}
    ),

    nation as (select n_nationkey, n_name from {{ ref("nation") }})

-- QUERY PRINCIPAL
select
    c.c_custkey,
    c.c_name,
    p.p_partkey,
    p.p_name,
    l.l_quantity,
    l.l_extendedprice,
    limpiar.o_orderdate,
    limpiar.clerk_id,
    case
        when l.l_returnflag = 'A'
        then 'Devolución'
        when l.l_returnflag = 'N'
        then 'Venta'
    end as tipo_operacion,
    t.tienda,
    t.pais_tienda,
    e.id_evento,
    l.l_extendedprice * cm_tienda.tasa_cambio as total_amount_tienda,
    l.l_extendedprice * cm_cliente.tasa_cambio as total_amount_cliente,
    convert_timezone(t.pais_tienda, 'UTC', limpiar.o_orderdate) as order_date_tienda,
    convert_timezone(n.n_name, 'UTC', limpiar.o_orderdate) as order_date_cliente,
    pz.id_plazo_entrega
from limpiar

-- JOINS (Aquí creo que está el problema)
-- lineitem con limpiar:
join {{ ref("lineitem") }} l on limpiar.o_orderkey = l.l_orderkey
-- customer con limpiar:
join {{ ref("customer") }} c on limpiar.o_custkey = c.c_custkey
-- part con lineitem:
join {{ ref("part") }} p on l.l_partkey = p.p_partkey
-- tienda con limpiar:
join {{ ref("tienda") }} t on limpiar.o_orderkey = t.o_orderkey
-- evento con limpiar:
join evento e on limpiar.o_orderkey = e.o_orderkey
-- cambio_moneda con tienda:
join cambio_moneda cm_tienda on t.pais_tienda = cm_tienda.pais
-- nation con customer:
join nation n on c.c_nationkey = n.n_nationkey
-- cambio_moneda con nation:
join cambio_moneda cm_cliente on n.n_name = cm_cliente.pais
-- plazo_entrega con lineitem:
join plazo_entrega pz on l.l_orderkey = pz.l_orderkey