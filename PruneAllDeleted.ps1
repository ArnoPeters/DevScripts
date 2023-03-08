$requiresUserConfirmation = $false
$sourceDir = $pwd
write-host "starting in $sourceDir"
cd $sourceDir


function PruneDir {
    param(
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference'),
        $WhatIfPreference = $PSCmdlet.GetVariableValue('WhatIfPreference'),
        [Parameter(Mandatory)]
        [string]$Path
    )
    process {
       
        cd $Path

        if (Test-Path -Path ".git") {
 
            write-host "Cleaning directory: $($Path)" 

            # Get all latest info
            git fetch
            #git pull
            #git push

            # Get branch names
            $branchesToRemove = git branch -vv | where {$_ -match '\[origin/.*: gone\]'} | foreach {$_.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[0]}

            if($branchesToRemove -ne $null) {
                write-host "Branches to delete"
                write-host "=================="
                $branchesToRemove

                if ($requiresUserConfirmation) {
                $message  = 'Delete Branches'
                $question = 'Are you sure you want to proceed?'

                $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
                $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
                $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

                $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
                }

                if ($requiresUserConfirmation -eq $false -or $decision -eq 0) {
                    $branchesToRemove | foreach {write-host "Deleting " $_; git branch -D $_}
                }
            }
            else {
                write-host "No branches to delete."
            }
        }
        else 
        {   
            write-host "'$Path' is Not a GIT dir - checking subdirectories"
            $dirs = dir $Path | ?{$_.PSISContainer}
            foreach ($dir in $dirs) {
                PruneDir -Path $dir.FullName
            }
        }


    }
}


PruneDir -Path $sourceDir.Path

cd $sourceDir

write-host "Done"