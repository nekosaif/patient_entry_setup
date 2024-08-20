# PatientEntry Program Installation Guide

This guide will walk you through creating a self-extracting executable (.exe) file for the installation of the PatientEntry program using WinRAR SFX. The executable will extract necessary files, run a PowerShell script to install the software, and clean up temporary files afterward.

## Prerequisites

- **WinRAR**

## Procedures

1. **Prepare the PowerShell Script and Files**
   - Write the `.ps1` script with all necessary installation commands.
   - Ensure all required installation files and folders are in place alongside the script.

2. **Create the Archive**
   - Select all files and folders, including the `.ps1` script.
   - Right-click and choose **"Add to archive..."**.

3. **General Tab Settings**
   - In the **"General"** tab, under the **"Archiving options"** section, check the **"Create SFX archive"** option.
   - In the **"Split to volumes, size"** field, set the size to **2 GB**.

4. **Comment Tab Settings**
   - Go to the **"Comment"** tab and paste the following code, replacing `patient_entry_setup.ps1` with the appropriate script name:

   ```plaintext
   ;The comment below contains SFX script commands

   Path=%temp%
   Setup=cmd /c SetExecutionPolicy.exe
   Setup=powershell.exe -ExecutionPolicy Bypass -File patient_entry_setup.ps1

## Downloads

<div align="left">
  <a href="https://drive.google.com/drive/folders/11uyVDkGI4VJK2E5ll6Sq2gj2m5xrMMrx?usp=sharing" style="text-decoration:none;">
    <img src="https://www.google.com/drive/static/images/drive/logo-drive.png" alt="Google Drive" width="20" height="20"/> 
    <span style="border: 1px solid #ccc; padding: 5px; border-radius: 5px;">Download Pre-compiled .exe File</span>
  </a>
</div>

<div align="left" style="margin-top: 10px;">
  <a href="https://drive.google.com/drive/folders/12X35Dg3Ya8JNwK0rmnlloJbCHW1Vy0xd?usp=sharing" style="text-decoration:none;">
    <img src="https://www.google.com/drive/static/images/drive/logo-drive.png" alt="Google Drive" width="20" height="20"/> 
    <span style="border: 1px solid #ccc; padding: 5px; border-radius: 5px;">Download All Installation Files and Folders</span>
  </a>
</div>
