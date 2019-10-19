#.SYNOPSIS 
#       Create a VM, base on the Input of the Params
#
#.DESCRIPTION
#       This Script will create a VM for Hyper-V. The Mandatory Params are as follows:
#               - $name 
#               - $memory 
#               - $capacity 
#       All other Params are optional and this Tasks will be done manually
#
# .PARAMETER $name
#   This is the Name for the New VM
#.PARAMETER $memory
#   Mandatory, here you can specify the Starting Memory for the VM
#.PARAMETER $capacity
#   The Capacity of the VHD
#.PARAMETER $vhdpath
#   The Path of the New VHD
#.PARAMETER $sname
#   Optional: Here you can specify a Switch for the VM
#.PARAMETER $isofile
#   Optional: With this Parameter you can specify with which ISOFILE the VM will be started
#.PARAMETER $startaftercreation
#   Optional: Here you can specify if the VM will be started when the creation is finished!
#
#.EXAMPLE
#.\CreateVM.ps1 -Name WindowsServer -memory 8GB -capacity 10GB -vhdpath "F:\Virtuelle Maschinen\test2.vhdx" -sname "Default Switch" -isofile "F:\Downloads\Windows2k16.iso" -startaftercreation $false

param(
    [Parameter (Mandatory=$true, HelpMessage="This is the Name of the New VM")]
    [ValidateNotNull()]
    [string] $name,

    [Parameter (Mandatory=$true, HelpMessage="Use this Parameter to assign Memory to the VM")]
    [ValidateNotNull()]
    [Int64] $memory,

    [Parameter (Mandatory=$true, HelpMessage="Use this Parameter to specify the capacity of the VHD!")]
    [ValidateNotNull()]
    [Int64] $capacity,

    [Parameter (Mandatory=$true, HelpMessage="Use this Parameter to specify a VHD, if the VHD dosen´t exists it will be created")]
    [ValidateNotNull()]
    [string] $vhdpath,

    [Parameter (HelpMessage="Choose this Parameter if you want to assign a VM Switch to the New VM!")]
    [string] $sname,

    [Parameter (HelpMessage="Use this Parameter to attach an ISO File")]
    [string] $isofile,

    [Parameter (HelpMessage="Should the VM start after creation?")]
    [bool] $startaftercreation
)



if ( Test-Path -Path $vhdpath )
{
  if ( Test-Path $isofile)
  {
      if ($sname)
      {
        Write-Debug -Message "vhdpath, isofile and sname are validate"
        New-VM -Name $name -MemoryStartupBytes $memory -VHDPath $vhdpath -SwitchName $sname
        Set-VMDvdDrive -VMName $name -Path $isofile
      }
      
  }
}
else {
    Write-Host -ForegroundColor Green "vhdx is not avaible, will create it now"
    #We will create the VM and then attach the vhdx
    New-VM -Name $name -MemoryStartupBytes $memory

    #Now we will create the VHDX
    New-VHD -Path $vhdpath -SizeBytes $capacity

    #And now attach it...
    Add-VMHardDiskDrive -VMName $name -Path $vhdpath

    #Attach a Switch to the VM
    if ($sname)
    {
        Add-VMNetworkAdapter -VMName $name -SwitchName $sname
    }
    else {
        Write-Host "Can´t find Switch $sname, please add it manually! VM was created"
    }

    if ( Test-Path $isofile)
    {
        Set-VMDvdDrive -VMName $name -Path $isofile
    }
    else {
        Write-Host "Can´t find ISOFile $isofile, please add it manually, VM was created!"
    }

}


