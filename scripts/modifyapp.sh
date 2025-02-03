#!/bin/bash

# Define the file path for the PetClinicApplication.java file
java_file="${HOME}/Workshop2/spring-petclinic/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java"
pom_file="${HOME}/Workshop2/spring-petclinic/pom.xml"

# Check if the file exists
if [[ -f "$java_file" ]]; then

    # Add the import for SpringBootServletInitializer
    sed -i '/package org.springframework.samples.petclinic;/a import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;' "$java_file"

    # Modify the class declaration to extend SpringBootServletInitializer
    sed -i 's/public class PetClinicApplication {/public class PetClinicApplication extends SpringBootServletInitializer {/g' "$java_file"


    
  #  echo "PetClinicApplication.java has been modified successfully."
#else
   # echo "File not found: $java_file"
fi

# Check if the pom.xml exists
if [[ -f "$pom_file" ]]; then
  
    # Check if the <packaging> tag already exists, if not add it
    if ! grep -q "<packaging>" "$pom_file"; then
        # Add the <packaging>war</packaging> tag inside the <project> element, after <parent> element
        sed -i '/<\/modelVersion>/a \ \ <packaging>war</packaging>' "$pom_file"
       
   # else
       # echo '<packaging>war</packaging> already exists in the pom.xml.'
    fi

    if ! grep -q "<finalName>" "$pom_file"; then
	# Add the <finalName> tag inside the <build> section to avoid version/snapshot in the WAR name
        sed -i '/<build>/a \ \ \ \ <finalName>petclinic</finalName>' "$pom_file"
        #echo '<packaging>war</packaging> and <finalName>petclinic</finalName> have been added to the pom.xml.'
    fi
    
#else
   # echo "File not found: $pom_file"
fi

