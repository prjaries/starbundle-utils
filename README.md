Welcome to PhysicsProp's Starbundle Utilities, a set of powershell scripts made to help people work with the IntelliSTAR 2's StarBundle content packages. These can be run either on the unit or on another powershell compatible machine.

NOTE: this has not been tested in or developed for Constrained Language Mode (CLM). The deployement tool relies on injecting C# code in a created upgrade package in order to get around the I2's SSL limitations, and directly violates CLM. If you are not comfortable with that, you can still use the bundle creation script, however the HTTP distribution script won't be available.

For more info on CLM, go here: https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/

Bundle Creator

How to use:

1. Place your files within the input folder. Make sure the folder structure you want to have in place is what is represented in the input folder.

For example:

I have 2 files to store in C:\Program Files\vizrt\viz\data\image\domestic\backgrounds\OT-Aptos.
This would be a changeset bundle since its storing data in the Viz folders.
I would need to make the following path in the input folder:

image\domestic\backgrounds\test

and put my files in that folder


Same kind of thing for items in  C:\Program Files\TWC\I2\Managed
If i wanted to apply a theme file in Managed, I would create the following folder path in the input folder:

themes\domestic

and put my files in that folder


2. Run the script and answer the questions.



3. Presto! The output folder will have the ZIP file.


Bundle Installer Creator
1. Upload the file to a web server.


2. Run the script


3. Send the .zip file to the I2 as an upgrade file. Once the I2 processes it, it should be able to pull the file and apply it.


Bundle Extractor

1. Call the script with a parameter of "-starbundle", once complete you will see the files extracted into a subfolder.
