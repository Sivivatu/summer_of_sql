-- Week 1 preppin' data project
-- https://preppindata.blogspot.com/2023/01/2023-week-1-data-source-bank.html
select * from PD2023_WK01; -- noqa: AM04: ambiguous.column_count

-- Output One
with BANK_TABLE as (
    select
        VALUE,
        case
            when ONLINE_OR_IN_PERSON = 1 then 'Online'
            when ONLINE_OR_IN_PERSON = 2 then 'In-Person'
            else ONLINE_OR_IN_PERSON::varchar
        end as ONLINE_OR_IN_PERSON_FACTS,
        to_timestamp(TRANSACTION_DATE, 'dd/mm/yyyy hh24:mi:ss') as TRANSACTION_TSAMP,
        dayofweek(TRANSACTION_TSAMP) as DAY_OF_WEEK,
        case 
            when DAY_OF_WEEK = 0 then 'Sunday'
            when DAY_OF_WEEK = 1 then 'Monday'
            when DAY_OF_WEEK = 2 then 'Tuesday'
            when DAY_OF_WEEK = 3 then 'Wednesday'
            when DAY_OF_WEEK = 4 then 'Thursday'
            when DAY_OF_WEEK = 5 then 'Friday'
            when DAY_OF_WEEK = 6 then 'Saturday'
            else DAY_OF_WEEK::varchar
        end as WEEKDAY,
        split_part(TRANSACTION_CODE, '-', 1) as BANK
    from PD2023_WK01
) 

select 
    BANK,
    sum(VALUE) as TRANSACTION_VALUE
from BANK_TABLE
group by BANK;

-- Output Two
with BANK_TABLE as (
    select
        VALUE,
        case
            when ONLINE_OR_IN_PERSON = 1 then 'Online'
            when ONLINE_OR_IN_PERSON = 2 then 'In-Person'
            else ONLINE_OR_IN_PERSON::varchar
        end as ONLINE_OR_IN_PERSON_FACTS,
        to_timestamp(TRANSACTION_DATE, 'dd/mm/yyyy hh24:mi:ss') as TRANSACTION_TSAMP,
        dayofweek(TRANSACTION_TSAMP) as DAY_OF_WEEK,
        case 
            when DAY_OF_WEEK = 0 then 'Sunday'
            when DAY_OF_WEEK = 1 then 'Monday'
            when DAY_OF_WEEK = 2 then 'Tuesday'
            when DAY_OF_WEEK = 3 then 'Wednesday'
            when DAY_OF_WEEK = 4 then 'Thursday'
            when DAY_OF_WEEK = 5 then 'Friday'
            when DAY_OF_WEEK = 6 then 'Saturday'
            else DAY_OF_WEEK::varchar
        end as WEEKDAY,
        split_part(TRANSACTION_CODE, '-', 1) as BANK
    from PD2023_WK01
) 

select 
    BANK,
    ONLINE_OR_IN_PERSON_FACTS as ONLINE_OR_IN_PERSON,
    WEEKDAY,
    sum(VALUE) as TRANSACTION_VALUE
from BANK_TABLE
group by BANK, ONLINE_OR_IN_PERSON, WEEKDAY;

-- Output Three
select -- noqa: ST06: structure.column_order
    CUSTOMER_CODE,
    split_part(TRANSACTION_CODE, '-', 1) as BANK,
    sum(VALUE) as TRANSACTION_VALUE
from PD2023_WK01
group by BANK, CUSTOMER_CODE;

-- Week 2 preppin' data project
-- https://preppindata.blogspot.com/2023/01/2023-week-2-international-bank-account.html

select * from PD2023_WK02_SWIFT_CODES; -- noqa: AM04: ambiguous.column_count

select * from PD2023_WK02_TRANSACTIONS; -- noqa: AM04: ambiguous.column_count

select 
    T.TRANSACTION_ID,
    concat( 'GB', S.CHECK_DIGITS, S.SWIFT_CODE, replace(T.SORT_CODE, '-', ''), T.ACCOUNT_NUMBER ) as IBAN
from PD2023_WK02_TRANSACTIONS as T
inner join PD2023_WK02_SWIFT_CODES as S on T.BANK = S.BANK;

-- Week 3 preppin' data project
-- https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html

select * from PD2023_WK03_TARGETS; -- noqa: AM04: ambiguous.column_count

with TRANSACTIONS as (
    select 
        quarter(to_timestamp(TRANSACTION_DATE, 'dd/mm/yyyy hh24:mi:ss')) as QUARTER,
        split_part(TRANSACTION_CODE, '-', 1) as BANK,
        case    
            when ONLINE_OR_IN_PERSON = 1 then 'Online'
            when ONLINE_OR_IN_PERSON = 2 then 'In-Person'
            else ONLINE_OR_IN_PERSON::varchar
        end as ONLINE_OR_IN_PERSON,
        sum(VALUE) as TRANSACTION_VALUE
    from PD2023_WK01
    where BANK = 'DSB'
    group by BANK, ONLINE_OR_IN_PERSON, QUARTER
)

select 
    TR.ONLINE_OR_IN_PERSON,
    TR.QUARTER,
    TR.TRANSACTION_VALUE,
    TA.TARGET,
    TR.TRANSACTION_VALUE - TA.TARGET as VARIANCE_TO_TARGET
from TRANSACTIONS as TR
inner join (
    select 
        ONLINE_OR_IN_PERSON,
        TARGET,
        replace(QUARTER, 'Q', '') as QUARTER
    from PD2023_WK03_TARGETS
    unpivot(TARGET for QUARTER in (Q1, Q2, Q3, Q4))
)
    as TA on TR.QUARTER = TA.QUARTER
and TR.ONLINE_OR_IN_PERSON = TA.ONLINE_OR_IN_PERSON;

-- Week 4 preppin' data project
-- https://preppindata.blogspot.com/2023/01/2023-week-4-new-customers.html

select * from PD2023_WK03_TARGETS; -- noqa: AM04: ambiguous.column_count

with CTE as (
    select 
        *,
        'PD2023_WK04_JANUARY' as TABLE_NAME 
    from PD2023_WK04_JANUARY
    union all
    select 
        *,
        'PD2023_WK04_FEBRUARY' as TABLE_NAME 
    from PD2023_WK04_FEBRUARY
    union all
    select 
        *,
        'PD2023_WK04_MARCH' as TABLE_NAME 
    from PD2023_WK04_MARCH
    union all
    select 
        *,
        'PD2023_WK04_APRIL' as TABLE_NAME 
    from PD2023_WK04_APRIL
    union all
    select 
        *,
        'PD2023_WK04_MAY' as TABLE_NAME 
    from PD2023_WK04_MAY
    union all
    select 
        *,
        'PD2023_WK04_JUNE' as TABLE_NAME 
    from PD2023_WK04_JUNE
    union all
    select 
        *,
        'PD2023_WK04_JULY' as TABLE_NAME 
    from PD2023_WK04_JULY
    union all
    select 
        *,
        'PD2023_WK04_AUGUST' as TABLE_NAME 
    from PD2023_WK04_AUGUST
    union all
    select 
        *,
        'PD2023_WK04_SEPTEMBER' as TABLE_NAME 
    from PD2023_WK04_SEPTEMBER
    union all
    select 
        *,
        'PD2023_WK04_OCTOBER' as TABLE_NAME 
    from PD2023_WK04_OCTOBER
    union all
    select 
        *,
        'PD2023_WK04_NOVEMBER' as TABLE_NAME 
    from PD2023_WK04_NOVEMBER
    union all
    select 
        *,
        'PD2023_WK04_DECEMBER' as TABLE_NAME 
    from PD2023_WK04_DECEMBER
),

PREPIVOT as (
    select 
        -- *,
        ID,
        DEMOGRAPHIC,
        VALUE,
        date(concat(JOINING_DAY, ' ', split_part(TABLE_NAME, '_', 3), ' 2023'), 'dd mmmm yyyy') as JOINING_DATE
    from CTE
),

PIVOTED as (
    select 
        ID,
        JOINING_DATE::date as JOINING_DATE,
        ETHNICITY,
        ACCOUNT_TYPE,
        DATE_OF_BIRTH::date as DATE_OF_BIRTH
    from PREPIVOT
    pivot(max(VALUE) for DEMOGRAPHIC in ('Ethnicity', 'Account Type', 'Date of Birth')) 
        as P (
            ID,
            JOINING_DATE, 
            ETHNICITY,
            ACCOUNT_TYPE,
            DATE_OF_BIRTH
        )
), 

DEDUP as (
    select 
        ID,
        ETHNICITY,
        ACCOUNT_TYPE,
        DATE_OF_BIRTH,
        JOINING_DATE,
        row_number() over(partition by ID order by JOINING_DATE) as ROWID
    from PIVOTED
)

select 
    ID,
    ETHNICITY,
    ACCOUNT_TYPE,
    DATE_OF_BIRTH, 
    JOINING_DATE
from DEDUP
where ROWID = 1;
