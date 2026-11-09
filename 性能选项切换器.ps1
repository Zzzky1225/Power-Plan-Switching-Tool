$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::Default
try {
    Set-ItemProperty "HKCU:\Console" -Name FaceName -Value "Consolas" -Force
} catch {}

$PowerPlanCatalog = @(
    [PSCustomObject]@{ Name = "节能";      Guid = "a1841308-3541-4fab-bc81-f71556f20b4a" },
    [PSCustomObject]@{ Name = "平衡";      Guid = "381b4222-f694-41f0-9685-ff5bb260df2e" },
    [PSCustomObject]@{ Name = "高性能";    Guid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" },
    [PSCustomObject]@{ Name = "卓越性能";  Guid = "e9a42b02-d5df-448d-aa00-03f14749eb61" }
)

function Test-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = [System.Security.Principal.WindowsPrincipal]$id
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-POSTLine {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )
    foreach ($c in $Text.ToCharArray()) {
        Write-Host $c -ForegroundColor $Color -NoNewline
        Start-Sleep -Milliseconds 0
    }
    Write-Host ""
}

function Write-SingleLineTitle {
    param(
        [string]$Bar,
        [string]$TitleText,
        [ConsoleColor]$Color = [ConsoleColor]::Cyan
    )
    $barLen = $Bar.Length
    $txtLen = $TitleText.Length
    $totalSpace = $barLen - $txtLen
    if ($totalSpace -lt 0) { $totalSpace = 0 }
    $leftSpaceCount = [Math]::Floor($totalSpace / 2)
    $finalLine = (" " * $leftSpaceCount) + $TitleText
    if ($finalLine.Length -gt $barLen) {
        $finalLine = $finalLine.Substring(0, $barLen)
    }
    Write-POSTLine $finalLine -Color $Color
}

function Write-POSTHeader {
    param([string]$TitleText)
    Clear-Host
    $bar = "===================================================================="
    Write-POSTLine $bar -Color Cyan
    Write-SingleLineTitle -Bar $bar -TitleText $TitleText -Color Cyan
    Write-POSTLine $bar -Color Cyan
}

function Show-MainMenu {
    $mainTitle = "POWER PLAN MANAGEMENT UTILITY 电源计划管理工具"
    Write-POSTHeader $mainTitle
    Write-POSTLine ""
    Write-POSTLine "[1] 节能"
    Write-POSTLine "[2] 平衡"
    Write-POSTLine "[3] 高性能"
    Write-POSTLine "[4] 卓越性能"
    Write-POSTLine "[5] 关于"
    Write-POSTLine "[0] 退出程序"
    Write-POSTLine ""
    Write-POSTLine "--------------------------------------------------------------------" -Color Gray
    Write-Host ">> 请输入目标选项编号..." -ForegroundColor Yellow
    Write-Host ">> " -ForegroundColor Yellow -NoNewline
}

function Show-AboutPage {
    Write-POSTHeader "ABOUT 关于本程序"
    Write-POSTLine ""

    $art = @(
        "",
        "████████   ████████   ████████   ████ █████   ████  ████",
        "██   ██    ██   ██    ██   ██     ██   ██      ██    ██",
        "    ██         ██         ██      ██  ██        ██  ██",
        "   ██         ██         ██       █████          ████",
        "  ██         ██         ██        ██  ██          ██",
	" ██   ██    ██   ██    ██   ██    ██   ██         ██",
        "████████   ████████   ████████   ████ █████      ████",
        ""
    )

    $colors = @(
    	[ConsoleColor]::Red,
    	[ConsoleColor]::Yellow,
    	[ConsoleColor]::Green,
    	[ConsoleColor]::Cyan,
    	[ConsoleColor]::Blue,
    	[ConsoleColor]::Magenta,
    	[ConsoleColor]::White
    )

    for ($i = 0; $i -lt $art.Count; $i++) {
        Write-Host "        " -NoNewline
        for ($j = 0; $j -lt $art[$i].Length; $j++) {
            $c = $art[$i][$j]
            $idx = ($i + $j) % $colors.Count
            Write-Host $c -ForegroundColor $colors[$idx] -NoNewline
            Start-Sleep -Milliseconds 0
        }
        Write-Host ""
    }

    Write-POSTLine ""
    Write-POSTLine "        POWER PLAN MANAGER TOOL" -Color White
    Write-POSTLine ""
    Write-POSTLine "        @Zzzky 2026 ;D <3 :D" -Color Yellow
    Write-POSTLine "        @Build:2026/11/9 2:13" -Color Yellow
    Write-POSTLine ""
    Write-POSTLine "        简易Windows电源方案切换控制台工具" -Color Gray
    Write-POSTLine ""

    $color16 = @(
        [ConsoleColor]::Black,
        [ConsoleColor]::DarkRed,
        [ConsoleColor]::DarkGreen,
        [ConsoleColor]::DarkYellow,
        [ConsoleColor]::DarkBlue,
        [ConsoleColor]::DarkMagenta,
        [ConsoleColor]::DarkCyan,
        [ConsoleColor]::Gray,
        [ConsoleColor]::DarkGray,
        [ConsoleColor]::Red,
        [ConsoleColor]::Green,
        [ConsoleColor]::Yellow,
        [ConsoleColor]::Blue,
        [ConsoleColor]::Magenta,
        [ConsoleColor]::Cyan,
        [ConsoleColor]::White
    )
    Write-Host "        " -NoNewline
    for ($x = 0; $x -lt 8; $x++) {
        Write-Host "████" -ForegroundColor $color16[$x] -NoNewline
        Start-Sleep -Milliseconds 0
    }
    Write-Host ""
    Write-Host "        " -NoNewline
    for ($x = 8; $x -lt 16; $x++) {
        Write-Host "████" -ForegroundColor $color16[$x] -NoNewline
        Start-Sleep -Milliseconds 0
    }
    Write-Host ""

    Write-POSTLine ""
    Write-POSTLine "--------------------------------------------------------------------"
    Write-Host ">> 按回车键返回主菜单..." -ForegroundColor Yellow
    Write-Host ">> " -ForegroundColor Yellow -NoNewline
    $null = Read-Host
}

function Invoke-PlanSwitchWorkflow {
    param([PSCustomObject]$Target)
    Write-POSTHeader "POWER PLAN SWITCH WORKFLOW"
    Write-POSTLine ""
    Write-POSTLine "  目标电源计划: $($Target.Name)" -Color White
    Write-POSTLine "  目标 GUID:     $($Target.Guid)" -Color White
    Write-POSTLine ""
    Write-POSTLine "--------------------------------------------------------------------"
    Write-POSTLine "  [STEP 1/4]  调用 powercfg /GETACTIVESCHEME 读取当前激活方案..." -Color White
    $null = powercfg /GETACTIVESCHEME 2>&1
    Write-POSTLine "  >> 操作完成，已读取当前系统电源配置" -Color Green
    Write-POSTLine ""
    Write-POSTLine "  [STEP 2/4]  调用 powercfg /S $($Target.Guid) 执行切换..." -Color White
    powercfg /S $Target.Guid 2>&1 | Out-Null
    Write-POSTLine ""
    Write-POSTLine "  [STEP 3/4]  调用 powercfg /GETACTIVESCHEME 验证切换结果..." -Color White
    $verify = powercfg /GETACTIVESCHEME 2>&1
    if ($verify -match [regex]::Escape($Target.Name)) {
        Write-POSTLine "  >> 验证通过：目标电源计划已成功激活" -Color Green
        Write-POSTLine ""
        Write-POSTLine "  [RESULT] 操作成功：系统电源配置已切换至【$($Target.Name)】" -Color Green
    } else {
        Write-POSTLine "  >> 验证失败：目标电源计划未处于激活状态" -Color Yellow
        Write-POSTLine "  >> 可能原因：该方案在系统中不存在或已被删除" -Color Yellow
        Write-POSTLine ""
        Write-POSTLine "  [STEP 4/4]  调用 powercfg /DUPLICATESCHEME $($Target.Guid) 重建方案..." -Color White
        powercfg -duplicatescheme $Target.Guid 2>&1 | Out-Null
        Write-POSTLine "  >> 重建完成，再次调用 powercfg /S $($Target.Guid) 激活方案..." -Color White
        powercfg /S $Target.Guid 2>&1 | Out-Null
        Write-POSTLine "  >> 正在执行二次验证..." -Color White
        $final = powercfg /GETACTIVESCHEME 2>&1
        if ($final -match [regex]::Escape($Target.Name)) {
            Write-POSTLine "  [RESULT] 操作成功：缺失方案已重建并激活【$($Target.Name)】" -Color Green
        } else {
            Write-POSTLine "  [RESULT] 操作失败：无法创建或激活目标电源方案" -Color Red
            Write-POSTLine "  >> 建议检查管理员权限、系统完整性及 powercfg 可用性" -Color Gray
        }
    }
    Write-POSTLine ""
    Write-POSTLine "--------------------------------------------------------------------"
    Write-Host ">> 按回车键返回主菜单..." -ForegroundColor Yellow
    Write-Host ">> " -ForegroundColor Yellow -NoNewline
    $null = Read-Host
}

function Show-ErrorScreen {
    param([string]$Title, [string]$Detail, [string]$Received = "")
    Write-POSTHeader $Title
    Write-POSTLine ""
    Write-POSTLine "  错误详情: $Detail" -Color Red
    if ($Received) { Write-POSTLine "  收到输入: $Received" -Color Red }
    Write-POSTLine ""
    Write-POSTLine "--------------------------------------------------------------------"
    Write-Host ">> 按回车键返回主菜单..." -ForegroundColor Yellow
    Write-Host ">> " -ForegroundColor Yellow -NoNewline
    $null = Read-Host
}

if (-not (Test-Admin)) {
    Clear-Host
    $bar = "===================================================================="
    Write-POSTLine $bar -Color Yellow
    $title = "PRIVILEGE REQUIREMENT NOTICE 权限提示"
    Write-SingleLineTitle -Bar $bar -TitleText $title -Color Yellow
    Write-POSTLine $bar -Color Yellow
    Write-POSTLine ""
    Write-POSTLine "  当前进程未持有管理员权限。"
    Write-POSTLine "  电源配置修改需要管理员权限。"
    Write-POSTLine ""
    Write-POSTLine "  程序将在 3 秒后发起 UAC 权限提升请求..." -Color Yellow
    Write-POSTLine "  如需取消，请直接关闭窗口。"
    Write-POSTLine ""
    Write-POSTLine $bar -Color Yellow
    Start-Sleep -Seconds 3
    try {
        $scriptPath = $MyInvocation.MyCommand.Definition
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    } catch {
        Clear-Host
        Write-POSTLine "[ERROR] 无法启动提升权限进程。" -Color Red
        Write-POSTLine "请手动以管理员身份运行此脚本。"
        Write-Host ">> 按回车键退出..." -ForegroundColor Yellow
        Write-Host ">> " -ForegroundColor Yellow -NoNewline
        $null = Read-Host
        exit 1
    }
    exit
}

while ($true) {
    Show-MainMenu
    $raw = Read-Host
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Show-ErrorScreen "输入校验失败" "输入内容为空，请输入有效的数字编号"
        continue
    }
    switch ($raw) {
        "0" {
            Write-POSTHeader "PROGRAM TERMINATION 程序退出"
            Write-POSTLine ""
            Write-POSTLine "  电源管理工具会话结束。" -Color Green
            Write-POSTLine ""
            Write-Host ">> 按回车键关闭窗口..." -ForegroundColor Yellow
            Write-Host ">> " -ForegroundColor Yellow -NoNewline
            $null = Read-Host
            break
        }
        "1" { Invoke-PlanSwitchWorkflow $PowerPlanCatalog[0] }
        "2" { Invoke-PlanSwitchWorkflow $PowerPlanCatalog[1] }
        "3" { Invoke-PlanSwitchWorkflow $PowerPlanCatalog[2] }
        "4" { Invoke-PlanSwitchWorkflow $PowerPlanCatalog[3] }
        "5" { Show-AboutPage }
        default { Show-ErrorScreen "输入校验失败" "输入编号超出可选范围" $raw }
    }
    if ($raw -eq "0") { break }
}
