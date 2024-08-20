if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch the script as administrator
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo
    $newProcess.FileName = "powershell.exe"
    $newProcess.Arguments = "& '$PSCommandPath'"
    $newProcess.Verb = "runas"
    $process = [System.Diagnostics.Process]::Start($newProcess)
    $process.WaitForExit()
    exit
}

# Rest of your script Run as Administrator
Set-ExecutionPolicy Unrestricted -Force
cd $env:TEMP

# Define the log file path
$logFilePath = "C:\:patient_entry_log.txt"

$tempFolders = @(
    "patiententry",
    "SQLEXPRADV_x64_ENU",
    "vs2013",
    "BMS",
    "BMS_"
)

$tempFiles = @(
    "C:\BAK3D_DB.sql",
    "C:\CommonDBUpgradescript.sql",
    "dotNetFx35setup.exe",
    "taoframework-2.1.0-setup.exe",
    "C:\updateesame3dbakupdated.sql",
    "C:\updateesame3dpodsupdated.sql",
    "CDM21218_Setup.exe",
    "patient_entry_setup.ps1"
)

# Function to write log entries
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$type] $message"
    Add-Content -Path $logFilePath -Value $logEntry
    Write-Host $logEntry
}

# Function to install a software and check for errors with progress tracking
function Install-Software {
    param (
        [string]$installerPath,
        [string]$installerArgs = "/S",
        [string]$softwareName
    )

    Write-Log "Installing $softwareName..."
    $startTime = Get-Date
    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    $process = Start-Process -FilePath $installerPath -ArgumentList $installerArgs -Wait -PassThru
    while (-not $process.HasExited) {
        $elapsedTime = $timer.Elapsed.ToString("hh\:mm\:ss")
        Write-Host "Installing $softwareName... Time elapsed: $elapsedTime" -NoNewline
        Start-Sleep -Seconds 1
        Write-Host "`r" -NoNewline
    }
    $timer.Stop()

    if ($process.ExitCode -ne 0) {
        Write-Log "Installation failed for $softwareName" "ERROR"
    } else {
        $totalTime = (Get-Date) - $startTime
        Write-Log "$softwareName installed successfully in $($totalTime.TotalMinutes) minutes."
    }
    Write-Log "==============================================================="
}

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = 'PatientEntry: Optional Components'
$form.Width = 600
$form.Height = 400

$checkBoxBMS = New-Object System.Windows.Forms.CheckBox
$checkBoxBMS.Text = 'BMS'
$checkBoxBMS.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($checkBoxBMS)

$checkBox3DPODS = New-Object System.Windows.Forms.CheckBox
$checkBox3DPODS.Text = '3DPODS'
$checkBox3DPODS.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($checkBox3DPODS)

$checkBoxBAK3D = New-Object System.Windows.Forms.CheckBox
$checkBoxBAK3D.Text = 'BAK3D'
$checkBoxBAK3D.Location = New-Object System.Drawing.Point(20, 80)
$form.Controls.Add($checkBoxBAK3D)

# Calculate button positions for bottom-right corner
$buttonWidth = 100
$buttonHeight = 30
$buttonSpacing = 10
$formMargin = 10

# Corrected calculation for button positions
$buttonInstallX = $form.ClientSize.Width - $buttonWidth - $formMargin
$buttonInstallY = $form.ClientSize.Height - $buttonHeight - $formMargin

$buttonCancelX = $buttonInstallX - $buttonWidth - $buttonSpacing
$buttonCancelY = $buttonInstallY 

$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = 'Install'
$buttonInstall.Location = New-Object System.Drawing.Point($buttonInstallX, $buttonInstallY)
$buttonInstall.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
# Initially disable the Install button
$buttonInstall.Enabled = $false

$buttonInstall.Add_Click({
    $selectedComponents = @()

    Write-Host "\n\n############################################################"
    Write-Host "###########################Paient Entry######################"
    Write-Host "############################################################\n\n"


    if (1) {
        # Install .NET Framework 3.5
        Install-Software -installerPath "dotNetFx35setup.exe" -softwareName ".NET Framework 3.5"

        # Install Tao Framework
        Install-Software -installerPath "taoframework-2.1.0-setup.exe" -softwareName "Tao Framework"

        # Install Visual Studio 2013
        Install-Software -installerPath "vs2013/vs_premium.exe" -softwareName "Visual Studio 2013"

        # Copy SQL files to C:\
        Write-Log "Copying SQL files to C:\..."
        $sqlFiles = @(
            "BAK3D_DB.sql",
            "CommonDBUpgradescript.sql",
            "updateesame3dbakupdated.sql",
            "updateesame3dpodsupdated.sql"
        )

        foreach ($file in $sqlFiles) {
            Copy-Item -Path $file -Destination "C:\" -Force
        }

        # Verify that SQL files were copied successfully
        $missingFiles = $sqlFiles | Where-Object { -not (Test-Path -Path "C:\$_" -PathType Leaf) }

        if ($missingFiles) {
            Write-Log "Failed to copy the following SQL files to C:\: $($missingFiles -join ', ')" "ERROR"
        } else {
            Write-Log "SQL files copied successfully to C:\"
        }
        Write-Log "==============================================================="

        # Install SQL Server 2014
        $installerPath = "SQLEXPRADV_x64_ENU\SETUP.EXE"
        $configFilePath = "SQLEXPRADV_x64_ENU\configuration.ini"
        Install-Software -installerPath $installerPath -installerArgs "/ConfigurationFile=$configFilePath" -softwareName "SQL Server 2014"

        # Update environment paths
        Write-Log "Updating environment paths..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Log "Environment paths updated."
        Write-Log "==============================================================="

        # Run SQL scripts to add the database
        Write-Log "Adding the database..."
        $databaseScripts = $sqlFiles

        foreach ($script in $databaseScripts) {
            sqlcmd.exe -S "$env:COMPUTERNAME\BAK3DSRVDB" -i "C:\$script"
            if ($LASTEXITCODE -ne 0) {
                Write-Log "Failed to execute $script" "ERROR"
            } else {
                Write-Log "Executed $script successfully"
            }
        }
        Write-Log "==============================================================="

        # Copy the patiententry folder and its contents to C:\
        Write-Log "Copying the patiententry folder and its contents to C:\..."
        Copy-Item -Path "patiententry" -Destination "C:\" -Recurse -Force

        if (-not (Test-Path -Path "C:\patiententry" -PathType Container)) {
            Write-Log "Failed to copy the patiententry folder and its contents to C:\" "ERROR"
        } else {
            Write-Log "PatientEntry folder and its contents copied successfully to C:\"
        }
        Write-Log "==============================================================="

        # Replace data source in PatientEntry.exe.config
        Write-Log "Updating data source in PatientEntry.exe.config..."
        $configPath = "C:\patiententry\PatientEntry.exe.config"
        (Get-Content -Path $configPath) -replace "NOMEPC", $($env:COMPUTERNAME) | Set-Content -Path $configPath
        Write-Log "Data source updated in PatientEntry.exe.config."
        Write-Log "==============================================================="

        # Run RegSetup.reg
        Write-Log "Running RegSetup.reg..."
        reg import "C:\patiententry\RegSetup.reg"
        Write-Log "RegSetup.reg executed successfully."
        Write-Log "==============================================================="

        # Set PatientEntry.exe compatibility mode and Run as administrator
        Write-Log "Setting compatibility mode and run as administrator for PatientEntry.exe..."
        $exePath = "C:\patiententry\PatientEntry.exe"
        $registryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
            Write-Log "Created registry path: $registryPath"
        }

        $compatLayer = (Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue).$exePath
        $newCompatLayer = " WIN7 RUNASADMIN".Trim()

        if ($compatLayer -notlike "*WIN7*" -or $compatLayer -notlike "*RUNASADMIN*") {
            New-ItemProperty -Path $registryPath -Name $exePath -Value $newCompatLayer -PropertyType String -Force
            Write-Log "Compatibility settings updated for $exePath"
            Write-Log "New settings: $newCompatLayer"
        } else {
            Write-Log "No changes were necessary. Current settings: $compatLayer"
        }
        Write-Log "==============================================================="

        # Create a shortcut on the desktop with the specified icon
        Write-Log "Creating a shortcut on the desktop..."
        $shortcutPath = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "PatientEntry.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $exePath
        $Shortcut.IconLocation = "C:\patiententry\MainArchive.ico"
        $Shortcut.Save()

        if (-not (Test-Path -Path $shortcutPath -PathType Leaf)) {
            Write-Log "Failed to create a shortcut on the desktop with the specified icon." "ERROR"
        } else {
            Write-Log "Shortcut created on the desktop with the specified icon."
        }
        Write-Log "==============================================================="
    }
    

    if ($checkBoxBMS.Checked) { 
        Write-Host "\n\n############################################################"
        Write-Host "#########################Install BMS########################"
        Write-Host "############################################################\n\n"

        Write-Log "#########################Install BMS########################"
        
        
        if (1) {
            # Instal CDM
            Install-Software -installerPath "CDM21218_Setup.exe" -softwareName "CDM21218"

            # Copy the  BMS folder and its contents to C:\
            Write-Log "Copying the BMS folder and its contents to C:\..."
            Copy-Item -Path "BMS" -Destination "C:\" -Recurse -Force
            Write-Log "Copying the BMS_ folder and its contents to C:\..."
            Copy-Item -Path "BMS_" -Destination "C:\" -Recurse -Force

            if (-not (Test-Path -Path "C:\BMS" -PathType Container)) {
                Write-Log "Failed to copy the BMS folder and its contents to C:\" "ERROR"
            } else {
                Write-Log "BMS folder and its contents copied successfully to C:\"
            }
            Write-Log "==============================================================="
            if (-not (Test-Path -Path "C:\BMS_" -PathType Container)) {
                Write-Log "Failed to copy the BMS_ folder and its contents to C:\" "ERROR"
            } else {
                Write-Log "BMS_ folder and its contents copied successfully to C:\"
            }
            Write-Log "==============================================================="

            # Run RegSetupCAMS.reg
            Write-Log "Running RegSetup.reg..."
            reg import "C:\BMS\RegSetup.reg"
            Write-Log "RegSetup.reg executed successfully."
            Write-Log "Running RegSetupCAMS.reg..."
            reg import "C:\BMS\RegSetupCAMS.reg"
            Write-Log "RegSetupCAMS.reg executed successfully."
            Write-Log "==============================================================="

            # Set BMS.exe compatibility mode and Run as administrator
            Write-Log "Setting compatibility mode and run as administrator for BMS.exe..."
            $exePath = "C:\BMS\BMS.exe"
            $registryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
                Write-Log "Created registry path: $registryPath"
            }

            $compatLayer = (Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue).$exePath
            $newCompatLayer = " WIN7 RUNASADMIN".Trim()

            if ($compatLayer -notlike "*WIN7*" -or $compatLayer -notlike "*RUNASADMIN*") {
                New-ItemProperty -Path $registryPath -Name $exePath -Value $newCompatLayer -PropertyType String -Force
                Write-Log "Compatibility settings updated for $exePath"
                Write-Log "New settings: $newCompatLayer"
            } else {
                Write-Log "No changes were necessary. Current settings: $compatLayer"
            }
            Write-Log "==============================================================="
        }
    }
    if ($checkBox3DPODS.Checked) {
        # Write-Host "\n\n############################################################"
        # Write-Host "#########################Install 3DPODS########################"
        # Write-Host "############################################################\n\n"

        # Write-Log "#########################Install 3DPODS########################"

        Write-Log "3DPODS Not Implemented Yet"
    }
    if ($checkBoxBAK3D.Checked) {
        # Write-Host "\n\n############################################################"
        # Write-Host "#########################Install BAK3D########################"
        # Write-Host "############################################################\n\n"
        
        # Write-Log "#########################Install BAK3D########################"

        Write-Log "BAK3D Not Implemented Yet"
    }

    Write-Log "==============================================================="

    Write-Log "Deleting temporary folders and files..."

    foreach ($folder in $tempFolders) {
        if (Test-Path $folder) {
            Remove-Item -Path $folder -Recurse -Force
            Write-Log "Deleted folder: $folder"
        } else {
            Write-Log "Folder not found: $folder"
        }
    }
    
    foreach ($file in $tempFiles) {
        if (Test-Path $file) {
            Remove-Item -Path $file -Force
            Write-Log "Deleted file: $file"
        } else {
            Write-Log "File not found: $file"
        }
    }

    Write-Log "Cleanup complete."
    Write-Log "==============================================================="
    Write-Log "Script execution completed."
    
    $form.Close()
})

$form.Controls.Add($buttonInstall)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Text = 'Cancel'
$buttonCancel.Location = New-Object System.Drawing.Point($buttonCancelX, $buttonCancelY)
$buttonCancel.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$buttonCancel.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonCancel)

# Function to check if any checkbox is checked
function CheckAnyCheckboxChecked {
    return $checkBoxBMS.Checked -or $checkBox3DPODS.Checked -or $checkBoxBAK3D.Checked
}

# Event handler to enable/disable the Install button based on checkbox selections
$checkBoxBMS.add_CheckedChanged({
    $buttonInstall.Enabled = CheckAnyCheckboxChecked
})
$checkBox3DPODS.add_CheckedChanged({
    $buttonInstall.Enabled = CheckAnyCheckboxChecked
})
$checkBoxBAK3D.add_CheckedChanged({
    $buttonInstall.Enabled = CheckAnyCheckboxChecked
})

$form.ShowDialog()