Impo Posh
Impo Dotils -force -PassThru -ea 'stop'
Impo Nin.Posh -ea 'stop' -PassThru -Force

# 0..4 | %{ 10 / 0 }
NinPosh.Write-ErrorRecency -WithoutSave -Debug
NinPosh.Write-ErrorRecency -WithoutSave -Debug



# Get-PSDrive
# Get-PSDrive | Group { $_.GetType() }

write-warning "this is supposed to be equivalent, but, it's not working right"
gci . | Nin.Posh.GroupBy.TypeName FullName | ft -AutoSize

#expected  result:
gci . | Group { $_ | Format-ShortTypeName }