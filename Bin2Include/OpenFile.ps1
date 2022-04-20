$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
}
$FileBrowser.Title = $args[0]
$initial = $args[1].ToString().Replace("/","\")
$FileBrowser.InitialDirectory = $initial
$chosenfilter = $args[2].ToString().Replace("^/^","|")
$FileBrowser.Filter = $chosenfilter

$null = $FileBrowser.ShowDialog()
$FileName = $FileBrowser.FileName
if ($FileName -ne ''){
$FileName > 'openfilename.txt'
exit 1
}
else{
exit 0
}