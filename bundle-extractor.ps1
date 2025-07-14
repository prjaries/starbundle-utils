## ---------------------------
##
## Script name: bundle-extractor.ps1
##
## Purpose of script: parses and extracts TWC I2 starbundles for ease of exploration.
##
## Author: physicsprop
##
## Date Created: 05-13-2025
##
## ---------------------------

param(
    $starbundle
)

Function Move-Item-Parent([string]$path, [string]$destination) {
    $destinationpath = split-path -path $destination -parent
    New-Item $destinationpath -ItemType Directory -force
    Move-Item $path $destination
}

Expand-Archive -LiteralPath $starbundle -DestinationPath ".\temp"

write-host "Gatering bundle information..."

# Load in the manifest XML file
$actions = select-xml -Path ".\temp\MetaData\manifest.xml" -xpath "//StarBundle/FileActions/*"
$metadata = select-xml -Path ".\temp\MetaData\manifest.xml" -xpath "//StarBundle"

if ($metadata.node.version) {
$type = $metadata.node.type.tostring()
$version = $metadata.node.version.ToString()
write-host "Valid bundle detected."
write-host "This is a $type bundle, version $version"
} else {
write-host "Could not find any metadata. Closing."
exit
}

Write-Host "Actions for a recieving STAR:"
# Iterate through child nodes to see what they say.
foreach ($node in $actions.Node) {
    $source = $node.src.tostring()
    $destinationfile = $node.dest.tostring()
    $starflag = $node.starFlags.tostring()
    Write-Output "$source -> $destinationfile to be committed for $starflag"
    Move-Item-Parent -path .\temp\$source -destination $type-$version\$destinationfile
}
remove-item -path ".\temp" -force -recurse
