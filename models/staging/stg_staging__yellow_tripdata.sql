with source as (

    select * from {{ source('staging', 'yellow_tripdata') }}

),

renamed as (

    select
        -- Identifiers
        {{ dbt_utils.generate_surrogate_key(['vendorid', 'tpep_pickup_datetime']) }} as tripid,
        cast(vendorid as integer) as vendorid,
        cast(ratecodeid as integer) as ratecodeid,
        cast(pulocationid as integer) as pickup_locationid,
        cast(dolocationid as integer) as dropoff_locationid,

        -- Timestamps
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

        -- Trip info
        store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        cast(1 as integer) as trip_type, -- Taxis amarillos son por defecto trip_type 1 (Street-hail)

        -- Payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(0 as numeric) as ehail_fee, -- No aplica a taxis amarillos
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric) as total_amount,
        cast(payment_type as integer) as payment_type,
        {{ get_payment_type_description('payment_type') }} as payment_type_description,
        cast(congestion_surcharge as numeric) as congestion_surcharge

    from source
    where vendorid is not null

)

select * from renamed

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}