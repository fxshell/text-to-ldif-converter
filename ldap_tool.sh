#!/bin/bash

#Filename: ldap_tool.sh
#Created by: fxshell
#Mail: snaped4@hotmail.com

#I DO NOT TAKE ANY RESPONSIBILITY FOR WHAT THIS TOOL DOES!
#Before using this tool you need to adjust password & IP Adress.

#Take what u can use and garbage the rest.
#Cheers, fx

# ----------------------------------------------------------------------------
#	usage: display usage information intended for the end user

function usage() {
	cat - <<END_OF_USAGE
	With this script can you easily import many users ato once in ldap.
	All you need to provide is a file with username and password called users.txt
	(Username and password need to be separated with a space).
	
	Then you can create the LDIF file for this users by using the create command.

	-create [pathofUsers.txt]
		creates the LDIF files.

	-import
		Run this AFTER you did the create command.
		It uploads the create.ldif to the LDAP server.

	-delete
		Run this AFTER you did the create command.
		It uploads the delete.ldif to the LDAp server and deletes the entries.

	-changepw
		change password of user

	-print
		print users

END_OF_USAGE
} # function usage}

function main(){
:
}

function import_func(){
l_path="$1"
g_fd="unknown"
randomvar=1100
echo "parsing '$l_path'"
exec {g_fd}<"${l_path}";
	while read -u "$g_fd" l_name l_password; do
#		echo "USER"
#		echo $l_name
#		echo $l_password
		randomvar=$((randomvar+1))
		first=$(<pre.txt)
		after=$(<attributes.txt)
cat >>create.ldif <<EOL
dn: uid=${l_name},ou=messe,dc=megagiga,dc=ch
changetype: add
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: ${l_name}
uid: ${l_name}
uidNumber: ${randomvar}
gidNumber: ${randomvar}
homeDirectory: /home/${l_name}
loginShell: /bin/bash
gecos: ${l_name}
userPassword: ${l_password}
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0

EOL

cat >>delete.ldif <<EOL
dn: uid=${l_name},ou=messe,dc=megagiga,dc=ch
changetype: delete
cn: ${l_name}
uid: ${l_name}
uidNumber: ${randomvar}
gidNumber: ${randomvar}
homeDirectory: /home/${l_name}
loginShell: /bin/bash
gecos: ${l_name}
userPassword: ${l_password}

EOL

#cat pre.txt >> test.txt
done

echo "LDIF FILE CREATED - NOW DO IMPORT OR DELETE"
}

function second_importfunc(){
ldapadd -x -D "cn=admin,dc=megagiga,dc=ch" -w BitConnect1337- -H ldap:// -f create.ldif
}

function deletefunc(){
ldapmodify -x -D "cn=admin,dc=megagiga,dc=ch" -w BitConnect1337- -H ldap:// -f delete.ldif
}

function printuser(){
	ldapsearch -xLLL -H ldap:/// -b "ou=messe,dc=megagiga,dc=ch"

}

function changepw(){
	echo "Enter user:"
	read userpw
	ldappasswd -H ldap://10.10.5.200 -x -D "cn=admin,dc=megagiga,dc=ch" -W -S "uid="$userpw",ou=messe,dc=megagiga,dc=ch"
	echo "SUCCES!"
}

while (( $# )) ; do     # eat up all positional parameters or loop forever
        g_cmd="$1"
	g_call_main="yes"
        shift   # eats up $1

        case "${g_cmd}" in
              
		-changepw)
		changepw
			
		;;

		-print)
			printuser
			shift
			;;

		-create)
			diskpath="${1}"
			echo "You entered the path of file $diskpath"
			import_func $diskpath
			shift
			;;
		-import)
       			second_importfunc			
			;;
		-delete)
			deletefunc
			;;
		-h|--help|help)
                        usage
                        g_result=0      # true
                        g_call_main="no"
                        break
                        ;;

		*)	
                        echo "unknown option or unexpected parameter - BREAK"       # never returns
                        exit 1          # make shure: yust in case, die returns ...
                        ;;
        esac
done
# ----------- CALL MAIN -------------- #

[ "${g_call_main}" = "yes" ]    &&  main "$@"

#
# -------------------------------------------------------------------
# End of File
