.\MigrateTfsToGit.ps1 `
    -TfsUrl 'http://vmtfs01.sportski.com:8080/tfs/defaultcollection' `
    -TfsPath '$/IT/Apps/EDI_Viewer' `
    -RepoUrl 'https://github.com/frasers-dim/migration-test-repo-tfs.git' `
    -RepoDirectory 'C:\Users\dagejev\Source\Repos' `
    -RepoFolder 'EDI_Viewer' `
    -Branch 'main'