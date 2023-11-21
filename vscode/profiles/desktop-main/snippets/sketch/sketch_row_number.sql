/*
## h1: Input
    select
        [e].[LastName], [e].[FirstName],
        * from crvAllEmployees as [e]

## h1: target output

    select
        top 5
        row_number() over (
            partition by
                [e].[LastName]
            order by
                [e].[LastName] asc
        ) as [RowNum],
        [e].[LastName], [e].[FirstName],

        * from crvAllEmployees as [e]
        order by
            [e].[LastName]
*/
goto L_TEST2

-- [cvARCustByJCJMStreet]  -- No Partition means row numbers
select
    top 15
    row_number() over (order by [Name] asc) as [RowNum],
    [Name] as [Name_],
    *
from [dbo].[cvARCustByJCJMStreet] as [street]
order by
    [Name_] asc

L_TEST2:

    with cte as (
        select
            top 20
        LastName, Employee
        from
            crvAllEmployees
    )
    select top 10 * from cte

/*
"with ${1:cte} as (",
"   ${TM_SELECTEDVALUE}",
")",
"select top 10 * from ${1:cte}",
*/
L_END: