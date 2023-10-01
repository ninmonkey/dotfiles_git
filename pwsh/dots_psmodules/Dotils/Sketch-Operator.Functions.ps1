if( -not $x ) {
   $x = get-date ; sleep 0.3; $y = Get-date
}

# 2023-09-25, 2023-10-01

function template.Func {
    <#
    .SYNOPSIS
        template for a compare
    #>
    param(
        # first object, nicely allow empty strings
        [Alias('Left', 'Obj1', 'ObjA')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, Position = 0)]
        [object]$LeftObj,

        # first object, nicely allow empty strings
        [Alias('Right', 'Obj2', 'ObjB')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, Position = 1)]
        [object]$RightObj,

        # List of Property names to use
        [string[]]$Property
    )
    $Property | %{
        $curProp = $_
        $LeftValue? = ($LeftObj)?[ $curProp ]
    }
    $LeftObj
    $info = [ordered]@{
        PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
    }
    return [pscustomobject]$info
}

    function Operator.Compare.SingleComparison {
        param(
            [Parameter(Mandatory)]
            [object]$Left,

            [Parameter(Mandatory)]
            [object]$Right,

            [Parameter(Mandatory)]
            [string]$Property
        )
        class OperandSummary {
            # meta per object (2)
            [bool]$IsNull = $null
            [bool]$IsFalsy = $null
            [bool]$IsTruthy = $null
            [bool]$IsEmptyStr = $null
            [bool]$IsBlank = $null
            [bool]$IsObjectCompareEqual = $null
            [bool]$IsEqualAfterCoercion = $null
            [bool]$BasicType = $null
            [bool]$NumberType = $null
            [bool]$IsValueType = $null
            [bool]$IsTypeInfo = $null
            [bool]$IsEnum = $null
            [bool]$IsGeneric = $null
            [bool]$IsGenericRelated = $null
            [object]$GenericParams = 'nyi'
            [object]$GenericAttrs = 'nyi'
        }
        class ComparisonResult {
            # metadata of the summary, the same for both
            [bool]$ExactEqual
            hidden [object]$LeftObject
            hidden [object]$RightObject
            hidden [type]$TypeOfLeft
            hidden [type]$TypeOfRight

            [bool]$IsSameType = $false

            # [hashtable]$Left = @{
            #     IsNull = $null
            #     IsBlank = $null
            #     TypeIsGeneric = $null
            # }
            # [hashtable]$Right = @{
            #     IsNull = $null
            #     IsBlank = $null
            #     TypeIsGeneric = $null
            # }

            ComparisonResult( [object]$Left, [object]$Right) {
                # //record of the compare

                $this.TypeOfLeft =  $LtInfo = ($Left)?.GetType()
                $this.TypeOfRight = $RtInfo = ($Right)?.GetType()

                $leftInfo  = [OperandSummary]::new()
                $rightInfo = [OperandSummary]::new()
                # first group of tests easly support null parameters

                $leftInfo.IsNull =  $null -eq $Left
                $leftInfo.IsString = $Left -is 'string'
                $leftInfo.IsFalsy = -not $Left
                $leftInfo.IsTruthy = [bool]( $Left )
                $leftInfo.IsEmptyString = $LeftInfo.IsString -and [string]::empty -eq $Left
                $leftInfo.IsValueType = $Left -is 'ValueType'
                $leftInfo.IsEnumType = $left -is 'enum'
                $leftInfo.IsTypeInfo = $left -is 'type'
                $LeftInfo.IsGeneric = $LtInfo.IsGenericType
                $LeftInfo.IsGenericRelated =
                    $ltInfo.IsGeneric -or
                    $ltInfo.IsGenericMethodParameter -or
                    $ltInfo.IsGenericParameter -or
                    $ltInfo.IsGenericType -or
                    $ltInfo.IsGenericTypeDefinition -or
                    $ltInfo.IsGenericTypeParameter


                    $ltInfo.GenericParameterAttributes -or
                #     @(

                #     ) |?{ $_ }
                # ).Count -gt 0

                write-warning 'left off
                    [System.Collections.Generic.List[IO.FileInfo]]$files = gi .\unins000.msg
                    $files
                    '


                $leftInfo.Psobject.Properties | ?{ $null -eq $_.Value } | Join-String -sep ', ' -op 'missing left: ' -p Name    | write-host -back 'red'
                $RightInfo.Psobject.Properties | ?{ $null -eq $_.Value } | Join-String -sep ', ' -op 'missing left: '  -p Name | write-host -back 'red'
                return

                 # return
                if($false) {
                    # $leftSummary.IsBlankStr = $Left -is 'string' -and [string]::IsNullOrWhiteSpace( $Left )

                    # $this.ExactEqual = $LeftObj -eq $Right

                    # $this.Left.IsNull = $null -eq $Left
                    # $this.Right.IsNull = $null -eq $Right

                    # $this.Left.IsFalsy = -not $Left
                    # $this.Left.IsTruthy = [bool]( $Left )

                    # $this.Left.IsEmptyStr =
                    #         $Left -is 'string' -and [string]::Empty -eq $Left

                    # $this.Right.IsEmptyStr =
                    #         $Right -is 'string' -and [string]::Empty -eq $Right

                    # $this.Right.IsBlank =
                    #         [string]::IsNullOrWhiteSpace( $Left )

                    # $this.Right.IsBlank =
                    #         [string]::IsNullOrWhiteSpace( $Right )

                    #     $this.Left.IsObjectCompareEqual =
                    #         [Object]::Equals( $Left, $Right )

                    #     $this.Right.IsObjectCompareEqual =
                    #         [Object]::Equals( $Right, $Left )

                    #     $this.Left.IsEqualAfterCoercion =
                    #         $left -eq $Right -and $

                    #     $this.Right.IsEqualAfterCoercion = $Right -eq $Left
                }

                # further tests may waytto exit here, if the values were true null

                <#
                good example on when it fails, dependings on types
                    (gi . ).FullName -eq (gcl -Raw)
                    # equal

                    (gi . ) -eq (gcl -Raw)
                    # False

                    (gi . ).ToString() -eq (gcl -Raw)
                    # true
                #>
            }
            # [string]$Operator
            # [string]$Property
            # [object]$Left
            # [object]$Right
        }

        $cresult  = [CompareResult]::new( $Left, $Right )
        $info = [ordered]@{
            PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
            LeftObject  = $Left
            RightObject = $Right
            Property = $Property
            CompareResult = $cResult
            Left = 'next: $cResult.LeftInfo '
            Right = 'next: $cResult.RightInfo '

        }
        return [pscustomobject]$info

    }
function Operator.Compare.ByProperty {
    <#
    .SYNOPSIS
        template for a compare, enumerate properties, using implicit equalities for a quick test
    #>
    param(
        # first object, nicely allow empty strings
        [Alias('Left', 'Obj1', 'ObjA')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, Position = 0)]
        [object]$LeftObj,

        # first object, nicely allow empty strings
        [Alias('Right', 'Obj2', 'ObjB')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, Position = 1)]
        [object]$RightObj,

        # List of Property names to use
        [string[]]$Property
    )




    $Property | %{
        $curProp = $_
        $LeftValue? = ($LeftObj)?[ $curProp ]
    }
    $LeftObj
    $info = [ordered]@{
        PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
        Left  = 10
    }
    [pscustomobject]$info | ft -auto | out-host
    return [pscustomobject]$info
    # $naive =
    #     $Left.$Property -eq $Right.$Property
}

function fastTestQuit () {
    Operator.Compare.ByProperty -Left $x -Right $y -Property 'Date'
}

if($true) { return (fastTEstQuit)}

$results = @(
    Operator.Compare.ByProperty -Left $x -Right $y -Property 'Date'
    Operator.Compare.ByProperty -Left $x -Right $y -Property 'Ticks'
)
$results| ft -AutoSize

function Operator.Compare.String {
    # param(
    #     [Alias('Left', 'A')]
    #     $Left

    #     [Parameter(Mandatory)]
    #     $InputObjectLeft,

    # )

    write-warning '
compares nyi
    String InvariariantCulture
    OrdinalInsensitveCase
'
    [string]::IsNullOrEmpty($Left) -and [string]::IsNullOrEmpty($Right)
}

get-date

# return

# equalsProps
# function Get-Foo {
#     <#
#     .synopsis
#         Stuff
#     .description
#        .
#     .example
#           .
#     .outputs
#           [string | None]

#     #>
#     [CmdletBinding(PositionalBinding = $false)]
#     param(

#        [Alias('Left', 'Obj1', 'ObjA')][Parameter(Mandatory, Position = 0)]
#        [object]$InputLeftObject,

#        [Alias('Right', 'Obj2', 'ObjB')][Parameter(Mandatory, Position = 1)]
#        [object]$InputRightObject,

#        [string[]]$Property
#     )

#     begin {
#         function compareOneLoose {
#             param( $Object1, $Object2, [string]$PropertyName )
#             $info = [ordered]@{}
#             $info.Default = $Object1 -eq $Object2
#             $info.EqualOperator
#         }
#     }
#     process {

#     }
#     end {}
# }