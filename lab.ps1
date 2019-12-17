Set-Location $PSScriptRoot

{git reset --hard HEAD} | Out-Null

{git pull -f} | Out-Null

$standName = $args[1]

function Get-Status {
    [string[]](Get-Content trainings.yaml | Select-String -Pattern 'name:') | Foreach {$_.Trim().Split(' ')[2]}
}

Function Docker-Start {
    docker-compose -f $(Join-Path -Path $PSScriptRoot -ChildPath "envs\$standName.yaml") pull
    docker-compose -f $(Join-Path -Path $PSScriptRoot -ChildPath "envs\$standName.yaml") up -d
}

Function Docker-Stop {
    docker-compose -f $(Join-Path -Path $PSScriptRoot -ChildPath "envs\$standName.yaml") down --volumes
}

switch ($args[0]){
    'status' {Get-Status}
    'start' {Docker-Start}
    'restart' {Docker-Stop;Docker-Start}
    'stop' {Docker-Stop}
}
