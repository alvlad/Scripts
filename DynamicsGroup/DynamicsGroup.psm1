<#
.Synopsis
   The script adds users,which have a mailbox, to group

.DESCRIPTION
   The script allows to add the users having postal addresses to group of safety
   At start of a script it is necessary to transfer a name of necessary group to the GroupName parameter
   and name organization unit, where it is necessary to look for users

.Parameter GroupName
   Group to which users will be added

.Parameter SearchOU
   OU in which it is necessary to find users for addition in group

.Parameter CountAddUser
   The counter of the users added to group. Increases with each new user

.Parameter MailUsers
   The massif supporting users with the filled Email addresses attribute, from a selected OU

.Parameter Group
   Contains a full LDAP way to group to which it is necessary to add users

.Parameter members
   Supports members of group to which users are added. Serves for definition of presence of the user in this group

.Example
   Import-Module -Name DynamicsGroup
   Add-UsersGroup -GroupName "TestGroup" -NameOU "Test OU"

.Notes
    Author:
        Alyushin Vladislav
        05/30/2016

    Related URLs:
        Original Git Repo: https://github.com/alvlad/Scripts
#>
function Add-UsersGroup
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Parameter contains a name of group
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Group to which users will be added",
                   Position=0)]
        $GroupName,

        # Parameter contains division where it is necessary to look for users
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage = "Organization unit in which it is necessary to find users for addition in group",
                   Position=1)]
        $NameOU
    )

    Begin
    {
        # Import Active Directory powershell module
        Import-Module ActiveDirectory

        # Install the counter of users
        $CountAddUser=0

        # Define a LDAP way to OU with users
        $DsNameOU = (Get-ADOrganizationalUnit -Filter 'Name -like $NameOU').DistinguishedName

        # Receive the users having an email address
        $MailUsers = Get-ADUser -Filter {mail -like '*'} -SearchBase $DsNameOU -Properties Mail

        # Receive LDAP way to destination group
        $group = (Get-ADGroup -Filter 'Name -like $GroupName').DistinguishedName

    }
    Process
    {
            try
            {
                # Start a cycle for addition of users in group
                foreach ($MailUser in $MailUsers)
                {
					# Receive the current members of group
                    $members = Get-ADGroupMember -Identity $GroupName -Recursive | Select -ExpandProperty Name

					# Check whether there is a user at group
                    if ($members -notcontains $MailUser.Name)
                    {

                        # Add user to group
                        Write-Host "Add user" $MailUser.Name "to group $GroupName" -ForegroundColor Green
                        Add-ADGroupMember -Identity $group -Members $MailUser -ErrorAction Continue
                        
                        # Increase the counter of the added users
                        $CountAddUser++
                    }

                    else
                    {
                        # Выводим сообщение о присутствии пользователя в группе
                        Write-Host "The user" $MailUser.Name "is already present at group $GroupName" -ForegroundColor Green
                    }
                }
              }
            Catch
            {
                # Display the message on presence of the user at group
                Write-Host $Error                
            }
            finally
            {
				# Output the number of the added users
                Write-Host "The number of the added users $CountAddUser" -ForegroundColor Green
            }
     }
   End
   {
		# Finish work scripts
        Write-Host "Work of a script is complete!" -ForegroundColor Green
   }
}