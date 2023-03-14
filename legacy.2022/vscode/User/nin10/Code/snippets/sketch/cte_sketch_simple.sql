
-- select * from crvAllEmployees as [e]
-- where [e].[Employee] in (370)

-- with inner as (
select top 2
    [e].[ActiveYN], [e].[LastName], [e].[Craft], [e].[Employee]
from
    crvAllEmployees as [e]
where
    ([e].[Employee] in (370)) or ([e].[Employee] between 15000 and 20000)

-- )

-- select * from inner
-- go
go

with cte as (
    select top 200
        [e].[ActiveYN], [e].[LastName], [e].[Craft], [e].[Employee]
    from
        crvAllEmployees as [e]
    where
        ([e].[Employee] in (370)) or ([e].[Employee] between 15000 and 20000)
)
select
    *, ROW_NUMBER() over (order by ActiveYN asc, LastName asc ) as 'Row?'
from
    cte
order by
    ActiveYN asc, LastName asc

/*
-- [cvARCustByJCJMStreet]  -- PartitionBy [Name] means resets based on names
select
    top 15
    row_number() over (partition by [Name]  order by Name asc) as [RowNum],
    [Name] as [Name_],
    *
from [dbo].[cvARCustByJCJMStreet] as [street] */