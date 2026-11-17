# Audit Trail Filtering Script

A high-performance custom PowerShell script designed to automate the parsing, filtering, and analysis of large audit trail CSV logs. Originally created for Laboratory System Administrators (LSAs) at MilliporeSigma, this tool filters raw system logs down to high-priority events, achieving a **90.8% reduction in files** requiring manual human review while maintaining full GxP compliance standards.

## 🚀 Key Performance Benchmarks
* **Data Volume Capacity:** Scalable across datasets of any size, tested successfully up to **6.24 GB**.
* **Filtering Power:** Delivers a **90.8% reduction in files** by automatically passing whitelisted automated bot actions and isolating off-hours or critical activities.
* **Review Speed:** Sustains an average analysis rate of **2,344 rows reviewed / second** through low-level performance engineering (`.NET` `StreamWriter` and custom parsing).

---

## 📂 Repository Structure
```text
├── audittrailscript.ps1          # Main PowerShell execution script
├── README.md                     # Project documentation and instructions
└── sample_data/                  # Synthetic input and output datasets
    ├── Q1_Input/                 # Sample raw subsystem audit logs
    └── Q1_Output/                # Generated filtered reports & summary logs
```

---

## 🛠️ Prerequisites & Materials
* **OS:** Windows 10/11 with PowerShell ISE (pre-installed).
* **Environment:** Access to PowerShell ISE or VS Code for script execution.
* **Input Data:** Sample audit log CSV exports categorized under subsystem folders.

---

## ⚙️ Step-by-Step Operating Instructions

### Step 1: Prepare Local Directories
1. Open **File Explorer** and navigate to your desired working directory (e.g., `C:\Users\YourUsername\Downloads\AuditTrailScript`).
2. Create two separate folders: one for your input files (`Q1_Input`) and one for your output files (`Q1_Output`).
   > ⚠️ **Important:** Do not place input and output files in the same folder to prevent double-reading errors or runtime crashes.

### Step 2: Configure File Paths in PowerShell ISE
1. Open **Windows PowerShell ISE**.
2. Open `audittrailscript.ps1` via `File > Open`.
3. Locate the configuration variables at the top of the script (lines 1–6):
   ```powershell
   $SourceDirectory = "C:\YourPath\Q1_Input"
   $OutputDirectory = "C:\YourPath\Q1_Output"
   $ActionItems     = @("Bulk.Delete", "Modify.Permissions", "Move.File")
   $WhitelistedUsers = @("scdm-autobot-one")
   $OffHoursStart   = 19
   $OffHoursEnd     = 6
   ```
4. Replace the `$SourceDirectory` and `$OutputDirectory` paths with your local folder paths, ensuring the text remains enclosed in quotation marks (`" "`).

### Step 3: Run the Script
1. Click the green **Play** (Run Script) button in the top PowerShell ISE toolbar (or press `F5`).
2. Monitor the real-time progress bar in the terminal window as it scans subsystem folders.

### Step 4: Review Output and Summary Logs
1. Upon successful execution, a summary text report (`Audit_Summary_Report_YYYYMMDD_HHMMSS.txt`) and filtered CSV files will be generated in your `$OutputDirectory`.
2. Inspect the terminal log or output text file to verify total lines scanned, lines exported, and execution runtime.

---

## 🔒 Engineering & Compliance Design Notes
* **Custom Parsing Strategy:** Bypasses standard, memory-heavy CSV loading methods to ensure stability when parsing irregular log formats.
* **StreamWriter Implementation:** Utilizes `.NET` `StreamWriter` output handling to keep memory usage minimal and handle massive datasets smoothly without disk I/O bottlenecks.

## 📚 References & Resources
* [Introduction to Windows PowerShell ISE](https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/introducing-the-windows-powershell-ise?view=powershell-7.6)
* [A Look at Filtering Performance in PowerShell](https://learn-powershell.net/2015/02/20/a-look-at-filtering-performance-in-powershell/)
* [File Parsing Techniques and Examples](https://www.docsumo.com/blog/file-parsing)