Here's the revised installation guide with your requested additions:

---

# PatientEntry Program Installation Guide

This guide will walk you through the process of creating a self-extracting executable (SFX .exe) file for the **PatientEntry** program installation using **WinRAR**. The executable will extract the necessary files, run a PowerShell script to install the software, and clean up temporary files afterward.

**Note:** 
- `cleanbackup.bat` is a script that deletes SQL backup files from the server to reduce size. It deletes a number of files based on the `cleanbackup.config` file located in the root `patiententry` folder.
- `PatientEntry-start.bat` is a process that runs `PatientEntry.exe`, but first executes `cleanbackup.bat` before starting the program.

---

## Prerequisites

- **WinRAR** installed on your system.

---

## Procedure

### 1. Prepare the PowerShell Script and Installation Files
   - Create a PowerShell script (e.g., `patient_entry_setup.ps1`) with all the necessary installation commands.
   - Ensure all required files and folders for the installation are placed in the same directory as the PowerShell script.

### 2. Convert Batch Files to Executables
   - Use "Bat_To_Exe_Converter" to convert `cleanbackup.bat` and `PatientEntry-start.bat` into `.exe` files.
   - Place the converted `.exe` files inside the root `patiententry` folder.

### 3. Create the Archive
   - Select all the files and folders, including the `.ps1` script and the newly created `.exe` files.
   - Right-click the selection and choose **"Add to archive..."**.

### 4. Configure the General Tab
   - In the **"General"** tab of the archive creation window, under **"Archiving options"**, check the **"Create SFX archive"** option.
   - In the **"Split to volumes, size"** field, set the size to **2 GB** to ensure the archive fits within limits for file transfer, if necessary.

### 5. Configure the Comment Tab
   - Go to the **"Comment"** tab and paste the following code (replace `patient_entry_setup.ps1` with the actual name of your PowerShell script):

   ```plaintext
   ;The comment below contains SFX script commands

   Path=%temp%
   Setup=cmd /c SetExecutionPolicy.exe
   Setup=powershell.exe -ExecutionPolicy Bypass -File patient_entry_setup.ps1
   ```

   - This configuration will ensure that the PowerShell script is executed once the files are extracted to the `%temp%` folder.

---

## Downloads

To make the process easier, you can download the pre-compiled `.exe` file or all the necessary installation files using the links below:

### Pre-compiled .exe File
<div align="left">
  <a href="https://drive.google.com/drive/folders/11uyVDkGI4VJK2E5ll6Sq2gj2m5xrMMrx?usp=sharing" style="text-decoration:none;">
    <img src="https://www.google.com/drive/static/images/drive/logo-drive.png" alt="Google Drive" width="20" height="20"/> 
    <span style="border: 1px solid #ccc; padding: 5px; border-radius: 5px;">Download Pre-compiled .exe File</span>
  </a>
</div>

### All Installation Files and Folders
<div align="left" style="margin-top: 10px;">
  <a href="https://drive.google.com/drive/folders/12X35Dg3Ya8JNwK0rmnlloJbCHW1Vy0xd?usp=sharing" style="text-decoration:none;">
    <img src="https://www.google.com/drive/static/images/drive/logo-drive.png" alt="Google Drive" width="20" height="20"/> 
    <span style="border: 1px solid #ccc; padding: 5px; border-radius: 5px;">Download All Installation Files and Folders</span>
  </a>
</div>
