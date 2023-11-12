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
        <#
        this data is the summary of the comparison of Left and Right. Drill down to []
        #>
        # meta per object (2)

        [bool]$IsNull = $null
        [bool]$IsFalsy = $null
        [bool]$IsFalsyWithoutNull = $null
        [bool]$IsTruthy = $null

        [bool]$IsString = $null
        [bool]$IsEmptyString = $null
        [bool]$IsBlank = $null
        [bool]$IsBlankWithoutNull = $null # coerces to '' but it's still an object

        [bool]$IsValueType = $null
        [bool]$IsEnumType = $null
        [bool]$IsTypeInfo = $null
        [bool]$IsBasicType = $null
        [bool]$IsNumberType = $null

        [bool]$IsGeneric = $null
        [bool]$IsGenericRelated = $null

        [string]$FullName = $Null
        [string]$AssemblyFullyQualifiedName = $null
        [string]$Namespace = $null
        [string]$Name = $null


        [hashtable]$Extra = @{} # extra items that may be thropwn out, or don't always exist

        hidden [type]$OriginalTypeInfo
        hidden [object]$OriginalObject

        [type]$UnderlyingType = $nul

        hidden [string]$DisplayString = [string]::Empty
        [object]$GenericParams = 'nyi, see: .extra'
        [object]$GenericTypeArgs = 'nyi see: .extra'

        OperandSummary ( [object]$InputObject ) {
            $RefObj = $InputObject
            $tInfo = ($RefObj)?.GetType()

            $this.OriginalObject = $InputObject
            $this.OriginalTypeInfo = $tInfo

            $this.IsNull =  $null -eq $RefObj
            $this.IsFalsy = -not $RefObj
            $this.IsFalsyWithoutNull = -not $this.IsNull -and $this.IsFalsy
            $this.IsTruthy = [bool]( $RefObj )

            $this.IsString = $RefObj -is 'string'
            $this.IsEmptyString = $this.IsString -and [string]::empty -eq $RefObj
            $this.IsBlank = [string]::IsNullOrWhiteSpace( $RefObj )

            $this.IsBlankWithoutNull = -not $this.IsNull -and $this.IsBlank

            $this.IsValueType = $RefObj -is 'ValueType'
            $this.IsEnumType = $RefObj -is 'enum' -or $tInfo.IsEnum
            $this.IsTypeInfo = $RefObj -is 'type'
            $this.IsBasicType =
                $tinfo.IsValueType -or ($tinfo.Name -in @(
                    'Int32', 'Int16', 'long', 'double', 'Byte', 'String', 'enum'
                ))
            $this.IsNumberType =
                $this.IsValueType -and
                $tinfo.Name -match '(u?long)|(u?short)|(u?Int\d+)|(u?short)(byte)'
                    '(u?Int\d+)|u?long|double|byte|Decimal'

            $this.FullName = $tInfo.FullName
            $this.AssemblyFullyQualifiedName = $tInfo.AssemblyFullyQualifiedName
            $this.Namespace = $tInfo.Namespace
            $this.Name = $tInfo.Name
            $this.UnderlyingType = $Tinfo.UnderlyingSystemType
            $this.DisplayString = ($Tinfo)?.DisplayString ?? $Tinfo.Name # from ClassExplorer


            # $this.IsGeneric =

            $this.IsGeneric = $tInfo.IsGenericType
            $this.IsGenericRelated =
                $tInfo.IsGeneric -or
                $tInfo.IsGenericMethodParameter -or
                $tInfo.IsGenericParameter -or
                $tInfo.IsGenericType -or
                $tInfo.IsGenericTypeDefinition -or
                $tInfo.IsGenericTypeParameter

            $this.Extra.FirstChild =
                ( $RefObj )?[0] ?? $null

            # $this.Extra.MemberType = $tinfo.MemberType
            # https://learn.microsoft.com/en-us/dotnet/api/system.reflection.memberinfo?view=net-7.0
            # see also [Reflection.MemberInfo]
            # MemberInfo[]

            $this.Extra.IsAnything =
                $tInfo | Select -Prop 'Is*'  -ea 'ignore'

            $this.Extra.IsAnythingElse =
                $tinfo | Select -Exclude 'Is*'

        }
    }
    class ComparisonResult {
        # metadata of the summary, the same for both
        <#
        this summarizes the object by itself, metadata before comparing Left and Right
        #>
        [bool]$ExactEqual
        hidden [object]$LeftObject
        hidden [object]$RightObject
        hidden [type]$TypeOfLeft
        hidden [type]$TypeOfRight

        [OperandSummary]$Left
        [OperandSummary]$Right

        [bool]$IsSameType = $false
        [bool]$IsObjectCompareEqual = $null
        [bool]$IsEqualAfterCoercion = $null

        ComparisonResult( [object]$Left, [object]$Right) {
            # //record of the compare

            $this.TypeOfLeft =  $LType = ($Left)?.GetType()
            $this.TypeOfRight = $RType = ($Right)?.GetType()

            $leftInfo  = [OperandSummary]::new( $Left )
            $rightInfo = [OperandSummary]::new( $Right )
            $this.Left = $leftInfo
            $this.Right = $rightInfo
            # first group of tests easly support null parameters

            <#
            TryMore
                <https://learn.microsoft.com/en-us/dotnet/api/system.object?view=net-7.0>
                <https://learn.microsoft.com/en-us/dotnet/api/system.type?view=net-7.0>

            try both, diff conversion paths

                Left.Equals( Right )
                Equals( Left, Right )

                > docs: Object.ReferenceEquals(x.GetType(),y.GetType()) returns true

                Object.ReferenceEquals( tinfo1, tinfo2 )
                Object.Equals( Left, Right ) )

            #>

            write-warning 'left off:
            > docs: Object.ReferenceEquals(x.GetType(),y.GetType()) returns true

        datatypes for OperandSummary, which datatypes are right for referencing generic parameter attributes

            <https://learn.microsoft.com/en-us/dotnet/api/system.type?view=net-7.0#properties>

            '
            $now1 ??= get-date; sleep -sec 2
            $now2 ??= get-date

            $leftInfo.Psobject.Properties | ?{ $null -eq $_.Value } | Join-String -sep ', ' -op 'missing left: ' -p Name    | write-host -back 'red'
            $RightInfo.Psobject.Properties | ?{ $null -eq $_.Value } | Join-String -sep ', ' -op 'missing left: '  -p Name | write-host -back 'red'
            return


            $LeftInfo.Extra.IsSomething =
                $LType | select -Prop Is* -ea 'ignore'
            $LeftInfo.Extra.NotIsSomething =
                $LType | Select -excl 'Is*' -ea 'ignore'

            $LeftInfo.Extra.Attributes =
                $LType.Attributes
            $LeftInfo.Extra.CustomAttributes =
                $LType.CustomAttributes

            $LeftINfo.Extra = 2

            $LeftInfo.Extra.MemberType = $LType.MemberType


                # $LType.GenericParameterAttributes -or
            #     @(

            #     ) |?{ $_ }
            # ).Count -gt 0

            write-warning 'left off
                [System.Collections.Generic.List[IO.FileInfo]]$files = gi .\unins000.msg
                $files
                '

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



    $cresult  = [ComparisonResult]::new( $Left, $Right )
    $info = [ordered]@{
        PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
        LeftObject  = $Left
        RightObject = $Right
        Property = $Property
        ComparisonResult = $cResult
        Left = 'next: $cResult.LeftInfo '
        Right = 'next: $cResult.RightInfo '

    }
    return [pscustomobject]$info

}
function Operator.Compare.ByProperty {
    <#
    .SYNOPSIS
        template for a compare, enumerate properties, using implicit equalities for a quick test
    .notes
        for each property, call [ComparisonResult] which also contains [OperandSummary] for each side
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

    $Property | Join-String -sep ', ' -op 'ToCompareProps: ' | write-verbose -verb


    $propName = 'Ticks' # , 'Year'
    $Shared =
            Operator.Compare.SingleComparison -Left $LeftObj -Right $RightObj -Property $PropName
    $info = [ordered]@{
        PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
        Left = $Shared
        # ByProp = $Shared

    }
    # // new early exit
    [pscustomobject]$info | ft -auto | out-host
    return [pscustomobject]$info



    # $Property | %{
    #     $curProp = $_
    #     $LeftValue? = ($LeftObj)?[ $curProp ]
    # }
    # $LeftObj
    # $info = [ordered]@{
    #     PSTypeName = 'dotils.{0}' -f $MyInvocation.MyCommand.Name # 'dotils.Operator.{0}'
    #     Left  =
    # }
    # [pscustomobject]$info | ft -auto | out-host
    # return [pscustomobject]$info
    # $naive =
    #     $Left.$Property -eq $Right.$Property
}

function fastTestQuit () {
    # Operator.Compare.ByProperty -Left $x -Right $y -Property 'Date'
    hr -fg 'orange'
    # Operator.Compare.SingleComparison -Left $now1 -Right $now2

    $now1 ??= get-date && sleep -s 1
    $now2 ??= get-date

    Operator.Compare.SingleComparison -Left $now1 -Right $now2 Year

    hr -fg 'green'
    Operator.Compare.ByProperty -Left $now1 -Right $now2 -Property 'Year'
    Operator.Compare.ByProperty -Left $now1 -Right $now2 -Property 'Ticks'

    hr -fg 'magenta'
    Operator.Compare.SingleComparison -Left $now1 -Right $now2 Year|json -d 1
    hr -fg 'orange'
    return
}

if($true) { return (fastTEstQuit)}

$results = @(
    Operator.Compare.ByProperty -Left $x -Right $y -Property 'Date'
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