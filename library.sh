#!/bin/bash
borrow()
{
	rollno=$1
	echo $rollno
	avail=0
	echo -e "List of all books and their number of available copies\n\n"
	cat books
	echo "Enter serial number of the book to be issued:"
	read ser
	awk -F"|" '{if($1=="'"$ser"'") $4=$4-1;{print $1 "|" $2 "|" $3 "|" $4}}' books > bookstemp
	cp bookstemp books
	grep -n "$ser|" books | cut -d ":" -f 1 > student1
	ln2=$(<student1)
	head -$ln2 books | tail -1 | cut -d "|" -f 4 > mp.txt
	avail=$(<mp.txt)
	
	if [ $avail -eq -1 ]
	then
		echo "Book not available"
		awk -F"|" '{if($1=="'"$ser"'") $4=$4+1;{print $1 "|" $2 "|" $3 "|" $4}}' books > bookstemp
		cp bookstemp books
	else
		echo "Book successfully issued"
		grep -n "$rollno|" borrowedbooks | cut -d ":" -f 1 > student1
  		ln3=$(<student1)
  		head -$ln3 borrowedbooks | tail -1 | cut -d "|" -f 2 > mp.txt
		alreadyborrowed=$(<mp.txt)
		awk -F"|" '{if($1=="'"$rollno"'") $2="'"$alreadyborrowed"'" "'"$ser"'" "'":"'" ; {print $1 "|" $2 }}' borrowedbooks > bookstemp
		cp bookstemp borrowedbooks
	fi 
}

returnbook()
{
	echo "Borrowed books are: "
	grep -n "$rollno|" borrowedbooks | cut -d ":" -f 1 > student1
	ln4=$(<student1)
	head -$ln4 borrowedbooks | tail -1 | cut -d "|" -f 2 > mp.txt
	alreadyborrowed=$(<mp.txt)
	i=1
	x1=1
  
	while [ $x1 ]
  	do
		cut -d ":" -f $i mp.txt > x
  		x1=$(<x)
  		i=$(echo "$i+1" | bc)
  		awk -F"|"  '{if($1=="'"$x1"'") {print $1 "    " $2 "    " $3 };}' books 
  	done

	echo serial number of book to be returned
	read ser2
	x1=1
	i=1
	cut -d ":" -f $i mp.txt > x
	x1=$(<x)
	i=2
	
	while [ $x1 ]
	do
  		if [ $x1 -ne $ser2 ]
  		then
 			echo -n "$x1" >> y
 			echo -n ":">>y
  		fi 
  		cut -d ":" -f $i mp.txt > x
  		x1=$(<x)
  		i=$(echo "$i+1" | bc)
  	done

	y11="$(< "y")"
	h=$(echo $y11 | tr -d '\015')
	echo  "" > y
	awk -F"|" -v var="$h" '{if($1=="'"$rollno"'") $2 = var;print $1"|"$2}' borrowedbooks > bookstemp
	cp bookstemp borrowedbooks
}

viewlistall()
{
	cat books
}

viewlistborrowed()
{
	echo "Your borrowed books are: "
	grep -n "$rollno|" borrowedbooks | cut -d ":" -f 1 > student1
  	ln4=$(<student1)
   	head -$ln4 borrowedbooks | tail -1 | cut -d "|" -f 2 > mp.txt
   	alreadyborrowed=$(<mp.txt)
  	i=1
  	x1=1
  
  	while [ $x1 ]
  	do
		cut -d ":" -f $i mp.txt > x
  		x1=$(<x)
  		i=$(echo "$i+1" | bc)
  		awk -F"|" '{if($1=="'"$x1"'") {print $1 "    " $2 "    " $3 };}' books 
   	done 
}

studentmainpage()
{
	rollno=$1
	cn=1
	
	while [ $cn -eq 1 ]
	do
		echo -e "\tSTUDENT MAIN PAGE"
		echo -e "1. Issue book.\n2. Return book\n3. View all books\n4. View list of borrowed books\n5. Logout\n"
		read studentchoice
		
		case $studentchoice in
		1)borrow $rollno
		;;
		2)returnbook $rollno
		;;
		3)viewlistall $rollno
		;;
		4)viewlistborrowed $rollno
		;;
		5)exit
		;;
		*)echo "Wrong choice entered. Try again"
		esac
	done
}


loginpage()
{
	echo "REGISTERED"
   	echo "Enter your roll number: "
   	read rollno
	c2=1
	cut -d "|" -f 2 studentdatabase > student1 
   	awk '$0=="'"$rollno"'" ' student1 > mp.txt
   	b1=$(wc -l mp.txt | cut -d " " -f 1)
   
   	if [ $b1 -eq 0 ]
   	then
   		echo "Roll number doesnt exist.Try again." 
         	student
	break
        else
    		grep -n "|$rollno|" studentdatabase | cut -d ":" -f 1 > student1
  		ln1=$(<student1)
   		head -$ln1 studentdatabase | tail -1 | cut -d "|" -f 3 > mp.txt
   		pss1=$(<mp.txt)
   	fi     
   
   	while [ $c2 -eq 1 ]
   	do
   		printf "Enter password: "
   		read -s ps1
   		echo ""
		
		if [ $pss1 == $ps1 ]
		then
			echo "logged in successfully"
			studentmainpage $rollno
			c2=0
		else
		echo "wrong password. Try again."
		fi
	done
}

registerpage()
{
   	echo "New Student"
   	printf "Enter name: "
   	read name
   	printf "Enter roll number: "
   	read rollnum
   	cut -d "|" -f 2 studentdatabase > student1 
   	awk '$0=="'"$rollnum"'" ' student1 > mp.txt
   	b1=$(wc -l mp.txt | cut -d " " -f 1)
   
   	if [ $b1 -eq 1 ]
   	then
   		echo "Roll number exists. Try again"
         	student
         	c1=0
       	fi
   
	while [ $c1 -eq 1 ]
   	do
   		printf "Enter password: "
   		read -s ps1
   		echo ""
   		printf "Re enter password: "
   		read -s ps2
   		echo ""
   
   		if [ $ps1 == $ps2 ]
   		then 
			c1=0
   			echo -n "$name|" >> studentdatabase
   			echo -n "$rollnum|">>studentdatabase
   			echo "$ps1">>studentdatabase
   			echo "$rollnum|">>borrowedbooks
			echo "Congratulations! You have registered successfully"
        		loginpage
   		else
			echo "Password do not match. Try again"
   		fi
   	done
}

student()
{
	c1=1
	echo -e "Enter 1 if you're a new student\nEnter 2 if already registered"
	read newreg
	
	case $newreg in
	1) registerpage
   	;;
  	2) loginpage
  	;; 
	*) echo "Wrong choice. Try again"
   	esac
}

viewbooks()
{
	cat books
} 


viewstud()
{
	cut -d "|" -f 1,2 studentdatabase
}

addbook()
{
	echo "enter 1 for existing book"
	echo "enter 2 for new book"
	read cbook
	
	case $cbook in
	1)echo enter the serial number of the book to be added
	  read book1
	  grep -n "|$book1|" books | cut -d ":" -f 1 > student1
 	  ln1=$(<student1)
 	  head -$ln1 books | tail -1 | cut -d "|" -f 4 > mp.txt
 	  ncexist=$(<mp.txt)
	  echo $ncexist
	  echo enter no of extra copies to be added
	  read nc1
	  n1=$(echo "$ncexist + $nc1" | bc)
	  echo $n1
	  awk -F"|" '{if($2=="'"$book1"'") $4="'"$n1"'";{print $1 "|" $2 "|" $3 "|" $4}}' books > bookstemp
	;;

	2)echo enter the no of new books
	  read tynn
	  for (( i=1; i<=$tynn; i++ ))
          do
	  echo "Enter serial number of book $i" 
	  echo -n "$i|" >> books
	  echo enter the name of the book
	  read book2
	  echo -n "$book2|" >>books
	  echo enter author
	  read author2
	  echo -n "$author2|" >>books
	  echo enter no of copies to be added
	  read nc2
	  echo "$nc2" >>books
	  done
	;;
	esac
}

changepass()
{
	ccp=1
	while [ $ccp -eq 1 ]
	do
		echo enter current password
		read -s p1

		if [ $p1 == $pass ]
		then
			echo enter new password
			read -s pp1
			echo confirm password
			read -s pp2
        		if [ $pp1 == $pp2 ]
			then
				ccp=0
				echo password change success
				echo $pp1 > secret
			else 
				echo password dont match.
				echo re-enter
			fi
		fi
	done
}



librarian()
{ 
	clib=1  		

	while [ $clib -eq 1 ]
	do
		echo -e "Enter 1 to view list of books\nEnter 2 to view student database\nEnter 3 to add books\nEnter 4 to change authentication password\nEnter 5 to logout"
		read choicelib
		case $choicelib in
		1)clib=0
		viewbooks
		;;
		2)clib=0
		viewstud
		;;
		3)clib=0
		addbook
 		;;
		4)clib=0
		changepass
		;;
		5)clib=0 
         	exit
	  	;;
		*)echo "Wrong choice entered. Try again"
		esac
	done
}

echo -e "\t\t\tWELCOME TO THE LIBRARY"

pass=$(<secret)

cont=1
while [ $cont -eq 1 ]
do 
	echo -e "Enter 1 for librarian\nEnter 2 for student"
	read libstud
	case $libstud in
	1) echo -e "\tLIBRARIAN"
   	printf "Enter password: "
   	read -s pass1
   	echo ""
   	if [ $pass == $pass1 ]
   	then
		echo "Access Granted"
        	librarian
   	else
		echo "Access Denied"
   	fi
   	cont=0
   	;;
	2) echo -e "\tSTUDENT"
   	cont=0
   	student
   	;; 
	*) echo "Wrong choice. Try again"
 	esac
done

