# Flow2C: DSL-to-Structured-C State Machine Transpiler

Flow2C is a source-to-source transpiler implemented in **C**, **Flex (Lex)**, and **Bison (Yacc)**. It parses flowchart-like control-flow specifications written in a custom Domain-Specific Language (DSL) and synthesizes deterministic, structured C code driven by a flat `switch-case` state-dispatch engine.

---

## Architecture Overview

1. **Lexical Analysis (`mylex.l`)**:
   - Matches DSL keywords (`SYSTEM`, `PROCESS`, `BLOCK`, `DECISION`, `GOTO`).
   - Uses Flex start conditions (`<IN_C_CODE>` and `<IN_IF_COND>`) to buffer raw C statements and expressions verbatim without parsing overhead.
2. **Grammar & Control-Flow Graph (`myyacc.y`, `header.h`)**:
   - Parses system and process definitions into an internal node buffer.
   - Represents basic blocks (`blockN`), two-way branch decisions (`decisionN`), and unconditional jumps (`uncondjN`).
   - Resolves label jumps dynamically via `linkGraph()` with implicit fallthrough resolution for sequential execution.
3. **Structured Code Synthesis (`main.c`)**:
   - Flattens the directed control graph into a single dispatch loop (`while (_state != -1)`) over a finite-state switch construct.

---

## Project Structure

```text
├── code/
│   ├── header.h        # Node structures and graph traversal declarations
│   ├── mylex.l         # Flex lexer specification
│   ├── myyacc.y        # Bison grammar rules and graph linkage
│   ├── main.c          # Symbol resolution and structured C generator
│   └── Makefile        # Build configuration
├── testcases/          # Sample DSL test cases (input01 - input05)
├── .gitignore
└── README.md
```

---

## Getting Started

### Prerequisites

- GCC
- Flex
- Bison (or Yacc)
- Make

Install dependencies on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install build-essential flex bison
```

### Build & Run

1. **Compile the transpiler:**
   ```bash
   cd code
   make
   ```

2. **Transpile a DSL file to C:**
   ```bash
   ./parser ../testcases/input01.txt > output.c
   ```

3. **Compile and execute the emitted C code:**
   ```bash
   gcc output.c -o run_output
   ./run_output
   ```
