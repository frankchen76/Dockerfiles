param (
    #[Parameter(Mandatory=$true)]
    [string]$path="C:\DockerProjects\spfx1"
)

$jsFile = $path+"\node_modules\@microsoft\sp-build-web\lib\SPWebBuildRig.js"
$jsBakFile = $path+"\node_modules\@microsoft\sp-build-web\lib\SPWebBuildRig.js.bak"
$jsContent = Get-Content $jsFile -Raw

#$jsContent.Insert(87, "if (!spBuildCoreTasks.writeManifests.taskConfig.debugBasePath) {");
#$jsContent.Insert(90, "}");

#rename
Rename-Item -Path $jsFile -NewName $jsBakFile
write-host "Backup $($jsFile) to $($jsBakFile)"

$source = "spBuildCoreTasks.writeManifests.mergeConfig({
            debugBasePath: \`\${serve.taskConfig.https ? 'https' : 'http'}://\${serve.taskConfig.hostname}:${serve.taskConfig.port}/\`
        });"

$target=@"
if (!spBuildCoreTasks.writeManifests.taskConfig.debugBasePath) {
    spBuildCoreTasks.writeManifests.mergeConfig({
        debugBasePath: \`\${serve.taskConfig.https ? 'https' : 'http'}://${serve.taskConfig.hostname}:\${serve.taskConfig.port}/\`
    });
}"
"@
$jsNewContent = $jsContent -replace $source, $target
Set-Content -Path $jsFile -Value $jsNewContent

#$jsContent | Set-Content ($jsFile)
write-host "Updated js to $(jsFile)"



$serveJson = $path+"\config\serve.json";
$serveBakJson = $path+"\config\serve.json.bak";

$serveObj = Get-Content $serveJson | ConvertFrom-Json
$included = [bool]($serveObj.PSobject.Properties.name -match "hostname")
if($included -eq $false)
{
    #rename
    Rename-Item -Path $serveJson -NewName $serveBakJson
    write-host "Backup $($serveJson) to $($serveBakJson)"

    $serveObj | Add-Member -NotePropertyName hostname -NotePropertyValue "0.0.0.0"
    $serveObj | ConvertTo-Json | Out-File $serveJson
    write-host "Updated hostname to $(serveJson)"
}

$manifestJson = $path + "\config\write-manifests.json";
$manifestBakJson = $path + "\config\write-manifests.json.bak";

$manifestObj = Get-Content $manifestJson | ConvertFrom-Json
$included = [bool]($manifestObj.PSobject.Properties.name -match "debugBasePath")
if($included -eq $false)
{
    #rename
    Rename-Item -Path $manifestJson -NewName $manifestBakJson
    write-host "Backup $($manifestJson) to $($manifestBakJson)"

    $manifestObj | Add-Member -NotePropertyName debugBasePath -NotePropertyValue "https://localhost:4321/"
    $manifestObj | ConvertTo-Json | Out-File $manifestJson
    write-host "Updated debugBasePath to $(manifestJson)"
}

$jsFile = $path+"\node_modules\@microsoft\sp-build-web\lib\SPWebBuildRig.js"
$jsBakFile = $path+"\node_modules\@microsoft\sp-build-web\lib\SPWebBuildRig.js.bak"
$jsContent = Get-Content $jsFile

#rename
Rename-Item -Path $jsFile -NewName $jsBakFile
write-host "Backup $($jsFile) to $($jsBakFile)"

$source="spBuildCoreTasks.writeManifests.mergeConfig({
            debugBasePath: `${serve.taskConfig.https ? 'https' : 'http'}://${serve.taskConfig.hostname}:${serve.taskConfig.port}/`
        });"
$target="if (!spBuildCoreTasks.writeManifests.taskConfig.debugBasePath) {
    spBuildCoreTasks.writeManifests.mergeConfig({
    debugBasePath: `${serve.taskConfig.https ? 'https' : 'http'}://${serve.taskConfig.hostname}:${serve.taskConfig.port}/`
        });
}"
Get-Content $jsFile | ForEach-Object { $_ -replace $source, $target } | Set-Content ($jsFile)
write-host "Updated js to $(manifestJson)"
