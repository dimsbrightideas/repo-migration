Param(
    [Parameter(Mandatory = $true)]
    [String]$TfsUrl,
    [Parameter(Mandatory = $true)]
    [String]$TfsPath,
    [Parameter(Mandatory = $true)]
    [String]$RepoUrl,
    [Parameter(Mandatory = $true)]
    [String]$RepoDirectory,
    [Parameter(Mandatory = $true)]
    [String]$RepoFolder,
    [Parameter(Mandatory = $true)]
    [String]$Branch
);

$env:GIT_REDIRECT_STDERR = '2>&1'

if ( -not ( Test-Path $RepoDirectory ) ) {
    throw "RepoDirectory specified does not exist."
}

#Make sure the repository folder exists.
$RepoPath = "$RepoDirectory\$RepoFolder"
New-Item -ItemType Directory -Force -Path $RepoPath

#Ensure the folder is empty so that we can clone into it.
Get-ChildItem -Path $RepoPath -Recurse | Remove-Item -Force -Recurse
Get-ChildItem -Path '.git' -Recurse | Remove-Item -Force -Recurse
Remove-Item '.git' -Force -ErrorAction SilentlyContinue

#Prepare for GIT.
Set-Location $RepoPath
Git init .

#Pull the destination branch.
Git remote add origin $RepoUrl
Git pull origin $Branch

#Clone TFS repo into a sub folder
Git tf clone $TfsUrl $TfsPath.Replace('/', '\') $RepoPath/TfsSource --deep
Get-ChildItem -Path $RepoPath/TfsSource -Filter '*.vs*cc' -Recurse | Remove-Item

#Connect to the folder and merge the changes into our current repo.
Git remote add --fetch tfs-source $RepoPath\TfsSource
Git merge tfs-source/master --allow-unrelated-histories -m 'Migrated from TFS to DevOps'
Git remote remove tfs-source

#Rename the branch from 'Master' to the destination branch name.
Git branch -m master $Branch

#Delete the source TFS Repo.
Get-ChildItem -Path $RepoPath\TfsSource -Recurse | Remove-Item -Force -Recurse
Remove-Item 'TfsSource' -Force -ErrorAction SilentlyContinue

#Commit any additional files & our merges.
Git add .
Git commit -m 'Added additional files during migration'
Git filter-branch --index-filter "git rm -r --cached --ignore-unmatch packages/" --prune-empty --tag-name-filter cat -- --all

#Push the changes to the destination repo.
Git remote add origin $RepoUrl
Git push -u origin $Branch
Git remote remove origin