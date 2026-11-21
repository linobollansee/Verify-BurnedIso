# Optical Disc ISO SHA-256 Verifier

A lightweight PowerShell utility to calculate the exact SHA-256 checksum of a burned optical disc (CD/DVD/Blu-ray) directly from the raw drive device, avoiding trailing padding issues that typically alter standard disc hashes.

## Why Use This?
When an ISO image is burned to an optical disc, the drive often pads the end of the session with extra blank sectors. Running a standard file hash on the raw disc (`\\.\D:`) reads those extra sectors and produces a checksum that does not match the original ISO. 

This script solves that problem by reading **only the exact byte length** of the original ISO file.

## Prerequisites
* **OS:** Windows 10 / Windows 11
* **Shell:** Windows PowerShell 5.1 or PowerShell 7+
* **Permissions:** **Administrator privileges** are required to access raw device paths (`\\.\X:`).

## Usage

1. Insert the burned disc into your optical drive.
2. Open PowerShell **as Administrator**.
3. Navigate to the folder containing the script and run it:
   ```powershell
   .\Verify-DiscHash.ps1
   ```
4. When prompted, enter:
   * **Optical drive letter:** Just the letter (e.g., `D` or `D:`).
   * **Exact ISO size in bytes:** The exact byte count of the original ISO (e.g., `9047330816`). Commas or spaces will be automatically stripped.

### Example Output
```text
Enter your optical drive letter (e.g., D): D
Enter the exact ISO size in bytes (e.g., 6842105856): 9,047,330,816

Reading 9047330816 bytes from \\.\D:... Please wait.

Calculated SHA-256:
A1B2C3D4E5F6...
```

## How It Works
* Opens a raw `FileStream` directly to the optical device (`\\.\<DriveLetter>:`).
* Streams data in **1 MB chunks** (`1,048,576` bytes) into a `SHA256` cryptographic provider, keeping memory usage minimal even for dual-layer Blu-rays.
* Stops reading at the exact byte boundary specified, finalizes the hash, and safely disposes of the stream and handles.
