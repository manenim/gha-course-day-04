# Day 4: Variables & Outputs

## **1. Concepts**

### **The Problem: The "Black Box" Step**
By default, Steps are isolated. If Step 1 runs a script that calculates a Version Number (e.g., `v1.2.3`), Step 2 has **no way** of knowing that value. It just sees the script finished successfully.

To enable the "Sharing Economy" of data, GitHub provides two mechanisms:

### **1. Environment Variables (`env`)**
*   **Static:** Defined in YAML. Available to all steps in the job (or workflow).
    ```yaml
    env:
      NODE_ENV: production
    ```
*   **Dynamic (`$GITHUB_ENV`):** You can write to a special file to set an env var for **subsequent steps**.
    ```bash
    echo "MY_VAR=hello" >> $GITHUB_ENV
    ```

### **2. Outputs (`$GITHUB_OUTPUT`)**
*   This is the modern, "Action-native" way to pass structured data.
*   **Writing:** formatting `key=value` to the special output file.
    ```bash
    echo "version=1.2.3" >> $GITHUB_OUTPUT
    ```
*   **Reading:** You must give the step an `id` to reference it later.
    ```yaml
    steps:
      - name: Calculate
        id: math
        run: echo "result=42" >> $GITHUB_OUTPUT

      - name: Use It
        run: echo "The result was ${{ steps.math.outputs.result }}"
    ```

---

## **2. Visuals: The Data Flow**

```
[ Step 1 (ID: calc) ]  
       | writes to
       v
[ $GITHUB_OUTPUT ] <---- Shared "Clipboard"
       | reads from
       v
[ Step 2 ] using ${{ steps.calc.outputs... }}
```

---

## **3. Code Examples**

**Example: The Dynamic Tag**
```yaml
steps:
  - name: Generate Date
    id: date
    run: echo "today=$(date +'%Y-%m-%d')" >> $GITHUB_OUTPUT

  - name: Build Docker Image
    run: docker build -t my-app:${{ steps.date.outputs.today }} .
```

---

## **4. References**
*   [Defining Outputs for Jobs](https://docs.github.com/en/actions/using-jobs/defining-outputs-for-jobs)
*   [Setting an output parameter](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter)

---

## **5. The Challenge: Platform Ticket PT-104**

**Context:** We have a bash script (`day-4/script.sh`) that generates a complex unique version number (e.g., `2024.1.13-build.123`). The Release Team needs this exact string to tag the release.

**Objective:** Capture the output of the script and use it in a later step.

**Requirements:**
1.  **Repo Setup:** Polyrepo (Day 4 is root).
2.  **File Location:** `.github/workflows/day-4.yaml`
3.  **Triggers:** `push` to `main`.
4.  **Job 1: `ci`**
    *   **Step 1:** Checkout.
    *   **Step 2:** Ensure the script is executable (`chmod +x script.sh`).
    *   **Step 3:** Run the script AND capture its output to `$GITHUB_OUTPUT`.
        *   *Hint:* The script prints to stdout. You need to assign that to the output file.
        *   *Hint 2:* `version=$(./script.sh)` might help, but how do you write that to `$GITHUB_OUTPUT`?
        *   *Critical:* Give this step an `id`.
    *   **Step 4:** Print the value: `"Building Release Version: <THE_VALUE>"`.

**Constraints:**
*   You MUST use `$GITHUB_OUTPUT`.
*   You MUST use `${{ steps... }}` context to read it.
