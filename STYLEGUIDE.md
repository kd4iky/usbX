# Coding Style Guide

Consistency makes the code easier to read, maintain, and contribute to.  
Please follow these guidelines when contributing.

---

## General Principles
- Write clean, readable, and well-documented code.  
- Keep functions short and focused.  
- Prefer clarity over cleverness.  

---

## C Coding Conventions

- **Indentation**: 4 spaces, no tabs.  
- **Braces**: K&R style  
  ```c
  if (condition) {
      do_something();
  } else {
      do_something_else();
  }
  ```
- **Variable Names**:
  - Use `snake_case` for variables and functions.  
  - Use `UPPER_CASE` for macros and constants.  

- **Comments**:
  - Use `/* ... */` for multi-line explanations.  
  - Use `//` for short, inline notes.  

- **Header Guards**:
  ```c
  #ifndef MODULE_H
  #define MODULE_H

  // Code here

  #endif // MODULE_H
  ```

---

## Commit Messages

- Use present tense: "Add feature" not "Added feature".  
- Keep messages concise but descriptive.  
- Reference related issues or tickets (e.g., `Fixes #42`).  

---

## Testing

- Write unit tests for new functionality.  
- Ensure all tests pass before submitting a pull request.
