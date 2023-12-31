#!/usr/bin/env sh
# Did I go overboard with the error checking
# Licensed under MIT

# Absolute path to ecs100.jar
ECS100LIBPATH="$HOME/projects/programming/java/lib/ecs100.jar"

# A little warning, just in case.
if [ -z "$(find . -path './*.java')" ]; then
	echo "Are you sure you're in the right folder? No java files found"
	printf "Continue? [y/N]: "

	read -r inp

	if ! { [ "$inp" = "y" ] || [ "$inp" = "Y" ]; }; then
		exit 1
	fi
fi

# Check that the jar actually exists.
if ! [ -f "$ECS100LIBPATH" ]; then
	echo 2>&1 "The file $ECS100LIBPATH doesn't exist.."
	exit 2
fi

# Is there a gradle file already?
if [ -f "build.gradle" ]; then
	echo 2>&1 "build.gradle already exists. What are you doing..?"
	exit 3
fi

if [ -f "lib/ecs100.jar" ]; then
	echo 2>&1 "There's already a lib/ecs100.jar. I'm not dealing with this."
	exit 4
fi

# Can provide the main class as an arg, otherwise just use the folder.
# The assignment folders usually have the name of the main class.
mainclass=$1
if [ -z "$mainclass" ]; then
	mainclass="$(basename "$(pwd)")"
fi

echo "Using $mainclass as main class"

# Make our gradle file
# File adapted from https://stackoverflow.com/q/20700053
cat <<EOF >build.gradle
/* A. java plugin, sourcesets, and dependencies are necessary to get this building  */
/* B. application plugin, and application for running with \`gradle run\` */

/*
 * Sources:
 * A. https://stackoverflow.com/q/20700053         
 * B. https://www.baeldung.com/gradle-run-java-main
 * B. https://docs.gradle.org/8.2.1/dsl/org.gradle.api.plugins.JavaApplication.html
 */

plugins {
  id "application"
  id "java"
}


application {
  mainClass.set("$mainclass")
}

// Use the current directory for source files
sourceSets {
  main {
    java {
      srcDir '.'
    }
  }
}

// We use java 17, right?
java {
    sourceCompatibility = JavaVersion.VERSION_17
}

dependencies {
  implementation files('lib/ecs100.jar')
}
EOF

# Actually add our ecs100.jar
mkdir -p "lib"
ln -s "$ECS100LIBPATH" lib/ecs100.jar

# Add a clang format file as well.
# Generated by https://zed0.co.uk/clang-format-configurator/
cat <<EOF >.clang-format
---
BasedOnStyle: Google
AllowShortBlocksOnASingleLine: 'false'
AllowShortFunctionsOnASingleLine: None
AllowShortIfStatementsOnASingleLine: Never
ColumnLimit: 120
BreakAfterJavaFieldAnnotations: false
IndentWidth: '4'
InsertBraces: true
...
EOF

# Convert from dos files to unix
sed 's/\r$//' -i ./*.java

# Add a modeline to the java files.
for src_file in *.java; do
  printf "\n%s\n" '// vim: tabstop=4 shiftwidth=4' >> "$src_file"
done

# Additionally, start a git repo
git init

cat <<EOF >.gitignore
.classpath
.project
.settings/*
.gradle/*
build/*
lib/*
out/*
bin/*
*.class
*.ctxt
EOF

git add .
git commit -m "Assignment code"
