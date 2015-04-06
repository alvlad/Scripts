#Скрипт просит ввести имя сервера к которому необходимо подключится
$ExchangeServer = Read-Host "Введите полное имя сервера"
#Запрашиваем учетные данные пользователя, под которым подключимся к серверу
$UserCredential = Get-Credential
#Создаем сессию подключения
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeServer/PowerShell/ -Authentication Kerberos -Credential $UserCredential
#Выполняем созданную сессию
Import-PSSession $Session