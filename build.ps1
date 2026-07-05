# build.ps1
# Automates Java compilation and deployment to Tomcat wtpwebapps directory

$ErrorActionPreference = "Stop"

$projectRoot = "c:\Users\User\eclipse-workspace\ElderEarn"
$tomcatHome = "C:\Users\User\Downloads\apache-tomcat-10.1.55"
$tomcatBase = "C:\Users\User\eclipse-workspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0"
$deployDir = "$tomcatBase\wtpwebapps\ElderEarn"

# Paths to libs
$servletJar = "$tomcatHome\lib\servlet-api.jar"
$jspJar = "$tomcatHome\lib\jsp-api.jar"
$mysqlJar = "C:\Users\User\Downloads\mysql-connector-j-9.7.0\mysql-connector-j-9.7.0.jar"

Write-Output "--- Starting Build and Deploy for ElderEarn ---"

# 1. Compile Java files
Write-Output "Compiling Java files..."
$srcDir = "$projectRoot\src\main\java"
$classesDir = "$projectRoot\build\classes"

# Ensure output directory exists
if (-not (Test-Path $classesDir)) {
    New-Item -ItemType Directory -Path $classesDir | Out-Null
}

# Find all Java files
$javaFiles = Get-ChildItem -Path $srcDir -Filter *.java -Recurse | ForEach-Object { $_.FullName }

if ($javaFiles) {
    # Run javac
    $classpath = "$servletJar;$jspJar;$mysqlJar"
    $javacCmd = "javac --release 21 -d `"$classesDir`" -classpath `"$classpath`" " + ($javaFiles -join " ")
    Invoke-Expression $javacCmd
    Write-Output "Compilation completed successfully."
} else {
    Write-Output "No Java source files found to compile."
}

# 2. Deploy Web Content and Classes
Write-Output "Deploying files to Tomcat..."

# Ensure target directories exist
$targetClasses = "$deployDir\WEB-INF\classes"
$targetLib = "$deployDir\WEB-INF\lib"

if (-not (Test-Path $targetClasses)) { New-Item -ItemType Directory -Path $targetClasses | Out-Null }
if (-not (Test-Path $targetLib)) { New-Item -ItemType Directory -Path $targetLib | Out-Null }

# Copy webapp folder contents (excluding Java source files)
Copy-Item -Path "$projectRoot\src\main\webapp\*" -Destination $deployDir -Recurse -Force

# Copy compiled classes
if (Test-Path $classesDir) {
    Copy-Item -Path "$classesDir\*" -Destination $targetClasses -Recurse -Force
}

# Copy MySQL Connector jar to WEB-INF/lib
Copy-Item -Path $mysqlJar -Destination $targetLib -Force

Write-Output "Deployment completed successfully."
