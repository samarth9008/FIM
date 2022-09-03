Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baselines?"
Write-Host "B) Begin monitoring files"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath){

   $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
   return $filehash

}

Function Del-Baseline(){

   $baselineexists = Test-Path -Path C:\Users\acer\Desktop\FIM\baseline.txt
   if($baselineexists){

      Remove-Item -Path C:\Users\acer\Desktop\FIM\baseline.txt
   
   }
}


if($response -eq "A".ToUpper()){
   Write-Host "Deleting old baselines if exists, Calculating Hashes and making a new baseline.txt"

   Del-Baseline

   #Collect files from the target folder
   $file = Get-ChildItem -Path C:\Users\acer\Desktop\FIM\Files

   #Calculate hashes for each files
   foreach ($f in $file){

      $hash = Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath C:\Users\acer\Desktop\FIM\baseline.txt -Append

   }
}

elseif($response -eq "B".ToUpper()){
   #Load file hash from baseline and create a dictionary

   Write-Host "Read exisitng Baseline.txt and start monitoring"

   $filehashdictionary = @{}

   $filepathandhashes = Get-Content -Path C:\Users\acer\Desktop\FIM\baseline.txt

   foreach ($f in $filepathandhashes){

      $filehashdictionary.Add($f.Split("|")[0],$f.Split("|")[1])

   }


   while($true){

      Start-Sleep -Seconds 1

      $file = Get-ChildItem -Path C:\Users\acer\Desktop\FIM\Files
      
      #Calculate hashes for each files
      foreach ($f in $file){

         $hash = Calculate-File-Hash $f.FullName

         if($filehashdictionary[$hash.Path] -eq $null){
            
            Write-Host "$($hash.Path) has been created!" -BackgroundColor Blue
           
         }

         else{
            
            if ($filehashdictionary[$hash.Path] -eq $hash.Hash){

            }

            else{
              Write-Host "$($hash.Path) has changed!!" -BackgroundColor Red
            }

         }

         foreach ($keys in $filehashdictionary.Keys){
           
           $iffileexists = Test-Path -Path $keys

           if (-Not $iffileexists){
             Write-Host "$($keys) is deleted !!"
           }

         }
      
      }

   }
}