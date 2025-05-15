#!/bin/bash

check_java() {
    list_java=$(update-alternatives --list java 2>&1 | awk -F'-' '/java/ {print $2}')

    required_version="8" # Define the required version

    found=false
    for version in $list_java; do
        if [ "$version" == "$required_version" ]; then
            found=true
            break # Exit the loop if the required version is found
        fi
    done

    if [ "$found" = true ]; then
        echo "Java version $required_version is already installed."
       
        switch_java
    else
        echo "You don't have the required version."
        echo "Would you like to install it? Type (Yes/No)"
        read Result

        case "$Result" in
            [Yy][Ee][Ss])
                sudo apt update
                sudo apt-get install openjdk-"$required_version"-jdk -y
                if [ $? -eq 0 ]; then
                    echo "Java $required_version has been installed successfully."
                else
                    echo "Java installation failed. Please check and try again."
                fi
                ;;
            *)
                echo "Java installation cancelled."
                exit
                ;;
        esac
    fi
}
switch_java(){
 # Check the current Java version
current_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
 echo "Current Java version is $current_version"
# Check if the current version is not 8  
if [ $current_version != *"8"* ]; then
        echo "Switching to Java 8..."
        sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
        java -version 2>&1 | awk -F '"' '/version/ {print $2}'
        echo "Switched successfully."
fi

}
check_java
check_mysql(){
   list_mysql=$(mysql --version | awk '{print $5}' |cut -d"," -f1)

    required_version="5.7.42" # Define the required version

    found=false
    for version in $list_mysql; do
        if [ "$version" == "$required_version" ]; then
            found=true
            break # Exit the loop if the required version is found
        fi
    done

    if [ "$found" = true ]; then
        echo "Mysql version $required_version is already installed."
    else
        echo "You don't have the required version of MySql."
        echo "Would you like to install it? Type (Yes/No)"
        read Result

        case "$Result" in
            [Yy][Ee][Ss])
                sudo apt install wget -y
            wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
            sudo dpkg -i mysql-apt-config_0.8.12-1_all.deb
            sudo apt-cache policy mysql-server
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
            sudo apt update
            sudo apt install -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
                if [ $? -eq 0 ]; then #$? represents the exit status of the last command executed.
                                      #-eq is an operator used to check for equality.
                                      #0 is the exit code that typically indicates success in most Unix-like systems. A command returning an exit status of 0 usually means it executed successfully.
                    echo "Mysql $required_version has been installed successfully."
                else
                    echo "Mysql installation failed. Please check and try again."
                fi
                ;;
            *)
                echo "Mysql installation cancelled."
                exit
                ;;
        esac
    fi
    }
 check_mysql
db_name="mfin_synergy"
check_database(){
    if mysql -u root -p -e "SHOW DATABASES;" | grep "$db_name"
     then
        echo "Database exits.Do you want to restore? Type(Yes/No)"
        read Result
        case "$Result" in
        [Yy][Ee][Ss])
          mysql -uroot -p "$db_name" < /home/puja/GlassfishScript/Database/mfin_db.sql
          ret=$?
          if (($ret != 0)); then
             echo "Restoring the database failed with exit status $ret!"
          else 
            echo "Sucessfully restored the database"
          fi
         ;;
        *)
          echo "Well, then lets check the war file."
            ;;
    esac  
    else
        echo "Required database does not exist."
        echo "Do you want to create new database?"
        read Result
        case "$Result" in
        [Yy][Ee][Ss])
         mysql -u root -p -e "CREATE DATABASE $db_name;" #-e is followed by the SQL statement that you want to execute without entering the interactive MySQL shell
         mysql -uroot -p "$db_name" < mfin_db.sql
      ;;
        *)
          echo "Database installation cancelled."
          exit
            ;;
    esac  
fi
}

file_path=$(find /home/puja/GlassfishScript/Database -name "mfin_db.sql")
if [ -n "$file_path" ]; then  # -n checks file_path is non-empty or not.
       echo "You have required database file, Now lets check the database"
       check_database
else
     echo "Bye,You do not have the required database file"
     exit 
fi

file_path=$(find /home/puja/GlassfishScript/WarFiles -name "synergy.war")
if [ -n "$file_path" ]; then
     echo "You do have the required war file. Lets check the domain status"
 
else
     echo "Bye,You do not have the required war file"
     exit 	
fi
#!/bin/bash

# Function to change domain.xml values
change_domain_value() {
    domain_xml="/home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/domains/domain1/config/domain.xml"

    if [ ! -f "$domain_xml" ]; then
        echo "domain.xml file not found!"
        exit 1
    fi

    read -p "Enter the new value for Xmx in MB (e.g., 4096): " new_xmx_value

    # Add 'm' after the user input for megabytes
    new_xmx_value="${new_xmx_value}m"

    # Replace the <jvm-options>-Xmx</jvm-options> pattern with the new value
    sed -i "s|<jvm-options>-Xmx[0-9]*[mMgG]*</jvm-options>|<jvm-options>-Xmx$new_xmx_value</jvm-options>|g" "$domain_xml" #-i: Enables in-place editing of the file.
                                             #s: Indicates the subsititution process.
    echo "Xmx value updated to $new_xmx_value in domain.xml"
}

# Function to check war deployment status and take actions accordingly
check_war_deployment() {
    deployment_status=$(bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin list-applications)

    if [[ $deployment_status == *"synergy"* ]]; then
        echo "War file is deployed already. Do you want to redeploy?"
        read result
        case "$result" in
            [Yy][Ee][Ss]) 
                bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin redeploy --name synergy /home/puja/GlassfishScript/WarFiles/synergy.war
                ;;
            *)
                echo "Redeployment cancelled"
               
                ;;
        esac
    else
        echo "First, you need to deploy the war file. Do you want to deploy?"
        read result
        case "$result" in
            [Yy][Ee][Ss]) 
                bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin deploy --name synergy /home/puja/GlassfishScript/WarFiles/synergy.war
                ;;
            *)
                echo "Deployment cancelled"
                exit
                ;;
        esac
    fi
}

# Function to redirect to the log file
log_file() {
    echo "Redirecting to the log file.."
    tail -F /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/domains/domain1/logs/server.log
}

file_path=$(find /home/puja/GlassfishScript/Glassfish -name "asadmin")
if [ -n "$file_path" ]; then
   domain_status=$(bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin list-domains)
    if [[ $domain_status == *"not running"* ]]; then
        echo "Domain is not running"
        echo "Do you want to make changes in system file"
        read result
        
        case "$result" in
            [Yy][Ee][Ss])
                change_domain_value
                change_domain_status=$?
                if [ $change_domain_status -eq 0 ]; then 
                    check_war_deployment
                    check_war_status=$?
                    if [ $check_war_status -eq 0 ]; then
                        log_file
                    fi
                fi
                ;;
            *)
                echo "You choose not to make changes in system file. Now starting the server. "
                bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin start-domain domain1
                check_war_deployment
                 check_war_status=$?
                  if [ $check_war_status -eq 0 ]; then
                    log_file
                  fi
                
                ;;
        esac
    else
        echo "Domain is running"
        echo "First, you need to stop the domain to make changes in .xmx file"
        echo "Do you want to stop the server and make changes?"
        read result
        
        case "$result" in
            [Yy][Ee][Ss]) 
                bash /home/puja/GlassfishScript/Glassfish/glassfish3/glassfish/bin/asadmin stop-domain domain1
                stop_domain_status=$?
                if [ $stop_domain_status -eq 0 ]; then
                    change_domain_value
                    change_domain_status=$?
                    if [ $change_domain_status -eq 0 ]; then 
                        check_war_deployment
                        check_war_status=$?
                        if [ $check_war_status -eq 0 ]; then
                            log_file
                        fi
                    fi
                fi
                ;;
            *)
                echo "Checking the war file"
                check_war_deployment
                check_war_status=$?
                if [ $check_war_status -eq 0 ]; then
                    log_file
                fi
                ;;
        esac
    fi
else 
    echo "You don't have the Glassfish setup." 
fi


  

