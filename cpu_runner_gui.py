import tkinter as tk
from tkinter import filedialog, scrolledtext, messagebox
import subprocess
import os

class CPURunnerGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("RISC-V CPU Automation Tool")
        self.root.geometry("800x600")

        self.c_file_path = ""

        # Verilog files list
        self.verilog_files = [
            "pipeline_tb.v", "Pipeline_Top.v", "fetch_cycle.v", "decode_cycle.v", 
            "execute_cycle.v", "memory_cycle.v", "writeback_cycle.v", "PC_Module.v", 
            "PC_Adder.v", "Mux.v", "Mux_3_by_1.v", "Sign_Extend.v", "Register_File.v", 
            "Instruction_Memory.v", "Data_Memory.v", "ALU.v", "ALU_Decoder.v", 
            "Main_Decoder.v", "Control_Unit_Top.v", "hazard_unit.v"
        ]

        # --- UI Elements ---
        # Top Frame for File Selection
        top_frame = tk.Frame(root)
        top_frame.pack(pady=10, fill=tk.X, padx=10)

        self.lbl_file = tk.Label(top_frame, text="No C file selected", fg="red", font=("Arial", 10, "bold"))
        self.lbl_file.pack(side=tk.LEFT, padx=10)

        btn_browse = tk.Button(top_frame, text="Select C File", command=self.browse_file)
        btn_browse.pack(side=tk.LEFT)

        self.btn_run = tk.Button(top_frame, text="Compile & Run Simulation", command=self.run_toolchain, state=tk.DISABLED, bg="green", fg="white", font=("Arial", 10, "bold"))
        self.btn_run.pack(side=tk.RIGHT, padx=10)

        # Output Text Area
        self.txt_output = scrolledtext.ScrolledText(root, wrap=tk.WORD, font=("Consolas", 10), bg="black", fg="lightgreen")
        self.txt_output.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)

    def browse_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("C Source Files", "*.c")])
        if file_path:
            self.c_file_path = file_path
            filename = os.path.basename(file_path)
            self.lbl_file.config(text=f"Selected: {filename}", fg="blue")
            self.btn_run.config(state=tk.NORMAL)

    def log(self, message):
        self.txt_output.insert(tk.END, message + "\n")
        self.txt_output.see(tk.END)
        self.root.update()

    def run_command(self, cmd, step_name):
        self.log(f"--- Running: {step_name} ---")
        self.log(f"Command: {cmd}")
        
        try:
            # Run command and capture output
            result = subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            
            if result.stdout:
                self.log(result.stdout)
                
            if result.returncode != 0:
                self.log(f"!!! ERROR during {step_name} !!!\nProcess stopped.")
                return False
            return True
        except Exception as e:
            self.log(f"Exception executing command: {str(e)}")
            return False

    def run_toolchain(self):
        self.txt_output.delete('1.0', tk.END)
        self.btn_run.config(state=tk.DISABLED)
        
        # Get relative path for the selected C file
        c_file = os.path.basename(self.c_file_path)

        # 1. Compile crt0.s
        if not self.run_command("riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c crt0.s -o crt0.o", "Assemble crt0.s"):
            self.btn_run.config(state=tk.NORMAL)
            return

        # 2. Compile C Code to ELF
        cmd_gcc = f"riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -O1 -mno-save-restore -ffreestanding -nostdlib -T linker.ld crt0.o {c_file} -o program.elf"
        if not self.run_command(cmd_gcc, "Compile C to ELF"):
            self.btn_run.config(state=tk.NORMAL)
            return

        # 3. Convert ELF to BIN
        if not self.run_command("riscv64-unknown-elf-objcopy -O binary program.elf program.bin", "Convert ELF to BIN"):
            self.btn_run.config(state=tk.NORMAL)
            return

        # 4. Convert BIN to HEX
        if not self.run_command("python3 make_hex.py program.bin memfile.hex", "Generate HEX File"):
            self.btn_run.config(state=tk.NORMAL)
            return

        # 5. Compile Verilog with iverilog
        v_files_str = " ".join(self.verilog_files)
        if not self.run_command(f"iverilog -o riscv_core -s pipeline_tb {v_files_str}", "Compile Verilog (iverilog)"):
            self.btn_run.config(state=tk.NORMAL)
            return

        # 6. Run Simulation
        self.run_command("vvp riscv_core", "Run CPU Simulation (vvp)")
        
        self.log("\n*** AUTOMATION COMPLETE ***")
        self.btn_run.config(state=tk.NORMAL)

if __name__ == "__main__":
    root = tk.Tk()
    app = CPURunnerGUI(root)
    root.mainloop()