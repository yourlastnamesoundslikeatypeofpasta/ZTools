Describe 'ZtEntity class' {
    It 'stores constructor parameters' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'ZtCore' 'ZtEntity.ps1'
        . $scriptPath
        $props = @{ Foo = 'Bar' }
        $entity = [ZtEntity]::new('Source','User','id',$props)
        $entity.Source | Should -Be 'Source'
        $entity.ObjectType | Should -Be 'User'
        $entity.Identifier | Should -Be 'id'
        $entity.Properties['Foo'] | Should -Be 'Bar'
    }
}

